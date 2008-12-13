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
    class Qos extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var global(getGlobal, setGlobal) : Bool;
         public var prefetchcount(getPrefetchcount, setPrefetchcount) : Int;
         public var prefetchsize(getPrefetchsize, setPrefetchsize) : Int;
         public function new() {
         _prefetchsize = 0;
         _prefetchcount = 0;
         _global = false;
         }
         
         var _prefetchsize:Int ;
         var _prefetchcount:Int ;
         var _global:Bool ;

         public function getPrefetchsize():Int{return _prefetchsize;}
         public function getPrefetchcount():Int{return _prefetchcount;}
         public function getGlobal():Bool{return _global;}

         public function setPrefetchsize(x:Int):Int{_prefetchsize = x;	return x;}
         public function setPrefetchcount(x:Int):Int{_prefetchcount = x;	return x;}
         public function setGlobal(x:Bool):Bool{_global = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new QosOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 60;
         }

         public override function getMethodId():Int{
             return 10;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLong(_prefetchsize);
             writer.writeShort(_prefetchcount);
             writer.writeBit(_global);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _prefetchsize = reader.readLong();
             _prefetchcount = reader.readShort();
             _global = reader.readBit();
         }

         public function dump():Void {
             trace("-------- basic.Qos --------");
             trace("prefetchsize: {" + _prefetchsize + "}");
             trace("prefetchcount: {" + _prefetchcount + "}");
             trace("global: {" + _global + "}");
         }
    }
