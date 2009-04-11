import org.amqp.fast.Import;

class Gateway {

    public static function main() {
        var x = "x";
        var q = "gateway";

        var amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"));
        trace("connection open");
        var inch = amqp.channel();
        inch.declareExchange(x, DIRECT);
        trace("exchange declared");
        var declareOk = inch.declareQueue(q);
        trace("inch Inspect "+declareOk.queue+" messageCount: "+declareOk.messagecount+", consumerCount: "+declareOk.consumercount);      

        inch.bind(q, x, q);
        trace("bound");

        var ouch = amqp.channel();

        var dh:String->Delivery->Void = 
        function(q:String, d:Delivery):Void {
            var dr = new DataReader(d.body);
            trace("delivery to "+q+" "+dr.string());

            ouch.publishString("hello", x, "flash");
        }
        
        var tag = inch.consume(q, callback(dh, q));

        while(true)
            inch.deliver();
    }
}
