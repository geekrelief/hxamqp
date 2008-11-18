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
    class Cancel extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var consumertag(getConsumertag, setConsumertag) : String;
         public var nowait(getNowait, setNowait) : Bool;
         public function new() {
			_consumertag = "";
			_nowait = false;
         }
         
         var _consumertag:String ;
         var _nowait:Bool ;

         public function getConsumertag():String{return _consumertag;}
         public function getNowait():Bool{return _nowait;}

         public function setConsumertag(x:String):String{_consumertag = x;	return x;}
         public function setNowait(x:Bool):Bool{_nowait = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new CancelOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 30;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShortstr(_consumertag);
             writer.writeBit(_nowait);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _consumertag = reader.readShortstr();
             _nowait = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Cancel --------");
             trace("consumertag: {" + _consumertag + "}");
             trace("nowait: {" + _nowait + "}");
         }
    }
