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
package org.amqp.methods.exchange;

    import org.amqp.Method;
    import org.amqp.methods.ArgumentReader;
    import org.amqp.methods.ArgumentWriter;
    import org.amqp.methods.MethodArgumentReader;
    import org.amqp.methods.MethodArgumentWriter;

    class Declare extends Method implements ArgumentReader implements ArgumentWriter {
         public var Internal : Bool;
         public var arguments : haxe.ds.StringMap<Dynamic>;
         public var autodelete : Bool;
         public var durable : Bool;
         public var exchange : String;
         public var nowait : Bool;
         public var passive : Bool;
         public var ticket : Int;
         public var type : String;

         public function new() {
             super();
             ticket = 0;
             exchange = "";
             type = "";
             passive = false;
             durable = false;
             autodelete = false;
             Internal = false;
             nowait = false;
             arguments = new haxe.ds.StringMap();
             hasResponse = true;
             classId = 40;
             methodId = 10;
         }
         
         public override function getResponse():Method {
             return new DeclareOk();
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(ticket);
             writer.writeShortstr(exchange);
             writer.writeShortstr(type);
             writer.writeBit(passive);
             writer.writeBit(durable);
             writer.writeBit(autodelete);
             writer.writeBit(Internal);
             writer.writeBit(nowait);
             writer.writeTable(arguments);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             ticket = reader.readShort();
             exchange = reader.readShortstr();
             type = reader.readShortstr();
             passive = reader.readBit();
             durable = reader.readBit();
             autodelete = reader.readBit();
             Internal = reader.readBit();
             nowait = reader.readBit();
             arguments = reader.readTable();
         }
    }
