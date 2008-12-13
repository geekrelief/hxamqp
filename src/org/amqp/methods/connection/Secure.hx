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
    class Secure extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var challenge(getChallenge, setChallenge) : LongString;
         public function new() {
    	     _challenge = new ByteArrayLongString();
         }
         
         var _challenge:LongString ;

         public function getChallenge():LongString{return _challenge;}

         public function setChallenge(x:LongString):LongString{_challenge = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new SecureOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 10;
         }

         public override function getMethodId():Int{
             return 20;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeLongstr(_challenge);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _challenge = reader.readLongstr();
         }

         public function dump():Void {
             trace("-------- connection.Secure --------");
             trace("challenge: {" + _challenge + "}");
         }
    }
