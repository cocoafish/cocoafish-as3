package com.cocoafish.api {
	import com.adobe.serialization.json.JSON;
	import com.cocoafish.constants.Constants;
	import com.cocoafish.utils.UploadPostHelper;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import org.iotashan.oauth.IOAuthSignatureMethod;
	import org.iotashan.oauth.OAuthConsumer;
	import org.iotashan.oauth.OAuthRequest;
	import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
	import org.iotashan.oauth.OAuthToken;
	
	public class Cocoafish {
		var appKey:String = null;
		var sessionId:String = null;
		var consumer:OAuthConsumer = null;
		
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
			
			if(this.sessionId != null) {
				reqURL += "&" + Constants.SESSION_ID + this.sessionId;
			}
			
			var httpMethod:String = null;
			if(method == URLRequestMethod.DELETE) {
				httpMethod = URLRequestMethod.GET;
			} else if (method == URLRequestMethod.PUT) {
				httpMethod = URLRequestMethod.POST;
			} else {
				httpMethod = method;
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
			var loader:URLLoader = new URLLoader();
			
			if(photoRef != null) {
				request.requestHeaders.push(new URLRequestHeader(Constants.CONTENT_TYPE_KEY, Constants.CONTENT_TYPE_BINARY_VALUE + UploadPostHelper.getBoundary()));
				request.requestHeaders.push(new URLRequestHeader(Constants.CACHE_CTRL_KEY, Constants.CACHE_CTRL_VALUE));
				request.method = URLRequestMethod.POST;
				var fileType:String = photoRef.type;
				if(fileType == null) {
					fileType = extractFileType(photoRef.name);	//workaround for Mac issue
				}
				if(fileType != null) {
					fileType = Constants.IMAGE_KEY + "/" + fileType;
				}
				request.data = UploadPostHelper.getPostData( photoRef.name, photoRef.data, attrName, fileType, data);
				loader.dataFormat = URLLoaderDataFormat.BINARY;
			} else {
				request.requestHeaders.push(new URLRequestHeader(Constants.CONTENT_TYPE_KEY, Constants.CONTENT_TYPE_JSON_VALUE));
				request.method = httpMethod;
				if(data != null) {
					var param:Object = JSON.encode(data);
					if(param != null && param != "null" && param != "{}") {
						request.data = param;
					}
				}
				loader.dataFormat = URLLoaderDataFormat.TEXT;
			}
			
			//Request complete
			loader.addEventListener(Event.COMPLETE, function():void{
				completeCallback(loader, callback);
			});
			
			//IO Error
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
				errorCallback(loader, event, callback);
			});
			
			//send request
			loader.load(request);
		}
		
		private function buildOAuthRequest(url:String, method:String, params:Object) : URLRequest {
			var oauthRequest:OAuthRequest = new OAuthRequest(method, url, params, consumer, null);
			var signatureMethod:IOAuthSignatureMethod = new OAuthSignatureMethod_HMAC_SHA1();
			var oauthURL:String = oauthRequest.buildRequest(signatureMethod, OAuthRequest.RESULT_TYPE_URL_STRING);
			var request:URLRequest = new URLRequest(oauthURL);
			return request;
		}
		
		private function completeCallback(loader:URLLoader, callback:Function):void {
			var data:String = loader.data;
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
		
		private function errorCallback(loader:Object, event:Event, callback:Function):void {
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
		
		private function extractFileType(fileName:String):String {
			var extensionIndex:Number = fileName.lastIndexOf(".");
			if (extensionIndex == -1) {
				return null;
			} else {
				return fileName.substr(extensionIndex + 1 ,fileName.length);
			}
		}
	}
}