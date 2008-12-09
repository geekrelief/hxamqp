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
    class Ack extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var deliverytag(getDeliverytag, setDeliverytag) : Float;
         public var multiple(getMultiple, setMultiple) : Bool;

         public function new() {
	         _deliverytag = 0;
	         _multiple = false;
         }
         
         var _deliverytag:Float ;
         var _multiple:Bool ;

         public function getDeliverytag():Float{return _deliverytag;}
         public function getMultiple():Bool{return _multiple;}

         public function setDeliverytag(x:Float):Float{_deliverytag = x;	return x;}
         public function setMultiple(x:Bool):Bool{_multiple = x;	return x;}

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
             return 80;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLonglong(_deliverytag);
             writer.writeBit(_multiple);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _deliverytag = reader.readLonglong();
             _multiple = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Ack --------");
             trace("deliverytag: {" + _deliverytag + "}");
             trace("multiple: {" + _multiple + "}");
         }
    }
