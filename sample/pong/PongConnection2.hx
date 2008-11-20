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
package pong;

    import flash.utils.ByteArray;
    import flash.utils.Timer;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;

    import org.amqp.BasicConsumer;
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.ProtocolEvent;
    import org.amqp.Session;
    import org.amqp.SessionManager;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.exchange.Declare;
    import org.amqp.methods.queue.Bind;
    import org.amqp.util.Properties;

    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.queue.Declare;

    class PongConnection2 extends EventDispatcher, implements BasicConsumer, implements LifecycleEventHandler {
        public var ax:String ;
        public var q:String ;
        public var q2:String ;
        public var routing_key:String;

        public var connection:Connection;
        public var baseSession:Session;
        public var sessionManager:SessionManager;
        public var sessionHandler:SessionStateHandler;

        public var connection2:Connection;
        public var baseSession2:Session;
        public var sessionManager2:SessionManager;
        public var sessionHandler2:SessionStateHandler;


        public function new() {
            super(); 
            ax = "";
            q = "pongq";
            q2 = "pongq2";
            connection = new Connection(buildConnectionParams());
            baseSession = connection.baseSession;
            sessionManager = connection.sessionManager;

            connection2 = new Connection(buildConnectionParams());
            baseSession2 = connection.baseSession;
            sessionManager2 = connection.sessionManager;

            ax = "";
            routing_key = q2;
        }

        public function buildConnectionParams():ConnectionParameters {
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            params.serverhost = "76.204.178.65";
            return params;
        }

        public function publish(data:ByteArray):Void {
            var publish:Publish = new Publish();
            publish.exchange = ax;
            publish.routingkey = routing_key;
            var props:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(publish, props, data);
            sessionHandler.dispatch(cmd);
        }


        public function run():Void {
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
			connection2.start();
        }

        public function afterOpen():Void {
            openChannel(runPublishTest);
        }

        public function openChannel(_callback:Dynamic):Void {
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
                //log("whoCares _called");
            };

            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            sessionHandler.rpc(new Command(open), whoCares);
            sessionHandler.rpc(new Command(queue), _callback);

            sessionHandler2 = sessionManager2.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            sessionHandler2.rpc(new Command(open), whoCares);
            sessionHandler2.rpc(new Command(queue), _callback);
        }

        public function runPublishTest(event:ProtocolEvent):Void {
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;
            sessionHandler2.register(consume, this);
        }

        public function cancel(event:TimerEvent):Void {
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
        }

        public function onConsumeOk(tag:String):Void {
        }

        public function onCancelOk(tag:String):Void {
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
            var data:ByteArray = body;
            data.position = 0;
            if (data.bytesAvailable > 0) {
                var y:Float = data.readFloat();
				var p:Puck = new Puck();
				p.i = data.readFloat();
				p.j = data.readFloat();
				p.x = data.readFloat();
				p.y = data.readFloat();
				dispatchEvent(new P1Event(y, p));
            }
        }
    }
