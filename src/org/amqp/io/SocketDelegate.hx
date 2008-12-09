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
package org.amqp.io;

    import neko.net.Socket;
    import haxe.io.Input;
    import haxe.io.Output;

    import org.amqp.ConnectionParameters;
    import org.amqp.IODelegate;
    import org.amqp.events.EventDispatcher;
    import org.amqp.events.Event;
    import org.amqp.events.Handler;

    class SocketDelegate extends Socket, implements IODelegate {
        var dispatcher:EventDispatcher;
        
        public function new()
        {
            super();
            dispatcher = new EventDispatcher();
        }

        public function isConnected():Bool {
            try {
                super.peer();
            } catch (err: Dynamic) {
                return false;
            }
            return true;
        }

        public function open(params:ConnectionParameters):Void {
            connect(new neko.net.Host(params.serverhost), params.port);
            trace("open "+peer());
        }


        public function addEventListener(type:String, h:Handler):Void {
            dispatcher.addEventListener(type, h);
        }

        public function removeEventListener(type:String, h:Handler):Void {
            dispatcher.removeEventListener(type, h);
        }

        public function dispatchEvent(e:Event):Void {
            dispatcher.dispatchEvent(e);
        }

        public function getInput():Input {
            input.bigEndian = true;
            return input;
        }

        public function getOutput():Output {
            output.bigEndian = true;
            return output;
        }
    }
