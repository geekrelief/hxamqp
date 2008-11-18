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
    class Reject extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var deliverytag(getDeliverytag, setDeliverytag) : UInt;
         public var requeue(getRequeue, setRequeue) : Bool;
         public function new() {
         _deliverytag = 0;
         _requeue = false;
         }
         
         var _deliverytag:UInt ;
         var _requeue:Bool ;

         public function getDeliverytag():UInt{return _deliverytag;}
         public function getRequeue():Bool{return _requeue;}

         public function setDeliverytag(x:UInt):UInt{_deliverytag = x;	return x;}
         public function setRequeue(x:Bool):Bool{_requeue = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }


         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 90;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLonglong(_deliverytag);
             writer.writeBit(_requeue);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _deliverytag = reader.readLonglong();
             _requeue = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Reject --------");
             trace("deliverytag: {" + _deliverytag + "}");
             trace("requeue: {" + _requeue + "}");
         }
    }
