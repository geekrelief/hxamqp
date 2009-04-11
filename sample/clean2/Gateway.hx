import org.amqp.fast.Import;

class Gateway {

    public static function main() {
        var x = "exchange-test";
        var q = "gateway";

        var amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"));
        trace("connection open");
        var inch = amqp.channel();

        inch.declareExchange(x, DIRECT);
        trace("declared exchange "+x);

        inch.deleteExchange(x);
        trace("deleted exchange "+x);

        inch.declareExchange(x, DIRECT);
        trace("declared exchange "+x);
        
        var declareOk = inch.declareQueue("q1");
        declareOk = inch.declareQueue("q2");
        trace("declare q1 and q2");

        var deleteOk = inch.deleteQueue("q1");
        trace("q1 "+deleteOk);
        inch.deleteQueue("q2");
        trace("delete q1 and q2");

        declareOk = inch.declareQueue(q);
        
        if(declareOk != null){
            trace("inch Inspect "+declareOk.queue+" messageCount: "+declareOk.messagecount+", consumerCount: "+declareOk.consumercount);      
        } else {
            trace("could not declare queue");
            return;
        }

        inch.bind(q, x, q);
        trace(q+" bound on "+x+" with routingkey "+q);

        var ouch = amqp.channel();

        var dh:String->Delivery->Void = 
        function(q:String, d:Delivery):Void {
            var dr = new DataReader(d.body);
            trace("delivery to "+q+" "+dr.string());

            trace("reply world to "+d.properties.replyto);
            ouch.publishString("world", x, d.properties.replyto);
        }
        
        var tag = inch.consume(q, callback(dh, q));

        while(true)
            inch.deliver();
    }
}
