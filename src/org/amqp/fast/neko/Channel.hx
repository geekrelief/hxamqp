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
        var exchangeCount:Int;
        var bindCount:Int;
        var consumeCount:Int;

        public var publishSettings(default, default):Publish;

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
            exchangeCount = 0;
            bindCount = 0;
            consumeCount = 0;
        }

        // helper functions for talking to the connection thread
        public function cDispatch(p:Publish, b:BasicProperties, d:Bytes) { 
            // dispatch sends aynch commands to server
            ct.sendMessage(SDispatch(ssh, new Command(p, b, d))); 
        } 
        public function cRpc(m:Method, ?ecount:Int = 1):ProtocolEvent { 
            // sends synchronous commands, blocks till reply received
            ct.sendMessage(SRpc(ssh, new Command(m), dh)); 
            // returns ProtocolEvent
            var e:ProtocolEvent = null;
            for(i in 0...ecount)
                e = Thread.readMessage(true);
            return e;
        }

        function dh(e:ProtocolEvent):Void { 
            //trace(e+" "+Type.typeof(e.command.contentHeader)+" "+e.command.contentHeader);
            mt.sendMessage(e);
        }

        public function declare_queue(dq:DeclareQueue):DeclareQueueOk {
            queueCount++;
            var e = cRpc(dq, queueCount);
            //trace("queue declared");
            //trace("declare queue "+e);
            return cast(e.command.method, DeclareQueueOk);
        }

        public function declare_exchange(de:DeclareExchange) {
            exchangeCount++;
            var e = cRpc(de, exchangeCount); 
            //trace("exchange declared "+e);
        }

        public function bind(qname:String, xname:String, routingkey:String) {
            //trace("bind "+routingkey);
            var b:Bind = new Bind();
            b.queue = qname;
            b.exchange = xname;
            b.routingkey = routingkey;
            bindCount++; // each bind returns a bindCount BindOk's
            var e = cRpc(b, bindCount);
            //trace("bind " +e);
            //trace("bind ok");
        }

        public function publish(data:Bytes, ?pub:Publish, ?prop:BasicProperties) {
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

        public function consume(c:Consume, dcb:DeliveryCallback):String {
            consumeCount++;
            ct.sendMessage(SRegister(ssh, c, new Consumer(callback(onDeliver, c, dcb), callback(onConsumeOk, c), callback(onCancelOk, c)))); 
            var consumerTag:String = "";
            for(i in 0...consumeCount) {
                consumerTag = Thread.readMessage(true);
            }
            //trace("consume tag "+consumerTag);
            return consumerTag;
        }

        public function onConsumeOk(c:Consume, tag:String):Void {
            // in connection thread
            //trace("onConsume q: "+c.queue+" tag: "+tag);
            mt.sendMessage(tag);
        }

        public function onDeliver(c:Consume, dcb:DeliveryCallback, method:Deliver, properties:BasicProperties, body:BytesInput):Void {
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

        public function cancel(consumerTag:String):Void {
            consumeCount--;
            ct.sendMessage(SUnregister(ssh, consumerTag));
            //trace("cancel "+Thread.readMessage(true));
        }

        public function onCancelOk(c:Consume, tag:String) {
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