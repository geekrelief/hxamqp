    import org.amqp.fast.Import;
    import flash.Lib;

	class FlashClient {

        public var x:String ;
        public var q:String ;
        public var routingkey:String;
        public var amqp:AmqpConnection;
        public var inch:Channel;
        public var ouch:Channel;
 
        var consumerTag:String;

        static function main() {
            flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
    		new FlashClient();
		}

        public function new() {
            x = "x";
			q = "flash";
            routingkey = "gateway";

            amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"), onConnectionOpenOk);
        }

        public function onConnectionOpenOk():Void {
            ouch = amqp.channel();
            inch = amqp.channel();

            inch.declareExchange(x, "topic");
            inch.declareQueue(q);
            inch.bind(q, x, q);
            inch.consume(q, onDeliver, onConsume/*, onCancel*/);
        }

        public function onDeliver(d:Delivery):Void {
            trace("onDeliver");
            var dr = new DataReader(d.body);
            trace(dr.string());
        }

        public function onConsume(tag:String){
            trace("onConsume");
            trace("publish");

            ouch.publishString("world", x, "gateway");
        }
    }
