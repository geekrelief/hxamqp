package org.amqp.fast;

typedef DeclareExchange = org.amqp.methods.exchange.Declare
typedef DeclareExchangeOk = org.amqp.methods.exchange.DeclareOk
typedef DeleteExchange = org.amqp.methods.exchange.Delete
typedef DeleteExchangeOk = org.amqp.methods.exchange.DeleteOk

typedef Bind = org.amqp.methods.queue.Bind
typedef BindOk = org.amqp.methods.queue.BindOk

typedef DeclareQueue = org.amqp.methods.queue.Declare
typedef DeclareQueueOk = org.amqp.methods.queue.DeclareOk

typedef DeleteQueue = org.amqp.methods.queue.Delete
typedef DeleteQueueOk = org.amqp.methods.queue.DeleteOk

typedef Purge = org.amqp.methods.queue.Purge
typedef PurgeOk = org.amqp.methods.queue.PurgeOk

typedef ConnectionParameters = org.amqp.ConnectionParameters
typedef Command = org.amqp.Command
typedef Publish = org.amqp.methods.basic.Publish
typedef Return = org.amqp.methods.basic.Return
typedef Consume = org.amqp.methods.basic.Consume
typedef Cancel = org.amqp.methods.basic.Cancel

typedef Deliver = org.amqp.methods.basic.Deliver
typedef BasicProperties = org.amqp.headers.BasicProperties
typedef Properties = org.amqp.util.Properties

typedef ProtocolEvent = org.amqp.ProtocolEvent;

typedef DataReader = org.amqp.fast.utils.DataReader;
typedef DataWriter = org.amqp.fast.utils.DataWriter;

typedef Consumer = org.amqp.fast.utils.Consumer

enum ExchangeType {
    DIRECT;
    TOPIC;
}

#if flash9
typedef ByteArray = flash.utils.ByteArray;
typedef Delivery = { method:Deliver, properties:BasicProperties, body:ByteArray }

// put these at the bottom to avoid recursive def issues
typedef AmqpConnection = org.amqp.fast.flash.AmqpConnection
typedef Channel = org.amqp.fast.flash.Channel

#else

typedef BytesInput = haxe.io.BytesInput;
typedef BytesOutput = haxe.io.BytesOutput;
typedef Bytes = haxe.io.Bytes;
import haxe.io.BytesInput;
typedef Delivery = { method:Deliver, properties:BasicProperties, body:BytesInput }

// put these at the bottom to avoid recursive def issues
typedef AmqpConnection = org.amqp.fast.neko.AmqpConnection
typedef Channel = org.amqp.fast.neko.Channel
#end
