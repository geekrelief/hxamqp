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

    import org.amqp.impl.SessionImpl;
    import org.amqp.impl.SessionStateHandler;

    class SessionManager
     {
        var connection:Connection;
        var sessions:IntHash<Session> ;
        var nextChannel:Int ;

        public function new(con:Connection) {
            
            sessions = new IntHash();
            nextChannel = 1;
            connection = con;
        }

        public function lookup(channel:Int):Session {
            return sessions.get(channel);
        }

        public function remove(ssh:SessionStateHandler) {
            var session:Session = sessions.get(ssh.channel);
            if(session != null) {
                session.closeGracefully();
                sessions.remove(ssh.channel);
            }
        }

        public function create(?stateHandler:SessionStateHandler = null):SessionStateHandler {
            var channel:Int = allocateChannelNumber();

            if (null == stateHandler) {
                stateHandler = new SessionStateHandler();
            }

            var session:Session = new SessionImpl(connection, channel, stateHandler);
            stateHandler.registerWithSession(session);
            sessions.set(channel, session);

            return stateHandler;
        }

        function allocateChannelNumber():Int {
            return nextChannel++;
        }

        public function closeGracefully():Void {
            for (session in sessions) {
                session.closeGracefully();
            }
            sessions = new IntHash();
        }

        public function forceClose():Void {
            for (session in sessions) {
                session.closeGracefully();
                session.forceClose();
            }
            sessions = new IntHash();
        }
    }
