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
package org.amqp.methods.queue;

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
    class Bind extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var arguments(getArguments, setArguments) : Hash<Dynamic>;
         public var exchange(getExchange, setExchange) : String;
         public var nowait(getNowait, setNowait) : Bool;
         public var queue(getQueue, setQueue) : String;
         public var routingkey(getRoutingkey, setRoutingkey) : String;
         public var ticket(getTicket, setTicket) : Int;
         public function new() {
         _ticket = 0;
         _queue = "";
         _exchange = "";
         _routingkey = "";
         _nowait = false;
         _arguments = new Hash();
         }
         
         var _ticket:Int ;
         var _queue:String ;
         var _exchange:String ;
         var _routingkey:String ;
         var _nowait:Bool ;
         var _arguments:Hash<Dynamic> ;

         public function getTicket():Int{return _ticket;}
         public function getQueue():String{return _queue;}
         public function getExchange():String{return _exchange;}
         public function getRoutingkey():String{return _routingkey;}
         public function getNowait():Bool{return _nowait;}
         public function getArguments():Hash<Dynamic>{return _arguments;}

         public function setTicket(x:Int):Int{_ticket = x;	return x;}
         public function setQueue(x:String):String{_queue = x;	return x;}
         public function setExchange(x:String):String{_exchange = x;	return x;}
         public function setRoutingkey(x:String):String{_routingkey = x;	return x;}
         public function setNowait(x:Bool):Bool{_nowait = x;	return x;}
         public function setArguments(x:Hash<Dynamic>):Hash<Dynamic>{_arguments = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new BindOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 50;
         }

         public override function getMethodId():Int{
             return 20;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_ticket);
             writer.writeShortstr(_queue);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_routingkey);
             writer.writeBit(_nowait);
             writer.writeTable(_arguments);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _ticket = reader.readShort();
             _queue = reader.readShortstr();
             _exchange = reader.readShortstr();
             _routingkey = reader.readShortstr();
             _nowait = reader.readBit();
             _arguments = reader.readTable();
         }

         public function dump():Void {
             trace("-------- queue.Bind --------");
             trace("ticket: {" + _ticket + "}");
             trace("queue: {" + _queue + "}");
             trace("exchange: {" + _exchange + "}");
             trace("routingkey: {" + _routingkey + "}");
             trace("nowait: {" + _nowait + "}");
             trace("arguments: {" + _arguments + "}");
         }
    }
