

	import flash.utils.ByteArray;

	import flash.display.Sprite;
	import flash.text.TextField;

	import flash.events.MouseEvent;
	import flash.events.Event;

	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	
	import pong.P1Event;
	import pong.PongConnection2;
	import pong.Puck;
	class Pong2 extends Sprite {

		static function main() {
			var p:Pong2 = new Pong2();
			flash.Lib.current.stage.addChild(p);
		}
		
		public var _stage:Stage;
		
		public var redScore:TextField;
		public var blueScore:TextField;

		public var rs:Int;
		public var bs:Int ;
		
		public var red:Sprite;
		public var blue:Sprite;
		
		public var puck:Puck;

		public var conn:PongConnection2;

		public var input:TextField;
		public var output:TextField;

        public function new() {
			super();

			_stage = flash.Lib.current.stage;

			input = new TextField();
			input.x = 30;
			input.y = 40;
			input.border = true;
			input.borderColor = 0;
			input.width = 200;
			input.height = 20;

			output = new TextField();
			output.x = 430;
			output.y = 40;
			output.border = true;
			output.borderColor = 0;
			output.width = 200;
			output.height = 20;


			init();
		
			addChild(input);
			addChild(output);
		}

		public function logInput(msg:String):Void {
			input.text = msg;
		}

		public function logOutput(msg:String):Void {
			output.text = msg;
		}


		public function createField():Void{
			var s:Shape = new Shape();
			var g:Graphics = s.graphics;	
			var w:Int = _stage.stageWidth;
			var h:Int = _stage.stageHeight;
			var y:Int, m:Int;
			// Create a border
			g.beginFill(0xffffff);
			g.lineStyle(3, 0, 1);
			g.moveTo(0, 0);
			g.lineTo(w, y = m = 0);	// set score variables
			g.lineTo(w, h);
			g.lineTo(0, h);
			g.lineTo(0, 0);
			g.endFill();

			// Create the net
			g.lineStyle (3,0,0.5);
			g.moveTo(w/2,0);
			g.lineTo(w/2, h);

			// Create some score fields
			redScore = new TextField();
			redScore.x = 190;
			redScore.y = 10;
			redScore.width  = 20;
			redScore.height = 20;
			redScore.borderColor = 0xff0000;
			redScore.border = true;
			
			blueScore = new TextField();
			blueScore.x = 590;
			blueScore.y = 10;
			blueScore.width = 20;
			blueScore.height = 20;
			blueScore.border = true;
			blueScore.borderColor = 0x0000ff;

			addChild(s);
			addChild(redScore);
			addChild(blueScore);
		}

		public function createPaddle(s:Sprite, color:UInt, func:Dynamic):Void { // enemy
			var g:Graphics = s.graphics;
			g.lineStyle(1, color, 1);
            g.moveTo(0, 0); 
 			g.lineTo(10, 0);
            g.lineTo(10, 60);
            g.lineTo(0, 60);
            g.lineTo(0, 0); 
			addChild(s);		
			if(func != null){
				addEventListener(Event.ENTER_FRAME, func);
			}
		}

		public function createRed():Void {
			red = new Sprite();
			createPaddle(red, 0xff0000, null);
		}

		public function updateRed(e:Event):Void {
			/*
			if (puck.y-34>red.y) {	// move the paddle
				red.y += 4;
			} else if (puck.y-30<red.y) {
				red.y -= 4;
			}
			*/
			//red.y = _stage.mouseY;

/*
			if (puck.x<red.x+10) {
				if (puck.y>red.y && puck.y<red.y+60) {	// if paddle hits ball
					puck.i *= -1;			// reverse the ball speed
					puck.j = (puck.y-(red.y+30))/2;
				} else {
					redScore.text = Std.string(++rs);			// increase score
					reset();				// reset the game
				}
			}		
*/
		}

		public function createPuck():Void {
			// draw the circle
			puck = new Puck();
			var g:Graphics = puck.graphics;
			g.beginFill(0x00fa00);
			g.drawCircle(0, 0, 5);
			addChild(puck);

//			addEventListener(Event.ENTER_FRAME, updatePuck);
		}

/*
		public function updatePuck(e:Event):void {
			puck.x += puck.i;
			puck.y += puck.j;
			if(puck.y > _stage.stageHeight -5 || puck.y < 5) {
				puck.j *= -1;
			}
		}
*/

		public function createBlue():Void {
			blue = new Sprite();
			createPaddle(blue, 0x0000ff, updateBlue);
		}

		public function updateBlue(e:Event):Void {
			blue.y  = _stage.mouseY;
			if(puck.x > blue.x) {
				if(puck.y > blue.y && puck.y < blue.y+60) {
//					puck.i *= -1;
//					puck.j = (puck.y -(blue.y+30))/2;
				} else {
					blueScore.text = Std.string(++bs);					
//					reset();
				}
			}			
		}

		public function reset():Void {
/*
			red.x = 10;
			red.y = _stage.stageHeight /2;	

			// position the ball in the center
			puck.x = _stage.stageWidth/2;
			puck.y = _stage.stageHeight/2;

			// give it a random direction and speed
			if (Math.random()*3>1) {
				puck.i = 8+Math.random()*3;
			} else {
				puck.i = -8-Math.random()*3;
			}
			puck.j = Math.random()*4;
*/
			blue.x = _stage.stageWidth-20;		// position on _stage
            blue.y = _stage.mouseY;
		}

		public function createConnection():Void{
			addEventListener(Event.ENTER_FRAME, updateConnection);

			conn = new PongConnection2();
			conn.addEventListener("p1", p1Event);

			conn.run();
		}

		public function p1Event(e:P1Event):Void {
			red.y = e.y;
			puck.i = e.p.i;
			puck.j = e.p.j;
			puck.x = e.p.x;
			puck.y = e.p.y;

			logInput("y:"+Std.string(red.y)+" p.i:"+Std.string(puck.i)+" p.j:"+Std.string(puck.j)+" p.x:"+Std.string(puck.x)+" p.y: "+Std.string(puck.y));
		}

		public function updateConnection(e:Event):Void {
			var data:ByteArray = new ByteArray();
			data.writeFloat(_stage.mouseY);
			conn.publish(data);
			logOutput("y: "+Std.string(_stage.mouseY));
		}

		public function init():Void {
			createConnection();
			createField();
			createRed();
			createPuck();
			createBlue();
			rs = bs = 0;
			reset();

			red.x = 10;
		}
	}
