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

    #if flash9
    import flash.net.Socket;
    #else
    import sys.net.Socket;
    import haxe.io.Input;
    import haxe.io.Output;
    #end

    import org.amqp.ConnectionParameters;
    import org.amqp.IODelegate;

    #if neko
    import org.amqp.events.EventDispatcher;
    import org.amqp.events.Event;
    import org.amqp.events.Handler;
    #end

    class SocketDelegate extends Socket implements IODelegate {
        #if flash9
        public function new(?host:String=null, ?port:Int=0){
            super(host, port);
        }
        #else
        var dispatcher:EventDispatcher;
        
        public function new() {
            super();
            dispatcher = new EventDispatcher();
        }
        #end

        public function isConnected():Bool {
            #if flash9
            return connected;
            #else
            try {
                super.peer();
            } catch (err: Dynamic) {
                return false;
            }
            return true;
            #end
        }

        public function open(params:ConnectionParameters):Void {
            #if flash9
            timeout = params.timeout;
            connect(params.serverhost, params.port);
            #else
            connect(new sys.net.Host(params.serverhost), params.port);
            #end
        }

        #if neko
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
        #end
    }
