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

    import neko.vm.Thread;
    import neko.vm.Mutex;
    import haxe.io.BytesInput;
    import haxe.io.BytesOutput;

    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Declare;

    class MouseData extends AbstractTest, 
        implements BasicConsumer, 
        implements LifecycleEventHandler {

        var consumerTag:String;
        var t:Thread;
        var mt:Thread;
        var mu:Mutex;

        public function new()
        {
			super();
            ax = "";
            routing_key = q2;
            mu = new Mutex();
        }

        public function run():Void {
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
            mt =  Thread.current();
            trace("create connection thread");
            t = neko.vm.Thread.create(callback(connection.onSocketData, mt));
            Thread.readMessage(true);
            runLoop();
            trace("sending close message");
            t.sendMessage(true);
            trace("block till done");
            Thread.readMessage(true);
            trace("run done");
       }

        public function runLoop():Void {
            trace("process in main thread");
            var count = 0;
            var degrees = 0;
            var factor = 3.14159/180;
            while(count < 10) {
                neko.Sys.sleep(0.01);
                trace("processing main thread "+count);
                count++;
                degrees++; 
                var b = new BytesOutput();
                b.bigEndian = true;
                b.writeFloat(Math.cos(degrees*factor) * 200 + 400);
                b.writeFloat(Math.sin(degrees*factor) * 200 + 400);
                publish(b.getBytes());
            }
        }

        public function afterOpen():Void {
            openChannel(setupConsumer);
        }

        override function openChannel(_callback:Dynamic):Void {
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
                //log("whoCares called");
            };

            sessionHandler = sessionManager.create();
            var open:Open = new Open();
            var queue:org.amqp.methods.queue.Declare = new org.amqp.methods.queue.Declare();
            queue.queue = q2;
            sessionHandler.rpc(new Command(open), whoCares);
            sessionHandler.rpc(new Command(queue), whoCares);

            sessionHandler2 = sessionManager.create();
            open = new Open();
            queue = new org.amqp.methods.queue.Declare();
            queue.queue = q;
            sessionHandler2.rpc(new Command(open), whoCares);
            sessionHandler2.rpc(new Command(queue), _callback);
        }

        public function setupConsumer(event:ProtocolEvent):Void {
			trace("setupConsumer");
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;
            sessionHandler2.register(consume, this);
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            trace("onConsumeOk: " + tag);
            mt.sendMessage("start");
        }

        public function onCancelOk(tag:String):Void {
            //log("onCancelOk: " + tag);
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:BytesInput):Void {
            var data:BytesInput = body;
            var x:Float = data.readFloat();
            var y:Float = data.readFloat();
			trace("-> "+x+", "+y);
        }
    }
