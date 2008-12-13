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
    class Consume extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var consumertag(getConsumertag, setConsumertag) : String;
         public var exclusive(getExclusive, setExclusive) : Bool;
         public var noack(getNoack, setNoack) : Bool;
         public var nolocal(getNolocal, setNolocal) : Bool;
         public var nowait(getNowait, setNowait) : Bool;
         public var queue(getQueue, setQueue) : String;
         public var ticket(getTicket, setTicket) : Int;
         public function new() {
         _ticket = 0;
         _queue = "";
         _consumertag = "";
         _nolocal = false;
         _noack = false;
         _exclusive = false;
         _nowait = false;
         }
         
         var _ticket:Int ;
         var _queue:String ;
         var _consumertag:String ;
         var _nolocal:Bool ;
         var _noack:Bool ;
         var _exclusive:Bool ;
         var _nowait:Bool ;

         public function getTicket():Int{return _ticket;}
         public function getQueue():String{return _queue;}
         public function getConsumertag():String{return _consumertag;}
         public function getNolocal():Bool{return _nolocal;}
         public function getNoack():Bool{return _noack;}
         public function getExclusive():Bool{return _exclusive;}
         public function getNowait():Bool{return _nowait;}

         public function setTicket(x:Int):Int{_ticket = x;	return x;}
         public function setQueue(x:String):String{_queue = x;	return x;}
         public function setConsumertag(x:String):String{_consumertag = x;	return x;}
         public function setNolocal(x:Bool):Bool{_nolocal = x;	return x;}
         public function setNoack(x:Bool):Bool{_noack = x;	return x;}
         public function setExclusive(x:Bool):Bool{_exclusive = x;	return x;}
         public function setNowait(x:Bool):Bool{_nowait = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new ConsumeOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 20;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_ticket);
             writer.writeShortstr(_queue);
             writer.writeShortstr(_consumertag);
             writer.writeBit(_nolocal);
             writer.writeBit(_noack);
             writer.writeBit(_exclusive);
             writer.writeBit(_nowait);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _ticket = reader.readShort();
             _queue = reader.readShortstr();
             _consumertag = reader.readShortstr();
             _nolocal = reader.readBit();
             _noack = reader.readBit();
             _exclusive = reader.readBit();
             _nowait = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Consume --------");
             trace("ticket: {" + _ticket + "}");
             trace("queue: {" + _queue + "}");
             trace("consumertag: {" + _consumertag + "}");
             trace("nolocal: {" + _nolocal + "}");
             trace("noack: {" + _noack + "}");
             trace("exclusive: {" + _exclusive + "}");
             trace("nowait: {" + _nowait + "}");
         }
    }
