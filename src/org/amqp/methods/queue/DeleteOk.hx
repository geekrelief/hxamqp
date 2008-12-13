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
    class DeleteOk extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var messagecount(getMessagecount, setMessagecount) : Int;
         public function new() {
         _messagecount = 0;
         }
         
         var _messagecount:Int ;

         public function getMessagecount():Int{return _messagecount;}

         public function setMessagecount(x:Int):Int{_messagecount = x;	return x;}

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
             return 41;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLong(_messagecount);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _messagecount = reader.readLong();
         }

         public function dump():Void {
             trace("-------- queue.DeleteOk --------");
             trace("messagecount: {" + _messagecount + "}");
         }
    }
