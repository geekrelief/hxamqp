
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

    class GS
        implements BasicConsumer, 
        implements LifecycleEventHandler {

        var ax:String ;
        var q:String ;
        var q2:String ;
        var routing_key:String;
        var connection:Connection;
        var sessionManager:SessionManager;
        var sessionHandler:SessionStateHandler;
        var sessionHandler2:SessionStateHandler;

        var consumerTag:String;
        var ct:Thread;
        var mt:Thread;
        var messages:Deque<BytesInput>;

        public static function main() {
            var g = new GS();
            g.run();
        }

        public function new()
        {
            ax = "";
			q = "q";
			q2 = "q2";
            routing_key = q2; // for publish

            connection = new Connection(buildConnectionParams());
            sessionManager = connection.sessionManager;

            messages = new Deque();
        }

        public function buildConnectionParams():ConnectionParameters {

            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            params.serverhost = "10.0.0.17";

            return params;
        }

        public function publish(data:Bytes):Void {
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
            mt =  Thread.current();
            trace("create connection thread");
            ct = neko.vm.Thread.create(callback(connection.onSocketData, mt));
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
            var count = 0;
            var degrees = 0;
            var dir = 1;
            var factor = 3.14159/180;
            var x:Float = 0;
            var y:Float = 0;
            var px:Float;
            var py:Float;
            var msg:BytesInput;

            while(true) {
                neko.Sys.sleep(0.01);
                trace("processing main thread "+count);
                px = x;
                py = y;
                while((msg = messages.pop(false)) != null){
                    x = msg.readFloat();
                    y = msg.readFloat();
                    trace("@"+count+" got -> x: "+x+", y: "+y);
                    if(x > px) {
                        dir = 1;
                    } else {
                        dir = -1;
                    }
                }
                count++;
                degrees += dir;
                var b = new BytesOutput();
                b.bigEndian = true;
                b.writeFloat(Math.cos(degrees*factor) * 200 + 400);
                b.writeFloat(Math.sin(degrees*factor) * 100 + 400);
                publish(b.getBytes());
            }
        }

        public function afterOpen():Void {
            openChannel(setupConsumer);
        }

        function openChannel(_callback:Dynamic):Void {
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
                trace(event);
            };

            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            sessionHandler.rpc(new Command(open), whoCares);
            sessionHandler.rpc(new Command(queue), whoCares);

            sessionHandler2 = sessionManager.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            sessionHandler2.rpc(new Command(open), whoCares);
            sessionHandler2.rpc(new Command(queue), _callback);
        }

        public function setupConsumer(event:ProtocolEvent):Void {
			trace("setupConsumer");
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;
            sessionHandler2.register(consume, this);
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            trace("onConsumeOk: " + tag);
            mt.sendMessage("start");
        }

        public function onCancelOk(tag:String):Void {
            //log("onCancelOk: " + tag);
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:BytesInput):Void {
            // this is called by the socket thread
            messages.add(body);
        }
    }
