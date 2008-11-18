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

    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;

    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.Connection;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Cancel;
    import org.amqp.methods.basic.CancelOk;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.queue.Declare;
    import org.amqp.patterns.CorrelatedMessageEvent;
    import org.amqp.patterns.Dispatcher;
    import org.amqp.patterns.SubscribeClient;

    class SubscribeClientImpl extends AbstractDelegate, implements SubscribeClient, implements BasicConsumer, implements Dispatcher {
        var replyQueue:String ;
        var topics:Hash<Dynamic> ;
        var dispatcher:EventDispatcher ;
        var sendBuffer:SendBuffer;

        public function new(c:Connection) {
            
            replyQueue = null;
            topics = new Hash();
            dispatcher = new EventDispatcher();
            super(c);
            sendBuffer = new SendBuffer(this);
        }

        public function subscribe(key:String, callback:Dynamic):Void {
            if (topics.containsKey(key)) {
                return;
            }

            topics.set(key, {callback:callback, consumerTag:null});

            if (replyQueue != null) {
                dispatch(key, null);
            }else {
                sendBuffer.buffer(key, null);
            }
        }

        public function unsubscribe(key:String):Void {
            var cancel:Cancel = new Cancel();
            var topic:Dynamic = topics.get(key);
            sessionHandler.unregister(topic.consumerTag);
            topics.remove(key);
        }

        public function dispatch(o:Dynamic, callback:Dynamic):Void {
            var consume:Consume = new Consume();
            consume.queue = replyQueue;
            consume.noack = true;
            consume.consumertag = replyQueue + ":" + o;
            sessionHandler.register(consume, this);

            bindQueue(exchange, replyQueue, o);
        }

        override function onChannelOpenOk(event:ProtocolEvent):Void {
            declareExchange(exchange, exchangeType);
            setupReplyQueue();
        }

        override function declareQueue(q:String):Void {
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            queue.autodelete = true;
            sessionHandler.dispatch(new Command(queue));
        }

        override function onQueueDeclareOk(event:ProtocolEvent):Void {
            replyQueue = getReplyQueue(event);
            sendBuffer.drain();
        }

        public function onConsumeOk(tag:String):Void {
          var key:String = tag.split(":")[1];
          var topic:Dynamic = topics.get(key);

          topic.consumerTag = tag;
          topics.set(key, topic);

          dispatcher.addEventListener(key, topic.callback);
        }

        public function onCancelOk(tag:String):Void {}

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
            var result:Dynamic = serializer.deserialize(body);
            dispatcher.dispatchEvent(new CorrelatedMessageEvent(properties.correlationid, result));
        }
    }
