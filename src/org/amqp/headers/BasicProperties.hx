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
package org.amqp.headers;

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class BasicProperties extends ContentHeader {

        public function new() {
            classId = 60;
        }

        public var appid : String;
        public var clusterid : String;
        public var contentencoding : String;
        public var contenttype : String;
        public var correlationid : String;
        public var deliverymode : Int;
        public var expiration : String;
        public var headers : Hash<Dynamic>;
        public var messageid : String;
        public var priority : Int;
        public var replyto : String;
        public var timestamp : Date;
        public var type : String;
        public var userid : String;

        public override function readPropertiesFrom(reader:ContentHeaderPropertyReader):Void{
            contenttype = reader.readShortstr();
            contentencoding = reader.readShortstr();
            headers = reader.readTable();
            deliverymode = reader.readOctet();
            priority = reader.readOctet();
            correlationid = reader.readShortstr();
            replyto = reader.readShortstr();
            expiration = reader.readShortstr();
            messageid = reader.readShortstr();
            timestamp = reader.readTimestamp();
            type = reader.readShortstr();
            userid = reader.readShortstr();
            appid = reader.readShortstr();
            clusterid = reader.readShortstr();
        }

        public override function writePropertiesTo(writer:ContentHeaderPropertyWriter):Void{
            writer.writeShortstr(contenttype);
            writer.writeShortstr(contentencoding);
            writer.writeTable(headers);
            writer.writeOctet(deliverymode);
            writer.writeOctet(priority);
            writer.writeShortstr(correlationid);
            writer.writeShortstr(replyto);
            writer.writeShortstr(expiration);
            writer.writeShortstr(messageid);
            writer.writeTimestamp(timestamp);
            writer.writeShortstr(type);
            writer.writeShortstr(userid);
            writer.writeShortstr(appid);
            writer.writeShortstr(clusterid);
        }

/*
        public var appid(getAppid, setAppid) : String;
        public var clusterid(getClusterid, setClusterid) : String;
        public var contentencoding(getContentencoding, setContentencoding) : String;
        public var contenttype(getContenttype, setContenttype) : String;
        public var correlationid(getCorrelationid, setCorrelationid) : String;
        public var deliverymode(getDeliverymode, setDeliverymode) : Int;
        public var expiration(getExpiration, setExpiration) : String;
        public var headers(getHeaders, setHeaders) : Hash<Dynamic>;
        public var messageid(getMessageid, setMessageid) : String;
        public var priority(getPriority, setPriority) : Int;
        public var replyto(getReplyto, setReplyto) : String;
        public var timestamp(getTimestamp, setTimestamp) : Date;
        public var type(getType, setType) : String;
        public var userid(getUserid, setUserid) : String;
        var _contenttype:String;
        var _contentencoding:String;
        var _headers:Hash<Dynamic>;
        var _deliverymode:Int;
        var _priority:Int;
        var _correlationid:String;
        var _replyto:String;
        var _expiration:String;
        var _messageid:String;
        var _timestamp:Date;
        var _type:String;
        var _userid:String;
        var _appid:String;
        var _clusterid:String;

        public function getContenttype():String{return _contenttype;}
        public function getContentencoding():String{return _contentencoding;}
        public function getHeaders():Hash<Dynamic>{return _headers;}
        public function getDeliverymode():Int{return _deliverymode;}
        public function getPriority():Int{return _priority;}
        public function getCorrelationid():String{return _correlationid;}
        public function getReplyto():String{return _replyto;}
        public function getExpiration():String{return _expiration;}
        public function getMessageid():String{return _messageid;}
        public function getTimestamp():Date{return _timestamp;}
        public function getType():String{return _type;}
        public function getUserid():String{return _userid;}
        public function getAppid():String{return _appid;}
        public function getClusterid():String{return _clusterid;}

        public function setContenttype(x:String):String{_contenttype = x;	return x;}
        public function setContentencoding(x:String):String{_contentencoding = x;	return x;}
        public function setHeaders(x:Hash<Dynamic>):Hash<Dynamic>{_headers = x;	return x;}
        public function setDeliverymode(x:Int):Int{_deliverymode = x;	return x;}
        public function setPriority(x:Int):Int{_priority = x;	return x;}
        public function setCorrelationid(x:String):String{_correlationid = x;	return x;}
        public function setReplyto(x:String):String{_replyto = x;	return x;}
        public function setExpiration(x:String):String{_expiration = x;	return x;}
        public function setMessageid(x:String):String{_messageid = x;	return x;}
        public function setTimestamp(x:Date):Date{_timestamp = x;	return x;}
        public function setType(x:String):String{_type = x;	return x;}
        public function setUserid(x:String):String{_userid = x;	return x;}
        public function setAppid(x:String):String{_appid = x;	return x;}
        public function setClusterid(x:String):String{_clusterid = x;	return x;}

        public override function getClassId():Int {
            return 60;
        }

        public override function readPropertiesFrom(reader:ContentHeaderPropertyReader):Void{
            _contenttype = reader.readShortstr();
            _contentencoding = reader.readShortstr();
            _headers = reader.readTable();
            _deliverymode = reader.readOctet();
            _priority = reader.readOctet();
            _correlationid = reader.readShortstr();
            _replyto = reader.readShortstr();
            _expiration = reader.readShortstr();
            _messageid = reader.readShortstr();
            _timestamp = reader.readTimestamp();
            _type = reader.readShortstr();
            _userid = reader.readShortstr();
            _appid = reader.readShortstr();
            _clusterid = reader.readShortstr();
        }

        public override function writePropertiesTo(writer:ContentHeaderPropertyWriter):Void{
            writer.writeShortstr(_contenttype);
            writer.writeShortstr(_contentencoding);
            writer.writeTable(_headers);
            writer.writeOctet(_deliverymode);
            writer.writeOctet(_priority);
            writer.writeShortstr(_correlationid);
            writer.writeShortstr(_replyto);
            writer.writeShortstr(_expiration);
            writer.writeShortstr(_messageid);
            writer.writeTimestamp(_timestamp);
            writer.writeShortstr(_type);
            writer.writeShortstr(_userid);
            writer.writeShortstr(_appid);
            writer.writeShortstr(_clusterid);
        }
*/
    }
