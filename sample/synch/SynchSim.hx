
    import haxe.io.Bytes;

    import org.amqp.Connection;
    import org.amqp.SMessage;
    import org.amqp.Method;
    import org.amqp.ConnectionParameters;
    import org.amqp.SessionManager;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.util.Properties;

    import neko.vm.Thread;
    import neko.vm.Deque;
    import haxe.io.BytesInput;
    import haxe.io.BytesOutput;

    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Declare;
    import org.amqp.methods.queue.DeclareOk;

    import AppState;
    import MessageCode;
    import Type;

    typedef Client = String
    typedef Tag = String
    typedef Queue = String
    typedef Delivery = { var method:Deliver; var properties:BasicProperties; var body:BytesInput; }
    typedef Latency = Int;
    typedef SSH = SessionStateHandler;

/*
    typedef TAConnecting = { var pendingConnects:Int; var connects:Int; var beginTime:Float; }

    enum AppState{
        AInit;
        AConnecting(?_:TAConnecting);
        ABeginSynch;
        ASynchronizing;
        AUpdating;
        AError;
        ADone;
    }
    */

    typedef App = { var state:AppState; var name:String; var maxConnects:Int; var update:Delivery -> Void; }

    class SynchSim implements LifecycleEventHandler {

        var co:Connection;
        var sm:SessionManager;

        var xdirect:String;
        var xtopic:String;
        var giq:Queue;
        var gis:SSH;

        public var iss:Hash<SSH>;
        public var oss:Hash<SSH>;

        var gct:Tag; 
        public var ct:Thread;
        public var mt:Thread;

        var ms:Deque<Delivery>;
        var ams:Deque<Delivery>;

        var oqcount:Int;

        var app:App;

        var beginTime:Float;
        var pingDuration:Float;
        var step:Float; // based on max avg. latency reported
        var lats:Array<Hash<Latency>>;

        public static function main() { (new SynchSim()).run(); }

        public function new() {
            xdirect = "";
            xtopic = "topic";
			giq = "gateway";

            co = new Connection(buildConnectionParams());
            sm = co.sessionManager;

            iss = new Hash();
            oss = new Hash();

            ms = new Deque();
            ams = new Deque();

            oqcount = 0;

            app = { state: AInit, name: "SynchSim", maxConnects: 2, update: doNothing };

            beginTime = neko.Sys.time();
        }

        public function buildConnectionParams():ConnectionParameters {
            var p:ConnectionParameters = new ConnectionParameters();
            p.username = "guest";
            p.password = "guest";
            p.vhostpath = "/";
            p.serverhost = "127.0.0.1";

            return p;
        }

        public function cDispatch(s:SSH, p:Publish, b:BasicProperties, d:Bytes) { ct.sendMessage(SDispatch(s, new Command(p, b, d))); } 
        public function cRpc(s:SSH, m:Method, cb:Dynamic) { ct.sendMessage(SRpc(s, new Command(m), cb)); }
        public function cRegister(s:SSH, c:Consume, ?fdeliver:Dynamic, ?fconsume: Dynamic, ?fcancel:Dynamic) { ct.sendMessage(SRegister(s, c, new Consumer(fdeliver, fconsume, fcancel))); }

        public function publish(q:Queue, data:Bytes):Void {
            var p:Publish = new Publish();
            p.exchange = xdirect;
            p.routingkey = q;
            var is = iss.get(q);
            if(is != null) {
                cDispatch(is, p, Properties.getBasicProperties(), data);
            }
        }

        public function run():Void {
            co.start();
            co.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            trace("create connection thread");
            ct = neko.vm.Thread.create(callback(co.socketLoop, mt));
            Thread.readMessage(true); // wait for a start message after onConsume
            runLoop();

            trace("sending close message");
            ct.sendMessage(SClose);
            trace("block till closeOk done");
            Thread.readMessage(true);
            trace("run done");
        }

        public function runLoop():Void {
            // implement this
            trace("process in main thread");
            while(true) {
                processGatewayMsg();
                processApp();
            }
        }

        public function processGatewayMsg():Void {
            var msg:Delivery = ms.pop(false);
            if(msg == null) return;
            var t = toEnum(msg.body.readByte());
            trace("processing "+t);
            switch(t) {
                case ClientJoin: joinApp(msg.body);
                default:
            }
        }

        public function stateVal():Dynamic {
            return Type.enumParameters(app.state)[0];
        }

        public function joinApp(body:BytesInput):Void {
            if (stateVal().pendingConnects >= app.maxConnects) return;
            else stateVal().pendingConnects++;

            var iq = body.readString(body.readByte());
            var appName = body.readString(body.readByte());

            trace("client "+iq+" join request for "+appName);

            var is = sm.create();
            iss.set(iq, is);
            var o = new Open();
            var q = new Declare();
            q.queue = iq;
            cRpc(is, o, dh);
            cRpc(is, q, createOq);
        }

        public function processApp():Void { app.update(ams.pop(false)); }

        public function setAppUpdate(fun):Void {
            
        }

        public function transitionApp(as:AppState) {
//        trace("transition from "+app.state+ " to "+as);
            switch(as) {
                //case AInit: can't go back to init
                case AConnecting(_):
                    if(stateVal() == null) {
                        app.state = AConnecting({pendingConnects:0, connects:0, beginTime:neko.Sys.time()});
                        app.update = waitForClients;
                    }
                    sendAppState();
                    // app ready?
                    if(stateVal().connects == app.maxConnects) transitionApp(ASynchronize);
                case ASynchronize:
                    app.update = synchClients;
                case AUpdating:
                    app.update = updateApp;
                case AError:
                    app.update = doNothing;
                case ADone:
                    app.update = doNothing;
                default:
            }
        }

        public function doNothing(msg:Delivery):Void { }

        public function mdx(m:MessageCode):Int {
            return Type.enumIndex(m);
        }

        public function toEnum(dx:Int):MessageCode { return Reflect.field(MessageCode, Type.getEnumConstructs(MessageCode)[dx]); }

        public function sendAppState() {
            var stateStr = haxe.Serializer.run(app.state);
            trace("send app state "+stateStr.length + " "+stateStr);
            var b = new BytesOutput();
            b.bigEndian = true;
            b.writeByte(mdx(ServerAppState)); // app state
            b.writeInt31(stateStr.length);
            b.writeString(stateStr);
            var by = b.getBytes();

            for(iq in iss.keys()) {
                publish(iq, by);
            }
        }

        public function waitForClients(msg:Delivery):Void {
            if(neko.Sys.time() - stateVal().beginTime > 10) {
                trace(" send wait for clients ");
                stateVal().beginTime = neko.Sys.time();
                sendAppState();
            }

            if(msg != null) {
                var t = toEnum(msg.body.readByte());
                trace("got app message "+t); 
                switch(t) {
                    case ClientReceivedOq:
                        stateVal().connects++;
                        transitionApp(app.state);
                    case ClientPing:
                        var m = new BytesOutput();
                        m.bigEndian = true;
                        m.writeByte(mdx(ServerPong));
                        m.writeDouble(neko.Sys.time());
                        //trace("pong @ "+msg.properties.replyto);
                        publish(msg.properties.replyto, m.getBytes());
                    default:
                }
            }
        }

        public function synchClients(msg:Delivery):Void { }

        public function updateApp(msg:Delivery):Void { }

        public function afterOpen():Void { openGateway(); }

        function dh(e:ProtocolEvent):Void { /*trace(e);*/ }

        function openGateway():Void {
            gis = sm.create();
            var d = new Declare();
            d.queue = giq;
            cRpc(gis, new Open(), dh);
            cRpc(gis, d, consumeGateway);
        }

        public function consumeGateway(e:ProtocolEvent):Void {
            var c:Consume = new Consume();
            c.queue = giq;
            c.noack = true;
            cRegister(gis, c, onDeliver, startMain);
        }

        public function startMain(tag:Queue):Void {
            gct = tag;
            transitionApp(AConnecting());
            mt.sendMessage("start");
        }

        public function createOq(e:ProtocolEvent):Void {
            var dk = cast(e.command.method, DeclareOk);

            // create the outq for consumption
            var os = sm.create();
            var d = new Declare();
            d.queue = app.name + oqcount; // client out
            oqcount++;
            
            oss.set(dk.queue, os); // hash on iq to get oq
            cRpc(os, new Open(), dh);
            cRpc(os, d, callback(oqConsumer, os, dk.queue, d.queue));
        }

        public function oqConsumer(os:SSH, iq:Queue, oq:Queue, e:ProtocolEvent):Void {
            var c:Consume = new Consume();
            c.queue = oq;
            c.noack = true;
            cRegister(os, c, onDeliverToApp, callback(oqSender, iq, oq));
        }

        public function oqSender(iq:Queue, oq:Queue, tag:Tag):Void {
            trace("sending oq:"+ oq + " to "+ iq);

            var m = new BytesOutput();
            m.bigEndian = true;
            m.writeByte(mdx(ServerSendOq));
            m.writeByte(oq.length);
            m.writeString(oq);
            publish(iq, m.getBytes());
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }


        public function onCancelOk(tag:String):Void {
            //log("onCancelOk: " + tag);
        }

        public function onDeliver(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            ms.add({method: method, properties: properties, body:body});
        }

        public function onDeliverToApp(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            //var d:Delivery = {method: method, properties: properties, body:body};
            ams.add({method: method, properties: properties, body:body});
        }
    }
