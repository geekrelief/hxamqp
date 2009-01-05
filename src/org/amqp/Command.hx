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
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.ByteArray;
    #elseif neko
    import haxe.io.Input;
    import haxe.io.Output;
    import haxe.io.Bytes;
    import haxe.io.BytesOutput;
    import haxe.io.BytesInput;
    #end

    import org.amqp.headers.ContentHeader;
    import org.amqp.methods.MethodArgumentWriter;
    import org.amqp.headers.ContentHeaderReader;
    import org.amqp.methods.MethodReader;
    import org.amqp.error.UnexpectedFrameError;

    /**
     * EMPTY_CONTENT_BODY_FRAME_SIZE, 8 = 1 + 2 + 4 + 1
     * - 1 byte of frame type
     * - 2 bytes of channel number
     * - 4 bytes of frame payload length
     * - 1 byte of payload trailer FRAME_END byte
     *
     **/
    class Command {
        inline public static var STATE_EXPECTING_METHOD:Int = 0;
        inline public static var STATE_EXPECTING_CONTENT_HEADER:Int = 1;
        inline public static var STATE_EXPECTING_CONTENT_BODY:Int = 2;
        inline public static var STATE_COMPLETE:Int = 3;
        inline public static var EMPTY_CONTENT_BODY_FRAME_SIZE:Int = 8;
        #if flash9
        public static var EMPTY_BYTE_ARRAY:ByteArray = new ByteArray();
        #elseif neko
        public static var EMPTY_BYTE_ARRAY:Bytes = Bytes.alloc(0);
        #end

        var state:Int;
        public var method:Method;
        public var contentHeader:ContentHeader;
        var remainingBodyBytes:Int;
        #if flash9
        public var content:ByteArray;
        #elseif neko
        public var content:BytesOutput;
        #end

        public var priority:Int;

        #if flash9
        public function new(?m:Method = null, ?c:ContentHeader = null, ?b:ByteArray = null) {
        #elseif neko
        public function new(?m:Method = null, ?c:ContentHeader = null, ?b:Bytes = null) {
        #end
            
            #if flash9
            content = new ByteArray();
            #elseif neko
            content = new BytesOutput(); content.bigEndian = true;
            #end
            method = m;
            contentHeader = c;
			if(b != null){
                #if flash9
                content.writeBytes(b);
                #elseif neko
	            content.write(b);
                #end
            }
            state = (m == null) ? STATE_EXPECTING_METHOD : STATE_COMPLETE;
            priority = (m == null) ? -1 : (m.getClassId() * 100 + m.getMethodId() ) * -1;
            remainingBodyBytes = 0;
        }

        public function isComplete():Bool {
            return this.state == STATE_COMPLETE;
        }

        /**
         * Chops the content of this command into frames and dispatches
         * it to the underlying transport mechanism.
         **/
        public function transmit(channelNumber:Int, connection:Connection):Void {
            //trace("transmit channel "+channelNumber+" method: "+method);

            if (method.getClassId() < 0 || method.getMethodId() < 0) {
                throw new Error("Method not implemented properly " + method);
            }

            var f:Frame = new Frame();
            f.type = AMQP.FRAME_METHOD;
            f.channel = channelNumber;

            var bodyOut = f.getOutputStream();
            #if flash9
            bodyOut.writeShort(method.getClassId());
            bodyOut.writeShort(method.getMethodId());
            #elseif neko
            bodyOut.writeUInt16(method.getClassId());
            bodyOut.writeUInt16(method.getMethodId());
            #end
            var argWriter:MethodArgumentWriter = new MethodArgumentWriter(bodyOut);
            method.writeArgumentsTo(argWriter);
            argWriter.flush();
            connection.sendFrame(f);

            if (this.method.hasContent()) {

                f = new Frame();
                f.type = AMQP.FRAME_HEADER;
                f.channel = channelNumber;
                bodyOut = f.getOutputStream();
                #if flash9
                bodyOut.writeShort(contentHeader.getClassId());
                #elseif neko
                bodyOut.writeUInt16(contentHeader.getClassId());
                #end
                contentHeader.writeTo(bodyOut, content.length);
                connection.sendFrame(f);

                var frameMax:Int = connection.frameMax;
                var bodyPayloadMax:Int =
                    (frameMax == 0) ? content.length : frameMax - EMPTY_CONTENT_BODY_FRAME_SIZE;
                //trace("bodyPayloadMax "+bodyPayloadMax);

                var offset:Int = 0;
                #if flash9
                var cb = content;
                #elseif neko
                var cb = content.getBytes();
                #end
                var i = 0;
                while (offset < cb.length) {
                    var remaining:Int = cb.length - offset;
                    //trace("sending : "+ ((remaining < bodyPayloadMax) ? remaining : bodyPayloadMax));
                    f = new Frame();
                    f.type = AMQP.FRAME_BODY;
                    f.channel = channelNumber;
                    bodyOut = f.getOutputStream();
                    bodyOut.writeBytes(cb, offset,
                                  (remaining < bodyPayloadMax) ? remaining : bodyPayloadMax);
                    connection.sendFrame(f);
                    offset += bodyPayloadMax;
                    ++i;
                }
                //trace("sent "+i+" frames");
            }
        }

        public function handleFrame(frame:Frame):Void {
            switch (this.state) {
              case STATE_EXPECTING_METHOD:
                  switch (frame.type) {
                    case AMQP.FRAME_METHOD: {
                        this.method = MethodReader.readMethodFrom(frame.getInputStream());
                        this.state = this.method.hasContent()
                            ? STATE_EXPECTING_CONTENT_HEADER
                            : STATE_COMPLETE;
                        return;
                    }
                    default: {
                        throw new UnexpectedFrameError("State: STATE_EXPECTING_METHOD", frame);
                    }
                  }

              case STATE_EXPECTING_CONTENT_HEADER:
                  switch (frame.type) {
                    case AMQP.FRAME_HEADER: {
                        var input = frame.getInputStream();
                        this.contentHeader = ContentHeaderReader.readContentHeaderFrom(input);
                        this.remainingBodyBytes = this.contentHeader.readFrom(input);
                        updateContentBodyState();
                        return;
                    }
                    default: throw new Error("Unexpected frame");
                  }

              case STATE_EXPECTING_CONTENT_BODY:
                  switch (frame.type) {
                    case AMQP.FRAME_BODY: {

                        var fragment = frame.getPayload();
                        this.remainingBodyBytes -= fragment.length;
                        updateContentBodyState();
                        if (this.remainingBodyBytes < 0) {
                            throw new Error("%%%%%% FIXME unimplemented");
                        }
                        #if flash9
                        content.writeBytes(fragment);
                        #elseif neko
                        content.write(fragment);
                        #end
                        return;
                    }
                    default: throw new Error("Unexpected frame");
                  }

              default:
                  throw new Error("Bad Command State " + this.state);
            }

        }

        public function updateContentBodyState():Void {
            this.state = (this.remainingBodyBytes > 0)
                ? STATE_EXPECTING_CONTENT_BODY
                : STATE_COMPLETE;
        }
    }
