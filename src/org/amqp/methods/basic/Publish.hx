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
    class Publish extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var exchange(getExchange, setExchange) : String;
         public var immediate(getImmediate, setImmediate) : Bool;
         public var mandatory(getMandatory, setMandatory) : Bool;
         public var routingkey(getRoutingkey, setRoutingkey) : String;
         public var ticket(getTicket, setTicket) : Int;
         public function new() {
         _ticket = 0;
         _exchange = "";
         _routingkey = "";
         _mandatory = false;
         _immediate = false;
         }
         
         var _ticket:Int ;
         var _exchange:String ;
         var _routingkey:String ;
         var _mandatory:Bool ;
         var _immediate:Bool ;

         public function getTicket():Int{return _ticket;}
         public function getExchange():String{return _exchange;}
         public function getRoutingkey():String{return _routingkey;}
         public function getMandatory():Bool{return _mandatory;}
         public function getImmediate():Bool{return _immediate;}

         public function setTicket(x:Int):Int{_ticket = x;	return x;}
         public function setExchange(x:String):String{_exchange = x;	return x;}
         public function setRoutingkey(x:String):String{_routingkey = x;	return x;}
         public function setMandatory(x:Bool):Bool{_mandatory = x;	return x;}
         public function setImmediate(x:Bool):Bool{_immediate = x;	return x;}

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
             return 40;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_ticket);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_routingkey);
             writer.writeBit(_mandatory);
             writer.writeBit(_immediate);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _ticket = reader.readShort();
             _exchange = reader.readShortstr();
             _routingkey = reader.readShortstr();
             _mandatory = reader.readBit();
             _immediate = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Publish --------");
             trace("ticket: {" + _ticket + "}");
             trace("exchange: {" + _exchange + "}");
             trace("routingkey: {" + _routingkey + "}");
             trace("mandatory: {" + _mandatory + "}");
             trace("immediate: {" + _immediate + "}");
         }
    }
