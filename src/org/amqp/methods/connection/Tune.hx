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
package org.amqp.methods.connection;

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
    class Tune extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var channelmax(getChannelmax, setChannelmax) : Int;
         public var framemax(getFramemax, setFramemax) : Int;
         public var heartbeat(getHeartbeat, setHeartbeat) : Int;
         public function new() {
         _channelmax = 0;
         _framemax = 0;
         _heartbeat = 0;
         }
         
         var _channelmax:Int ;
         var _framemax:Int ;
         var _heartbeat:Int ;

         public function getChannelmax():Int{return _channelmax;}
         public function getFramemax():Int{return _framemax;}
         public function getHeartbeat():Int{return _heartbeat;}

         public function setChannelmax(x:Int):Int{_channelmax = x;	return x;}
         public function setFramemax(x:Int):Int{_framemax = x;	return x;}
         public function setHeartbeat(x:Int):Int{_heartbeat = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new TuneOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 10;
         }

         public override function getMethodId():Int{
             return 30;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_channelmax);
             writer.writeLong(_framemax);
             writer.writeShort(_heartbeat);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _channelmax = reader.readShort();
             _framemax = reader.readLong();
             _heartbeat = reader.readShort();
         }

         public function dump():Void {
             trace("-------- connection.Tune --------");
             trace("channelmax: {" + _channelmax + "}");
             trace("framemax: {" + _framemax + "}");
             trace("heartbeat: {" + _heartbeat + "}");
         }
    }
