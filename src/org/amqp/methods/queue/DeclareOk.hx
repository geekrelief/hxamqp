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
    class DeclareOk extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var consumercount(getConsumercount, setConsumercount) : Int;
         public var messagecount(getMessagecount, setMessagecount) : Int;
         public var queue(getQueue, setQueue) : String;
         public function new() {
         _queue = "";
         _messagecount = 0;
         _consumercount = 0;
         }
         
         var _queue:String ;
         var _messagecount:Int ;
         var _consumercount:Int ;

         public function getQueue():String{return _queue;}
         public function getMessagecount():Int{return _messagecount;}
         public function getConsumercount():Int{return _consumercount;}

         public function setQueue(x:String):String{_queue = x;	return x;}
         public function setMessagecount(x:Int):Int{_messagecount = x;	return x;}
         public function setConsumercount(x:Int):Int{_consumercount = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }


         public override function isBottomHalf():Bool {
             return true;
         }

         public override function getClassId():Int{
             return 50;
         }

         public override function getMethodId():Int{
             return 11;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShortstr(_queue);
             writer.writeLong(_messagecount);
             writer.writeLong(_consumercount);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _queue = reader.readShortstr();
             _messagecount = reader.readLong();
             _consumercount = reader.readLong();
         }

         public function dump():Void {
             trace("-------- queue.DeclareOk --------");
             trace("queue: {" + _queue + "}");
             trace("messagecount: {" + _messagecount + "}");
             trace("consumercount: {" + _consumercount + "}");
         }
    }
