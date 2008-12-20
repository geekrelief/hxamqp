
    import haxe.io.Bytes;

    import org.amqp.Connection;
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

    enum Sams {
        JoinRequest(iq:Queue);
    }

    class SynchSim implements LifecycleEventHandler {

        var co:Connection;
        var sm:SessionManager;

        var xdirect:String;
        var xtopic:String;
        var giq:Queue;
        var gis:SessionStateHandler;

        public var iss:Hash<SessionStateHandler>;
        public var oss:Hash<SessionStateHandler>;

        var gct:Tag; 
        public var ct:Thread;
        public var mt:Thread;
        public var at:Thread;

        var ms:Deque<Delivery>;
        var ams:Deque<Delivery>;

        var appName:String;
        var oqcount:Int;

        var con:Consumer;

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


            appName = "SynchSim-";
            oqcount = 0;

            con = new Consumer();
        }

        public function buildConnectionParams():ConnectionParameters {
            var p:ConnectionParameters = new ConnectionParameters();
            p.username = "guest";
            p.password = "guest";
            p.vhostpath = "/";
            p.serverhost = "127.0.0.1";

            return p;
        }

        public function publish(q:Queue, data:Bytes):Void {
            var p:Publish = new Publish();
            p.exchange = xdirect;
            p.routingkey = q;
            var b:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(p, b, data);
          
            var is = iss.get(q);
            if(is != null) {
                is.dispatch(cmd);
                //trace("published to "+q);
            }
        }


        public function run():Void {
            co.start();
            co.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            trace("create connection thread");
            ct = neko.vm.Thread.create(callback(co.onSocketData, mt));
        //    at = neko.vm.Thread.create(runApp);
            Thread.readMessage(true); // wait for a start message after onConsume
            runLoop();

            trace("sending close message");
            ct.sendMessage("close");
            trace("block till closeOk done");
            Thread.readMessage(true);
            trace("run done");
       }

        public function runLoop():Void {
            // implement this
            trace("process in main thread");
            var m:Delivery;
            var am:Delivery;
            while(true) {
                m = ms.pop(false);
                processMsg(m);
                am = ams.pop(false);
                updateLoop(am);
            }

        }

        public function processMsg(msg:Delivery):Void {
            if(msg == null) {
                return;
            }              

            var body = msg.body;
            var t:Int = body.readByte();
            //trace("got message "+t); 
            switch(t) {
                case 10:
                    joinApp(body);
                default:
            }
        }
/*
        public function runApp():Void {
            var am:Delivery;
            while(true) {
                am = ams.pop(false);
                updateLoop(am);
            }
        }
        */

        public function joinApp(body:BytesInput):Void {
            var len = body.readByte();
            var iq = body.readString(len);
            var alen = body.readByte();
            var appName = body.readString(alen);

            trace("client "+iq+" join request for "+appName);
            var is = sm.create();
            iss.set(iq, is);
            var o = new Open();
            var q = new Declare();
            q.queue = iq;
            is.rpc(new Command(o), dh);
            is.rpc(new Command(q), createOq);
        }

        public function updateLoop(msg:Delivery):Void {
            if(msg == null) {
                return;
            }              

            var body = msg.body;
            var t:Int = body.readByte();
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

        public function afterOpen():Void {
            openChannel();
        }

        function dh(e:ProtocolEvent):Void {
            //trace(e);
        }

        function openChannel():Void {

            gis = sm.create();
            var o = new Open();
            var q = new Declare();
            q.queue = giq;
            gis.rpc(new Command(o), dh);
            gis.rpc(new Command(q), consumeGateway);
        }

        public function consumeGateway(e:ProtocolEvent):Void {
            var c:Consume = new Consume();
            c.queue = giq;
            c.noack = true;
            gis.register(c, new Consumer(onDeliver, startMain));
        }

        public function startMain(tag:Queue):Void {
            gct = tag;
            mt.sendMessage("start");
        }

        public function createOq(e:ProtocolEvent):Void {
            var dk = cast(e.command.method, DeclareOk);

            // create the outq for consumption
            var os = sm.create();
            var o = new Open();
            var d = new Declare();
            d.queue = appName + oqcount;
            
            oss.set(dk.queue, os);
            oqcount++;
            os.rpc(new Command(o), dh);
            os.rpc(new Command(d), getOqConsumer(os, dk.queue, d.queue));
        }

        public function getOqConsumer(os:SessionStateHandler, iq:Queue, oq:Queue) {
            //trace("getOnDeclareOkQ ");
            var t = this;
            return function (e:ProtocolEvent):Void {
            //trace("setup oq consumer "+oq);
                var dk = cast(e.command.method, DeclareOk);
                var c:Consume = new Consume();
                c.queue = oq;
                c.noack = true;
                os.register(c, new Consumer(t.onDeliverToApp, t.getOqSender(iq, oq)));
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
