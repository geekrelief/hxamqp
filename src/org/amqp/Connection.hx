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
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    #elseif neko
    import org.amqp.Error;
    import neko.vm.Thread;
    #end

    import haxe.io.Bytes;

    import org.amqp.error.ConnectionError;
    import org.amqp.impl.ConnectionStateHandler;
    import org.amqp.impl.SessionImpl;
    import org.amqp.io.SocketDelegate;

    #if flash9
    // not supporting for now
    //import org.amqp.io.TLSDelegate;
    #end

    import org.amqp.methods.connection.CloseOk;

    class Connection
     {
        public var baseSession(getBaseSession, null) : Session ;
        inline static var CLOSED:Int = 0;
        inline static var CONNECTING:Int = 1;
        inline static var CONNECTED:Int = 2;

        var currentState:Int ;
        var shuttingDown:Bool ;
        var delegate:IODelegate;
        var session0:Session;
        var connectionParams:ConnectionParameters;
        public var sessionManager:SessionManager;
        public var frameMax:Int ;

        public function new(state:ConnectionParameters) {
            
            //trace("new");
            currentState = CLOSED;
            shuttingDown = false;
            frameMax = 0;
            connectionParams = state;

            var stateHandler:ConnectionStateHandler = new ConnectionStateHandler(state);

            session0 = new SessionImpl(this, 0, stateHandler);
            stateHandler.registerWithSession(session0);

            sessionManager = new SessionManager(this);

            if (state.useTLS) {
                #if flash9
                //delegate = new TLSDelegate();
                #end
                throw new Error("TLS not supported at this time");
            } else {
                delegate = new SocketDelegate();
            }

            #if flash9
            delegate.addEventListener(Event.CONNECT, onSocketConnect);
            delegate.addEventListener(Event.CLOSE, onSocketClose);
            delegate.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
            delegate.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
            #end 
        }

        public function getBaseSession():Session {
            return session0;
        }

        public function start():Void {
            if (currentState < CONNECTING) {
                currentState = CONNECTING;
                delegate.open(connectionParams);
                #if neko
				onSocketConnect();
                #end
            }
        }

        public function isConnected():Bool {
            return delegate.isConnected();
        }


        #if flash9
        public function onSocketConnect(event:Event):Void {
        #elseif neko
        public function onSocketConnect():Void {
        #end
            currentState = CONNECTED;
            var header = AMQP.generateHeader();
             #if flash9
            delegate.writeBytes(header, 0, header.length);
            delegate.flush();
            #elseif neko
            delegate.getOutput().write(header);
            delegate.getOutput().flush();
            #end
       }


        #if flash9
        public function onSocketClose(event:Event):Void {
        #elseif neko
        public function onSocketClose():Void {
        #end
            currentState = CLOSED;
            handleForcedShutdown();
        }

        #if flash9
        public function onSocketError(event:Event):Void {
        #elseif neko
        public function onSocketError():Void {
        #end
            currentState = CLOSED;
            delegate.dispatchEvent(new ConnectionError());
        }

        public function close(?reason:Dynamic = null):Void {
            if (!shuttingDown) {
                if (delegate.isConnected()) {
                    handleGracefulShutdown();
                }
                else {
                    handleForcedShutdown();
                }
            }
        }

        /**
         * Socket timeout waiting for a frame. Maybe missed heartbeat.
         **/
        public function handleSocketTimeout():Void {
            handleForcedShutdown();
        }

        function handleForcedShutdown():Void {
            if (!shuttingDown) {
                shuttingDown = true;
                sessionManager.forceClose();
                session0.forceClose();
            }
        }

        function handleGracefulShutdown():Void {
            if (!shuttingDown) {
                //trace("handleGracefulShutdown");
                shuttingDown = true;
                sessionManager.closeGracefully();
                session0.closeGracefully();
                //trace("sessionManager, session0 closed");
            }
        }

        /**
         * This parses frames from the network and hands them to be processed
         * by a frame handler.
         **/
        #if flash9
        public function onSocketData(event:Event):Void {
            try{ while (delegate.isConnected() && delegate.bytesAvailable > 0) {
                var frame:Frame = parseFrame(delegate);
                //maybeSendHeartbeat();
                if (frame != null) {
                    // missedHeartbeats = 0;
                        if (frame.type == AMQP.FRAME_HEARTBEAT) {
                            // just ignore this for now
                        } else if (frame.channel == 0) {
                            session0.handleFrame(frame);
                        } else {
                            var session:Session = sessionManager.lookup(frame.channel);
                            session.handleFrame(frame);
                        }
                } else {
                    handleSocketTimeout();
                }
            } } catch (err:Dynamic) {
                if(Std.is(err, haxe.io.Eof)) {
                    trace("end of stream");
                } else {
                    trace(err+" this should be logged and reported!");
                }
            }
        }
        #elseif neko
        // neko does not have asynch i/o, instead spawn a thread for onSocketData, and send Thread messages
        public function onSocketData(_mainThread:Thread):Void {
            try{ while (true) {
                var select = neko.net.Socket.select([cast(delegate, neko.net.Socket)], [], [], 0.01);
                if(neko.vm.Thread.readMessage(false) == "close") { close();}
                if(select.read.length == 0) continue;

                var frame:Frame = parseFrame(delegate);
                maybeSendHeartbeat();
                if (frame != null) {
                    // missedHeartbeats = 0;
                        if (frame.type == AMQP.FRAME_HEARTBEAT) {
                            // just ignore this for now
                        } else if (frame.channel == 0) {
                            session0.handleFrame(frame);
                        } else {
                            var session:Session = sessionManager.lookup(frame.channel);
                            session.handleFrame(frame);
                        }
                } else {
                    handleSocketTimeout();
                }
            } } catch (err:Dynamic) {
                if(Std.is(err, haxe.io.Eof)) {
                    trace("end of stream");
                } else {
                    trace(err+" this should be logged and reported!");
                }
            }
            _mainThread.sendMessage("close");
        }
        #end

        function parseFrame(delegate:IODelegate):Frame {
            //trace("parseFrame");
            var frame:Frame = new Frame();
            #if flash9
            return frame.readFrom(delegate) ? frame : null;
            #elseif neko
            return frame.readFrom(delegate.getInput()) ? frame : null;
            #end
        }

        public function sendFrame(frame:Frame):Void {
            if (delegate.isConnected()) {
                #if flash9
                frame.writeTo(delegate);
                delegate.flush();
                #elseif neko
                frame.writeTo(delegate.getOutput());
                delegate.getOutput().flush();
                #end
            } else {
                throw new Error("Connection main loop not running");
            }
        }

    #if flash9
        public function addSocketEventListener(type:String, listener:Dynamic):Void {
            delegate.addEventListener(type, listener);
        }

        public function removeSocketEventListener(type:String, listener:Dynamic):Void {
            delegate.removeEventListener(type, listener);
        }
	#end

        function maybeSendHeartbeat():Void {}
    }

