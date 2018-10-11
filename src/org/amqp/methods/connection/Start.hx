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

    class Start extends Method implements ArgumentReader implements ArgumentWriter {
         public var locales : LongString;
         public var mechanisms : LongString;
         public var serverproperties : haxe.ds.StringMap<Dynamic>;
         public var versionmajor : Int;
         public var versionminor : Int;

         public function new() {
             super();
             versionmajor = 0;
             versionminor = 0;
             serverproperties = new haxe.ds.StringMap();
             mechanisms = new ByteArrayLongString();
             locales = new ByteArrayLongString();

             hasResponse = true;
             classId = 10;
             methodId = 10;
         }
         
         public override function getResponse():Method {
             return new StartOk();
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeOctet(versionmajor);
             writer.writeOctet(versionminor);
             writer.writeTable(serverproperties);
             writer.writeLongstr(mechanisms);
             writer.writeLongstr(locales);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             versionmajor = reader.readOctet();
             versionminor = reader.readOctet();
             serverproperties = reader.readTable();
             mechanisms = reader.readLongstr();
             locales = reader.readLongstr();
         }

    }
