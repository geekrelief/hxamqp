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

    import org.amqp.Command;
    import org.amqp.Connection;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.exchange.Declare;
    import org.amqp.methods.queue.Bind;
    import org.amqp.methods.queue.DeclareOk;
    import org.amqp.patterns.Serializer;
    import org.amqp.util.Properties;

    class AbstractDelegate implements LifecycleEventHandler {
        public var exchange:String;
        public var exchangeType:String;
        public var connection:Connection;

        public var serializer:Serializer;

        var sessionHandler:SessionStateHandler;

        public function new(c:Connection) {
            connection = c;
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
        }

        public function afterOpen():Void {
            openChannel();
        }

        function openChannel():Void {
            sessionHandler = connection.sessionManager.create();
            sessionHandler.rpc(new Command(new Open()), onChannelOpenOk);
        }

        function publish(x:String, routing_key:String, data:ByteArray, ?properties:BasicProperties = null):Void {
            var publish:Publish = new Publish();
            publish.exchange = x;
            publish.routingkey = routing_key;
            var props:BasicProperties = (properties == null) ? Properties.getBasicProperties() : properties;
            var cmd:Command = new Command(publish, props, data);
            sessionHandler.dispatch(cmd);
        }

        function declareExchange(x:String, type:String):Void {
            var exchange:org.amqp.methods.exchange.Declare = new org.amqp.methods.exchange.Declare();
            exchange.exchange = x;
            exchange.type = type;
            sessionHandler.rpc(new Command(exchange), onExchangeDeclareOk);
        }

        function declareQueue(q:String):Void {
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            sessionHandler.rpc(new Command(queue), onQueueDeclareOk);
        }

        function bindQueue(x:String,q:String, key:String):Void {
            var bind:Bind = new Bind();
            bind.exchange = x;
            bind.queue = q;
            bind.routingkey = key;

            sessionHandler.rpc(new Command(bind), onQueueBindOk);
        }

        function setupReplyQueue():Void {
            declareQueue("");
        }

        function getReplyQueue(event:ProtocolEvent):String {
            var declareOk:DeclareOk = cast( event.command.method, DeclareOk);
            return declareOk.queue;
        }


        /**
         * This should be overriden by specializing classes
         **/
        function onChannelOpenOk(event:ProtocolEvent):Void {}

        /**
         * This should be overriden by specializing classes
         **/
        function onQueueDeclareOk(event:ProtocolEvent):Void {}

        /**
         * This should be overriden by specializing classes
         **/
        function onExchangeDeclareOk(event:ProtocolEvent):Void {}

        /**
         * This should be overriden by specializing classes
         **/
        function onQueueBindOk(event:ProtocolEvent):Void {}

    }
