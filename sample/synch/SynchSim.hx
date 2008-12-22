
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

    typedef Client = String
    typedef Tag = String
    typedef Queue = String
    typedef Delivery = { var method:Deliver; var properties:BasicProperties; var body:BytesInput; }
    typedef Latency = Int;
    typedef SSH = SessionStateHandler;

    typedef TAConnecting = { var pendingConnects:Int; var connects:Int; var beginTime:Float; }

    enum AppState{
        AInit;
        AConnecting(_:TAConnecting);
        ABeginSynch;
        ASynchronizing;
        AUpdating;
        AError;
        ADone;
    }

    typedef App = { var state:AppState; var name:String; var maxConnects:Int; }

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

        public static function main() {
            var s = new SynchSim();
            s.run();
        }

        public function new()
        {
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

            app = { state: AInit, name: "SynchSim-", maxConnects: 2 };

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
                updateApp();
            }
        }

        public function processGatewayMsg():Void {
            var msg:Delivery = ms.pop(false);
            if(msg == null) return;

            switch(msg.body.readByte()) {
                case 10: joinApp(msg.body);
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

        public function updateApp():Void {
            var msg:Delivery = ams.pop(false);
            if(msg == null) return;

            /*
            switch(app.state) {
                case AInit:
                    // still initializing
                case AConnecting:
                    // waiting for enough users to connect
                    if(stateVal().connects == app.maxConnects) { // is app ready to start?
                        app.state = ABeginSynch; // transition
                    } else {
                        waitForUsers();
                    }
                case ABeginSynch:
                    // send out messages to users to synch
                    app.state = ASynchronizing;
                    beginSynch();
                case ASynchronizing:
                    // measure clients (latency, etc..)
                    measureClients();
                case AUpdating:
                    // update the simulation
                    */
                    update(msg);
                    /*
                case AError:
                case ADone:
                default:
            }
            */
        }

        public function waitForUsers(){
            var elapsedTime = neko.Sys.time() - beginTime;
        }

        public function update(msg:Delivery):Void {
            var t:Int = msg.body.readByte();
            //trace("got app message "+t); 
            switch(t) {
                case 20:
                    var m = new BytesOutput();
                    m.bigEndian = true;
                    m.writeByte(21);
                    m.writeDouble(neko.Sys.time());
                    //trace("pong @ "+msg.properties.replyto);
                    publish(msg.properties.replyto, m.getBytes());
                default:
            }
        }

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
            app.state = AConnecting({pendingConnects:0, connects:0, beginTime:neko.Sys.time()});
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
            cRpc(os, d, getOqConsumer(os, dk.queue, d.queue));
        }

        public function getOqConsumer(os:SSH, iq:Queue, oq:Queue) {
            //trace("getOnDeclareOkQ ");
            var t = this;
            return function (e:ProtocolEvent):Void {
                // oq declared, now consume it
                var c:Consume = new Consume();
                c.queue = oq;
                c.noack = true;
                t.cRegister(os, c, t.onDeliverToApp, t.getOqSender(iq, oq));
                };
        }


        public function getOqSender(iq:Queue, oq:Queue): Tag -> Void {
            var t = this;
            return function(tag:Tag):Void { 
                    trace("sending oq:"+ oq + " to "+ iq);

                    var m = new BytesOutput();
                    m.bigEndian = true;
                    m.writeByte(11);
                    m.writeByte(oq.length);
                    m.writeString(oq);
                    t.publish(iq, m.getBytes());

                    t.stateVal().connects = t.stateVal().pendingConnects;
                    trace("connects "+t.stateVal().connects);
                    //userCount = pendingUserCount;
                };
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
            var d:Delivery = {method: method, properties: properties, body:body};
            ms.add(d);
        }

        public function onDeliverToApp(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            var d:Delivery = {method: method, properties: properties, body:body};
            ams.add(d);
        }
    }
