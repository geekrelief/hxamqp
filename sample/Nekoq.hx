	import nekoq.MouseData;
	
	class Nekoq {

		public var s:MouseData;
		public var i:Int;

		public static function main() {
			var n:Nekoq = new Nekoq(); // doesn't return
		}

		public function new() {
            trace("");
			i = 0;
			init();
		}

		public function createSim():Void{
            trace("createSim");
			s = new MouseData();
			//conn.addEventListener("p2", p2Event);

			s.run();
		}

/*
		public function p2Event(e:P2Event):Void {
			blue.y = e.y;
			logInput("y: "+Std.string(blue.y));
		}
		*/

		public function init():Void {
			createSim();
		}

		public function update():Void {
			trace("update "+i);
		}
	}
