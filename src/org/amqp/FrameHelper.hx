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

    import org.amqp.error.IllegalArgumentError;

    class FrameHelper
     {
         public static function shortStrSize(str:String):Int{
            return str.length + 1;
            //str.getBytes("utf-8").length + 1;
        }

        /** Computes the AMQP wire-protocol length of a protocol-encoded long string. */
        public static function longStrSize(str:String):Int {
            return str.length + 4;
            //str.getBytes("utf-8").length + 4;
        }

        public static function tableSize(table:Hash<Dynamic>):Int{
            var acc:Int = 0;

            for (key in table.keys()) {
                   acc += shortStrSize(key);
                   acc++;
                   var value:Dynamic = table.get(key);

                   if(Std.is( value, String)) {
                    acc += longStrSize(cast( value, String));
                }
                else if(Std.is( value, LongString)) {
                    acc += 4;
                    var optimizeMe:Int = (cast( value, LongString)).length();
                    acc += optimizeMe;
                }
                else if(Std.is( value, int)) {
                    acc += 4;
                }
                /*
                else if(value is BigDecimal) {
                    acc += 5;
                }
                */
                else if(Std.is( value, Date)) {
                    acc += 8;
                }
                else if(Std.is( value, Hash<Dynamic>)) {
                    acc += 4;
                    acc += tableSize(cast( value, Hash<Dynamic>));
                }
                else {
                    throw new IllegalArgumentError("invalid value in table");
                }
            }
            return acc;
        }
    }
