
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
        public var ms:Deque<Dynamic>;
        var ams:Deque<Dynamic>;

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
            trace("ready publish "); 
            var p:Publish = new Publish();
            p.exchange = xdirect;
            p.routingkey = q;
            var b:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(p, b, data);
            var is = iss.get(q);
            if(is != null)
                is.dispatch(cmd);

            trace("publish with "+is);
        }


        public function run():Void {
            co.start();
            co.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            trace("create connection thread");
            ct = neko.vm.Thread.create(callback(co.onSocketData, mt));
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
            while(true) {
                trace("---------waiting for message------");
                var msg:Dynamic = ms.pop(true);
                trace("got message "+msg.properties);
                var body = msg.body;
                var t:Int = body.readByte();
                trace("message type: "+t);
                switch(t) {
                    case 10:
                        var len = body.readByte();
                        var iq = body.readString(len);
                        trace("!! in main got in queue : "+len+" "+iq);
                        var is = sm.create();
                        iss.set(iq, is);
                        var o = new Open();
                        var q = new Declare();
                        q.queue = iq;
                        is.rpc(new Command(o), dh);
                        is.rpc(new Command(q), onDeclareOkIQ);
                    default:
                }
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
            gis.rpc(new Command(q), onDeclareOkGatewayI);
        }

        public function onDeclareOkGatewayI(e:ProtocolEvent):Void {
            var c:Consume = new Consume();
            c.queue = giq;
            c.noack = true;
            gis.register(c, new Consumer(onDeliver, onConsumeOkGatewayI));
        }

        public function onConsumeOkGatewayI(tag:Queue):Void {
            gct = tag;
            mt.sendMessage("start");
        }

        public function onDeclareOkIQ(e:ProtocolEvent):Void {
            var dk = cast(e.command.method, DeclareOk);
            // create the outq for consumption
            var os = sm.create();
            var o = new Open();
            var d = new Declare();
            d.queue = appName + oqcount;
            trace("oq "+d.queue);
            oss.set(dk.queue, os);
            oqcount++;
            os.rpc(new Command(o), dh);
            os.rpc(new Command(d), getOnDeclareOkOQ(os, dk.queue, d.queue));
        }

        public function getOnDeclareOkOQ(os:SessionStateHandler, _iq:Queue, _oq:Queue) {
            trace("getOnDeclareOkQ ");
            var t = this;
            return function (e:ProtocolEvent):Void {
            trace("setup oq consumer "+_oq);
                var dk = cast(e.command.method, DeclareOk);
                var c:Consume = new Consume();
                c.queue = _oq;
                c.noack = true;
                os.register(c, new Consumer(t.onDeliverToApp, t.getOnConsumeOkOQ(_iq, _oq)));
                };
        }


        public function getOnConsumeOkOQ(_iq:Queue, _oq:Queue): Tag -> Void {
            trace("get consume ok oq");

            var t = this;
            return function(tag:Tag):Void { 
            // send message to app thread to publish to iq.
                    trace("sending oq:"+ _oq + " to "+ _iq);
                    if(Thread.current() == t.mt) {
                        trace("in main thread");
                    } else {
                        trace("in conn thread");
                    }

                    var m = new BytesOutput();
                    m.writeByte(11);
                    m.writeByte(_oq.length);
                    m.writeString(_oq);
                    t.publish(_iq, m.getBytes());
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
            // this is called by the socket thread
            ms.add({method: method, properties: properties, body:body});
        }

        public function onDeliverToApp(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            // this is called by the socket thread
            ams.add({method: method, properties: properties, body:body});
        }
    }
