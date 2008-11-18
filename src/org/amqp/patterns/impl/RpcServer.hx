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

    import org.amqp.BasicConsumer;
    import org.amqp.Connection;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.queue.DeclareOk;
    import org.amqp.patterns.RequestHandler;
    import org.amqp.util.Properties;

    class RpcServer extends AbstractDelegate, implements BasicConsumer {
        public var requestHandler:RequestHandler;

        public var bindingKey:String;
        var consumerTag:String;

        public var debug:Bool ;

        public function new(c:Connection)
        {
            debug = true;
            trace(new Date() + " - Starting AMQP JSON Server.....please stand by");
            super(c);
        }

        override function onChannelOpenOk(event:ProtocolEvent):Void {
            declareExchange(exchange,exchangeType);
            declareQueue("");
        }

        override function onQueueDeclareOk(event:ProtocolEvent):Void {
            var declareOk:DeclareOk = cast( event.command.method, DeclareOk);
            bindQueue(exchange,declareOk.queue,bindingKey);
            var consume:Consume = new Consume();
            consume.queue = declareOk.queue;
            consume.noack = true;
            sessionHandler.register(consume, this);
        }


        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            trace(new Date() + " - AMQP JSON Server has booted and will now accept requests :-)");
        }

        public function onCancelOk(tag:String):Void {}

        public function onDeliver(method:Deliver,
                                  inProps:BasicProperties,
                                  body:ByteArray):Void {
            var param:Dynamic = serializer.deserialize(body);
            var result:Dynamic = requestHandler.process(param);
            var response:ByteArray = new ByteArray();
            serializer.serialize(result,response);
            var outProps:BasicProperties = Properties.getBasicProperties();
            outProps.correlationid = inProps.correlationid;
            publish("",inProps.replyto,response,outProps);

            if (debug) {
                body.position = 0;
                response.position = 0;
                trace(new Date() + " - Received " + body.readUTF() +
                               " as input, returning " + response.readUTF());
            }

        }

    }
