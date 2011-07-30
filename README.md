# Cocoafish Actionscript 3 Library

## Setup

The Cocoafish Actionscript 3 library is contained within the file `cocoafish-1.0.swc`. To use it in an ActionScript/Flex project, just configure it into project's build path as a referenced library.

## Usage

1. Import the class `com.cocoafish.api.Cocoafish`
2. Create an instance of class `Cocoafish` with an app key or OAuth consumer key & secret

    `var sdk:Cocoafish = new Cocoafish("<AppKey>"); // app key`  
    `var sdk:Cocoafish = new Cocoafish("<OAuth Key>", "<OAuth Secret>"); // OAuth key/secret`

3. Send an API request with the `sendRequest` method

Method:  

     public function sendRequest(url:String, method:String, data:Object, useSecure:Boolean, callback:Function):void

Parameters:  

     url: the API url (without "http://api.cocoafish.com/v1/" prefix)  
     method: the http method (accept values are GET, POST, PUT, DELETE)  
     data: the parameters to be passed to the API  
     useSecure: a boolean that indicates whether to use https  
     callback: the callback function  

## Example

The following is an example of creating user by using the Cocoafish as3 library. This example will create a user with a profile photo. To send photo data, the library accepts an instance of `FileReference` as the `photo` field. The File Reference instance should be loaded with the local file information before being passed to `sendRequest`.

### Example Source Code

  	private var photo:FileReference;	// FileReference instance for "photo" field of input data

  	var sdk:Cocoafish = new Cocoafish("tplS0cAZtDjO1QYOdQphroMcLIJ98WJZ");	// using app key
  	//var sdk:Cocoafish = new Cocoafish("2ywmQMDvPvDvySPjfTykTFHEPxa0zKDE", "63Y2eW7QmmUTpGmNUxrGoHzx7760od9u");	// using OAuth
	
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
	
  	// Browse and load photo file
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