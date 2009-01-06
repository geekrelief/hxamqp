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
    import flash.Vector;
    import flash.utils.ByteArray;
    #elseif neko
    import org.amqp.Error;
    import neko.vm.Thread;
    import org.amqp.SMessage;
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

        #if flash9
        public var recs:Vector<Frame>;
        public var receiving:Bool;
        public var frameBuffer:ByteArray;
        #end

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

            recs = new Vector();
            receiving = false;
            frameBuffer = new ByteArray();
            frameBuffer.position = 0;
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
        public function onSocketData(event:ProgressEvent):Void {
            try{ 
                delegate.readBytes(frameBuffer, frameBuffer.position + frameBuffer.bytesAvailable, delegate.bytesAvailable); 
                
                var frame:Frame = null;
                do {
                    frame = parseFrame(frameBuffer);
                    if(frame != null) {
                        if (frame.type == AMQP.FRAME_HEARTBEAT) {
                            // just ignore this for now
                        } else if (frame.channel == 0) {
                            session0.handleFrame(frame);
                        } else {
                            var session:Session = sessionManager.lookup(frame.channel);
                            session.handleFrame(frame);
                        }
                    }
                } while(frameBuffer.bytesAvailable > 0 && frame != null);
                
                if(frameBuffer.bytesAvailable < frameBuffer.length) {
                    //trace("truncate the frameBuffer available: "+frameBuffer.bytesAvailable+" length: "+frameBuffer.length);
                    var b = frameBuffer;
                    frameBuffer = new ByteArray();
                    b.readBytes(frameBuffer, 0, b.bytesAvailable);
                }
            } catch (err:Dynamic) {
                if(Std.is(err, haxe.io.Eof)) {
                    trace("end of stream");
                } else {
                    throw (err+" this should be logged and reported!");
                }
            }
        }
        #elseif neko
        // neko does not have asynch i/o, instead spawn a thread for reading and writing to the socket
        // reading and writing to the socket is controlled by the socketLoop
        public function socketLoop(mt:Thread):Void {
            var idt = Thread.create(callback(incomingData, Thread.current())); // incoming data detector
            var msg:SMessage;
            try{
                while (true) {
                    msg = neko.vm.Thread.readMessage(true);
                    switch(msg) {
                        case SRpc(s, cmd, fun): s.rpc(cmd, fun);
                        case SDispatch(s, cmd): s.dispatch(cmd);
                        case SRegister(s, c, b): s.register(c, b);
                        case SSetReturn(s, r): s.setReturn(r);
                        case SClose: close();
                        case SData: onSocketData(); idt.sendMessage(true);
                        default:
                    }
                }
            } catch (err:Dynamic) {
                if(Std.is(err, haxe.io.Eof)) {
                    trace("end of stream"); // probably from SClose
                } else {
                    trace(err+" this should be logged and reported!");
                    throw (err+" this should be logged and reported!");
                }
            }

            mt.sendMessage("close");
        }

        // notifies the socket loop of incoming data
        public function incomingData(ct:Thread):Void {
            var s = cast(delegate, neko.net.Socket);
            while(true) {
                s.waitForRead();
                ct.sendMessage(SData);
                Thread.readMessage(true);
            }
        }

        public function onSocketData():Void {
            var frame:Frame = parseFrame(delegate);
        
            if (frame != null) {
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
        }
        #end
        
        #if flash9
        function parseFrame(b:ByteArray):Frame {
            var frame:Frame = new Frame();
            return frame.readFrom(b) ? frame : null;
        }
        #elseif neko
        function parseFrame(delegate:IODelegate):Frame {
            var frame:Frame = new Frame();
            return frame.readFrom(delegate.getInput()) ? frame : null;
        }
        #end

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

