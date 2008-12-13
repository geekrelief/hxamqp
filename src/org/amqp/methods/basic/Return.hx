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
    class Return extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var exchange(getExchange, setExchange) : String;
         public var replycode(getReplycode, setReplycode) : Int;
         public var replytext(getReplytext, setReplytext) : String;
         public var routingkey(getRoutingkey, setRoutingkey) : String;
         public function new() {
         _replycode = 0;
         _replytext = "";
         _exchange = "";
         _routingkey = "";
         }
         
         var _replycode:Int ;
         var _replytext:String ;
         var _exchange:String ;
         var _routingkey:String ;

         public function getReplycode():Int{return _replycode;}
         public function getReplytext():String{return _replytext;}
         public function getExchange():String{return _exchange;}
         public function getRoutingkey():String{return _routingkey;}

         public function setReplycode(x:Int):Int{_replycode = x;	return x;}
         public function setReplytext(x:String):String{_replytext = x;	return x;}
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
             return 50;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_replycode);
             writer.writeShortstr(_replytext);
             writer.writeShortstr(_exchange);
             writer.writeShortstr(_routingkey);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _replycode = reader.readShort();
             _replytext = reader.readShortstr();
             _exchange = reader.readShortstr();
             _routingkey = reader.readShortstr();
         }

         public function dump():Void {
             trace("-------- basic.Return --------");
             trace("replycode: {" + _replycode + "}");
             trace("replytext: {" + _replytext + "}");
             trace("exchange: {" + _exchange + "}");
             trace("routingkey: {" + _routingkey + "}");
         }
    }
