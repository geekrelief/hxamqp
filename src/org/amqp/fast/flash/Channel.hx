package org.amqp.fast.flash;
// Amqp Channel instance
    import haxe.io.Bytes;

    import org.amqp.fast.FastImport;
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
        var deleteQueueCount:Int;
        var deleteQueueEventCount:Int;
        var exchangeCount:Int;
        var exchangeEventCount:Int;
        var deleteExchangeCount:Int;
        var deleteExchangeEventCount:Int;
        var bindCount:Int;
        var bindEventCount:Int;
        var consumeCount:Int;
        var consumeEventCount:Int;
        var tag:String; // for convenience save the last consumed tag

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
            // such as declaring multiple queues on the same channel
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

        function cDispatch(p:Publish, b:BasicProperties, d:ByteArray) { 
            ssh.dispatch(new Command(p, b, d));
        } 

        inline public function publish(data:ByteArray, exchange:String, routingkey:String, ?replyto:String) {
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var prop = Properties.getBasicProperties();
            prop.replyto = replyto;
            publishWith(data, p, prop);
        }

        public function publishWith(data:ByteArray, pub:Publish, prop:BasicProperties) {
            cDispatch(pub, prop, data);
        }

        public function publishData(dw:DataWriter, exchange:String, routingkey:String, ?replyto:String) {
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var prop = Properties.getBasicProperties();
            prop.replyto = replyto;
            publishDataWith(dw, p, prop);
        }

        inline public function publishDataWith(dw:DataWriter, pub:Publish, prop:BasicProperties) {
            publishWith(dw.getBytes(), pub, prop);
        }

        public function publishString(s:String, exchange:String, routingkey:String, ?replyto:String){
            var dw = new DataWriter();
            dw.string(s); 
            publishData(dw, exchange, routingkey, replyto);
        }

        function dh(e:ProtocolEvent):Void {}

        function nullH(h:Dynamic):Dynamic { return ((h == null) ? dh : h); }

        public function declareExchange(x:String, t:ExchangeType, ?h:ProtocolEvent->Void) {
            var e = new DeclareExchange();
            e.exchange = x;
            e.type = switch(t) {
                case DIRECT:
                    "direct";
                case TOPIC:
                    "topic";
            };
            declareExchangeWith(e, nullH(h));
        }

        public function declareExchangeWith(de:DeclareExchange, ?h:ProtocolEvent->Void) {
            ++exchangeCount;
            exchangeEventCount = 0;
            ssh.rpc(new Command(de), callback(declareExchangeOk, nullH(h)));
        }

        function declareExchangeOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++exchangeEventCount;
            if(exchangeEventCount == exchangeCount)
                h(e);
        }

        public function deleteExchange(x:String, ?h:ProtocolEvent->Void, ?ifunused:Bool = false, ?nowait:Bool = false) {
            var de = new DeleteExchange();
            de.exchange = x;
            de.ifunused = ifunused;
            de.nowait = nowait;
            deleteExchangeWith(de, h);
        }

        public function deleteExchangeWith(de:DeleteExchange, ?h:ProtocolEvent->Void) {
            ++deleteExchangeCount;
            deleteExchangeEventCount = 0;
            ssh.rpc(new Command(de), callback(deleteExchangeOk, nullH(h)));
        }

        function deleteExchangeOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++deleteExchangeEventCount;
            if(deleteExchangeCount == deleteExchangeEventCount)
                h(e);
        }

        public function declareQueue(q:String, ?h:ProtocolEvent->Void):Void {
            var d = new DeclareQueue();
            d.queue = q;
            declareQueueWith(d, nullH(h));
        }

        public function declareQueueWith(dq:DeclareQueue, ?h:ProtocolEvent->Void):Void {
            ++queueCount;
            queueEventCount = 0;
            ssh.rpc(new Command(dq), callback(declareQueueOk, nullH(h)));
        }

        function declareQueueOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++queueEventCount;
            if(queueEventCount == queueCount)
                h(e);
        }

        public function deleteQueue(q:String, ?h:ProtocolEvent->Void, ?ifunused:Bool = false, ?ifempty:Bool = false, ?nowait:Bool = false):Void {
            var dq = new DeleteQueue();
            dq.ifunused = ifunused;
            dq.ifempty = ifempty;
            dq.nowait = nowait;
            deleteQueueWith(dq, h);
        }

        public function deleteQueueWith(dq:DeleteQueue, ?h:ProtocolEvent->Void):Void {
            ++deleteQueueCount;
            deleteQueueEventCount = 0;
            ssh.rpc(new Command(dq), callback(deleteQueueOk, nullH(h)));
        }

        function deleteQueueOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++deleteQueueEventCount;
            if(deleteQueueCount == deleteQueueEventCount)
                h(e);
        }

        public function bind(q:String, x:String, r:String, ?h:ProtocolEvent->Void) {
            var b:Bind = new Bind();
            b.queue = q;
            b.exchange = x;
            b.routingkey = r;
            bindCount++; // each bind returns a bindCount BindOk's
            bindEventCount = 0;
            ssh.rpc(new Command(b), callback(onBindOk, nullH(h)));
        }

        public function bindWith(b:Bind, ?h:ProtocolEvent->Void) {
            bindCount++; // each bind returns a bindCount BindOk's
            bindEventCount = 0;
            ssh.rpc(new Command(b), callback(onBindOk, nullH(h)));
        }


        function onBindOk(h:ProtocolEvent->Void, e:ProtocolEvent):Void {
            ++bindEventCount;
            if(bindEventCount == bindCount)
                h(e);
        }

        public function consume(q:String, dcb:DeliveryCallback, ?conh:String->Void, ?canh:String->Void):Void {
            var c = new Consume();
            c.queue = q;
            c.noack = true;
            consumeWith(c, dcb, conh, conh);
        }

        public function consumeWith(c:Consume, dcb:DeliveryCallback, ?conh:String->Void, ?canh:String->Void):Void {
            consumeCount++;
            consumeEventCount = 0;
            ssh.register(c, new Consumer(callback(onDeliver, dcb), callback(onConsumeOk, conh), callback(onCancelOk, canh))); 
        }

        function onConsumeOk(h:String->Void, _tag:String):Void {
            ++consumeEventCount;
            if(consumeEventCount == consumeCount) {
                tag = _tag;
                if(h != null)
                    h(tag);
            }
        }

        function onDeliver(dcb:DeliveryCallback, method:Deliver, properties:BasicProperties, body:ByteArray):Void {
            dcb({method:method, properties:properties, body:body});
        }

        function onCancelOk(h:String->Void, tag:String) {
            if(h != null)
                h(tag);
        }

        public function cancel(?_tag:String):Void {
            consumeCount--;
            ssh.unregister((_tag == null) ? tag : _tag);
            tag = null;
        }

        public function setReturn(rh:Command->Return->Void) {
            ssh.setReturn(rh); 
        }

        public function close() {
            sm.remove(ssh);
            amqp.removeChannel(this);
        }
    }
