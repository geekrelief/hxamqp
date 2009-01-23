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

    class ConnectionParameters
     {
        public var port(getPort, null) : Int ;
        public var username:String;
        public var password:String;
        public var serverhost:String;
        public var vhostpath:String;

        public var serverport:Int ;

        public var useTLS:Bool ;
        public var tlsPort:Int ;
        public var options:Dynamic ;

		public function new (?_host:String="", ?_port:Int=-1, ?_user:String="", ?_pass:String="", ?_vhost:String="", ?_options) {
            serverhost = _host;
            if(_port == -1)
			    serverport = AMQP.PORT;
            else
                serverport = _port;
            username = _user;
            password = _pass;
            vhostpath = _vhost;
            options = _options;
		}

        public function getPort():Int {
            return useTLS ? tlsPort : serverport;
        }
    }
