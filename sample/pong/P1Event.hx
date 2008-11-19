package pong;
	import flash.events.Event;

	class P1Event extends Event {
		public var y:Float;
		public var p:Puck;
		public function new(_y:Float, _p:Puck){
			super("p1");
			y=_y;
			p=_p;
		}
	}
