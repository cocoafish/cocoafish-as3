package com.cocoafish.sdk {
	import flash.net.FileReference;
	import flash.net.URLLoader;

	public class CCRequest {
		var loader:URLLoader = null;
		var fileUploader:FileReference = null;
		
		public function CCRequest(request:Object) {
			if(request instanceof URLLoader) {
				loader = request as URLLoader;
			} else if (request instanceof FileReference) {
				fileUploader = request as FileReference;
			}
		}
		
		public function cancel():void {
			try {
				if(loader != null) {
					loader.close();
				} else if (fileUploader != null) {
					fileUploader.cancel();
				}
			} catch (e:Error) {
				//mute
			}
		}
	}
}