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
    import flash.utils.ByteArray;
    #elseif neko
    import haxe.io.BytesOutput;
    #end
    import org.amqp.LongString;
    import org.amqp.impl.ByteArrayLongString;

    class LongStringHelper
     {
        public static function asLongString(str:String):LongString {
            #if flash9
            var b:ByteArray = new ByteArray();
            b.writeUTFBytes(str);
            #elseif neko
            var b:BytesOutput = new BytesOutput(); b.bigEndian = true;
            b.writeString(str);
            #end
            return new ByteArrayLongString(b);
        }
    }
