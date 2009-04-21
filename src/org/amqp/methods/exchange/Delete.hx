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

    class Delete extends Method, implements ArgumentReader, implements ArgumentWriter {
         public var exchange : String;
         public var ifunused : Bool;
         public var nowait : Bool;
         public var ticket : Int;

         public function new() {
             super();
             ticket = 0;
             exchange = "";
             ifunused = false;
             nowait = false;
             hasResponse = true;
             classId = 40;
             methodId = 20;
         }
         
         public override function getResponse():Method {
             return new DeleteOk();
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(ticket);
             writer.writeShortstr(exchange);
             writer.writeBit(ifunused);
             writer.writeBit(nowait);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             ticket = reader.readShort();
             exchange = reader.readShortstr();
             ifunused = reader.readBit();
             nowait = reader.readBit();
         }
    }
