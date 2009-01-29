    import org.amqp.fast.Import;
    import flash.Lib;

	class FlashClient {

        public var exchange:String ;
        public var x_type:String;
        public var q:String ;
        public var routingkey:String;
        public var amqp:AmqpConnection;
        public var ouch:Channel;
 
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
            routingkey = "gateway";

            amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"), onConnectionOpenOk);
        }

        public function run(e:ProtocolEvent){
            trace("publish");
            amqp.channel();

            var dw = new DataWriter();
            dw.string("hello");

            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;

            ouch.publish(dw.getBytes(), p);

            ouch.publish_string("world", exchange, routingkey);
        }

        public function onConnectionOpenOk():Void {
            ouch = amqp.channel();
        
            var de = new DeclareExchange();
            de.exchange = exchange;
            de.type = x_type;
            ouch.declare_exchange(de, run);
        }
    }
