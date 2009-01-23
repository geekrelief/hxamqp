/**
 * ---------------------------------------------------------------------------
 *   Copyright (C) 2008 0x6e6562
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 * ---------------------------------------------------------------------------
 **/
package org.amqp.methods.basic;

    import org.amqp.Method;
    import org.amqp.LongString;
    import org.amqp.methods.ArgumentReader;
    import org.amqp.methods.ArgumentWriter;
    import org.amqp.methods.MethodArgumentReader;
    import org.amqp.methods.MethodArgumentWriter;
    import org.amqp.impl.ByteArrayLongString;

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class Deliver extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var consumertag(getConsumertag, setConsumertag) : String;
         public var deliverytag(getDeliverytag, setDeliverytag) : Float;
         public var redelivered(getRedelivered, setRedelivered) : Bool;
         public var exchange(getExchange, setExchange) : String;
         public var routingkey(getRoutingkey, setRoutingkey) : String;
         public function new() {
         _consumertag = "";
         _deliverytag = 0;
         _redelivered = false;
         _exchange = "";
         _routingkey = "";
         }
         
         var _consumertag:String ;
         var _deliverytag:Float ;
         var _redelivered:Bool ;
         var _exchange:String ;
         var _routingkey:String ;

         public function getConsumertag():String{return _consumertag;}
         public function getDeliverytag():Float{return _deliverytag;}
         public function getRedelivered():Bool{return _redelivered;}
         public function getExchange():String{return _exchange;}
         public function getRoutingkey():String{return _routingkey;}

         public function setConsumertag(x:String):String{_consumertag = x;	return x;}
         public function setDeliverytag(x:Float):Float{_deliverytag = x;	return x;}
         public function setRedelivered(x:Bool):Bool{_redelivered = x;	return x;}
         public function setExchange(x:String):String{_exchange = x;	return x;}
         public function setRoutingkey(x:String):String{_routingkey = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function hasContent():Bool {
             return true;
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 60;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShortstr(_consumertag);
             writer.writeLonglong(_deliverytag);
             writer.writeBit(_redelivered);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_routingkey);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _consumertag = reader.readShortstr();
             _deliverytag = reader.readLonglong();
             _redelivered = reader.readBit();
             _exchange = reader.readShortstr();
             _routingkey = reader.readShortstr();
         }

         public function dump():Void {
             trace("-------- basic.Deliver --------");
             trace("consumertag: {" + _consumertag + "}");
             trace("deliverytag: {" + _deliverytag + "}");
             trace("redelivered: {" + _redelivered + "}");
             trace("exchange: {" + _exchange + "}");
             trace("routingkey: {" + _routingkey + "}");
         }
    }
