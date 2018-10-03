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
    import org.amqp.methods.ArgumentReader;
    import org.amqp.methods.ArgumentWriter;
    import org.amqp.methods.MethodArgumentReader;
    import org.amqp.methods.MethodArgumentWriter;

    class Get extends Method implements ArgumentReader implements ArgumentWriter {
         public var noack : Bool;
         public var queue : String;
         public var ticket : Int;

         public function new() {
             super();
             ticket = 0;
             queue = "";
             noack = false;
             hasResponse = true;
             classId = 60;
             methodId = 70;
         }
         
         public override function getResponse():Method {
             return new GetOk();
         }
         public override function getAltResponse():Method {
             return new GetEmpty();
         }

         public override function writeArgumentsTo(writer:MethodArgumentWriter):Void {
             writer.writeShort(ticket);
             writer.writeShortstr(queue);
             writer.writeBit(noack);
         }

         public override function readArgumentsFrom(reader:MethodArgumentReader):Void {
             ticket = reader.readShort();
             queue = reader.readShortstr();
             noack = reader.readBit();
         }
    }
