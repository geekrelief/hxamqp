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

    import flash.Vector;

	class Timings implements BasicConsumer, implements LifecycleEventHandler {

        public var ax:String ;
        public var q:String ;
        public var q2:String ;
        public var routing_key:String;
        public var connection:Connection;
        public var sessionManager:SessionManager;
        public var sessionHandler:SessionStateHandler;
        public var sessionHandler2:SessionStateHandler;
 
        var consumerTag:String;

        var beginTime:Int;
        var startTime:Int;
        var endTime:Int;
        var tpool:Vector<Vector<Float>>;
        var timings:Vector<Float>;
        var trun:Int;

        static function main() {
    		var a = new Timings();
			a.run();
		}

        public function new()
        {
            trun = 0;
            ax = "";
			q = "q";
			q2 = "q2";
            routing_key = q;

            connection = new Connection(buildConnectionParams());
            sessionManager = connection.sessionManager;

            tpool = new Vector();
            for(i in 0...10) {
                tpool[i] = new Vector();
            }

            timings = tpool[trun];
        }

        public function buildConnectionParams():ConnectionParameters {
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            params.serverhost = "10.0.0.17";
            return params;
        }

        public function publish(data:ByteArray):Void {
            var publish:Publish = new Publish();
            publish.exchange = ax;
            publish.routingkey = routing_key;
            var props:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(publish, props, data);
            sessionHandler.dispatch(cmd);
        }

        public function run():Void {
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
        }

        public function afterOpen():Void {
            openChannel(setupConsumer);
        }

        public function openChannel(_callback:Dynamic):Void {
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
            };

            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            sessionHandler.rpc(new Command(open), whoCares);
            sessionHandler.rpc(new Command(queue), whoCares);

            sessionHandler2 = sessionManager.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            sessionHandler2.rpc(new Command(open), whoCares);
            sessionHandler2.rpc(new Command(queue), _callback);
        }

        public function setupConsumer(event:ProtocolEvent):Void {
            var consume:Consume = new Consume();
            consume.queue = q2;
            consume.noack = true;
            sessionHandler2.register(consume, this);
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onConsumeOk(tag:String):Void {
            try{
            consumerTag = tag;
            trace("onConsumeOk");
            beginTime = startTime = Lib.getTimer();
            publish(new ByteArray());
            } catch (err:Dynamic) { trace(err); }
        }

        public function onCancelOk(tag:String):Void {
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
            try{
            endTime = Lib.getTimer();
            timings.push(endTime - startTime);
            if(trun < 10) {
                if(endTime < 10000+beginTime) {
                    startTime = Lib.getTimer();
                    publish(new ByteArray());
                } else {
                    var sum:Float = 0;
                    for(t in timings) {
                        sum += t;
                    }
                    trace("run: "+trun+" samples: "+timings.length+" avg roundtrip (ms): "+(sum / timings.length)+" sample time (secs): "+((endTime-beginTime)/1000.0));
                    ++trun;
                    if(trun < 10) {
                        timings = tpool[trun];
                        beginTime = startTime = Lib.getTimer();
                        publish(new ByteArray());
                    }
                }
            }
            } catch (err:Dynamic) { trace(err); }
        }
    }
