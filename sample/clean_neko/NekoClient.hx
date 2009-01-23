import neko.AmqpConnection;
import neko.DeclareQueue;
import neko.DeclareExchange;
import neko.Delivery;

import org.amqp.ConnectionParameters;
import org.amqp.Command;
import org.amqp.methods.basic.Publish;
import org.amqp.methods.basic.Return;
import org.amqp.methods.basic.Consume;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;

class NekoClient {

    public static function main() {
        var amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"));
        
        // setup first inbox
        var inch =  amqp.channel();
        
        var d = new DeclareQueue();
        d.queue = "inch";
        d.autodelete = true;
        inch.declare_queue(d);

        var xd = new DeclareExchange();
        xd.exchange = "lobby";
        xd.type = "topic";
        inch.declare_exchange(xd);

        inch.bind("inch", "lobby", "#.on.#");

 
        var dh:Delivery->Void = 
        function(d:Delivery):Void {
            var b:BytesInput = d.body;
            trace("delivery to inch "+b.readString(b.readByte()));
        }
        
        var c = new Consume();
        c.queue = "inch";
        c.noack = true;
        var tag = inch.consume(c, dh);

        
        // setup second inbox
        var inch2 =  amqp.channel();
        
        var d2 = new DeclareQueue();
        d2.queue = "inch2";
        d2.autodelete = true;
        inch2.declare_queue(d2);

        var xd2 = new DeclareExchange();
        xd2.exchange = "lobby";
        xd2.type = "topic";
        inch2.declare_exchange(xd2);

        inch2.bind("inch2", "lobby", "#.bikes");
 
        var dh2:Delivery->Void = 
        function(d:Delivery):Void {
            var b:BytesInput = d.body;
            trace("delivery to inch2 "+b.readString(b.readByte()));
        }
        
        var c2 = new Consume();
        c2.queue = "inch2";
        c2.noack = true;
        var tag2 = inch2.consume(c2, dh2);
       
        // setup output channel
        var ouch = amqp.channel();

        var pub = new Publish();
        pub.exchange = "lobby";
        pub.routingkey = "babes.on.bikes";
        pub.mandatory = true;
        ouch.publishSettings = pub;
        ouch.setReturn(function(c:Command, r:Return):Void{ trace("message returned "+c+" "+r);});

        var s = "Honda DN-01 2009";
        var b = new BytesOutput();
        b.bigEndian = true;
        b.writeByte(s.length);
        b.writeString("Honda DN-01 2009");
        var by = b.getBytes();
        ouch.publish(by);

        trace("publish "+ pub.exchange+ " "+pub.routingkey);
      
        inch.deliver();
        inch2.deliver();

        //amqp.deliver();

        //inch.cancel(tag);

        //inch.close();
        //inch2.close();
        //ouch.close();
        amqp.close();
    }
}
