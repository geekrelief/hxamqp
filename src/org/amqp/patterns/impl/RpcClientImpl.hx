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

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    
    import org.amqp.BasicConsumer;
    import org.amqp.Connection;
    import org.amqp.ProtocolEvent;
    import org.amqp.error.TimeoutError;
    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.patterns.CorrelatedMessageEvent;
    import org.amqp.patterns.Dispatcher;
    import org.amqp.patterns.RpcClient;
    import org.amqp.util.Guid;
    import org.amqp.util.Properties;

	typedef Calls = {
		var callback:Dynamic;
		var timer:Timer;
	}

    class RpcClientImpl extends AbstractDelegate, implements RpcClient, implements BasicConsumer, implements Dispatcher {
        public var routingKey:String;

        public var replyQueue:String;
        public var consumerTag:String;

        var dispatcher:EventDispatcher ;
        var sendBuffer:SendBuffer;
        var calls:Hash<Calls> ;

        public function new(c:Connection) {
            
            dispatcher = new EventDispatcher();
            calls = new Hash();
            super(c);
            sendBuffer = new SendBuffer(this);
        }

        public function send(o:Dynamic,callback:Dynamic,?timeout:Int=-1):Void {
            if (null != o) {
            	var data:Dynamic = {data:o, timeout:timeout};
            	
                if (null == consumerTag) {
                    sendBuffer.buffer(data,callback);
                }
                else {
                    dispatch(data,callback);
                }
            }
        }

        public function dispatch(o:Dynamic,callback:Dynamic):Void {
            var correlationId:String = Guid.next();
            var data:ByteArray = new ByteArray();
            serializer.serialize(o.data,data);
            var props:BasicProperties = Properties.getBasicProperties();
            props.correlationid = correlationId;
            props.replyto = replyQueue;
            
            if (o.timeout < 0) {
            	dispatcher.addEventListener(correlationId,callback);
            }else {
            	dispatcher.addEventListener(correlationId,timeoutHandler);
            	
            	var timer:Timer = new Timer(o.timeout,1);
            	timer.addEventListener(TimerEvent.TIMER_COMPLETE,timeoutHandler);
            	timer.start();
            	
            	calls.set(correlationId, {callback:callback, timer:timer});
            }
            
            publish(exchange,routingKey,data,props);
        }
        
        public function timeoutHandler(event:Event):Void {
            if (event.type == TimerEvent.TIMER_COMPLETE) {
                dispatcher.dispatchEvent(new TimeoutError());
            }else {
                var response:Dynamic = calls.get(event.type);
                response.timer.stop();
                response.callback.call(null, event);
                calls.remove(event.type);
        	}
        }

        public function addTimeoutHandler(callback:Dynamic):Void {
        	dispatcher.addEventListener(TimeoutError.TIMEOUT_ERROR, callback);
        }

        override function onChannelOpenOk(event:ProtocolEvent):Void {
            declareExchange(exchange,exchangeType);
            setupReplyQueue();
        }

        override function onQueueDeclareOk(event:ProtocolEvent):Void {
            replyQueue = getReplyQueue(event);
            var consume:Consume = new Consume();
            consume.queue = replyQueue;
            consume.noack = true;
            sessionHandler.register(consume, this);
        }

        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            sendBuffer.drain();
        }

        public function onCancelOk(tag:String):Void {}

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
            var result:Dynamic = serializer.deserialize(body);
            dispatcher.dispatchEvent(new CorrelatedMessageEvent(properties.correlationid,result));
        }

    }
