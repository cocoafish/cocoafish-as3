package com.cocoafish.constants {
	public class Constants {
		//URLs
		public static var BASE_URL:String = "http://api.cocoafish.com/v1/";
		public static var BASE_URL_SECURE:String = "https://api.cocoafish.com/v1/";
		public static var KEY:String = "?key=";
		public static var SESSION_ID:String = "_session_id";
		
		//Parameters
		public static var PHOTO_KEY:String = "photo";
		public static var FILE_KEY:String = "file";
		public static var SUPPRESS_RESPONSE_KEY:String = "suppress_response_codes";
		
		//Request headers
		public static var CONTENT_TYPE_KEY:String = "Content-Type";
		public static var CONTENT_TYPE_JSON_VALUE:String = "application/json;charset=utf-8";
		public static var ACCEPT_KEY:String = "Accept";
		public static var ACCEPT_VALUE:String = "application/json";
		public static var CACHE_CTRL_KEY:String = "Cache-Control";
		public static var CACHE_CTRL_VALUE:String = "no-cache";
//		public static var IMAGE_KEY:String = "image";
		
		//Others
		public static var PARAMETER_DELIMITER:String = "&";
		public static var PARAMETER_EQUAL:String = "=";
	}
}