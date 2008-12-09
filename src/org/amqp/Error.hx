package org.amqp;

class Error {
	
	var msg:String;
	var id:Int;

	public function new(?_msg:String="", ?_id:Int=0){
		msg = _msg;
		id = _id;
	}

	public function toString():String {
		return id+" "+msg;
	}
}
