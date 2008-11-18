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
    import flash.utils.ByteArray;

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class GetOk extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var deliverytag(getDeliverytag, setDeliverytag) : UInt;
         public var exchange(getExchange, setExchange) : String;
         public var messagecount(getMessagecount, setMessagecount) : Int;
         public var redelivered(getRedelivered, setRedelivered) : Bool;
         public var routingkey(getRoutingkey, setRoutingkey) : String;
         public function new() {
         _deliverytag = 0;
         _redelivered = false;
         _exchange = "";
         _routingkey = "";
         _messagecount = 0;
         }
         
         var _deliverytag:UInt ;
         var _redelivered:Bool ;
         var _exchange:String ;
         var _routingkey:String ;
         var _messagecount:Int ;

         public function getDeliverytag():UInt{return _deliverytag;}
         public function getRedelivered():Bool{return _redelivered;}
         public function getExchange():String{return _exchange;}
         public function getRoutingkey():String{return _routingkey;}
         public function getMessagecount():Int{return _messagecount;}

         public function setDeliverytag(x:UInt):UInt{_deliverytag = x;	return x;}
         public function setRedelivered(x:Bool):Bool{_redelivered = x;	return x;}
         public function setExchange(x:String):String{_exchange = x;	return x;}
         public function setRoutingkey(x:String):String{_routingkey = x;	return x;}
         public function setMessagecount(x:Int):Int{_messagecount = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function hasContent():Bool {
             return true;
         }

         public override function isBottomHalf():Bool {
             return true;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 71;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLonglong(_deliverytag);
             writer.writeBit(_redelivered);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_routingkey);
             writer.writeLong(_messagecount);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _deliverytag = reader.readLonglong();
             _redelivered = reader.readBit();
             _exchange = reader.readShortstr();
             _routingkey = reader.readShortstr();
             _messagecount = reader.readLong();
         }

         public function dump():Void {
             trace("-------- basic.GetOk --------");
             trace("deliverytag: {" + _deliverytag + "}");
             trace("redelivered: {" + _redelivered + "}");
             trace("exchange: {" + _exchange + "}");
             trace("routingkey: {" + _routingkey + "}");
             trace("messagecount: {" + _messagecount + "}");
         }
    }
