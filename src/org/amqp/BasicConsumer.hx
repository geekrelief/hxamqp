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
    import flash.utils.ByteArray;
    #else
    import haxe.io.BytesInput;
    #end

    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Deliver;

    interface BasicConsumer
    {
        function onConsumeOk(tag:String):Void;
        function onCancelOk(tag:String):Void;
        #if flash9
        function onDeliver(method:Deliver, properties:BasicProperties, body:ByteArray):Void;
        #else
        function onDeliver(method:Deliver, properties:BasicProperties, body:BytesInput):Void;
        #end
    }
