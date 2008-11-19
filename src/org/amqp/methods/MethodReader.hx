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
package org.amqp.methods;

    import org.amqp.Method;
    import flash.utils.IDataInput;
    import org.amqp.methods.connection.Start;
    import org.amqp.methods.connection.Secure;
    import org.amqp.methods.connection.Tune;
    import org.amqp.methods.connection.Open;
    import org.amqp.methods.connection.Close;
    import org.amqp.methods.connection.Redirect;
    import org.amqp.methods.channel.Open;
    import org.amqp.methods.channel.Flow;
    import org.amqp.methods.channel.Close;
    import org.amqp.methods.channel.Alert;
    import org.amqp.methods.exchange.Declare;
    import org.amqp.methods.exchange.Delete;
    import org.amqp.methods.queue.Declare;
    import org.amqp.methods.queue.Bind;
    import org.amqp.methods.queue.Purge;
    import org.amqp.methods.queue.Delete;
    import org.amqp.methods.basic.Qos;
    import org.amqp.methods.basic.Consume;
    import org.amqp.methods.basic.Cancel;
    import org.amqp.methods.basic.Get;
    import org.amqp.methods.basic.Publish;
    import org.amqp.methods.basic.Return;
    import org.amqp.methods.basic.Deliver;
    import org.amqp.methods.basic.GetEmpty;
    import org.amqp.methods.basic.Ack;
    import org.amqp.methods.basic.Reject;
    import org.amqp.methods.basic.Recover;
    import org.amqp.methods.tx.Select;
    import org.amqp.methods.tx.Commit;
    import org.amqp.methods.tx.Rollback;

	
	import flash.Error;

    /**
     *   THIS IS AUTO-GENERATED CODE. DO NOT EDIT!
     **/
    class MethodReader
     {
        
        public static function readMethodFrom(input:IDataInput):Method {

            var classId:Int = input.readShort();
              var methodId:Int = input.readShort();
              var method:Method;

              switch (classId) {
                case 10:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.connection.Start();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.connection.StartOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.connection.Secure();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.connection.SecureOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 30: {
                            method = new org.amqp.methods.connection.Tune();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 31: {
                            method = new org.amqp.methods.connection.TuneOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 40: {
                            method = new org.amqp.methods.connection.Open();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 41: {
                            method = new org.amqp.methods.connection.OpenOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 60: {
                            method = new org.amqp.methods.connection.Close();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 61: {
                            method = new org.amqp.methods.connection.CloseOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 50: {
                            method = new org.amqp.methods.connection.Redirect();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }


                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);

                    }
                    case 20:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.channel.Open();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.channel.OpenOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.channel.Flow();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.channel.FlowOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 40: {
                            method = new org.amqp.methods.channel.Close();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 41: {
                            method = new org.amqp.methods.channel.CloseOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 30: {
                            method = new org.amqp.methods.channel.Alert();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);


                    }
                    case 40:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.exchange.Declare();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.exchange.DeclareOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.exchange.Delete();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.exchange.DeleteOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);
                    }
                    case 50:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.queue.Declare();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.queue.DeclareOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.queue.Bind();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.queue.BindOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 30: {
                            method = new org.amqp.methods.queue.Purge();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 31: {
                            method = new org.amqp.methods.queue.PurgeOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 40: {
                            method = new org.amqp.methods.queue.Delete();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 41: {
                            method = new org.amqp.methods.queue.DeleteOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }
                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);

                    }
                    case 60:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.basic.Qos();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.basic.QosOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.basic.Consume();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.basic.ConsumeOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 30: {
                            method = new org.amqp.methods.basic.Cancel();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 31: {
                            method = new org.amqp.methods.basic.CancelOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 70: {
                            method = new org.amqp.methods.basic.Get();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 71: {
                            method = new org.amqp.methods.basic.GetOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 40: {
                            method = new org.amqp.methods.basic.Publish();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 50: {
                            method = new org.amqp.methods.basic.Return();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 60: {
                            method = new org.amqp.methods.basic.Deliver();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 72: {
                            method = new org.amqp.methods.basic.GetEmpty();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 80: {
                            method = new org.amqp.methods.basic.Ack();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 90: {
                            method = new org.amqp.methods.basic.Reject();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 100: {
                            method = new org.amqp.methods.basic.Recover();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);

                    }
                    case 90:
                    switch(methodId) {

                        case 10: {
                            method = new org.amqp.methods.tx.Select();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 11: {
                            method = new org.amqp.methods.tx.SelectOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 20: {
                            method = new org.amqp.methods.tx.Commit();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 21: {
                            method = new org.amqp.methods.tx.CommitOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }case 30: {
                            method = new org.amqp.methods.tx.Rollback();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                        case 31: {
                            method = new org.amqp.methods.tx.RollbackOk();
                            method.readArgumentsFrom(new MethodArgumentReader(input));
                            return method;
                        }

                		default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);
                    }
                    
                
                default:throw new Error("Could not resolve method: classid = " + classId + ", methodid = " + methodId);
              }
        }      
    }
