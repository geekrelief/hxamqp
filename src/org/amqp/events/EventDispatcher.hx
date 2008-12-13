package org.amqp.events;

    //import haxe.FastList;

    typedef Handlers = List<Handler>

    class EventDispatcher {

	var table:Hash<Handlers>;

        public function new(){ 
            table = new Hash();
        }

        public function addEventListener(type:String, h:Handler):Void {
            var hs:Handlers = table.get(type);
            if (hs == null) {
                hs = new Handlers();
                table.set(type, hs);
            }
            hs.add(h);
        }

        public function removeEventListener(type:String, h:Handler):Void {
            var hs:Handlers = table.get(type);
            if (hs != null) {
                for (f in hs) {
                    if (Reflect.compareMethods(f, h)) { // neko hack
                        hs.remove(f);
                        break;
                    }
                }
	    }
        }

        public function dispatchEvent(e:Event):Void {
            var hs:Handlers = table.get(e.type);
            if (hs != null) {
                for (f in hs) {
                    f(e);
                }
            }
        }
    }
