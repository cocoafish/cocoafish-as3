package org.iotashan.oauth
{
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	
	import mx.utils.UIDUtil;
	
	import org.iotashan.utils.URLEncoding;

	/**
	 * The OAuthRequest class is the workhorse class.
	 * This is the class you will use to generate and sign your OAuth requests.
	*/
	public class OAuthRequest
	{
		private var _httpMethod:String;
		private var _requestURL:String;
		private var _requestParams:Object;
		private var _oauthReqParams:Object;
		private var _consumer:OAuthConsumer;
		private var _token:OAuthToken;
		private var _version:String;
		
		public static const HTTP_MEHTOD_HEAD:String = "HEAD";
		public static const HTTP_MEHTOD_GET:String = "GET";
		public static const HTTP_MEHTOD_POST:String = "POST";

		/**
		 * Constructor method.
		*/
		public function OAuthRequest(httpMethod:String,requestURL:String,requestParams:Object=null,consumer:OAuthConsumer=null,token:OAuthToken=null, version:String = "1.0")
		{
			_httpMethod = httpMethod;
			_requestURL = requestURL;
			if (!requestParams) {
				requestParams = {};
			}
			_requestParams = requestParams;
			_consumer = consumer;
			_token = token;
			_version = version;
			_oauthReqParams = new Object();
		}

		/**
		 * The HTTP request method used to send the request. Value MUST be uppercase, for example:
		 * HEAD, GET , POST, etc.
		*/
		public function get httpMethod():String {
			return _httpMethod;
		}

		/**
		 * @private
		*/
		public function set httpMethod(val:String):void {
			if (val != _httpMethod)
				_httpMethod = val;
		}

		/**
		 * The requestURL MUST include the scheme, authority, and path, and MUST exclude the query string.
		*/
		public function get requestURL():String {
			return _requestURL;
		}

		/**
		 * @private
		*/
		public function set requestURL(val:String):void {
			if (val != _requestURL)
				_requestURL = val;
		}

		/**
		 * The requestParams object must be a simple object with name value pairs, with the value being
		 * able to be converted to a string. Example: { title: "My Book title", pageCount: 10, inLibrary: true }
		*/
		public function get requestParams():Object {
			return _requestParams;
		}

		/**
		 * @private
		*/
		public function set requestParams(val:Object):void {
			if (val != _requestParams)
				_requestParams = val;
		}

		/**
		 *
		*/
		public function get consumer():OAuthConsumer {
			return _consumer;
		}

		/**
		 * @private
		*/
		public function set consumer(val:OAuthConsumer):void {
			_consumer = val;
		}

		/**
		 *
		*/
		public function get token():OAuthToken {
			return _token;
		}

		/**
		 * @private
		*/
		public function set token(val:OAuthToken):void {
			_token = val;
		}

		public function get version():String {
			return _version;
		}
		
		public function set version(val:String):void {
			_version = val;
		}
		
		public static const RESULT_TYPE_URL_STRING:String = "url";
		public static const RESULT_TYPE_POST:String = "post";
		public static const RESULT_TYPE_HEADER:String = "header";

		/**
		 * Builds out the request as you need to use it.
		*/
		public function buildRequest(signatureMethod:IOAuthSignatureMethod,resultType:String=RESULT_TYPE_URL_STRING,headerRealm:String=""):* {
			var curDate:Date = new Date();
			var uuid:String = UIDUtil.getUID(curDate);

			// first, let's add the oauth required params
			
			_oauthReqParams["oauth_nonce"] = uuid;
			_oauthReqParams["oauth_timestamp"] = String(curDate.time).substring(0, 10);
			_oauthReqParams["oauth_consumer_key"] = _consumer.key;
			_oauthReqParams["oauth_signature_method"] = signatureMethod.name;
			_oauthReqParams["oauth_version"] = _version;
				
			// if there already is a token, add that too
			if (_token) {
				_oauthReqParams["oauth_token"] = _token.key;
			} else {
				// if there is no token, remove any old ones
				if (_oauthReqParams.hasOwnProperty("oauth_token"))
					var checkDelete:Boolean = delete(_oauthReqParams.oauth_token);
			}

			// generate the signature
			var signature:String = signatureMethod.signRequest(this);
			_oauthReqParams["oauth_signature"] = signature;

			switch (resultType) {
				case RESULT_TYPE_URL_STRING:
					var ret1:String = _requestURL + "?" + getOAuthParameters();
					return ret1;
				break;
				case RESULT_TYPE_POST:
					var ret4:String = getOAuthParameters();
					return ret4;
				break;
				case RESULT_TYPE_HEADER:
					var data:String = "";

					data += "OAuth";
					if (headerRealm.length > 0)
						data += " realm=\"" + headerRealm + "\"";
					var params:String = "";
					for (var param:Object in _requestParams) {
						// if this is an oauth param, include it
//						if (param.toString().indexOf("oauth") == 0) {
						params += "," + param + "=\"" + URLEncoding.encode(_oauthReqParams[param]) + "\"";
//						}
					}
					//remove the comma
					if(params.length > 0) {
						params = params.substring(1, params.length);
					}
					data += " " + params;
					var ret3:URLRequestHeader = new URLRequestHeader("Authorization",data);
					return ret3;
				break;
			}
		}

		/**
		 * Returns a string that consists of all the parameters that need to be signed
		*/
		private function getSignableParameters():String {
			var aParams:Array = new Array();

			// loop over params, find the ones we need
			for (var param:String in _requestParams) {
//				if (param != "oauth_signature")
					aParams.push(param + "=" + URLEncoding.encode(_requestParams[param].toString()));
			}

			// put them in the right order
			aParams.sort();

			// return them like a querystring
			return aParams.join("&");
		}

		/**
		 * Returns a string that consists of all the parameters that need to be signed
		*/
		private function getOAuthParameters():String {
			var aParams:Array = new Array();

			// loop over params, find the ones we need
			for (var param:String in _oauthReqParams) {
				aParams.push(param + "=" + URLEncoding.encode(_oauthReqParams[param].toString()));
			}

			// put them in the right order
			aParams.sort();

			// return them like a querystring
			return aParams.join("&");
		}

		/**
		 * Returns the signable string
		*/
		public function getSignableString():String {
			// create the string to be signed
			var ret:String = URLEncoding.encode(_httpMethod.toUpperCase());
			ret += "&";
			ret += URLEncoding.encode(_requestURL);
			var params:String = getSignableParameters();
			if(params.length > 0) {
				ret += "&";
				ret += URLEncoding.encode(params);
			}
			return ret;
		}
	}
}