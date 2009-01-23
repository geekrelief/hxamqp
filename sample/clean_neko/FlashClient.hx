	import flash.display.Sprite;
	import flash.text.TextField;

	import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.Lib;

	import flash.events.EventDispatcher;

    import org.amqp.Command;
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.ProtocolEvent;
    import org.amqp.Session;
    import org.amqp.SessionManager;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.methods.channel.Open;
    import org.amqp.util.Properties;


    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Bind;

    import flash.Vector;

	class FlashClient implements BasicConsumer, implements LifecycleEventHandler {

        public var exchange:String ;
        public var x_type:String;
        public var q:String ;
        public var routingkey:String;
        public var connection:Connection;
        public var sessionManager:SessionManager;
        public var sessionHandler:SessionStateHandler;
 
        var consumerTag:String;

        static function main() {
            flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
    		new FlashClient();
		}

        public function new()
        {
            exchange = "lobby";
            x_type = "topic";
			q = "inq";
            routingkey = "#.don.#";

            connection = new Connection(buildConnectionParams());
            sessionManager = connection.sessionManager;
            
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
        }

        public function buildConnectionParams():ConnectionParameters {
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            params.serverhost = "127.0.0.1";
            return params;
        }

        public function afterOpen():Void {
            openChannel();
        }

        public function openChannel():Void {

            // opens the channel
            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            sessionHandler.rpc(new Command(open), declareExchange);
        }

        public function declareExchange(e:ProtocolEvent):Void {
            trace("channel opened "+e);
            // declares the exchange
            var de = new org.amqp.methods.exchange.Declare();
            de.exchange = exchange;
            de.type = x_type;
            sessionHandler.rpc(new Command(de), declareQueue);
        }

        public function declareQueue(e:ProtocolEvent):Void {
            trace("exchange declared "+e);
            // declares the queue
            var dq = new org.amqp.methods.queue.Declare();
            dq.queue = q;
            sessionHandler.rpc(new Command(dq), setupBind);
        }

        public function setupBind(e:ProtocolEvent):Void {
            trace("queue declared "+e);
            // assumes the exchange is already created
            // bind the queue to the exchange
            var b:Bind = new Bind();
            b.queue = q;
            b.exchange = exchange;
            b.routingkey = routingkey;
            sessionHandler.rpc(new Command(b), setupConsumer);
        }

        public function setupConsumer(e:ProtocolEvent):Void {
            trace("bind queue "+e);
            // after the bind
            // setup the consumer
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;
            sessionHandler.register(consume, this);
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            trace("onConsumeOk");
        }

        public function onCancelOk(tag:String):Void {
        }

        public function onDeliver(method:Deliver, properties:BasicProperties, body:ByteArray):Void {
            var s = body.readUTFBytes(body.readByte());          
            trace("delivered "+s); 
        }
    }
