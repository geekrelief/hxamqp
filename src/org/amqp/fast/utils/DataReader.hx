package org.amqp.fast.utils;

import haxe.Unserializer;
import haxe.io.Bytes;

#if flash9
import flash.utils.ByteArray;
class DataReader {
    var b:ByteArray;

    public function new(?_b:ByteArray, ?pos:Int = 0){
        b = _b;
        if(b != null)
            b.position = pos;
    }

    public function select(_b:ByteArray, ?pos:Int = 0) {
        b = _b;
        b.position = pos;
    }

    public function bytes(?len:Int = -1):ByteArray {
        if(len == -1 || len > b.bytesAvailable) {
            len = b.bytesAvailable;
        }

        var r = new ByteArray();
        b.readBytes(r, 0, len);
        return r;
    }


    inline public function string():String {
        return b.readUTFBytes(long());
    }

    inline public function object(decompress:Bool = false):Dynamic {
        // decompress if object was compressed
        if(decompress) {
            var by:ByteArray = bytes(long());
            by.uncompress();
            return Unserializer.run(by.readUTFBytes(long()));
        } else {
            return Unserializer.run(string());
        }
    }

    inline public function byte():Int {
        return b.readByte();
    }

    inline public function short():Int {
        return b.readShort();
    }

    inline public function long():Int {
        return b.readInt();
    }

    inline public function float():Float {
        return b.readFloat();
    }

    inline public function double():Float {
        return b.readDouble();
    }

    inline public function bool():Bool {
        return (byte() == 1);
    }
}
#elseif neko
import haxe.io.BytesInput;
import haxe.io.Bytes;
class DataReader {
    var b:BytesInput;

    public function new(?_b:BytesInput){
        b = _b;
    }

    public function select(?_b:BytesInput){
        b = _b;
    }

    public function bytes(?len:Int = -1):Bytes {
        if(len == -1) {
            return b.readAll();
        } else {
            return b.read(len);
        }
    }

    inline public function string():String {
        return b.readString(long());
    }

    inline public function object(decompress:Bool = false):Dynamic {
        // decompress if object was compressed
        if(decompress) {
            return Unserializer.run(new BytesInput(neko.zip.Uncompress.run(bytes(long()))).readString(long()));
        } else {
            return Unserializer.run(string());
        }
    }

    inline public function byte():Int {
        return b.readByte();
    }

    inline public function short():Int {
        return b.readInt16();
    }

    public function long():Int {
        return b.readInt31();
    }

    inline public function float():Float {
        return b.readFloat();
    }

    inline public function double():Float {
        return b.readDouble();
    }

    inline public function bool():Bool {
        return (byte() == 1);
    }
}
#end
