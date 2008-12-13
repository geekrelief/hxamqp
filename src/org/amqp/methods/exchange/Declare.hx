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
package org.amqp.methods.exchange;

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
    class Declare extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var Internal(getInternal, setInternal) : Bool;
         public var arguments(getArguments, setArguments) : Hash<Dynamic>;
         public var autodelete(getAutodelete, setAutodelete) : Bool;
         public var durable(getDurable, setDurable) : Bool;
         public var exchange(getExchange, setExchange) : String;
         public var nowait(getNowait, setNowait) : Bool;
         public var passive(getPassive, setPassive) : Bool;
         public var ticket(getTicket, setTicket) : Int;
         public var type(getType, setType) : String;
         public function new() {
         _ticket = 0;
         _exchange = "";
         _type = "";
         _passive = false;
         _durable = false;
         _autodelete = false;
         _Internal = false;
         _nowait = false;
         _arguments = new Hash();
         }
         
         var _ticket:Int ;
         var _exchange:String ;
         var _type:String ;
         var _passive:Bool ;
         var _durable:Bool ;
         var _autodelete:Bool ;
         var _Internal:Bool ;
         var _nowait:Bool ;
         var _arguments:Hash<Dynamic> ;

         public function getTicket():Int{return _ticket;}
         public function getExchange():String{return _exchange;}
         public function getType():String{return _type;}
         public function getPassive():Bool{return _passive;}
         public function getDurable():Bool{return _durable;}
         public function getAutodelete():Bool{return _autodelete;}
         public function getInternal():Bool{return _Internal;}
         public function getNowait():Bool{return _nowait;}
         public function getArguments():Hash<Dynamic>{return _arguments;}

         public function setTicket(x:Int):Int{_ticket = x;	return x;}
         public function setExchange(x:String):String{_exchange = x;	return x;}
         public function setType(x:String):String{_type = x;	return x;}
         public function setPassive(x:Bool):Bool{_passive = x;	return x;}
         public function setDurable(x:Bool):Bool{_durable = x;	return x;}
         public function setAutodelete(x:Bool):Bool{_autodelete = x;	return x;}
         public function setInternal(x:Bool):Bool{_Internal = x;	return x;}
         public function setNowait(x:Bool):Bool{_nowait = x;	return x;}
         public function setArguments(x:Hash<Dynamic>):Hash<Dynamic>{_arguments = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new DeclareOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 40;
         }

         public override function getMethodId():Int{
             return 10;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_ticket);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_type);
             writer.writeBit(_passive);
             writer.writeBit(_durable);
             writer.writeBit(_autodelete);
             writer.writeBit(_Internal);
             writer.writeBit(_nowait);
             writer.writeTable(_arguments);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _ticket = reader.readShort();
             _exchange = reader.readShortstr();
             _type = reader.readShortstr();
             _passive = reader.readBit();
             _durable = reader.readBit();
             _autodelete = reader.readBit();
             _Internal = reader.readBit();
             _nowait = reader.readBit();
             _arguments = reader.readTable();
         }

         public function dump():Void {
             trace("-------- exchange.Declare --------");
             trace("ticket: {" + _ticket + "}");
             trace("exchange: {" + _exchange + "}");
             trace("type: {" + _type + "}");
             trace("passive: {" + _passive + "}");
             trace("durable: {" + _durable + "}");
             trace("autodelete: {" + _autodelete + "}");
             trace("Internal: {" + _Internal + "}");
             trace("nowait: {" + _nowait + "}");
             trace("arguments: {" + _arguments + "}");
         }
    }
