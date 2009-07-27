package org.amqp.fast.flash;
// Amqp instance
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.SessionManager;

    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;

    class AmqpConnection implements LifecycleEventHandler {
        var co:Connection;
        var sm:SessionManager;

        var channels:List<Channel>;

        var openh:Void->Void;
        var errorh:Void->Void;

        public function new(cp:ConnectionParameters, _openh:Void->Void, ?_errorh:Void->Void ) {
            co = new Connection(cp);
            if(_errorh != null)
                co.errorh = _errorh;
            sm = co.sessionManager;
            channels = new List();

            openh = _openh;
            
            co.start();
            co.baseSession.registerLifecycleHandler(this);
        }

        public function channel(?h:ProtocolEvent->Void):Channel {
            var ch = new Channel(this, co, sm, h);
            channels.add(ch);
            return ch;
        }

        public function afterOpen():Void { openh(); }
        
        public function removeChannel(ch:Channel) {
            channels.remove(ch);
        }

        public function close() {
            co.close();
        }
    }
