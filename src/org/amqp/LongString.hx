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
    import flash.utils.ByteArray;
    #elseif neko
    import haxe.io.Input;
    import haxe.io.Bytes;
    #end

    interface LongString
    {
        function length():Int;
        #if flash9
        function getStream():IDataInput;
        function getBytes():ByteArray;
        #elseif neko
        function getStream():Input;
        function getBytes():Bytes;
        #end
    }
