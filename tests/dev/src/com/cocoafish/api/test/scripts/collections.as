import com.cocoafish.api.Cocoafish;
import com.cocoafish.api.test.scripts.CollectionPanel;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.URLRequestMethod;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.containers.Panel;
import mx.containers.TitleWindow;
import mx.controls.Alert;
import mx.controls.Button;

var collectionPhoto:FileReference = null;
var collectionId:String = null;
var panelMap:Object = new Object();

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
			updateScrollbar();
			panelMap[collection.id] = p;
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
		updateScrollbar();
		coverflow.selectedChild = p;
		collectionName.text = "";
		panelMap[collection.id] = p;
	});
	showLoading();
}

private function createCollectionPanel(collection:Object):mx.containers.Panel {
	var p:CollectionPanel = new CollectionPanel(
		collection.id, 
		getSDK(), 
		function(event:MouseEvent):void {
			uploadPhotoToCollection(collection.id);
		},
		function(event:MouseEvent):void {
			deleteCollection(collection.id);
		},
		removePhoto
	);
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
		//var photo:Object = data.response.photos[0];
		var panel:CollectionPanel = panelMap[collectionId];
		flash.utils.setTimeout(function():void {
			panel.refresh();
			hideLoading();
		}, 5000, null);
	});
}

protected function deleteCollection(collID:String):void {
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.collection_id = collID;
	sdk.sendRequest("collections/delete.json", URLRequestMethod.DELETE, param, false, function(data:Object):void {
		hideLoading();
		if(data.meta.code == 200) {
			coverflow.removeChild(panelMap[collID]);
			updateScrollbar();
			panelMap[collID] = null;
		} else {
			Alert.show("Cannot delete a collection which has photos.", "Failed");
		}
	});
	showLoading();
}

public function removePhoto(row:Object, photosArray:ArrayCollection):void {
	var sdk:Cocoafish = getSDK();
	var id:String = row.id;
	var param:Object = new Object();
	param.photo_id = id;
	sdk.sendRequest("photos/delete.json", URLRequestMethod.DELETE, param, false, function(data:Object):void {
		if(data.meta.code == 200) {
			var index:int = photosArray.getItemIndex(row);
			if(index != -1) {
				photosArray.removeItemAt(index);
			}
		} else {
			Alert.show(data.meta.message, "Failed");
		}
		hideLoading();
	});
	showLoading();
}

private function updateScrollbar():void {
	scrollbar.maxScrollPosition = coverflow.numChildren - 1;
	scrollbar.scrollPosition = coverflow.selectedIndex;
}