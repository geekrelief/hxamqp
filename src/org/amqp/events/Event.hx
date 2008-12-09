package org.amqp.events;

class Event { 

    public var type(default, null):String;
    
    public function new(_type:String) {
        type = _type;
    }    
}
