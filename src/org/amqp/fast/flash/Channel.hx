package org.amqp.fast.flash;
// Amqp Channel instance
    import haxe.io.Bytes;

    import org.amqp.fast.Import;
    import org.amqp.Connection;
    import org.amqp.Method;
    import org.amqp.SessionManager;

    import org.amqp.methods.channel.Open;

    import org.amqp.events.EventDispatcher;

    typedef DeliveryCallback = Delivery -> Void

    class Channel extends EventDispatcher {

        var amqp:AmqpConnection;
        var co:Connection;
        var sm:SessionManager;
        var ssh:org.amqp.impl.SessionStateHandler;
    
        var queueCount:Int;
        var queueEventCount:Int;
        var exchangeCount:Int;
        var exchangeEventCount:Int;
        var bindCount:Int;
        var bindEventCount:Int;
        var consumeCount:Int;
        var consumeEventCount:Int;

        public var publishSettings(default, default):Publish;

        public function new(_amqp:AmqpConnection, _co:Connection, _sm:SessionManager, ?_onOpenOk:ProtocolEvent->Void) {
            super();
            amqp = _amqp;
            co = _co;
            sm = _sm;

            ssh = sm.create();
            // open a channel
            ssh.rpc(new Command(new Open()), (_onOpenOk == null) ? onOpenOk : _onOpenOk);
            //trace("channel open");

            // these counts manage multiple Oks returned
            // when executing repeat methods on the channel
            queueCount = 0;
            queueEventCount = 0;
            exchangeCount = 0;
            exchangeEventCount = 0;
            bindCount = 0;
            bindEventCount = 0;
            consumeCount = 0;
            consumeEventCount = 0;
        }

        function onOpenOk(e:ProtocolEvent):Void { /* ignore */ }

        public function cDispatch(p:Publish, b:BasicProperties, d:ByteArray) { 
            ssh.dispatch(new Command(p, b, d));
        } 

        public function publish(data:ByteArray, ?pub:Publish, ?prop:BasicProperties) {
            #if debug
            if(publishSettings == null && pub == null) {
                trace("Channel#publish needs .publishSettings set or a Publish instance argument");
                throw "Channel#publish needs .publishSettings set or a Publish instance argument";
            }
            #end 

            cDispatch( (pub == null) ? publishSettings : pub
                     , (prop == null) ? Properties.getBasicProperties() : prop
                     , data);
        }

        public function publish_string(s:String, exchange:String, routingkey:String){
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var dw = new DataWriter();
            dw.string(s); 
            cDispatch(p, Properties.getBasicProperties(), dw.getBytes());
        }

       public function declare_queue(dq:DeclareQueue, h:ProtocolEvent->Void):Void {
            queueCount++;
            queueEventCount = 0;
            ssh.rpc(new Command(dq), callback(declareQueueOk, h));
        }

        function declareQueueOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++queueEventCount;
            if(queueEventCount == queueCount)
                h(e);
        }


        public function declare_exchange(de:DeclareExchange, h:ProtocolEvent->Void) {
            exchangeCount++;
            exchangeEventCount = 0;
            ssh.rpc(new Command(de), callback(declareExchangeOk, h));
        }

        function declareExchangeOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++exchangeEventCount;
            if(exchangeEventCount == exchangeCount)
                h(e);
        }

        public function bind(qname:String, xname:String, routingkey:String, h:ProtocolEvent->Void) {
            //trace("bind "+routingkey);
            var b:Bind = new Bind();
            b.queue = qname;
            b.exchange = xname;
            b.routingkey = routingkey;
            bindCount++; // each bind returns a bindCount BindOk's
            bindEventCount = 0;
            ssh.rpc(new Command(b), callback(onBindOk, h));
            //trace("bind " +e);
            //trace("bind ok");
        }

        function onBindOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++bindEventCount;
            if(bindEventCount == bindCount)
                h(e);
        }

        public function consume(c:Consume, dcb:DeliveryCallback, ?conh:String->Void, ?canh:String->Void):Void {
            consumeCount++;
            consumeEventCount = 0;
            ssh.register(c, new Consumer(callback(onDeliver, dcb), callback(onConsumeOk, conh), callback(onCancelOk, canh))); 
        }

        function onConsumeOk(h:String->Void, tag:String):Void {
            ++consumeEventCount;
            if(consumeEventCount == consumeCount)
                if(h != null)
                    h(tag);
        }

        function onDeliver(dcb:DeliveryCallback, method:Deliver, properties:BasicProperties, body:ByteArray):Void {
            dcb({method:method, properties:properties, body:body});
        }

        function onCancelOk(h:String->Void, tag:String) {
            if(h != null)
                h(tag);
        }

        public function cancel(consumerTag:String):Void {
            consumeCount--;
            ssh.unregister(consumerTag);
        }

        public function setReturn(rh:Command->Return->Void) {
            ssh.setReturn(rh); 
        }

        public function close() {
            sm.remove(ssh);
            amqp.removeChannel(this);
        }
    }
