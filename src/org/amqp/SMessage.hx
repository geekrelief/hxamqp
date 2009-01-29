package org.amqp;
// for neko to send messages to socket/session thread

import org.amqp.impl.SessionStateHandler;
import org.amqp.Command;
import org.amqp.methods.basic.Consume;
import org.amqp.methods.basic.Return;
import org.amqp.BasicConsumer;

typedef Ssh = SessionStateHandler

// Socket and Session messages
enum SMessage {
    SClose;
    SData;
    SSetReturn(s:Ssh, r:Command->Return->Void);
    SRegister(s:Ssh, c:Consume, b:BasicConsumer);
    SUnregister(s:Ssh, t:String);
    SRpc(s:Ssh, c:Command, fun:Dynamic);
    SDispatch(s:Ssh, c:Command);
}
