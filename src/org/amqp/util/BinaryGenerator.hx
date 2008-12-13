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
package org.amqp.util;

    #if flash9
    import flash.Error;
    import flash.utils.IDataOutput;
    import flash.utils.ByteArray;
    #elseif neko
    import org.amqp.Error;
    import haxe.io.BytesOutput;
    import haxe.io.Output;
    #end

    import org.amqp.FrameHelper;
    import org.amqp.LongString;
    import org.amqp.error.IllegalArgumentError;

    class BinaryGenerator {

        #if flash9
        var output:IDataOutput;
        #elseif neko
        var output:Output;
        #end

        var needBitFlush:Bool;
        /** The current group of bits */
        var bitAccumulator:Int;
        /** The current position within the group of bits */
        var bitMask:Int;

        #if flash9
        public function new(output:IDataOutput) {
        #elseif neko
        public function new(output:Output) {
        #end 
            this.output = output;
            resetBitAccumulator();
        }

        function resetBitAccumulator(): Void {
            needBitFlush = false;
            bitAccumulator = 0;
            bitMask = 1;
        }

        /**
         * Private API - called when we may be transitioning from encoding
         * a group of bits to encoding a non-bit value.
         */
        function bitflush():Void {
            if (needBitFlush) {
                output.writeByte(bitAccumulator);
                resetBitAccumulator();
            }
        }

        /** Public API - encodes a short string argument. */
        public function writeShortstr(str:String):Void {
            bitflush();
            //byte [] bytes = str.getBytes("utf-8");

            output.writeByte(str.length);
            #if flash9
            output.writeUTFBytes(str);
            #elseif neko
            output.writeString(str);
            #end
        }

        /** Public API - encodes a long string argument from a LongString. */
        public function writeLongstr(str:LongString):Void {
            bitflush();
            writeLong(str.length());
            #if flash9
            output.writeBytes(str.getBytes());
            #elseif neko
            output.write(str.getBytes());
            #end
        }

        /** Public API - encodes a long string argument from a String. */
        public function writeString(str:String):Void {
            bitflush();
            //byte [] bytes = str.getBytes("utf-8");
            writeLong(str.length);
            #if flash9
            output.writeUTFBytes(str);
            #elseif neko
            output.writeString(str);
            #end
        }

        /** Public API - encodes a short integer argument. */
        public function writeShort(s:Int):Void {
            bitflush();
            #if flash9
            output.writeShort(s);
            #elseif neko
            output.writeUInt16(s);
            #end
        }

        /** Public API - encodes an integer argument. */
        public function writeLong(l:Int):Void {
            bitflush();
            // java's arithmetic on this type is signed, however its
            // reasonable to use ints to represent the unsigned long
            // type - for values < Integer.MAX_VALUE everything works
            // as expected
            #if flash9
            output.writeInt(l);
            #elseif neko
            output.writeInt31(l);
            #end
        }

        /** Public API - encodes a long integer argument. */
        public function writeLonglong(ll:Int):Void {
            #if flash9
            throw new Error("No 64 bit integers in Flash");
            #elseif neko
            throw new Error("No 64 bit integers in Neko");
            #end
            //bitflush();
            //output.writeInt(ll);
        }

        /** Public API - encodes a boolean/bit argument. */
        public function writeBit(b:Bool):Void {
            if (bitMask > 0x80) {
                bitflush();
            }
            if (b) {
                bitAccumulator |= bitMask;
            } else {
                // um, don't set the bit.
            }

            bitMask = bitMask << 1;
            needBitFlush = true;
        }

        /** Public API - encodes a table argument. */
        public function writeTable(table:Hash<Dynamic>, ?encodeSize:Bool = true):Void {

            bitflush();
            if (table == null) {
                // Convenience.
                #if flash9
                output.writeInt(0);
                #elseif neko
                output.writeInt31(0);
                #end
            } else {
                if (encodeSize) {
                    #if flash9
                    output.writeInt( FrameHelper.tableSize(table) );
                    #elseif neko
                    output.writeInt31( FrameHelper.tableSize(table) );
                    #end
                 }
                for (key in table.keys()) {
                    writeShortstr(key);
                    var value:Dynamic = table.get(key);

                    if(Std.is( value, String)) {
                        writeOctet(83); // 'S'
                        writeShortstr(cast( value, String));
                    }
                    else if(Std.is( value, LongString)) {
                        writeOctet(83); // 'S'
                        writeLongstr(cast( value, LongString));
                    }
                    else if(Std.is( value, Int)) {
                        writeOctet(73); // 'I'
                        writeShort(cast( value, Int));
                    }
                    /*
                    else if(value is BigDecimal) {
                        writeOctet(68); // 'D'
                        BigDecimal decimal = (BigDecimal)value;
                        writeOctet(decimal.scale());
                        BigInteger unscaled = decimal.unscaledValue();
                        if(unscaled.bitLength() > 32) //Integer.SIZE in Java 1.5
                            throw new IllegalArgumentException
                                ("BigDecimal too large to be encoded");
                        writeLong(decimal.unscaledValue().intValue());
                    }
                    */
                    else if(Std.is( value, Date)) {
                        writeOctet(84);//'T'
                        writeTimestamp(cast( value, Date));
                    }
                    else if(Std.is( value, Hash)) {
                        writeOctet(70); // 'F"
                        writeTable(cast( value, Hash<Dynamic>));
                    }
                    else if (value == null) {
                        throw new Error("Value for key {" + key + "} was null");
                    }
                    else {
                        throw new IllegalArgumentError
                            ("Invalid value type: [" + value
                             + "] for key [" + key+"]");
                    }
                }
            }

        }

        /** Public API - encodes an octet argument from an int. */
        public function writeOctet(octet:Int):Void {
            bitflush();
            output.writeByte(octet);
        }

        /** Public API - encodes a timestamp argument. */
        public function writeTimestamp(timestamp:Date):Void {
            // AMQP uses POSIX time_t which is in seconds since the epoc
            writeLonglong( Math.floor(timestamp.getTime() / 1000) );
        }

        /**
         * Public API - call this to ensure all accumulated argument
         * values are correctly written to the output stream.
         */
        public function flush():Void {
            bitflush();
            //output.flush();
        }
    }
