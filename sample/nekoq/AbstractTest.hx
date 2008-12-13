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
package nekoq;

    import haxe.io.Bytes;

	import org.amqp.events.EventDispatcher;

    import org.amqp.Command;
    import org.amqp.Connection;
    import org.amqp.ConnectionParameters;
    import org.amqp.Session;
    import org.amqp.SessionManager;
    import org.amqp.headers.BasicProperties;
    import org.amqp.impl.SessionStateHandler;
    import org.amqp.methods.basic.Publish;
    import org.amqp.util.Properties;

    class AbstractTest extends EventDispatcher {
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

        public var sessionHandler2:SessionStateHandler;


        public function new() {
			super();
			
			//ax = "ax";
			q = "q";
			q2 = "q2";
			//x_type = "topic";
			//bind_key = "a.b.c.*";
			//routing_key = "a.b.c.d";
			//routing_key2 = "a.b.c.e";

            trace("new creating connection");
            connection = new Connection(buildConnectionParams());
            baseSession = connection.baseSession;
            sessionManager = connection.sessionManager;
        }

        public function buildConnectionParams():ConnectionParameters {
            trace("buildConnectionParams");
            var params:ConnectionParameters = new ConnectionParameters();
            params.username = "guest";
            params.password = "guest";
            params.vhostpath = "/";
            params.serverhost = "10.0.0.19";
            trace(params);
            return params;
        }

        public function publish(data:Bytes):Void {
            var publish:Publish = new Publish();
            publish.exchange = ax;
            publish.routingkey = routing_key;
            var props:BasicProperties = Properties.getBasicProperties();
            var cmd:Command = new Command(publish, props, data);
            sessionHandler.dispatch(cmd);
        }

		// publish channel
        // override in subclass
        public function openChannel(_callback:Dynamic):Void {
        }
    }
