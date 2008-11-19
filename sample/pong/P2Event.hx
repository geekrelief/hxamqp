package pong;
	import flash.events.Event;

	class P2Event extends Event {
		public var y:Float;
		public function new(_y:Float){
			super("p2");
			y=_y;
		}
	}
