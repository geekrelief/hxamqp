
    import haxe.io.Bytes;

    import org.amqp.Connection;
    import org.amqp.SMessage;
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

    class TS
        implements BasicConsumer, 
        implements LifecycleEventHandler {

        var data:Bytes;

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
            var s = new TS();
            s.run();
        }

        public function new()
        {
            var bo = new BytesOutput();
            bo.bigEndian = true;
            for( i in 1...20000) {
                bo.writeInt31(i);
            }
            data = bo.getBytes();

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
            params.serverhost = "127.0.0.1";

            return params;
        }

        public function publish(data:Bytes):Void {
            //trace("publish");
            var publish:Publish = new Publish();
            publish.exchange = ax;
            publish.routingkey = routing_key;
            var props:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(publish, props, data);

            ct.sendMessage(SDispatch(sessionHandler, cmd));
            //sessionHandler.dispatch(cmd);
        }


        public function run():Void {
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            trace("create connection thread");
            ct = neko.vm.Thread.create(callback(connection.socketLoop, mt));
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
            var msg:BytesInput;
            var count = 0;
           
            var b = new BytesOutput();
            b.bigEndian = true;
            var by = b.getBytes();
            //publish(by);  
            while(true) {
                msg = messages.pop(true);
                //trace("got ping "+count);//+" @"+neko.Sys.time());
                //msg.readByte();

                /*
                var b = new BytesOutput();
                b.bigEndian = true;
               
                b.writeByte("hello, are you getting this long string?".length);
                b.writeString("hello, are you getting this long string?");
              
                var by = b.getBytes();
                */
                //publish(by);
                publish(data);
                trace("bounce back @"+neko.Sys.time());
                count++;
            }
        }

        public function afterOpen():Void {
            openChannel(setupConsumer);
        }

        function openChannel(_callback:Dynamic):Void {
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
                //trace(event);
            };

            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            ct.sendMessage(SRpc(sessionHandler, new Command(open), whoCares));
            ct.sendMessage(SRpc(sessionHandler, new Command(queue), whoCares));
            /*
            sessionHandler.rpc(new Command(open), whoCares);
            sessionHandler.rpc(new Command(queue), whoCares);
            */

            sessionHandler2 = sessionManager.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            ct.sendMessage(SRpc(sessionHandler2, new Command(open), whoCares));
            ct.sendMessage(SRpc(sessionHandler2, new Command(queue), _callback));
            /*
            sessionHandler2.rpc(new Command(open), whoCares);
            sessionHandler2.rpc(new Command(queue), _callback);
            */
        }

        public function setupConsumer(event:ProtocolEvent):Void {
			//trace("setupConsumer");
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;

            ct.sendMessage(SRegister(sessionHandler2, consume, this));
            //sessionHandler2.register(consume, this);
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
