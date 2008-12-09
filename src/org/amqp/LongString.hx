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

    import haxe.io.Input;
    import haxe.io.Bytes;

    interface LongString
    {

        function length():Int;

        /**
         * Get the content stream.
         * Repeated calls to this function return the same stream,
         * which may not support rewind.
         * @return An input stream the reads the content
         * @throws IOException
         */
        function getStream():Input;

        /**
         * Get the content as a byte array.
         * Repeated calls to this function return the same array.
         * This function will fail if getContentLength() > Integer.MAX_VALUE
         * throwing an IllegalStateException.
         * @return the content as an array
         * @throws IOException
         */
        function getBytes():Bytes;

    }
