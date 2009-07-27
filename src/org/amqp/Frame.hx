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
    import flash.Error;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    #elseif neko
    import org.amqp.Error;

    import haxe.io.Bytes;
    import haxe.io.BytesInput;
    import haxe.io.BytesOutput;
    import haxe.io.Input;
    import haxe.io.Output;
    #end

    import org.amqp.error.MalformedFrameError;

    class Frame
     {

        public var type:Int;
        public var channel:Int;
        public var payloadSize:UInt;

        #if flash9
        var payload:ByteArray;
        var accumulator:ByteArray;
        #elseif neko
        var payload:BytesOutput;
        var accumulator:BytesOutput;
        #end

        public function new() {
            #if flash9
            payload = new ByteArray();
            accumulator = new ByteArray();
            #elseif neko
            payload = new BytesOutput(); payload.bigEndian = true;
            accumulator = new BytesOutput(); accumulator.bigEndian = true;
            #end
        }

        #if flash9
        inline public function bufferCheck(buffer:ByteArray, len:UInt) {
            return (buffer.bytesAvailable >= len);
        }

        public function readFrom(input:ByteArray):Bool {
        #elseif neko
        public function readFrom(input:Input):Bool {
        #end

            //trace("readFrom");
            #if flash9
            // check if there's enough in the buffer to continue
            var pos = input.position;
            if(input.bytesAvailable < 7) {  // 7 = type:1, channel:2, payloadSize:4
                input.position = pos;
                return false;
            }
            type = input.readUnsignedByte();
            #elseif neko
            type = input.readByte();
            #end
            //trace("type "+type);

            /*
            if (type == 'A'.charCodeAt(0)) {
                // Probably an AMQP.... header indicating a version mismatch. 
                // Otherwise meaningless, so try to read the version, and
                // throw an exception, whether we read the version okay or
                // not. 
                protocolVersionMismatch(input);
            }
            */

            #if flash9
            channel = input.readUnsignedShort();
            #elseif neko
            channel = input.readUInt16();
            #end
            //trace("channel "+channel);

            #if flash9
            payloadSize = input.readUnsignedInt();
            #elseif neko
            payloadSize = input.readUInt30();
            #end
            //trace("type: "+type+" channel: "+channel+" payloadSize: "+payloadSize);

            if (payloadSize > 0) {
                #if flash9
                //trace("payloadSize: "+payloadSize +" bytesAvailable:"+input.bytesAvailable);
                if(input.bytesAvailable < payloadSize + 1) { // + 1 for frameEndMarker
                    //trace("not enough bytes to complete frame");
                    input.position = pos;
                    return false;
                }
                payload = new ByteArray();
                input.readBytes(payload, 0, payloadSize);
                //trace("read payload: "+payloadSize);
                #elseif neko
                payload = new BytesOutput(); payload.bigEndian = true;
                payload.write(input.read(payloadSize));
                #end
            }

            accumulator = null;

            #if flash9
            var frameEndMarker = input.readUnsignedByte();
            #elseif neko
            var frameEndMarker = input.readByte();
            #end

            if (frameEndMarker != AMQP.FRAME_END) {
                throw new MalformedFrameError("Bad frame end marker: " + frameEndMarker);
            }

            return true;
        }

        #if flash9
        function protocolVersionMismatch(input:IDataInput):Void {
        #elseif neko
        function protocolVersionMismatch(input:Input):Void {
        #end

            var x:Error = null;

            try {
                var gotM = input.readByte() == 'M'.charCodeAt(0);
                var gotQ = input.readByte() == 'Q'.charCodeAt(0);
                var gotP = input.readByte() == 'P'.charCodeAt(0);
                var transportHigh = input.readByte();
                var transportLow = input.readByte();
                var serverMajor = input.readByte();
                var serverMinor = input.readByte();
                
                x = new MalformedFrameError("AMQP protocol version mismatch; we are version " +
                                                AMQP.PROTOCOL_MAJOR + "." +
                                                AMQP.PROTOCOL_MINOR + ", server is " +
                                                serverMajor + "." + serverMinor +
                                                " with transport " +
                                                transportHigh + "." + transportLow);
            } catch (e:Error) {
                throw new Error("Invalid AMQP protocol header from server");
            }

            throw x;
        }

        public function finishWriting():Void {
            if (accumulator != null) {
                #if flash9
                payload.writeBytes(accumulator, 0, accumulator.bytesAvailable);
                payload.position = 0;
                #elseif neko
                payload.write(accumulator.getBytes());
                #end
                accumulator = null;
            }
        }

        /**
         * Public API - writes this Frame to the given DataOutputStream
         */
        #if flash9
        public function writeTo(os:IDataOutput):Void {
        #elseif neko
        public function writeTo(os:Output):Void{
        #end
            finishWriting();
            #if neko
            var b:Bytes = payload.getBytes();
            #end
            os.writeByte(type);
            #if flash9
            os.writeShort(channel);
            os.writeInt(payload.length);
            os.writeBytes(payload);
            #elseif neko
            os.writeUInt16(channel);
            os.writeInt31(b.length);
            os.write(b);
            #end
            os.writeByte(AMQP.FRAME_END);
        }

        /**
         * Public API - retrieves the frame payload
         */
        #if flash9
        public function getPayload():ByteArray {
            return payload;
        #elseif neko
        public function getPayload():Bytes {
            return payload.getBytes();
        #end
        }

        /**
         * Public API - retrieves a new DataInputStream streaming over the payload
         */
        #if flash9
        public function getInputStream():IDataInput {
            return payload;
        #elseif neko
        public function getInputStream():Input {
            var bi:BytesInput = new BytesInput(payload.getBytes()); bi.bigEndian = true;
            return bi;
        #end
        }

        /**
         * Public API - retrieves a fresh DataOutputStream streaming into the accumulator
         */
        #if flash9
        public function getOutputStream():IDataOutput {
        #elseif neko
        public function getOutputStream():Output {
        #end
            return accumulator;
        }
    }
