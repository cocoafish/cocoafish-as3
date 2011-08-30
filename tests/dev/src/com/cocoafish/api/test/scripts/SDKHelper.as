package com.cocoafish.api.test.scripts
{
	import com.cocoafish.api.Cocoafish;

	public class SDKHelper
	{
		private static var helper:SDKHelper = null;
		private var sdk:Cocoafish = null;
		
		public function SDKHelper()
		{
			if(helper != null)
			{
				throw new Error("Cannot create instance! Please use getInstance() instead.");
			}
		}
		
		public static function getInstance():SDKHelper
		{
			if(helper == null)
			{
				helper = new SDKHelper();
			}
			return helper;
		}
		
		public function getSDK(key:String, oauthSecret:String = ""):Cocoafish
		{
			if(sdk == null) {
				if(oauthSecret == "") {
					sdk = new Cocoafish(key);
				} else {
					sdk = new Cocoafish(key, oauthSecret);
				}
			}
			return sdk;
		}
	}
}