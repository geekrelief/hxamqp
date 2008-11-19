package samp;
	import flash.events.Event;

	class MyEvent extends Event {
		public var msg:String;
		public function new(type:String, _msg:String){
			super(type);
			msg=_msg;
		}
	}
