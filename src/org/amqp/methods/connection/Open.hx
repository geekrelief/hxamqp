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
    class Open extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var capabilities(getCapabilities, setCapabilities) : String;
         public var insist(getInsist, setInsist) : Bool;
         public var virtualhost(getVirtualhost, setVirtualhost) : String;
         public function new() {
         _virtualhost = "";
         _capabilities = "";
         _insist = false;
         }
         
         var _virtualhost:String ;
         var _capabilities:String ;
         var _insist:Bool ;

         public function getVirtualhost():String{return _virtualhost;}
         public function getCapabilities():String{return _capabilities;}
         public function getInsist():Bool{return _insist;}

         public function setVirtualhost(x:String):String{_virtualhost = x;	return x;}
         public function setCapabilities(x:String):String{_capabilities = x;	return x;}
         public function setInsist(x:Bool):Bool{_insist = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new OpenOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 10;
         }

         public override function getMethodId():Int{
             return 40;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShortstr(_virtualhost);
             writer.writeShortstr(_capabilities);
             writer.writeBit(_insist);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _virtualhost = reader.readShortstr();
             _capabilities = reader.readShortstr();
             _insist = reader.readBit();
         }

         public function dump():Void {
             trace("-------- connection.Open --------");
             trace("virtualhost: {" + _virtualhost + "}");
             trace("capabilities: {" + _capabilities + "}");
             trace("insist: {" + _insist + "}");
         }
    }
