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

    import org.amqp.Error;

    import haxe.io.Bytes;
    import haxe.io.BytesInput;
    import haxe.io.BytesOutput;
    import haxe.io.Input;
    import haxe.io.Output;
    import org.amqp.error.MalformedFrameError;

    class Frame
     {

        public var type:Int;
        public var channel:Int;
        var payload:BytesOutput;
        var accumulator:BytesOutput;

        public function new() {
            payload = new BytesOutput(); payload.bigEndian = true;
            accumulator = new BytesOutput(); accumulator.bigEndian = true;
        }

        public function readFrom(input:Input):Bool {
            trace("readFrom");
            type = input.readByte();
            trace("type "+type);
            if (type == 'A'.charCodeAt(0)) {
                /* Probably an AMQP.... header indicating a version mismatch. */
                /* Otherwise meaningless, so try to read the version, and
                 * throw an exception, whether we read the version okay or
                 * not. */
                protocolVersionMismatch(input);
            }

            channel = input.readUInt16();
            trace("channel "+channel);

            var payloadSize:Int = input.readInt31();
            trace("payloadSize "+payloadSize);
            if (payloadSize > 0) {
                payload = new BytesOutput(); payload.bigEndian = true;
                payload.write(input.read(payloadSize));
            }

            accumulator = null;

            var frameEndMarker:Int = input.readByte();

            if (frameEndMarker != AMQP.FRAME_END) {
                throw new MalformedFrameError("Bad frame end marker: " + frameEndMarker);
            }

            return true;
        }

        function protocolVersionMismatch(input:Input):Void {

            var x:Error = null;

            try {
                var gotM:Bool = input.readByte() == 'M'.charCodeAt(0);
                var gotQ:Bool = input.readByte() == 'Q'.charCodeAt(0);
                var gotP:Bool = input.readByte() == 'P'.charCodeAt(0);
                var transportHigh:Int = input.readByte();
                var transportLow:Int = input.readByte();
                var serverMajor:Int = input.readByte();
                var serverMinor:Int = input.readByte();
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
                payload.write(accumulator.getBytes());

                accumulator = null;
            }
        }

        /**
         * Public API - writes this Frame to the given DataOutputStream
         */
        public function writeTo(os:Output):Void{
            finishWriting();
            var b:Bytes = payload.getBytes();
            payload = null;

            os.writeByte(type);
            //os.writeByte(0);
            os.writeUInt16(channel);
            os.writeInt31(b.length);
            //accumulator.position = 0;
            //trace("ba = " + accumulator.length);
            //os.writeInt(accumulator.length);
            os.write(b);
            //os.writeBytes(accumulator, 0, accumulator.bytesAvailable);
            os.writeByte(AMQP.FRAME_END);
        }

        /**
         * Public API - retrieves the frame payload
         */
        public function getPayload():Bytes {
            trace("getPayLoad");
            return payload.getBytes();
        }

        /**
         * Public API - retrieves a new DataInputStream streaming over the payload
         */
        public function getInputStream():Input {
            var bi:BytesInput = new BytesInput(payload.getBytes()); bi.bigEndian = true;
            return bi;
        }

        /**
         * Public API - retrieves a fresh DataOutputStream streaming into the accumulator
         */
        public function getOutputStream():Output {
            return accumulator;
        }
    }
