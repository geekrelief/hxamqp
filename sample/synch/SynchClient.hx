	import flash.display.Sprite;
	import flash.text.TextField;

	import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.Lib;

	import flash.events.EventDispatcher;

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
        var ssTime:Int;     // start
        var sTime:Int;      // current

        // used for pings
        var startTime:Int;
        var endTime:Int;
        var timings:Vector<Float>;

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
            params.serverhost = "127.0.0.1";
            return params;
        }

        public function publishGateway(data:ByteArray):Void {
            var p:Publish = new Publish();
            p.exchange = xd;
            p.routingkey = giq;
            var b:BasicProperties = Properties.getBasicProperties();
            var c:Command = new Command(p, b, data);
            gis.dispatch(c);
        }


        public function publish(data:ByteArray):Void {
            var p:Publish = new Publish();
            p.exchange = xd;
            p.routingkey = oq;
            var b:BasicProperties = Properties.getBasicProperties();
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
            trace(e);
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

        public function onIDeliver(method:Deliver, properties:BasicProperties, m:ByteArray):Void {
            var t = m.readUnsignedByte();
            trace("message type: "+t);
            switch(t) {
                case 11: // out q in message
                    var len = m.readUnsignedByte();
                    oq = m.readUTF();
                    trace("got oq: "+oq);
                    os = sm.create();
                    var o = new Open();
                    var d = new Declare();
                    os.rpc(new Command(o), dh);
                    os.rpc(new Command(d), function(e:ProtocolEvent):Void{ trace("app can write to out q now");});
                default:
            }
        }

        public function onIConsumeOk(ct:String) {
            trace("consumer tag "+ct);
            connectGateway();
        }
         
        public function connectGateway():Void {
            trace("connect to gateway, in");
            gis = sm.create();
            var o = new Open();
            var d = new Declare();
            d.queue = giq;
            gis.rpc(new Command(o), dh);
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
            trace("connected to gateway in q");
            
            var m = new ByteArray();
            m.writeByte(10);  // get out q
            m.writeByte(iq.length);
            m.writeUTF(iq);
            trace("sending iq, expecting oq");
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


        /*
        public function openChannel(_callback:Dynamic):Void {
            var onOpen = function(event:ProtocolEvent):Void {
                trace("gateway open");
                te(event);
            }

            // create reply queue

             // create sesson gateway
            sessiong = sm.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = gq;
            sessionHandler.rpc(new Command(open), onOpen);
            sessionHandler.rpc(new Command(queue), onQDeclare);


            sessionHandler2 = sm.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            sessionHandler2.rpc(new Command(open), onOpen2);
            sessionHandler2.rpc(new Command(queue), _callback);
        }
        */

        /*
        public function setupConsumer(event:ProtocolEvent):Void {
            var consume:Consume = new Consume();
            consume.queue = q2;
            consume.noack = true;
            sessionHandler2.register(consume, this);
        }
        */
//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        /*
        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            trace("onConsumeOk");
            beginTime = startTime = Lib.getTimer();
            publish(new ByteArray());
            
            //trace("measure cost of publish"); // empty publish is very cheap 585 - 900 ms for 10000 publishes
            //beginTime = startTime = Lib.getTimer();
            //var samples = 10000;
            //for(i in 0...samples) {
            //    publish(new ByteArray());
            //}
            //endTime = Lib.getTimer();
            //var length = endTime-beginTime;
            //trace(" total time: "+length+" avg time (ms): "+(length / samples));
            
        }

        public function onCancelOk(tag:String):Void {
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
           
            endTime = Lib.getTimer();
            timings.push(endTime - startTime);
            if(trun < maxRuns) {
                if(endTime < 5000+beginTime) {
                    startTime = Lib.getTimer();
                    publish(new ByteArray());
                } else {
                    var sum:Float = 0;
                    for(t in timings) {
                        sum += t;
                    }
                    trace("run: "+trun+" samples: "+timings.length+" avg roundtrip (ms): "+(sum / timings.length)+" sample time (secs): "+((endTime-beginTime)/1000.0));
                    ++trun;
                    if(trun < maxRuns) {
                        timings = tpool[trun];
                        beginTime = startTime = Lib.getTimer();
                        publish(new ByteArray());
                    }
                }
            }
          
            //trace(++dcount);
        }
        */
    }
