import flash.net.Socket;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.Vector;
import flash.Lib;

class Bare {

    static function main(){
        new Bare();
    }

    var s:Socket;
    var maxRuns:Int;
    var trun:Int;
    var beginTime:Float;
    var startTime:Float;
    var endTime:Float;
    var tpool:Vector<Vector<Float>>;
    var timings:Vector<Float>;

    public function new() {
        // create a socket
        s = new Socket();
        s.addEventListener(Event.CONNECT, onSocketConnect);
        s.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        s.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):Void { trace(e); });
        s.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):Void { trace(e); });

        maxRuns = 10;
        trun = 0;
        tpool = new Vector();
        for(i in 0...maxRuns) {
            tpool[i] = new Vector();
        }
        timings = tpool[0];
        s.connect("10.0.0.17", 6783);
        trace("connecting");
    }

    public function onSocketConnect(e:Event) {
        //start cycle
        trace("connected -> starting");
        beginTime = startTime = Lib.getTimer();
        for(i in 0...20)
            s.writeFloat(1.1);
        s.flush();
    }
    public function onSocketData(e:ProgressEvent) {
        // got data repeat cycle
        endTime = Lib.getTimer();
        timings.push(endTime - startTime);
        if(trun < maxRuns) {
            if(endTime < 10000+beginTime) {
                startTime = Lib.getTimer();
                s.writeByte(1);
                s.flush();
            } else {
                var sum:Float = 0;
                for(t in timings) {
                    sum += t;
                }
                trace("run: "+trun+" samples: "+timings.length+" avg roundtrip (ms): "+(sum / timings.length)+" sample time (secs): "+((endTime-beginTime)/1000.0));
                ++trun;
                if(trun < maxRuns) {
                    timings = tpool[trun];
                    beginTime = startTime = Lib.getTimer();
                    s.writeByte(1);
                    s.flush();
                }
            }
        } else {
            trace("done");
        }
    }
}
