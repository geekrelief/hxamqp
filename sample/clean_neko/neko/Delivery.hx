package neko;
import org.amqp.methods.basic.Deliver;
import org.amqp.headers.BasicProperties;

#if flash9
import flash.utils.ByteArray; 
typedef Delivery = { var method:Deliver; var properties:BasicProperties; var body:ByteArray; }
#elseif neko
import haxe.io.BytesInput;
typedef Delivery = { var method:Deliver; var properties:BasicProperties; var body:BytesInput; }
#end
