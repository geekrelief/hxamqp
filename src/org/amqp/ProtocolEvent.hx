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
package org.amqp;

    #if flash9
    import flash.events.Event;
    #elseif neko
    import org.amqp.events.Event;
    #end

    class ProtocolEvent extends Event {
        public var command:Command;

        public function new(cmd:Command)
        {
            super(eventType(cmd.method));
            command = cmd;
        }

        public static function eventType(method:Method):String {
            return method.classId + "" + method.methodId;
        }

    }
