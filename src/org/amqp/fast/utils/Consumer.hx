// for dependency (constructor) injection with Consume method

package org.amqp.fast.utils;

import org.amqp.BasicConsumer;
#if flash9
import flash.utils.ByteArray;
#else
import haxe.io.BytesInput;
#end

import org.amqp.headers.BasicProperties;
import org.amqp.methods.basic.Deliver;

#if flash9
typedef DeliverSig = Deliver -> BasicProperties -> ByteArray -> Void
#else
typedef DeliverSig = Deliver -> BasicProperties -> BytesInput -> Void
#end

class Consumer implements BasicConsumer {

    private var dh:DeliverSig;
    private var conh:String->Void;
    private var canh:String->Void;

    public function new(?_onDeliver:DeliverSig, ?_onConsumeOk:String -> Void, ?_onCancelOk:String -> Void) {
        dh = ddh; 
        if(_onDeliver != null)
            dh = _onDeliver;

        conh = dconh;
        if(_onConsumeOk != null)
            conh = _onConsumeOk;

        canh = dcanh;
        if(_onCancelOk != null)
            canh = _onCancelOk;
    }

    #if flash9
    private function ddh(method:Deliver, properties:BasicProperties, body:ByteArray):Void {}
    public function onDeliver(method:Deliver, properties:BasicProperties, body:ByteArray):Void {
    #else
    private function ddh(method:Deliver, properties:BasicProperties, body:BytesInput):Void {}
    public function onDeliver(method:Deliver, properties:BasicProperties, body:BytesInput):Void {
    #end
        dh(method, properties, body);
    }

    private function dconh(tag:String):Void {}
    public function onConsumeOk(tag:String):Void {
        conh(tag);
    }

    private function dcanh(tag:String):Void {}
    public function onCancelOk(tag:String):Void {
        canh(tag);
    }
}
