package org.amqp.fast.neko;
// Amqp instance
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.SMessage;
    import org.amqp.SessionManager;

    import neko.vm.Thread;
    import neko.vm.Deque;
    import haxe.io.BytesInput;
    import haxe.io.BytesOutput;

    import org.amqp.LifecycleEventHandler;

    class AmqpConnection implements LifecycleEventHandler {

        var co:Connection;
        var sm:SessionManager;

        var channels:List<Channel>;

        public var ct:Thread;
        public var mt:Thread;

        public function new(cp:ConnectionParameters) {
            co = new Connection(cp);
            sm = co.sessionManager;
            channels = new List();

            co.start();
            co.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            //trace("create connection thread");
            ct = neko.vm.Thread.create(callback(co.socketLoop, mt));
            Thread.readMessage(true); // wait for a start message from afterOpen
        }

        public function channel():Channel {
            var ch = new Channel(this, co, sm, ct);
            channels.add(ch);
            return ch;
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
            neko.Sys.sleep(0.1); // need this or we get a bus error
            // I assume it has to do with some interaction with the ct or idt thread
        }
    }
