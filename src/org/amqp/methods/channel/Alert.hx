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
package org.amqp.methods.channel;

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
    class Alert extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var details(getDetails, setDetails) : Hash<Dynamic>;
         public var replycode(getReplycode, setReplycode) : Int;
         public var replytext(getReplytext, setReplytext) : String;
         public function new() {
         _replycode = 0;
         _replytext = "";
         _details = new Hash();
         }
         
         var _replycode:Int ;
         var _replytext:String ;
         var _details:Hash<Dynamic> ;

         public function getReplycode():Int{return _replycode;}
         public function getReplytext():String{return _replytext;}
         public function getDetails():Hash<Dynamic>{return _details;}

         public function setReplycode(x:Int):Int{_replycode = x;	return x;}
         public function setReplytext(x:String):String{_replytext = x;	return x;}
         public function setDetails(x:Hash<Dynamic>):Hash<Dynamic>{_details = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }


         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 20;
         }

         public override function getMethodId():Int{
             return 30;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(_replycode);
             writer.writeShortstr(_replytext);
             writer.writeTable(_details);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _replycode = reader.readShort();
             _replytext = reader.readShortstr();
             _details = reader.readTable();
         }

         public function dump():Void {
             trace("-------- channel.Alert --------");
             trace("replycode: {" + _replycode + "}");
             trace("replytext: {" + _replytext + "}");
             trace("details: {" + _details + "}");
         }
    }
