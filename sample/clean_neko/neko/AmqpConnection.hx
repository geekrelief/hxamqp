package neko;
// Amqp instance
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
    import org.amqp.methods.basic.Return;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Declare;
    import org.amqp.methods.queue.DeclareOk;

    class AmqpConnection implements LifecycleEventHandler {

        var co:Connection;
        var sm:SessionManager;

        var channels:List<Channel>;

        public var ct:Thread;
        public var mt:Thread;

        //var ms:Deque<Delivery>;
        //var ams:Deque<AppMessage>;

        var sentDisconnect:Bool;

        public function new(cp:ConnectionParameters) {
            //co = new Connection(buildConnectionParams());
            co = new Connection(cp);
            sm = co.sessionManager;
            channels = new List();

            //ms = new Deque();
            //ams = new Deque();

            sentDisconnect = false;

            run();
        }

        public function channel():Channel {
            var ch = new Channel(this, co, sm, ct);
            channels.add(ch);
            return ch;
        }

        public function run():Void {
            co.start();
            co.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            //trace("create connection thread");
            ct = neko.vm.Thread.create(callback(co.socketLoop, mt));
            Thread.readMessage(true); // wait for a start message from afterOpen
            //trace("after open");
        }

        public function afterOpen():Void { mt.sendMessage(true); }
        
        public function deliver(?block=true):Void {
            // loop through all channels
            // until one delivers
            do {
                for(ch in channels) {
                    if (ch.deliver(false)) {
                        block = false;
                    }
                }
            } while(block);
        }

        public function removeChannel(ch:Channel) {
            channels.remove(ch);
        }

        public function close() {
            ct.sendMessage(SClose);
            Thread.readMessage(true);
        }
    }
