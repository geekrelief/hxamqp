package org.amqp;
// for neko to send messages to socket/session thread

import org.amqp.impl.SessionStateHandler;
import org.amqp.Command;
import org.amqp.methods.basic.Consume;
import org.amqp.BasicConsumer;

// Socket and Session messages
enum SMessage {
    SClose;
    SRegister(s:SessionStateHandler, c:Consume, b:BasicConsumer);
    SRpc(s:SessionStateHandler, c:Command, fun:Dynamic);
    SDispatch(s:SessionStateHandler, c:Command);
}
