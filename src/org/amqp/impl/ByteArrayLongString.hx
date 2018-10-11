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

    #if flash9
    import flash.utils.IDataInput;
    import flash.utils.ByteArray;
    #else
    import haxe.io.Input;
    import haxe.io.Bytes;
    import haxe.io.BytesOutput;
    import haxe.io.BytesInput;
    #end

    import org.amqp.LongString;

    class ByteArrayLongString implements LongString {

        #if flash9
        var buf:ByteArray;
        #else
        var buf:Bytes;
        #end

        #if flash9
        public function new(?b:ByteArray=null) {
            buf = b==null? new ByteArray() : b;
        }
        #else
        public function new(?b:BytesOutput=null) {
            if(b == null) {
                b = new BytesOutput(); b.bigEndian = true;
            }

            if(b.bigEndian == false)
                throw "BytesOutput argument to ByteArrayLongString must be bigEndian";

            buf = b.getBytes();
        }
        #end

        public function length():Int
        {
            return buf.length;
        }

        #if flash9
        public function getBytes():ByteArray {
            return buf;
        }

        public function getStream():IDataInput {
            return buf;
        }
        #else
        public function getBytes():Bytes
        {
            return buf;
        }

        public function getStream():Input
        {
            var b = new BytesInput(buf); b.bigEndian = true;
            return b;
        }
        #end
    }
