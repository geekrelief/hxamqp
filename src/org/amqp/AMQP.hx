/**
 * ---------------------------------------------------------------------------
 *   Copyright (C) 2008 0x6e6562
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 * ---------------------------------------------------------------------------
 **/
package org.amqp;


    #if flash9
    import flash.utils.ByteArray;
    #else
    import haxe.io.Bytes;
    import haxe.io.BytesOutput;
    #end

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class AMQP
     {
        inline public static var FRAME_METHOD:Int = 1;
        inline public static var FRAME_HEADER:Int = 2;
        inline public static var FRAME_BODY:Int = 3;
        inline public static var FRAME_OOB_METHOD:Int = 4;
        inline public static var FRAME_OOB_HEADER:Int = 5;
        inline public static var FRAME_OOB_BODY:Int = 6;
        inline public static var FRAME_TRACE:Int = 7;
        inline public static var FRAME_HEARTBEAT:Int = 8;
        inline public static var FRAME_MIN_SIZE:Int = 4096;
        inline public static var FRAME_END:Int = 206;
        inline public static var REPLY_SUCCESS:Int = 200;
        inline public static var NOT_DELIVERED:Int = 310;
        inline public static var CONTENT_TOO_LARGE:Int = 311;
        inline public static var CONNECTION_FORCED:Int = 320;
        inline public static var INVALID_PATH:Int = 402;
        inline public static var ACCESS_REFUSED:Int = 403;
        inline public static var NOT_FOUND:Int = 404;
        inline public static var RESOURCE_LOCKED:Int = 405;
        inline public static var FRAME_ERROR:Int = 501;
        inline public static var SYNTAX_ERROR:Int = 502;
        inline public static var COMMAND_INVALID:Int = 503;
        inline public static var CHANNEL_ERROR:Int = 504;
        inline public static var RESOURCE_ERROR:Int = 506;
        inline public static var NOT_ALLOWED:Int = 530;
        inline public static var NOT_IMPLEMENTED:Int = 540;
        inline public static var INTERNAL_ERROR:Int = 541;
        inline public static var PROTOCOL_MAJOR:Int = 8;
        inline public static var PROTOCOL_MINOR:Int = 0;
        inline public static var PORT:Int = 5672;

        #if flash9
        public static function generateHeader():ByteArray {
            var buffer =  new ByteArray();
            buffer.writeUTFBytes("AMQP");
        #else
        public static function generateHeader():Bytes {
            var buffer:BytesOutput = new BytesOutput(); buffer.bigEndian = true;
            buffer.writeString("AMQP");
        #end
            buffer.writeByte(1);
            buffer.writeByte(1);
            buffer.writeByte(PROTOCOL_MAJOR);
            buffer.writeByte(PROTOCOL_MINOR);
            #if flash9
            return buffer;
            #else
            return buffer.getBytes();
            #end
        }
    }
