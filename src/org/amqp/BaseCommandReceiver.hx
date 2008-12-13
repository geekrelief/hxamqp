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
    import flash.events.EventDispatcher;
    #elseif neko
    import org.amqp.events.EventDispatcher;
    #end

    class BaseCommandReceiver implements CommandReceiver {
        var dispatcher:EventDispatcher ;
        var session:Session;

        public function new(){ dispatcher = new EventDispatcher(); }

        public function registerWithSession(s:Session):Void {
            session = s;
        }

        public function forceClose():Void{}

        public function closeGracefully():Void{}

        public function addEventListener(method:Method, fun:Dynamic):Void {
            dispatcher.addEventListener(ProtocolEvent.eventType(method), fun);
        }

        public function removeEventListener(method:Method, fun:Dynamic):Void {
            dispatcher.removeEventListener(ProtocolEvent.eventType(method), fun);
        }

        public function receive(cmd:Command):Void {
        //trace("receive command method "+cmd.method);
            dispatcher.dispatchEvent(new ProtocolEvent(cmd));
        }
    }
