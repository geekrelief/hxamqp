    import org.amqp.fast.Import;
    import flash.Lib;

	class FlashClient {

        public var x:String ;
        public var x_type:String;
        public var iq:String ;
        public var routingkey:String;
        public var amqp:AmqpConnection;
        public var inch:Channel;
        public var ouch:Channel;
 
        var consumerTag:String;

        static function main() {
            flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
    		new FlashClient();
		}

        public function new()
        {
            x = "x";
            x_type = "topic";
			iq = "flash";
            routingkey = "gateway";

            amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"), onConnectionOpenOk);
        }

        public function onConnectionOpenOk():Void {
            ouch = amqp.channel();
            inch = amqp.channel();

            var de = new DeclareExchange();
            de.exchange = x;
            de.type = x_type;
            inch.declareExchangeWith(de);
 
            var dq = new DeclareQueue();
            dq.queue = iq;
            inch.declareQueueWith(dq);

            inch.bind("flash", x, "flash", dh);

            var c = new Consume();
            c.queue = iq;
            c.noack = true;
            inch.consumeWith(c, onDeliver, onConsume/*, onCancel*/);

        /*
            var de = new DeclareExchange();
            de.exchange = exchange;
            de.type = x_type;
            ouch.declare_exchange(de, run);
            */
        }

        public function onDeliver(d:Delivery):Void {
            trace("onDeliver");
            var dr = new DataReader(d.body);
            trace(dr.string());
        }

        public function onConsume(tag:String){
            trace("onConsume");
            trace("publish");

            /*
            var dw = new DataWriter();
            dw.string("hello");

            var p = new Publish();
            p.exchange = exchange;
            p.routingkey = routingkey;

            //ouch.publish(dw.getBytes(), p);
            */

            ouch.publishString("world", x, routingkey);
        }


        public function dh(e:ProtocolEvent){
            // ignore
        }
    }
