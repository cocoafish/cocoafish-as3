import com.cocoafish.api.Cocoafish;
import com.cocoafish.api.test.scripts.CollectionPanel;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.URLRequestMethod;

import mx.containers.Panel;
import mx.containers.TitleWindow;
import mx.controls.Button;

var collectionPhoto:FileReference = null;
var collectionId:String = null;

protected function initCollectionCoverFlow():void {
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.user_id = "4e4b606f6f709545b6000076";
	sdk.sendRequest("collections/search.json", URLRequestMethod.GET, param, false, function(data:Object):void {
		hideLoading();
		var collections:Array = data.response.collections;
		for(var i:int=0; i<collections.length; i++) {
			var collection:Object = collections[i];
			var p:mx.containers.Panel = createCollectionPanel(collection);
			coverflow.addChild(p);
		}
	});
	showLoading();
}

protected function createCollection():void {
	var name:String = collectionName.text;
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.name = name;
	
	sdk.sendRequest("collections/create.json", URLRequestMethod.POST, param, false, function(data:Object):void {
		hideLoading();
		var collection:Object = data.response.collections[0];
		var p:mx.containers.Panel = createCollectionPanel(collection);
		coverflow.addChild(p);
		coverflow.selectedChild = p;
		collectionName.text = "";
	});
	showLoading();
}

private function createCollectionPanel(collection:Object):mx.containers.Panel {
	var p:CollectionPanel = new CollectionPanel(collection.id, getSDK(), function(event:MouseEvent):void {
		uploadPhotoToCollection(collection.id);
	});
	p.width = 200;
	p.height = 200;
	p.title = collection.name;
	return p;
}

private function uploadPhotoToCollection(collID:String):void {
	collectionPhoto = new FileReference();
	collectionPhoto.addEventListener(Event.SELECT, colPhotoSelected);
	collectionPhoto.addEventListener(Event.CANCEL, function():void {
		hideLoading();
	});
	showLoading();
	collectionId = collID;
	collectionPhoto.browse();
}

protected function colPhotoSelected(event:Event):void {
	collectionPhoto.removeEventListener(Event.SELECT, colPhotoSelected);
	collectionPhoto.addEventListener(Event.COMPLETE, colPhotoLoaded);
	collectionPhoto.load();
}

protected function colPhotoLoaded(event:Event):void {
	collectionPhoto.removeEventListener(Event.COMPLETE, colPhotoLoaded);
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.collection_id = collectionId;
	param.file = collectionPhoto;
	sdk.sendRequest("photos/create.json", URLRequestMethod.POST, param, false, function(data:Object):void {
		hideLoading();
		var photo:Object = data.response.photos[0];
		
	});
}