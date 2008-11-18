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
package org.amqp.patterns.impl;

    import flash.utils.ByteArray;

    import org.amqp.Connection;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.patterns.Dispatcher;
    import org.amqp.patterns.PublishClient;
    import org.amqp.util.Properties;

    class PublishClientImpl extends AbstractDelegate, implements PublishClient, implements Dispatcher {
        var sendBuffer:SendBuffer;
        var openOk:Bool;

        public function new(c:Connection) {
            super(c);
            sendBuffer = new SendBuffer(this);
        }

        public function send(key:String, o:Dynamic):Void {
            if (o != null) {
                var data:Dynamic = { key:key, content:o };

                if (openOk) {
                    dispatch(data, null);
                }else {
                    sendBuffer.buffer(data, null);
                }
            }
        }

        public function dispatch(o:Dynamic, callback:Dynamic):Void {
            var key:String = o.key;
            var data:ByteArray = new ByteArray();
            serializer.serialize(o.content, data);
            var props:BasicProperties = Properties.getBasicProperties();
            props.correlationid = key;
            publish(exchange, key, data, props);
        }

        override function onChannelOpenOk(event:ProtocolEvent):Void {
            declareExchange(exchange, exchangeType);
            sendBuffer.drain();
            openOk = true;
        }
    }
