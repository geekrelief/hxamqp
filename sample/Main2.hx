

	import flash.display.Sprite;
	import flash.text.TextField;
	import samp.PublishSubscribeTest2;
	import samp.MyEvent;
	
	class Main2 extends Sprite {
        static function main() {
/*
			var t:TextField = new TextField();
			t.x = 0;
			t.y = 0;
			t.multiline = true;
			t.width = 800;
			t.height = 600;
			t.background = true;
			t.backgroundColor = 0xffffff;
			t.selectable = true;
			addChild(t);
*/
			var t2:TextField = new TextField();
			t2.x = 300;
			t2.y = 0;
			t2.multiline = true;
			t2.width = 200;
			t2.height = 25;
			t2.background = true;
			t2.backgroundColor = 0xfafafa;
			t2.selectable = true;
			flash.Lib.current.stage.addChild(t2);

			var t3:TextField = new TextField();
			t3.x = 300;
			t3.y = 25;
			t3.multiline = true;
			t3.width = 200;
			t3.height = 25;
			t3.background = true;
			t3.backgroundColor = 0xefefef;
			t3.selectable = true;
			flash.Lib.current.stage.addChild(t3);

    		var a:PublishSubscribeTest2 = new PublishSubscribeTest2(flash.Lib.current.stage, t2, t3); 
//			a.addEventListener("log", function(e:MyEvent):Void { t.appendText("\n"+e.msg);});
			//a.addEventListener("log", function(e:MyEvent):void { t.text = ("\n"+e.msg);});
			a.run();
		}
	}
