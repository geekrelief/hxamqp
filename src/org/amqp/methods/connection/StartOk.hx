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
    import flash.utils.ByteArray;

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class StartOk extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var clientproperties(getClientproperties, setClientproperties) : Hash<Dynamic>;
         public var locale(getLocale, setLocale) : String;
         public var mechanism(getMechanism, setMechanism) : String;
         public var response(_getResponse, setResponse) : LongString;
         public function new() {
         _clientproperties = new Hash();
         _mechanism = "";
         _response = new ByteArrayLongString(new ByteArray());
         _locale = "";
         }
         
         var _clientproperties:Hash<Dynamic> ;
         var _mechanism:String ;
         var _response:LongString ;
         var _locale:String ;

         public function getClientproperties():Hash<Dynamic>{return _clientproperties;}
         public function getMechanism():String{return _mechanism;}
         public function _getResponse():LongString{return _response;}
         public function getLocale():String{return _locale;}

         public function setClientproperties(x:Hash<Dynamic>):Hash<Dynamic>{_clientproperties = x;	return x;}
         public function setMechanism(x:String):String{_mechanism = x;	return x;}
         public function setResponse(x:LongString):LongString{_response = x;	return x;}
         public function setLocale(x:String):String{_locale = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }


         public override function isBottomHalf():Bool {
             return true;
         }

         public override function getClassId():Int{
             return 10;
         }

         public override function getMethodId():Int{
             return 11;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeTable(_clientproperties);
             writer.writeShortstr(_mechanism);
             writer.writeLongstr(_response);
             writer.writeShortstr(_locale);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _clientproperties = reader.readTable();
             _mechanism = reader.readShortstr();
             _response = reader.readLongstr();
             _locale = reader.readShortstr();
         }

         public function dump():Void {
             trace("-------- connection.StartOk --------");
             trace("clientproperties: {" + _clientproperties + "}");
             trace("mechanism: {" + _mechanism + "}");
             trace("response: {" + _response + "}");
             trace("locale: {" + _locale + "}");
         }
    }
