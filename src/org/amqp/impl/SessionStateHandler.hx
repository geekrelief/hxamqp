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
package org.amqp.impl;

    #if flash9
    import flash.utils.ByteArray;
    #else
    import haxe.io.BytesInput;
    #end

    import org.amqp.BaseCommandReceiver;
    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.ConsumerRegistry;
    import org.amqp.Method;
    import org.amqp.ProtocolEvent;
    import org.amqp.SynchronousCommandClient;
    import org.amqp.error.IllegalStateError;
    import org.amqp.headers.BasicProperties;
    import org.amqp.headers.ChannelProperties;
    import org.amqp.headers.ConnectionProperties;
    import org.amqp.methods.basic.Cancel;
    import org.amqp.methods.basic.CancelOk;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.ConsumeOk;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.basic.Return;
    import org.amqp.methods.channel.CloseOk;
    import org.amqp.methods.channel.OpenOk;

    class SessionStateHandler extends BaseCommandReceiver implements SynchronousCommandClient implements ConsumerRegistry {
        static var STATE_CLOSED:Int = 0;
        static var STATE_CONNECTION:Int = new ConnectionProperties().classId;
        static var STATE_CHANNEL:Int = new ChannelProperties().classId;
        static var STATE_OPEN:Int = STATE_CHANNEL + 1;

        var state:Int;
        var QUEUE_SIZE:Int ;

        var consumers:haxe.ds.StringMap<BasicConsumer>;
        var returnCallback:Command->Return->Void;

        public var channel(get, null):Int;

        public function new(){
            // TODO Look into whether this is really necessary
            super();
            
            state = STATE_CONNECTION;
            QUEUE_SIZE = 100;
            consumers = new haxe.ds.StringMap();
            unsetReturn();
            addEventListener(new Deliver(), onDeliver);
            addEventListener(new Return(), onReturn);
        }

        inline public function get_channel():Int {
            return session.channel;
        }

        public override function forceClose():Void{
            // trace("forceClose called");
            transition(STATE_CLOSED);
        }

        public override function closeGracefully():Void{
            //trace("closeGracefully called");
            transition(STATE_CLOSED);
        }

        public function rpc(cmd:Command, fun:Dynamic):Void {
            session.rpc(cmd, fun);
        }

        function cancelRpcHandler(method:Method, fun:Dynamic):Void {
            removeEventListener(method, fun);
        }

        public function dispatch(cmd:Command):Void {
            session.sendCommand(cmd, null);
        }

        public function register(consume:Consume, consumer:BasicConsumer):Void{
            rpc(new Command(consume), onConsumeOk.bind(consumer));
        }

        public function unregister(tag:String):Void{
            var cancel:Cancel = new Cancel();
            cancel.consumertag = tag;
            rpc(new Command(cancel), onCancelOk);
        }

        public function onConsumeOk(consumer:BasicConsumer, event:ProtocolEvent):Void {
            var consumeOk:ConsumeOk = cast( event.command.method, ConsumeOk);

            var tag:String = consumeOk.consumertag;
            consumers.set(tag, consumer);
            //trace("onConsumeOk "+consumer+" "+tag);
            consumer.onConsumeOk(tag);
        }

        public function onCancelOk(event:ProtocolEvent):Void {
            var cancelOk:CancelOk = cast( event.command.method, CancelOk);
            var tag:String = cancelOk.consumertag;
            var consumer:BasicConsumer = consumers.get(tag);
            if (null != consumer) {
                consumers.remove(tag);
                consumer.onCancelOk(tag);
            }
        }

        public function onDeliver(event:ProtocolEvent):Void {
            var deliver:Deliver = cast( event.command.method, Deliver);
            var props:BasicProperties = cast( event.command.contentHeader, BasicProperties);
            #if flash9
            var body:ByteArray = cast( event.command.content, ByteArray);
            body.position = 0;
            #else
            var body:BytesInput = new BytesInput(event.command.content.getBytes()); body.bigEndian = true;
            #end
            var consumer:BasicConsumer = consumers.get(deliver.consumertag);
            consumer.onDeliver(deliver, props, body);
        }

        public function setReturn(r:Command->Return->Void):Void {
            returnCallback = r;
        }

        public function unsetReturn():Void {
            returnCallback = dummyReturn;
        }

        public function dummyReturn(c:Command, r:Return):Void {
        }

        public function onReturn(e:ProtocolEvent):Void {
            //trace("contentHeader "+Type.typeof(e.command.contentHeader));
            //trace("content length:"+e.command.content.length);
            // call the onReturn callback
            returnCallback(e.command, cast(e.command.method, Return));
        }

        public function onOpenOk(event:ProtocolEvent):Void {
            transition(STATE_OPEN);
        }

        /**
         *  This frees up any resources associated with this session.
         **/
        public function onCloseOk(event:ProtocolEvent):Void {
            transition(STATE_CONNECTION);
        }

        /**
         * Cheap hack of an FSM
         **/
        function transition(newState:Int):Void {
            switch (state) {
                case 0: stateError(newState);
                default: state = newState;
            }
        }

        /**
         * Renders an error according to the attempted transition.
         **/
        function stateError(newState:Int):Void {
            throw new IllegalStateError("Illegal state transition: " + state + " ---> " + newState);
        }
    }
