	import flash.display.Sprite;
	import flash.text.TextField;

	import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.Lib;

	import flash.events.EventDispatcher;
    import flash.events.TimerEvent;

    import org.amqp.Command;
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.ProtocolEvent;
    import org.amqp.Session;
    import org.amqp.SessionManager;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.methods.channel.Open;
    import org.amqp.util.Properties;


    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Declare;
    import org.amqp.methods.queue.DeclareOk;

    import flash.Vector;

    import AppState;
    import MessageCode;

	class SynchClient implements LifecycleEventHandler {

        public var xd:String;  // direct exchange
        public var xt:String;  // topic exchange
        public var giq:String; // gateway in queue
        public var goq:String; // gateway out queue
        public var iq:String;  // app in queue
        public var oq:String;  // app out queue
        public var co:Connection;
        public var sm:SessionManager;
        public var gis:SessionStateHandler;
        public var gos:SessionStateHandler;
        public var is:SessionStateHandler;
        public var os:SessionStateHandler;

        var consumerTag:String;

        // use for sim events
        var serverTime:Float;

        // used for pings
        var pinger:Timer;
        var startTime:Int;
        var endTime:Int;
        var timings:Vector<Float>;

        public static var appName:String = "SynchSim";

        static function main() {
            flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
    		var a = new SynchClient();
			a.run();
		}

        public function new()
        {
            xd = "";
            xt = "topic";
            giq = "gateway";

            co = new Connection(buildConnectionParams());
            sm = co.sessionManager;

            timings = new Vector();
        }

        public function buildConnectionParams():ConnectionParameters {
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            //params.serverhost = "72.14.181.42";
            params.serverhost = "127.0.0.1";

            trace("connecting to "+params.serverhost);

            return params;
        }

        public function publishGateway(data:ByteArray):Void {
            var p:Publish = new Publish();
            p.exchange = xd;
            p.routingkey = giq;
            var b:BasicProperties = Properties.getBasicProperties();
            b.replyto = iq;
            var c:Command = new Command(p, b, data);
            gis.dispatch(c);
        }

        public function publish(data:ByteArray):Void {
            //trace("publishing to "+oq);
            var p:Publish = new Publish();
            p.exchange = xd;
            p.routingkey = oq;
            var b:BasicProperties = Properties.getBasicProperties();
            b.replyto = iq;
            var c:Command = new Command(p, b, data);
            os.dispatch(c);
        }

        public function run():Void {
            co.start();
            co.baseSession.registerLifecycleHandler(this);
        }

        public function afterOpen():Void {
            openICh();
        }

        public function dh(e:ProtocolEvent):Void {
            //trace(e);
        }

        public function openICh():Void {
            trace("open in channel");
            is = sm.create();
            var o = new Open();
            var q = new Declare();
            q.queue = "";
            q.autodelete = true;
            is.rpc(new Command(o), dh);
            is.rpc(new Command(q), setupIC);
        }

        public function setupIC(e:ProtocolEvent):Void {
            var method:DeclareOk = cast(e.command.method, DeclareOk);
            iq = method.queue;

            trace("consume from in queue: "+iq);

            var consume:Consume = new Consume();
            consume.queue = iq;
            consume.noack = true;
            is.register(consume, new Consumer(onIDeliver, onIConsumeOk));
        }

        inline public function mdx(m:MessageCode) {
            return Type.enumIndex(m);
        }

        public function onIDeliver(method:Deliver, properties:BasicProperties, m:ByteArray):Void {
            //trace("onIDeliver");
            var t:MessageCode = Type.enumFromIndex(MessageCode, m.readUnsignedByte());
            trace("message type: "+t);
           
            switch(t) {
                case ServerSendOq: // out q in message
                    oq = m.readUTFBytes(m.readUnsignedByte());
                    trace("got oq: "+oq);
                    os = sm.create();
                    var d = new Declare();
                    d.queue = oq;
                    os.rpc(new Command(new Open()), dh);
                    os.rpc(new Command(d), onOQOk);

                case ServerPong:
                    pong(m);

                case ServerAppState:
                    var state:AppState = haxe.Unserializer.run(m.readUTFBytes(m.readInt()));
                    trace("got app state "+state);
                    switch (state) {
                        case AConnecting(s):
                            trace( s.connects+ " users connected ");
                        case ASynchronize:
                            trace("synchronizing");
                        default:
                    }
                default:
            }
        }

        public function onIConsumeOk(ct:String) {
            //trace("consumer tag "+ct);
            connectGateway();
        }
         
        public function connectGateway():Void {
            //trace("connect to gateway, in");
            gis = sm.create();
            var d = new Declare();
            d.queue = giq;
            gis.rpc(new Command(new Open()), dh);
            gis.rpc(new Command(d), onGatewayWriteOk);
        }

/*
        public function onGatewayDeclareReadOk(e:ProtocolEvent):Void {
            var c = new Consume();
            c.queue = giq;
            c.noack = true;

            grs.register(c, new Consumer(onReadDeliver, onGatewayReadOk));
        }

        public function onGatewayReadOk(tag:String) {
            trace("consumeOk for gateway read, tag: "+tag);
        }
*/
        public function onGatewayWriteOk(e:ProtocolEvent):Void {
            //trace("connected to gateway in q");
            
            var m = new ByteArray();
            trace("sending iq, expecting oq "+mdx(ClientJoin));
            m.writeByte(mdx(ClientJoin));  // get out q
            m.writeByte(iq.length);
            m.writeUTFBytes(iq);
            m.writeByte(appName.length);
            m.writeUTFBytes(appName);
            publishGateway(m);

            /*
            grs = sm.create();
            var o = new Open();
            var d = new Declare();
            d.queue = grq;
            grs.rpc(new Command(o), dh);
            grs.rpc(new Command(d), onGatewayDeclareReadOk);
            */
        }


//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onOQOk(e:ProtocolEvent):Void{ 
            var d = cast(e.command.method, DeclareOk);
            trace("app can write to out q "+d.queue+" == "+oq);
            var m = new ByteArray();
            m.writeByte(mdx(ClientReceivedOq));
            publish(m);
            //setupPinger();
        }

        public function setupPinger():Void{
            //trace("setupPinger");
            pinger = new Timer(200);
            pinger.addEventListener(TimerEvent.TIMER, ping);
            pinger.start();
        }

        public function ping(e:TimerEvent):Void {
            var m:ByteArray = new ByteArray();
            m.writeByte(mdx(ClientPing));
            //trace(iq+"pinging server ");
            startTime = Lib.getTimer();
            publish(m);
        }

        public function pong(m:ByteArray):Void {
            serverTime = m.readDouble(); 
            endTime = Lib.getTimer();
            trace(iq+" pong time:("+serverTime+") trip time "+(endTime - startTime));
        }
    }
