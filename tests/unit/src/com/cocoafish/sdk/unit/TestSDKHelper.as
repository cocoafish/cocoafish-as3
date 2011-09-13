package com.cocoafish.sdk.unit {
	import com.cocoafish.utils.SDKHelper;
	
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;
	
	public class TestSDKHelper extends TestCase {
		
		public function TestSDKHelper(methodName:String) {
			super(methodName);
		}
		
		public static function Suite():TestSuite {    
			var suite:TestSuite = new TestSuite();    
			
			   
			suite.addTest(new TestSDKHelper("testCreateSDKWithAppKey"));
			suite.addTest(new TestSDKHelper("testCreateSDKWithOAuth"));
			suite.addTest(new TestSDKHelper("testCreateSDKWithoutInitialize")); 
			suite.addTest(new TestSDKHelper("testInitializeSDKWithNullAppKey"));
			suite.addTest(new TestSDKHelper("testInitializeSDKWithNullOAuthKey"));
			suite.addTest(new TestSDKHelper("testMultipleInitializeSDK"));
			suite.addTest(new TestSDKHelper("testCreateSDKHelperWithConstructor"));
			return suite;    
		}
		
		override public function setUp():void {
			super.setUp();
			SDKHelper.getInstance();
		}
		
		override public function tearDown():void {
			super.tearDown();
		}
		
		public function testCreateSDKWithAppKey():void {
			SDKHelper.getInstance().resetSDK();
			SDKHelper.getInstance().initializeSDK("test_app_key");
			assertNotNull(SDKHelper.getInstance().getSDK());
		}
		
		public function testCreateSDKWithOAuth():void {
			SDKHelper.getInstance().resetSDK();
			SDKHelper.getInstance().initializeSDK("test_oauth_key", "test_oauth_secret");
			assertNotNull(SDKHelper.getInstance().getSDK());
		}
		
		public function testCreateSDKWithoutInitialize():void {
			SDKHelper.getInstance().resetSDK();
			try {
				SDKHelper.getInstance().getSDK();
			} catch(e:Error) {
				assertNotNull(e);
				assertEquals(e.message, "The sdk has not been initialized. Please use initializeSDK() to initialize SDK.");
				trace(e);
			}
		}
		
		public function testInitializeSDKWithNullAppKey():void {
			SDKHelper.getInstance().resetSDK();
			try {
				SDKHelper.getInstance().initializeSDK(null);
			} catch(e:Error) {
				assertNotNull(e);
				assertEquals(e.message, "Application key cannot be null.");
				trace(e);
			}
		}
		
		public function testInitializeSDKWithNullOAuthKey():void {
			SDKHelper.getInstance().resetSDK();
			try {
				SDKHelper.getInstance().initializeSDK(null, "test_oauth_secret");
			} catch(e:Error) {
				assertNotNull(e);
				assertEquals(e.message, "OAuth key cannot be null.");
				trace(e);
			}
		}
		
		public function testMultipleInitializeSDK():void {
			SDKHelper.getInstance().resetSDK();
			try {
				SDKHelper.getInstance().initializeSDK("test_app_key");
				SDKHelper.getInstance().initializeSDK("test_app_key");
			} catch(e:Error) {
				assertNotNull(e);
				assertEquals(e.message, "The sdk has been already initialized.");
				trace(e);
			}
		}
		
		public function testCreateSDKHelperWithConstructor():void {
			try {
				var helper:SDKHelper = new SDKHelper();
			} catch(e:Error) {
				assertNotNull(e);
				assertEquals(e.message, "Cannot create SDKHelper instance. Please use getInstance() instead.");
				trace(e);
			}
		}
	}
}