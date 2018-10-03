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
package org.amqp.headers;


    #if flash9
    import flash.Error;
    import flash.utils.IDataOutput;
    import flash.utils.ByteArray;
    #else
    import org.amqp.Error;
    import haxe.io.Bytes;
    import haxe.io.Output;
    import haxe.io.BytesOutput;
    #end

    import org.amqp.FrameHelper;
    import org.amqp.LongString;
    import org.amqp.error.IllegalArgumentError;

    class ContentHeaderPropertyWriter
     {
        public var flags:Array<Dynamic>;
        /** Output stream collecting the packet as it is generated */
        #if flash9
        public var outBytes:ByteArray; 
        #else
        public var outBytes:BytesOutput; 
        #end

        /** Current flags word being accumulated */
        public var flagWord:Int;
        /** Position within current flags word */
        public var bitCount:Int;

        public function new(){
            this.flags = new Array();
            #if flash9
            this.outBytes = new ByteArray();
            #else
            this.outBytes = new BytesOutput(); outBytes.bigEndian = true;
            #end
            this.flagWord = 0;
            this.bitCount = 0;
        }

        /**
         * Private API - encodes the presence or absence of a particular
         * object, and returns true if the main data stream should contain
         * an encoded form of the object.
         */
        public function argPresent(value:Dynamic):Bool {
            if (bitCount == 15) {
                flags.push(flagWord | 1);
                flagWord = 0;
                bitCount = 0;
            }

            if (value != null) {
                var bit:Int = 15 - bitCount;
                flagWord |= (1 << bit);
                bitCount++;
                return true;
            } else {
                bitCount++;
                return false;
            }
        }

        #if flash9
        public function dumpTo(output:IDataOutput):Void {
            if (bitCount > 0) {
                flags.push(flagWord);
            }
            for (i in 0...flags.length ) {
                output.writeShort(flags[i]);
            }
            output.writeBytes(outBytes);
        } 
        #else
        public function dumpTo(output:Output):Void {

            if (bitCount > 0) {
                flags.push(flagWord);
            }
            for (i in 0...flags.length ) {
                output.writeUInt16(flags[i]);
            }
            output.write(outBytes.getBytes());
        }
        #end

        /** Protected API - Writes a String value as a short-string to the stream, if it's non-null */
        public function writeShortstr(x:String):Void {
            if (argPresent(x)) {
                _writeShortstr(x);
            }
        }

        public function _writeShortstr(x:String):Void {
            outBytes.writeByte(x.length);
            #if flash9
            outBytes.writeUTFBytes(x);
            #else
            outBytes.writeString(x);
            #end
        }

        /** Protected API - Writes a String value as a long-string to the stream, if it's non-null */
        public function writeLongstr(x:String):Void {
            if(argPresent(x)){
                _writeLongstr(x);
            }
        }

        public function _writeLongstr(x:String):Void {
            #if flash9
            outBytes.writeInt(x.length);
            outBytes.writeUTFBytes(x);
            #else
            outBytes.writeInt32(x.length);
            outBytes.writeString(x);
            #end
        }

        /** Protected API - Writes a LongString value to the stream, if it's non-null */
        public function __writeLongstr(x:LongString):Void {
            if(argPresent(x)){
                ___writeLongstr(x);
            }
        }

        public function ___writeLongstr(x:LongString):Void {
            #if flash9
            outBytes.writeInt(x.length());
            outBytes.writeBytes(x.getBytes());
            #else
            outBytes.writeInt32(x.length());
            outBytes.write(x.getBytes());
            #end
        }

        /** Protected API - Writes a short integer value to the stream, if it's non-null */
        public function writeShort(x:Int):Void {
            if(argPresent(x)) {
                _writeShort(x);
            }
        }

        /** Protected API - Writes a short integer value to the stream, if it's non-null */
        public function _writeShort(x:Int):Void {
            #if flash9
            outBytes.writeShort(x);
            #else
            outBytes.writeUInt16(x);
            #end
        }

        /** Protected API - Writes an integer value to the stream, if it's non-null */
        public function writeLong(x:Int):Void {
            if(argPresent(x)) {
                _writeLong(x);
            }
        }

        public function _writeLong(x:Int):Void {
            #if flash9
            outBytes.writeInt(x);
            #else
            outBytes.writeInt32(x);
            #end
        }

        /** Protected API - Writes a long integer value to the stream, if it's non-null */
        public function writeLonglong(x:Float):Void {
            if(argPresent(x)) {
                _writeLonglong(x);
            }
        }

        public function _writeLonglong(x:Float):Void {
            outBytes.writeDouble(x);
        }

        /** Protected API - Writes a table value to the stream, if it's non-null */
        public function writeTable(x:haxe.ds.StringMap<Dynamic>):Void {
            if(argPresent(x)){
                _writeTable(x);
            }
        }
        public function _writeTable(table:haxe.ds.StringMap<Dynamic>):Void {
            #if flash9
            outBytes.writeInt( FrameHelper.tableSize(table) );
            #else
            outBytes.writeInt32( FrameHelper.tableSize(table) );
            #end

            for (key in table.keys()) {
                writeShortstr(key);
                var value:Dynamic = table.get(key);

                if(Std.is( value, String)) {
                    _writeOctet(83); // 'S'
                    _writeShortstr(cast( value, String));
                }
                else if(Std.is( value, LongString)) {
                    _writeOctet(83); // 'S'
                    ___writeLongstr(cast( value, LongString));
                }
                else if(Std.is( value, Int)) {
                    _writeOctet(73); // 'I'
                    _writeShort(cast( value, Int));
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
                    _writeOctet(84);//'T'
                    _writeTimestamp(cast( value, Date));
                }
                else if(Std.is( value, haxe.ds.StringMap)) {
                    _writeOctet(70); // 'F"
                    _writeTable(cast( value, haxe.ds.StringMap<Dynamic>));
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

        /** Protected API - Writes an octet value to the stream, if it's non-null */
        public function writeOctet(x:Int):Void {
            if(argPresent(x)) {
                _writeOctet(x);
            }
        }

        public function _writeOctet(x:Int):Void {
            outBytes.writeByte(x);
        }

        /** Protected API - Writes a timestamp value to the stream, if it's non-null */
        public function writeTimestamp(x:Date):Void {
            if(argPresent(x)) {
                _writeTimestamp(x);
            }
        }

        public function _writeTimestamp(x:Date):Void {
            #if flash9
            outBytes.writeInt( Math.floor(x.getTime() / 1000));
            #else
            outBytes.writeInt32( Math.floor(x.getTime() / 1000));
            #end
        }
    }
