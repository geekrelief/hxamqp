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

class NekoClient {

    public static function main() {
        var amqp = new AmqpConnection(new ConnectionParameters("127.0.0.1", 5672, "guest", "guest", "/"));

        // setup first inbox
        var inch =  amqp.channel();
        
        var d = new DeclareQueue();
        d.queue = "inch";
        var declareOk = inch.declare_queue(d);
        trace("inch Inspect "+declareOk.queue+" messageCount: "+declareOk.messagecount+", consumerCount: "+declareOk.consumercount);      

        d.queue = "inch2";
        trace(inch.declare_queue(d));

        d.queue = "inch3";
        trace(inch.declare_queue(d));

        var xd = new DeclareExchange();
        xd.exchange = "lobby";
        xd.type = "topic";
        inch.declare_exchange(xd);

        inch.bind("inch", "lobby", "#.on.#");
        inch.bind("inch2", "lobby", "dinosaurs");
        inch.bind("inch3", "lobby", "nothing");
        inch.bind("inch", "lobby", "4th");

        var dh:String->Delivery->Void = 
        function(q:String, d:Delivery):Void {
            var b:BytesInput = d.body;
            trace("delivery to "+q+" "+b.readString(b.readByte()));
        }
        
        var c = new Consume();
        c.queue = "inch";
        c.noack = true;
        var tag = inch.consume(c, callback(dh, c.queue));

        c.queue = "inch3";
        c.noack = true;
        var tag3 = inch.consume(c, callback(dh, c.queue));

        // setup second inbox
        /*
        var inch2 =  amqp.channel();
        
        var d2 = new DeclareQueue();
        d2.queue = ""; // get a reply queue
        declareOk = inch2.declare_queue(d2);
        trace("inch2 Inspect "+declareOk.queue+" messageCount: "+declareOk.messagecount+", consumerCount: "+declareOk.consumercount);      

        var xd2 = new DeclareExchange();
        xd2.exchange = "lobby";
        xd2.type = "topic";
        inch2.declare_exchange(xd2);

        inch2.bind(declareOk.queue, "lobby", "#.bikes");
 
        var dh2:Delivery->Void = 
        function(d:Delivery):Void {
            var b:BytesInput = d.body;
            trace("delivery inch2 "+b.readString(b.readByte()));
        }
        
        var c2 = new Consume();
        c2.queue = declareOk.queue;
        c2.noack = true;
        inch2.consume(c2, dh2);
        */
       
        // setup output channel
        var ouch = amqp.channel();

        var pub = new Publish();
        pub.exchange = "lobby";
        pub.routingkey = "babes.on.bikes";
        pub.mandatory = true; // if there are no consumers returns the message
        ouch.publishSettings = pub;
        ouch.setReturn(function(c:Command, r:Return):Void{ trace("message returned "+c+" "+r);});

        var s = "Honda DN-01 2009";
        var b = new BytesOutput();
        b.bigEndian = true; // gotta remember to this send this bigEndian over network
        b.writeByte(s.length);
        b.writeString(s);
        ouch.publish(b.getBytes());

        //trace("publish "+ pub.exchange+ " "+pub.routingkey);

   
        // deliver the messsages to their handlers
        trace("waiting for delivery inch");
        inch.deliver();

/*
        trace("waiting for delivery inch2");
        inch2.deliver();
        */

        // waits until one of the channels has their message delivered
        // other channels may still be waiting
        //amqp.deliver();

        // cancel consumption
        inch.cancel(tag);

        c.queue = "inch2";
        c.noack = true;
        var tag2 = inch.consume(c, callback(dh, c.queue));

        ouch.publish_string("Triceratops", "lobby", "dinosaurs");
        inch.deliver();

        inch.cancel(tag3);


        // closese a specific channel
        //inch.close();
        //inch2.close();
        //ouch.close();
        // closes all the channels, this has a bug in it, works sometimes
        amqp.close();
    }
}
