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
    class Start extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var locales(getLocales, setLocales) : LongString;
         public var mechanisms(getMechanisms, setMechanisms) : LongString;
         public var serverproperties(getServerproperties, setServerproperties) : Hash<Dynamic>;
         public var versionmajor(getVersionmajor, setVersionmajor) : Int;
         public var versionminor(getVersionminor, setVersionminor) : Int;
         public function new() {
         _versionmajor = 0;
         _versionminor = 0;
         _serverproperties = new Hash();
         _mechanisms = new ByteArrayLongString(new ByteArray());
         _locales = new ByteArrayLongString(new ByteArray());
         }
         
         var _versionmajor:Int ;
         var _versionminor:Int ;
         var _serverproperties:Hash<Dynamic> ;
         var _mechanisms:LongString ;
         var _locales:LongString ;

         public function getVersionmajor():Int{return _versionmajor;}
         public function getVersionminor():Int{return _versionminor;}
         public function getServerproperties():Hash<Dynamic>{return _serverproperties;}
         public function getMechanisms():LongString{return _mechanisms;}
         public function getLocales():LongString{return _locales;}

         public function setVersionmajor(x:Int):Int{_versionmajor = x;	return x;}
         public function setVersionminor(x:Int):Int{_versionminor = x;	return x;}
         public function setServerproperties(x:Hash<Dynamic>):Hash<Dynamic>{_serverproperties = x;	return x;}
         public function setMechanisms(x:LongString):LongString{_mechanisms = x;	return x;}
         public function setLocales(x:LongString):LongString{_locales = x;	return x;}

         public override function hasResponse():Bool {
             return null != getResponse();
         }

         public override function getResponse():Method {
             return new StartOk();
         }

         public override function isBottomHalf():Bool {
             return false;
         }

         public override function getClassId():Int{
             return 10;
         }

         public override function getMethodId():Int{
             return 10;
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeOctet(_versionmajor);
             writer.writeOctet(_versionminor);
             writer.writeTable(_serverproperties);
             writer.writeLongstr(_mechanisms);
             writer.writeLongstr(_locales);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             _versionmajor = reader.readOctet();
             _versionminor = reader.readOctet();
             _serverproperties = reader.readTable();
             _mechanisms = reader.readLongstr();
             _locales = reader.readLongstr();
         }

         public function dump():Void {
             trace("-------- connection.Start --------");
             trace("versionmajor: {" + _versionmajor + "}");
             trace("versionminor: {" + _versionminor + "}");
             trace("serverproperties: {" + _serverproperties + "}");
             trace("mechanisms: {" + _mechanisms + "}");
             trace("locales: {" + _locales + "}");
         }
    }
