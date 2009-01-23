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

    class Channel extends EventDispatcher {

        var amqp:AmqpConnection;
        var co:Connection;
        var sm:SessionManager;
        var ssh:Ssh;
    
        var mt:Thread;
        var ct:Thread;
        var ms:Deque<Delivery>;

        var deliver_callback:Delivery->Void;

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
            cRpc(ssh, new Open(), dh); // open a channel
            //trace("channel open");

            ms = new Deque();
            sentDisconnect = false;
        }

        // helper functions for talking to the connection thread
        public function cDispatch(s:Ssh, p:Publish, b:BasicProperties, d:Bytes) { 
            // dispatch sends aynch commands to server
            ct.sendMessage(SDispatch(s, new Command(p, b, d))); 
        } 
        public function cRpc(s:Ssh, m:Method, cb:Dynamic):ProtocolEvent { 
            // sends synchronous commands, blocks till reply received
            ct.sendMessage(SRpc(s, new Command(m), cb)); 
            // returns ProtocolEvent
            return Thread.readMessage(true);
        }
        public function cConsume(s:Ssh, c:Consume, ?fdeliver:Dynamic, ?fconsume: Dynamic, ?fcancel:Dynamic):String { 
            ct.sendMessage(SRegister(s, c, new Consumer(fdeliver, fconsume, fcancel))); 
            // used for the consume call, returns the consumer tag
            return Thread.readMessage(true);
        }
        
        public function cSetReturn(s:Ssh, rc:Dynamic) { 
            // set a message return callback
            ct.sendMessage(SSetReturn(s, rc)); 
        }
      
        function dh(e:ProtocolEvent):Void { 
            //trace(e+" "+Type.typeof(e.command.contentHeader)+" "+e.command.contentHeader);
            mt.sendMessage(e);
        }

        public function declare_queue(dq:DeclareQueue):DeclareQueueOk {
            var e = cRpc(ssh, dq, dh); // declare a queue on this channel
                                       // get the return value from dh
            //trace("queue declared");
            return cast(e.command.method, DeclareQueueOk);
        }

        public function declare_exchange(de:DeclareExchange) {
            cRpc(ssh, de, dh); 
            //trace("exchange declared");
        }

        public function bind(qname:String, xname:String, routingkey:String) {
            var b:Bind = new Bind();
            b.queue = qname;
            b.exchange = xname;
            b.routingkey = routingkey;
            cRpc(ssh, b, dh); 
            //trace("bind ok");
        }

        public function publish(data:Bytes) {
            cDispatch(ssh, publishSettings, Properties.getBasicProperties(), data);
        }

        public function publish_with(data:Bytes, pub:Publish, prop:BasicProperties ):Void {
            cDispatch(ssh, pub, prop, data);
        }
 
        // returns the consumer tag
        public function consume(c:Consume, dh:Delivery->Void):String {
            deliver_callback = dh;
            return cConsume(ssh, c, onDeliver, onConsumeOk);
        }

        public function onConsumeOk(tag:String):Void {
            // in connection thread
            mt.sendMessage(tag);
        }

        public function onDeliver(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
            // in connection thread
            ms.add({method: method, properties: properties, body:body});
        }

        public function cancel(tag:String):Void {
            var c = new Cancel();
            c.consumertag = tag;
            cRpc(ssh, c, dh);
        }

        public function setReturn(rh:Command->Return->Void) {
            cSetReturn(ssh, rh);
        }

        public function deliver(?_block:Bool=true):Bool {
            var msg:Delivery = ms.pop(_block);
            if(msg != null) {
                if(deliver_callback != null) {
                    deliver_callback(msg);
                }
            }

            return (msg != null);
        }

        public function close() {
            sm.remove(ssh);
            amqp.removeChannel(this);
        }
    }
