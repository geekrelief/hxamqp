import neko.vm.Thread;
import org.amqp.impl.SessionStateHandler;

class Buserror {

    static function main(){
        var b = new Buserror();
        b.run();
    }

    var h:Hash<SessionStateHandler>;
    var t:Thread;

    public function new(){
        h = new Hash();
    }

    public function run():Void{
        trace("creating thread");
        t = Thread.create(threadMain);
        trace("sleeping in main");
        neko.Sys.sleep(1);
    }

    public function threadMain():Void{
        trace("in thread");
        var t = this;
        var l = function():Void { trace(haxe.Stack.callStack()); trace("--access hash "+t.h); };
        l();
    }
}
