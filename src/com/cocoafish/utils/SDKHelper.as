package com.cocoafish.utils {
	import com.cocoafish.sdk.Cocoafish;

	public class SDKHelper {
		private static var helper:SDKHelper = new SDKHelper();
		
		private var appKey:String = null;
		private var oauthKey:String = null;
		private var oauthSecret:String = null;
		private var baseURL:String = null;
		private var sdk:Cocoafish = null;
		
		private var isInitialized:Boolean = false;
		
		public function SDKHelper() {
			if(helper != null)
				throw new Error("Cannot create SDKHelper instance. Please use getInstance() instead.");
		}
		
		public static function getInstance():SDKHelper {
			return helper;
		}
		
		public function initializeSDK(key:String, oauthSecret:String = null, baseURL:String = null):void {
			if(isInitialized) {
				throw new Error("The sdk has been already initialized.");
			}
			
			if(oauthSecret == null) {
				if(key == null) {
					throw new Error("Application key cannot be null.");
				}
				this.appKey = key;
			} else {
				if(key == null) {
					throw new Error("OAuth key cannot be null.");
				}
				this.oauthKey = key;
				this.oauthSecret = oauthSecret;
			}
			this.baseURL = baseURL;
			isInitialized = true;
		}
		
		public function getSDK():Cocoafish {
			if(!isInitialized) {
				throw new Error("The sdk has not been initialized. Please use initializeSDK() to initialize SDK.");
			}
			
			if(sdk == null) {
				if(oauthSecret == null) {
					sdk = new Cocoafish(appKey, null, baseURL);
				} else {
					sdk = new Cocoafish(oauthKey, oauthSecret, baseURL);
				}
			}
			return sdk;
		}
		
		public function resetSDK():void {
			sdk == null;
			oauthKey = null;
			oauthSecret = null;
			appKey = null;
			baseURL = null;
			isInitialized = false;
		}
	}
}