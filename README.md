= Cocoafish Actionscript 3 Library

== Setup

The file "cocoafish-1.0.swc" is the SDK library file, to use it in an ActionScript/Flex project, just configure it into project's build path as a referenced library.

== Usage

1. Import the class "com.cocoafish.api.Cocoafish"

2. Create an instance of class "Cocoafish" with an app key or OAuth token & secret

- App. Key: 
	var sdk:Cocoafish = new Cocoafish("<AppKey>");
- OAuth
	var sdk:Cocoafish = new Cocoafish("<OAuth Key>", "<OAuth Secret>");

3. Send API request with "sendRequest" method

Method: public function sendRequest(url:String, method:String, data:Object, useSecure:Boolean, callback:Function):void
Parameters:
 - url: The API's url (without "http://api.cocoafish.com/v1/" prefix)
 - method: The http method (accept values are GET, POST, PUT, DELETE)
 - data: The parameters to be passed to the API
 - useSecure: A boolean indicates whether to use https
 - callback: The callback function
	
== Example

The following is an example of creating user by using the cocoafish as3 sdk.
This example will create a user with a photo, for the photo data, the sdk accept an instance of "FileReference" as the "photo" field, and the File Reference instance should be loaded with the local file information before being passed to the sdk.

=== Example Source Code:

	private var photo:FileReference;	//The FileReference instance for "photo" field of input data

	var sdk:Cocoafish = new Cocoafish("<AppKey>");	//using app key
	//var sdk:Cocoafish = new Cocoafish("<OAuth Key>", "<OAuth Secret>");	//using OAuth
	
	//the user's parameters
	var data:Object = new Object();
	data.email = "test@cocoafish.com";
	data.first_name = "test_firstname";
	data.last_name = "test_lastname";
	data.password = "test_password";
	data.password_confirmation = "test_password";
	data.photo = photo;
				
	sdk.sendRequest("users/create.json", URLRequestMethod.POST, data, false, function(data:Object):void {
		var result:String = JSON.encode(data);
		Alert.show(result);
	});
	
	//Browse and load photo file
	protected function selectPhoto(event:MouseEvent):void {
		photo= new FileReference();
		photo.addEventListener(Event.SELECT, photoSelected);
		photo.browse();
	}
			
	protected function photoSelected(event:Event):void {
		photoTextField.text = photo.name;
		photo.removeEventListener(Event.SELECT, photoSelected);
		photo.addEventListener(Event.COMPLETE, photoLoaded);
		photo.load();
	}
			
	protected function photoLoaded(event:Event):void {
		photo.removeEventListener(Event.COMPLETE, photoLoaded);
	}