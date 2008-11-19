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
package samp;

    import flash.utils.ByteArray;
//    import flash.utils.Timer;

	import flash.events.EventDispatcher;

    import org.amqp.Command;
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

    class AbstractTest2 extends EventDispatcher {
        inline public static var TIMEOUT:Int = 3000;
        inline public static var DELAY:Int = 2000;

        public var ax:String ;
        public var q:String ;
        public var q2:String ;
        public var x_type:String ;
        public var bind_key:String;
        public var routing_key:String;
        public var routing_key2:String;
        public var connection:Connection;
        public var baseSession:Session;
        public var sessionManager:SessionManager;
        public var sessionHandler:SessionStateHandler;

        public var connection2:Connection;
        public var baseSession2:Session;
        public var sessionManager2:SessionManager;
        public var sessionHandler2:SessionStateHandler;


        public function new() {
			
			ax = "ax";
			q = "q";
			q2 = "q2";
			x_type = "topic";
			bind_key = "a.b.c.*" ;
			routing_key = "a.b.c.d" ;
			routing_key2 = "a.b.c.e" ;
			log("constr AbstractTest2");
            connection = new Connection(buildConnectionParams());
            baseSession = connection.baseSession;
            sessionManager = connection.sessionManager;

            connection2 = new Connection(buildConnectionParams());
            baseSession2 = connection.baseSession;
            sessionManager2 = connection.sessionManager;
        }

        public function buildConnectionParams():ConnectionParameters {
			log("AbstractTest2: buildConnectionParams");
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest2";
            params.password = "guest2";
            params.vhostpath = "/";
            params.serverhost = "10.0.0.19";
            return params;
        }

        public function publish(data:ByteArray):Void {
			log("AbstractTest2: publish");
            var publish:Publish = new Publish();
            publish.exchange = ax;
            publish.routingkey = routing_key2;
//			log("AbstractTest2: publish "+publish);
            var props:BasicProperties = Properties.getBasicProperties();
//			log("AbstractTest2: publish props"+props);
            var cmd:Command = new Command(publish, props, data);
//			log("AbstractTest2: publish cmd"+cmd);
            sessionHandler.dispatch(cmd);
            var timer:Timer = new Timer(DELAY, 1);
            timer.start();
        }

		// publish channel
        public function openChannel(_callback:Dynamic):Void {
			log("AbstractTest2: openChannel");
            sessionHandler = sessionManager.create();

            var open:Open = new Open();

            var exchange:org.amqp.methods.exchange.Declare = new org.amqp.methods.exchange.Declare();
            exchange.exchange = ax;
            exchange.type = x_type;

            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q2;

            var bind:Bind = new Bind();
            bind.exchange = ax;
            bind.queue = q2;
            bind.routingkey = bind_key;

            var devNull:Dynamic = function(event:ProtocolEvent):Void{
                log("devNull called for " + event.command.method);
            };

            sessionHandler.rpc(new Command(open), devNull);
            sessionHandler.rpc(new Command(exchange), devNull);
            sessionHandler.rpc(new Command(queue), devNull);
            sessionHandler.rpc(new Command(bind), _callback);//addAsync(_callback, TIMEOUT));
        }

		// get channel
		public function openChannel2(_callback:Dynamic):Void {
			log("AbstractTest2: openChannel");
            sessionHandler2 = sessionManager2.create();

            var open:Open = new Open();

            var exchange:org.amqp.methods.exchange.Declare = new org.amqp.methods.exchange.Declare();
            exchange.exchange = ax;
            exchange.type = x_type;

            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q;

            var bind:Bind = new Bind();
            bind.exchange = ax;
            bind.queue = q;
            bind.routingkey = bind_key;

            var devNull:Dynamic = function(event:ProtocolEvent):Void{
                log("devNull called for " + event.command.method);
            };

            sessionHandler.rpc(new Command(open), devNull);
            sessionHandler.rpc(new Command(exchange), devNull);
            sessionHandler.rpc(new Command(queue), devNull);
            sessionHandler.rpc(new Command(bind), _callback);//addAsync(_callback, TIMEOUT));
        }

		public function log(s:String):Void {
			dispatchEvent(new MyEvent("log", s));
		}
    }
