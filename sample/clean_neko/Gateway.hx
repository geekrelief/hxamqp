import neko.AmqpConnection;
import neko.DeclareQueue;
import neko.DeclareQueueOk;
import neko.DeclareExchange;
import neko.Delivery;

import org.amqp.ConnectionParameters;
import org.amqp.Command;
import org.amqp.methods.basic.Publish;
import org.amqp.methods.basic.Return;
import org.amqp.methods.basic.Consume;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;

import neko.vm.Thread;

class Gateway {

    public static function main() {
        var amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"));

        // setup first inbox
        var inch =  amqp.channel();
        
        var d = new DeclareQueue();
        d.queue = "gateway";
        var declareOk = inch.declare_queue(d);
        trace("inch Inspect "+declareOk.queue+" messageCount: "+declareOk.messagecount+", consumerCount: "+declareOk.consumercount);      

        var xd = new DeclareExchange();
        xd.exchange = "lobby";
        xd.type = "topic";
        inch.declare_exchange(xd);

        inch.bind("gateway", "lobby", "#");

        var dh:String->Delivery->Void = 
        function(q:String, d:Delivery):Void {
            var b:BytesInput = d.body;
            trace("delivery to "+q+" "+b.readString(b.readByte()));
        }
        
        var c = new Consume();
        c.queue = "gateway";
        c.noack = true;
        var tag = inch.consume(c, callback(dh, c.queue));

        // deliver the messages to their handlers
        while(true)
            inch.deliver();
    }
}
