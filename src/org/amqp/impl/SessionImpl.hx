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
package org.amqp.impl;

    import flash.events.EventDispatcher;

    import org.amqp.Command;
    import org.amqp.CommandReceiver;
    import org.amqp.Connection;
    import org.amqp.Frame;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.Method;
    import org.amqp.Session;

	typedef Rpc = {
		var command:Command; 
		var _callback:Dynamic;
	}

    class SessionImpl implements Session {
        //var QUEUE_SIZE:Int ;

        var connection:Connection;
        var channel:Int;
        var commandReceiver:CommandReceiver;
        var currentCommand:Command;

        var dispatcher:EventDispatcher ;

        /**
        * I'm not too happy about this new RPC queue - the whole queueing
        * thing needs a complete refactoring so that RPCs are executed serially
        * but also so that different intra-class RPC order is guaranteed.
        */
        //protected var rpcQueue:PriorityQueue = new PriorityQueue(QUEUE_SIZE);
        var rpcQueue:List<Rpc> ;

        var lifecycleHandlers:Array<LifecycleEventHandler> ;

        public function new(con:Connection, ch:Int, receiver:CommandReceiver) {
            
            //QUEUE_SIZE = 100;
            dispatcher = new EventDispatcher();
            rpcQueue = new List();
            lifecycleHandlers = new Array();
            connection = con;
            channel = ch;
            commandReceiver = receiver;
        }

        public function handleFrame(frame:Frame):Void {
            if (currentCommand == null) {
                currentCommand = new Command();
            }
            currentCommand.handleFrame(frame);
            if (currentCommand.isComplete()) {
                /**
                * The idea is that this _callback will always be invoked when a command is
                * to be processed by the session handler, so it can kick off the dequeuing
                * of any pending RPCs in addition to dispatching to the target _callback handler,
                * which is implemented in the super class.
                */
                commandReceiver.receive(currentCommand);
                if (currentCommand.method.isBottomHalf()) {
                    rpcBottomHalf();
                }
                currentCommand = new Command();
            }
        }

        public function registerLifecycleHandler(handler:LifecycleEventHandler):Void {
            lifecycleHandlers.push(handler);
        }

        public function emitLifecyleEvent():Void {
            for (i in lifecycleHandlers) {
                i.afterOpen();
            }
        }

        /**
        * The logic behind this is that a non-null fun signifies an RPC,
        * if the fun is null, then it is an asynchronous command.
        */
        public function sendCommand(cmd:Command, ?fun:Dynamic = null):Void {

            if (null != fun) {
                if (rpcQueue.isEmpty()) {
                    send(cmd);
                }
                rpcQueue.add({command:cmd,_callback:fun});
            }
            else {
                send(cmd);
            }
        }

        function send(cmd:Command):Void {
            cmd.transmit(channel, connection);
        }

        public function rpc(cmd:Command, fun:Dynamic):Void {
            var method:Method = cmd.method;
            commandReceiver.addEventListener(method.getResponse(), fun);
            if (null != method.getAltResponse()) {
                commandReceiver.addEventListener(method.getAltResponse(), fun);
            }
            sendCommand(cmd, fun);
            //trace("RPC top half: " + cmd.method);
        }

        function rpcBottomHalf():Void {
            if (!rpcQueue.isEmpty()) {
                rpcQueue.pop();
                if (!rpcQueue.isEmpty()) {
                    var o:Dynamic = rpcQueue.first();
                    //trace("RPC bottom half: " + o.command.method);
                    send(o.command);
                }
            }
        }

        public function closeGracefully():Void {
            commandReceiver.closeGracefully();
        }

        public function forceClose():Void {
            commandReceiver.forceClose();
        }

    }
