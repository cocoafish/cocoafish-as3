package com.cocoafish.sdk {
	import com.adobe.serialization.json.JSON;
	import com.cocoafish.constants.Constants;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayList;
	import mx.utils.URLUtil;
	
	import org.iotashan.oauth.IOAuthSignatureMethod;
	import org.iotashan.oauth.OAuthConsumer;
	import org.iotashan.oauth.OAuthRequest;
	import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
	
	public class Cocoafish {
		var appKey:String = null;
		var sessionId:String = null;
		var consumer:OAuthConsumer = null;
		var listeners:ArrayList = null;
		
		public function Cocoafish(key:String, oauthSecret:String = "") {
			if(oauthSecret == "") {
				this.appKey = key;
			} else {
				consumer = new OAuthConsumer(key, oauthSecret);
			}
		}
		
		public function sendRequest(url:String, method:String, data:Object, useSecure:Boolean, callback:Function):void {
			var baseURL:String = Constants.BASE_URL;
			if(useSecure) {
				baseURL = Constants.BASE_URL_SECURE;
			}
			
			var reqURL:String = null;
			if(appKey != null) {
				reqURL = baseURL + url + Constants.KEY + appKey;
			} else if(consumer != null) {
				reqURL = baseURL + url;
			}
			
			var httpMethod:String = null;
			if(method == URLRequestMethod.DELETE) {
				httpMethod = URLRequestMethod.GET;
			} else if (method == URLRequestMethod.PUT) {
				httpMethod = URLRequestMethod.POST;
			} else {
				httpMethod = method;
			}
			
			//append suppress_response_codes=true
			if(data == null) {
				data = new Object();
			}
			if(!data.hasOwnProperty(Constants.SUPPRESS_RESPONSE_KEY)) {
				data[Constants.SUPPRESS_RESPONSE_KEY] = true;
			}
			
			var photoRef:FileReference = null;
			var attrName:String = Constants.PHOTO_KEY;
			if(data != null) {
				photoRef = data.photo;
				if(photoRef != null) {
					delete(data.photo);
					attrName= Constants.PHOTO_KEY;
				} else {
					photoRef = data.file;
					if(photoRef != null) {
						delete(data.file);
						attrName= Constants.FILE_KEY;
					}
				}
			}
			
			var request:URLRequest = null;
			if(appKey != null) {
				//append session id
				if(this.sessionId != null) {
					reqURL += Constants.PARAMETER_DELIMITER + Constants.SESSION_ID + Constants.PARAMETER_EQUAL + this.sessionId;
				}
				request = new URLRequest(reqURL);
			} else if(consumer != null) {
				if(photoRef != null) {
					request = this.buildOAuthRequest(reqURL, httpMethod, null);
				} else {
					request = this.buildOAuthRequest(reqURL, httpMethod, data);
				}
			} else {
				//TODO: error handling
			}
			
			request.requestHeaders.push(new URLRequestHeader(Constants.ACCEPT_KEY, Constants.ACCEPT_VALUE));
			
			if(photoRef != null) {
				request.requestHeaders.push(new URLRequestHeader(Constants.CACHE_CTRL_KEY, Constants.CACHE_CTRL_VALUE));
				request.method = URLRequestMethod.POST;
				//append session id
				if(this.sessionId != null) {
					if(request.url.indexOf(Constants.SESSION_ID) == -1) {
						request.url += Constants.PARAMETER_DELIMITER + Constants.SESSION_ID + Constants.PARAMETER_EQUAL + this.sessionId;
					}
				}
				/*
				var fileType:String = photoRef.type;
				if(fileType == null) {
					fileType = extractFileType(photoRef.name);	//workaround for Mac issue
				}
				if(fileType != null) {
					fileType = Constants.IMAGE_KEY + "/" + fileType;
				}
				*/
				var urlVars:URLVariables = new URLVariables();
				for(var name:String in data) {
					urlVars[name] = data[name];
				}
				request.data = urlVars;
				
				//Request complete
				photoRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:DataEvent):void{
					completeCallback(event.data, callback);
				});
				
				//IO Error
				photoRef.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
					errorCallback(event, callback);
				});
				
				//Register upload progress listeners
				registerProgressListeners(photoRef);
				
				photoRef.upload(request, attrName);
			} else {
				var loader:URLLoader = new URLLoader();
				request.method = httpMethod;
				if(data != null) {
					var params:String = getURLParameters(data);
					if(params != null && params.length > 0) {
						if(httpMethod == URLRequestMethod.GET) {
							request.url += Constants.PARAMETER_DELIMITER + params;
						} else {
							request.data = params;
						}
					}
				}
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				
				//Request complete
				loader.addEventListener(Event.COMPLETE, function():void{
					completeCallback(loader.data, callback);
				});
				
				//IO Error
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
					errorCallback(event, callback);
				});
				
				//send request
				loader.load(request);
			}
		}
		
		public function addProgressListener(listener:Function):void {
			if(listeners == null) {
				listeners = new ArrayList();
			}
			listeners.addItem(listener);
		}
		
		public function removeProgressListener(listener:Function):void {
			if(listeners != null) {
				listeners.removeItem(listener);
			}
		}
		
		private function registerProgressListeners(fileRef:FileReference):void {
			if(listeners != null) {
				for(var i:int = 0; i< listeners.length; i++) {
					fileRef.addEventListener(ProgressEvent.PROGRESS, listeners.getItemAt(i) as Function);
				}
			}
		}
		
		private function buildOAuthRequest(url:String, method:String, params:Object) : URLRequest {
			//append session id
			if(this.sessionId != null) {
				if(params == null) {
					params = new Object();
				}
				params[Constants.SESSION_ID] = this.sessionId;
			}
			
			var oauthRequest:OAuthRequest = new OAuthRequest(method, url, params, consumer, null);
			var signatureMethod:IOAuthSignatureMethod = new OAuthSignatureMethod_HMAC_SHA1();
			var oauthURL:String = oauthRequest.buildRequest(signatureMethod, OAuthRequest.RESULT_TYPE_URL_STRING);
			var request:URLRequest = new URLRequest(oauthURL);
			return request;
		}
		
		private function completeCallback(data:String, callback:Function):void {
			if(data != null) {
				var json:Object = JSON.decode(data);
				var sessionId:String = parseSessionId(json);
				if(sessionId != null) {
					setSessionId(sessionId);
				}
				json.json = data;
				callback(json);
			} else {
				callback(new Object());
			}
		}
		
		private function errorCallback(event:Event, callback:Function):void {
			callback(event);
		}
		
		private function parseSessionId(data:Object):String {
			if(data != null) {
				var meta:Object = data.meta;
				if(meta != null) {
					var sessionId:String = meta.session_id;
					if(sessionId != null) {
						return sessionId;
					}
				}
			}
			return null;
		}
		
		private function setSessionId(sessionId:String):void {
			this.sessionId = sessionId;
		}
		
		/*
		private function extractFileType(fileName:String):String {
			var extensionIndex:Number = fileName.lastIndexOf(".");
			if (extensionIndex == -1) {
				return null;
			} else {
				return fileName.substr(extensionIndex + 1 ,fileName.length);
			}
		}
		*/
		
		private function getURLParameters(data:Object):String {
			var params:String = URLUtil.objectToString(data, Constants.PARAMETER_DELIMITER);
			return params;
		}
	}
}