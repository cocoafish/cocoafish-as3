package com.cocoafish.sdk.test.scripts
{
	public class SessionHelper
	{
		public static var VALID_SESSION:int = 0;
		public static var USER_NOT_LOGIN:int = 1;
		public static var INVALID_RESPONSE:int = 2;
		
		private static var instance:SessionHelper = null;
		
		private var userId:String = null;
		
		public function SessionHelper()
		{
			if(instance != null)
			{
				throw new Error("Cannot create instance! Please use getInstance() instead.");
			}
		}
		
		public static function getInstance():SessionHelper
		{
			if(instance == null) 
			{
				instance = new SessionHelper();
			}
			return instance;
		}
		
		public function validateSession(data:Object):int
		{
			if(data) 
			{
				
			}
			else
			{
				return INVALID_RESPONSE;
			}
			return VALID_SESSION;
		}
		
		public function getUserId():String
		{
			return this.userId;
		}
		
		public function setUserId(userId:String):void
		{
			this.userId = userId;
		}
	}
}