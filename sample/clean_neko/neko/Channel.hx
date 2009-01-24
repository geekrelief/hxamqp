package neko;
// Amqp Channel instance
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
    import org.amqp.methods.basic.Cancel;
    import org.amqp.methods.channel.Open;

    import org.amqp.methods.queue.Bind;

    import org.amqp.events.EventDispatcher;
    typedef DeliveryMessage = {var dcb:Delivery->Void; var method:Deliver; var properties:BasicProperties; var body:BytesInput;}

    class Channel extends EventDispatcher {

        var amqp:AmqpConnection;
        var co:Connection;
        var sm:SessionManager;
        var ssh:Ssh;
    
        var mt:Thread;
        var ct:Thread;
        //var ms:Deque<Delivery>;

        var ms:Deque<DeliveryMessage>;

        var queueCount:Int;
        var exchangeCount:Int;
        var bindCount:Int;
        var consumeCount:Int;

        var sentDisconnect:Bool;

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
            sentDisconnect = false;

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
            cDispatch( (pub == null) ? publishSettings : pub
                     , (prop == null) ? Properties.getBasicProperties() : prop
                     , data);
        }

        public function publish_string(s:String, exchange:String, routingkey:String){
            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;
            var b = new BytesOutput();
            b.bigEndian = true;
            b.writeByte(s.length);
            b.writeString(s);
            cDispatch(p, Properties.getBasicProperties(), b.getBytes());
        }

        public function consume(c:Consume, dcb:Delivery->Void):String {
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

        public function onDeliver(c:Consume, dcb:Delivery->Void, method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            // in connection thread
            ms.add({dcb: dcb, method: method, properties: properties, body:body});
        }

        public function deliver(?_block:Bool=true):Bool {
            var msg:DeliveryMessage = ms.pop(_block);
            if(msg != null) {
                if(msg.dcb != null)
                    msg.dcb({method: msg.method, properties: msg.properties, body: msg.body});
                    /*
                if(deliver_callback != null) {
                    deliver_callback(msg);
                }
                */
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
