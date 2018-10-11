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

//    import flash.events.TimerEvent;
    import flash.utils.ByteArray;

    import org.amqp.BasicConsumer;
    import org.amqp.Command;
    import org.amqp.LifecycleEventHandler;
    import org.amqp.ProtocolEvent;
    import org.amqp.headers.BasicProperties;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.queue.Declare;

	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Graphics;

    class PublishSubscribeTest2 extends AbstractTest implements BasicConsumer implements LifecycleEventHandler {
        var consumerTag:String;
		public var root:DisplayObjectContainer;
		public var t:TextField;
		public var t2:TextField;

		public var player1:Sprite;
		public var player2:Sprite;

        public function new(_root:DisplayObjectContainer, _t:TextField, _t2:TextField)
        {
			super();
            ax = "";
            //q = "q-" + new Date().getMilliseconds();
            routing_key = q2;

			root = _root;
			t = _t;
			t2 = _t2;

			player1 = new Sprite();
			drawPlayer(player1, 0x0000ff, 0, 0);
			player2 = new Sprite();
			drawPlayer(player2, 0xff0000, 0, 0);
			root.addChild(player1);
			root.addChild(player2);
        }

		public function drawPlayer(s:Sprite, c:UInt, x:Float, y:Float):Void {
			var g:Graphics = s.graphics;
			g.beginFill(c);
			g.moveTo(-2.5, -2.5);
			g.drawCircle(0, 0, 5);
			g.endFill();
			s.x = x;
			s.y = y;
		}

        public function run():Void {
			//log("PublishSubscribeTest run");
            connection.start();
            connection.baseSession.registerLifecycleHandler(this);
			connection2.start();
        }

        public function afterOpen():Void {
			//log("PublishSubscribeTest afterOpen");
            openChannel(runPublishTest);
        }

        override function openChannel(_callback:Dynamic):Void {
			//log("PublishSubscribeTest openChannel");
            var whoCares:Dynamic = function(event:ProtocolEvent):Void{
                //log("whoCares called");
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
			//log("PublishSubscribeTest runPublishTest");
            var consume:Consume = new Consume();
            consume.queue = q;
            consume.noack = true;
            sessionHandler2.register(consume, this);

			root.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

//        public function cancel(event:TimerEvent):Void {
   //         log("Initiating cancellation "+consumerTag);
            //assertNotNull(consumerTag);
    //        sessionHandler.unregister(consumerTag);
 //       }

        public function onConsumeOk(tag:String):Void {
            consumerTag = tag;
            //log("onConsumeOk: " + tag);
        }

        public function onCancelOk(tag:String):Void {
            //log("onCancelOk: " + tag);
        }

        public function onDeliver(method:Deliver,
                                  properties:BasicProperties,
                                  body:ByteArray):Void {
            //log("onDeliver --> " + body.readUTF()+" "+routing_key+", "+method.routingkey);
            var data:ByteArray = body;
            data.position = 0;
            if (data.bytesAvailable > 0) {
                var x:Float = data.readFloat();
                var y:Float = data.readFloat();
				t2.text = ("GetTest: onMouseGetOk ----> "+x+", "+y);
				drawPlayer(player2, 0xff0000, x, y);
            }
        }

		public function onMouseMove(e:MouseEvent):Void {
			 var data:ByteArray = new ByteArray();
            data.writeFloat(e.stageX);
            data.writeFloat(e.stageY);
			t.text = "My mouse "+e.stageX+", "+e.stageY;
			drawPlayer(player1, 0x0000ff, e.stageX, e.stageY);
            publish(data);
		}
    }
