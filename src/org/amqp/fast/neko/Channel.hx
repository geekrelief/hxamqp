package org.amqp.fast.neko;
// Amqp Channel instance
    import haxe.io.Bytes;

    import org.amqp.fast.Import;
    import org.amqp.Connection;
    import org.amqp.SMessage;
    import org.amqp.Method;
    import org.amqp.SessionManager;

    import neko.vm.Thread;
    import neko.vm.Deque;

    import org.amqp.methods.channel.Open;

    import org.amqp.events.EventDispatcher;

    typedef DeliveryCallback = Delivery -> Void
    typedef DeliveryMessage = {> Delivery, dcb:DeliveryCallback }

    class Channel extends EventDispatcher {

        var amqp:AmqpConnection;
        var co:Connection;
        var sm:SessionManager;
        var ssh:Ssh;
    
        var mt:Thread;
        var ct:Thread;
        var ms:Deque<DeliveryMessage>;

        var queueCount:Int;
        var deleteQueueCount:Int;
        //var purgeCount:Int;
        var exchangeCount:Int;
        var deleteExchangeCount:Int;
        var bindCount:Int;
        var consumeCount:Int;
        var tag:String;

        public function new(_amqp:AmqpConnection, _co:Connection, _sm:SessionManager, _ct:Thread) {
            super();
            amqp = _amqp;
            co = _co;
            sm = _sm;
            ct = _ct;
            mt = Thread.current();

            ssh = sm.create();
            cRpc(new Open()); // open a channel
            //trace("channel open");

            ms = new Deque();

            // these counts manage multiple Oks returned
            // when executing repeat methods on the channel
            queueCount = 0;
            deleteQueueCount = 0;
            //purgeCount = 0;
            exchangeCount = 0;
            deleteExchangeCount = 0;
            bindCount = 0;
            consumeCount = 0;
        }

        // helper functions for talking to the connection thread
        function cDispatch(p:Publish, b:BasicProperties, d:Bytes) { 
            // dispatch sends aynch commands to server
            ct.sendMessage(SDispatch(ssh, new Command(p, b, d))); 
        } 
        function cRpc(m:Method, ?ecount:Int = 1):ProtocolEvent { 
            // sends synchronous commands, blocks till reply received
            ct.sendMessage(SRpc(ssh, new Command(m), dh)); 
            // returns ProtocolEvent
            var e:ProtocolEvent = null;
            // throw away repeated/previous Oks
            trace("cRpc "+m);
            for(i in 0...ecount) {
                e = Thread.readMessage(true);
            }
            trace("cRpc res "+e);
            return e;
        }

        function dh(e:ProtocolEvent):Void { 
            //trace(e+" "+Type.typeof(e.command.contentHeader)+" "+e.command.contentHeader);
            mt.sendMessage(e);
        }

        public function declareExchange(x:String, t:ExchangeType):DeclareExchangeOk {
            var d = new DeclareExchange();
            d.exchange = x;
            d.type = switch(t){
                case DIRECT:
                    "direct";
                case TOPIC:
                    "topic";
            };
            return declareExchangeWith(d);
        }

        public function declareExchangeWith(de:DeclareExchange):DeclareExchangeOk {
            exchangeCount++;
            var e = cRpc(de, exchangeCount);
            return cast(e.command.method, DeclareExchangeOk);
        }

        // note it is an error to delete an exchange that does not exist
        public function deleteExchange(x:String, ?ifunused:Bool = false, ?nowait:Bool = false):DeleteExchangeOk {
            var d = new DeleteExchange();
            d.exchange = x;
            d.ifunused = ifunused;
            d.nowait = nowait;
            return deleteExchangeWith(d);
        }

        public function deleteExchangeWith(de:DeleteExchange):DeleteExchangeOk {
            ++deleteExchangeCount;
            var e = cRpc(de, deleteExchangeCount);
            return cast(e.command.method, DeleteExchangeOk);
        }

        public function declareQueue(q:String):DeclareQueueOk {
            var d = new DeclareQueue();
            d.queue = q;
            return declareQueueWith(d);
        }

        public function declareQueueWith(dq:DeclareQueue):DeclareQueueOk {
            ++queueCount;
            var e = cRpc(dq, queueCount);
            return cast(e.command.method, DeclareQueueOk);
        }

        // note it is an error to delete a queue that does not exist
        public function deleteQueue(qname:String, ?ifunused:Bool = false, ?ifempty:Bool = false, ?nowait:Bool = false):DeleteQueueOk {
            var d = new DeleteQueue();
            d.queue = qname;
            d.ifunused = ifunused;
            d.ifempty = ifempty;
            d.nowait = nowait;
            return deleteQueueWith(d);
        }

        public function deleteQueueWith(dq:DeleteQueue):DeleteQueueOk {
            ++deleteQueueCount;
            var e = cRpc(dq, deleteQueueCount);
            trace("deleteQueueWith "+e.command);
            return cast(e.command.method, DeleteQueueOk);
        }

/*
        // I don't understand the semantics of purge.
        // How are messages acknowledged by not consumed.
        // An alternative to purge is to consume all the messages.
        // But maybe the users doesn't want to do that (too many? too large?)...
        // Another option is to delete the queue
        public function purge(q:String):PurgeOk {
            var p = new Purge();
            p.queue = q;
            return purgeWith(p);
        }

        public function purgeWith(p:Purge):PurgeOk {
            ++purgeCount;
            var e = cRpc(p, purgeCount);
            return cast(e.command.method, PurgeOk);
        }
        */

        public function bind(qname:String, xname:String, routingkey:String) {
            //trace("bind "+routingkey);
            var b:Bind = new Bind();
            b.queue = qname;
            b.exchange = xname;
            b.routingkey = routingkey;
            bindWith(b);
        }

        public function bindWith(b:Bind):Void {
            ++bindCount; // each bind returns a bindCount BindOk's
            var e = cRpc(b, bindCount);
        }

        public function publish(data:Bytes, exchange:String, routingkey:String, ?replyto:String) {
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var prop = Properties.getBasicProperties();
            prop.replyto = replyto;
            publishWith(data, p, prop);
        }

        inline public function publishWith(data:Bytes, p:Publish, prop:BasicProperties) {
            cDispatch(p, prop, data);
        }

        public function publishData(dw:DataWriter, exchange:String, routingkey:String, ?replyto:String) {
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var prop = Properties.getBasicProperties();
            prop.replyto = replyto;
            publishDataWith(dw, p, prop);
        }

        inline public function publishDataWith(dw:DataWriter, p:Publish, prop:BasicProperties) {
            publishWith(dw.getBytes(), p, prop);
        }

        public function publishString(s:String, exchange:String, routingkey:String, ?replyto:String){
            var dw = new DataWriter();
            dw.string(s);
            publishData(dw, exchange, routingkey, replyto);
        }

        public function consume(q:String, dcb:DeliveryCallback):String {
            var c = new Consume();
            c.queue =  q;
            c.noack = true;
            tag = consumeWith(c, dcb);
            return tag;
        }

        public function consumeWith(c:Consume, dcb:DeliveryCallback):String {
            ++consumeCount;
            ct.sendMessage(SRegister(ssh, c, new Consumer(callback(onDeliver, c, dcb), callback(onConsumeOk, c), callback(onCancelOk, c)))); 
            // loop to ignore repeats/previous Oks
            for(i in 0...consumeCount) {
                tag = Thread.readMessage(true);
            }
            //trace("consume tag "+consumerTag);
            return tag;
        }

        function onConsumeOk(c:Consume, _tag:String):Void {
            // in connection thread
            //trace("onConsume q: "+c.queue+" tag: "+tag);
            mt.sendMessage(_tag);
        }

        function onDeliver(c:Consume, dcb:DeliveryCallback, method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            // in connection thread
            ms.add({dcb: dcb, method: method, properties: properties, body:body});
        }

        public function deliver(?_block:Bool=true):Bool {
            var msg:DeliveryMessage = ms.pop(_block);
            if(msg != null) {
                if(msg.dcb != null)
                    msg.dcb({method: msg.method, properties: msg.properties, body: msg.body});
            }

            return (msg != null);
        }

        public function cancel(?_tag:String):Void {
            --consumeCount;
            ct.sendMessage(SUnregister(ssh, (_tag == null) ? tag : _tag));
            Thread.readMessage(true);
            tag = null;
        }

        function onCancelOk(c:Consume, tag:String) {
            // in connection thread
            mt.sendMessage(tag);
        }

        public function setReturn(rh:Command->Return->Void) {
            ct.sendMessage(SSetReturn(ssh, rh)); 
        }

        public function close() {
            sm.remove(ssh);
            amqp.removeChannel(this);
        }
    }
