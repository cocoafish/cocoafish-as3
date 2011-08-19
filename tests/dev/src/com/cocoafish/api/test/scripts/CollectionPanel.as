package com.cocoafish.api.test.scripts
{
	import com.cocoafish.api.Cocoafish;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class CollectionPanel extends Panel
	{
		private var collectionId:String = null;
		private var photosArray:ArrayCollection = new ArrayCollection();
		private var uploadButton:Image = new Image();
		private var deleteButton:Image = new Image();
		private var switchButton:Image = new Image();
		private var dg:DataGrid = null;
		private var cover:Image = null;
		
		private var deletePhotoCallback:Function = null;
		
		private var sdk:Cocoafish = null;
		public function CollectionPanel(collectionId:String, sdk:Cocoafish, uploadCallback:Function, deleteCallback:Function, deletePhotoCallback:Function)
		{
			super();
			this.collectionId = collectionId;
			this.sdk = sdk;
			this.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				deleteButton.visible = true;
			});
			
			this.addEventListener(MouseEvent.MOUSE_OUT, function():void{
				deleteButton.visible = false;
			});
			
			uploadButton.source = "com/cocoafish/api/test/images/upload.gif";
			uploadButton.useHandCursor = true;
			uploadButton.buttonMode = true;
			uploadButton.addEventListener(MouseEvent.CLICK, uploadCallback);
			
			deleteButton.source = "com/cocoafish/api/test/images/delete.gif";
			deleteButton.useHandCursor = true;
			deleteButton.buttonMode = true;
			deleteButton.visible = false;
			deleteButton.addEventListener(MouseEvent.CLICK, deleteCallback);
			
			switchButton.source = "com/cocoafish/api/test/images/switch.png";
			switchButton.useHandCursor = true;
			switchButton.buttonMode = true;
			switchButton.addEventListener(MouseEvent.CLICK, function():void{
				dg.visible = !dg.visible;
				dg.includeInLayout = dg.visible;
				
				cover.visible = !cover.visible;
				cover.includeInLayout = cover.visible;
			});
			
			this.deletePhotoCallback = deletePhotoCallback;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			super.titleBar.addChild(uploadButton);
			super.titleBar.addChild(deleteButton);
			super.titleBar.addChild(switchButton);
			
			cover = createCoverImage();
			super.addChild(cover);
			
			dg = createPhotoGrid();
			dg.visible = false;
			dg.includeInLayout = false;
			super.addChild(dg);
			
			populateCover();
			populatePhotos();
			
			super.setStyle("veritcalAlign", "middle");
			super.setStyle("horizontalAlign", "center");
			super.setStyle("backgroundColor", "#efefef");
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			uploadButton.x = super.titleBar.width - 25;
			uploadButton.y = 9;
			uploadButton.width = 16;
			uploadButton.height = 16;
			uploadButton.toolTip = "Upload photo...";
			
			deleteButton.x = super.titleBar.width - 9;
			deleteButton.y = -5;
			deleteButton.width = 15;
			deleteButton.height = 15;
			deleteButton.toolTip = "Delete collection...";
			
			switchButton.x = super.titleBar.width - 45;
			switchButton.y = 9;
			switchButton.width = 16;
			switchButton.height = 16;
			switchButton.toolTip = "Switch..."
		}
		
		private function createPhotoGrid():DataGrid {
			var dg:DataGrid = new DataGrid();
			dg.width = this.width - 2;
			dg.height = this.height - 33;
			dg.showHeaders = false;
			dg.doubleClickEnabled = true;
			dg.addEventListener(MouseEvent.DOUBLE_CLICK, openPhoto);
			dg.dataProvider = photosArray;
			
			var cols:Array = new Array();
			
			var photo:DataGridColumn = new DataGridColumn();
			photo.dataField = "photo";
			photo.itemRenderer = new PhotoIcon();
			photo.width = 30;
			photo.setStyle("horizontalAlign", "center");
			cols.push(photo);
			
			var name:DataGridColumn = new DataGridColumn();
			name.dataField = "name";
			cols.push(name);
			
			var url:DataGridColumn = new DataGridColumn();
			url.dataField = "url";
			url.visible = false;
			cols.push(url);
			
			var id:DataGridColumn = new DataGridColumn();
			id.dataField = "id";
			id.visible = false;
			cols.push(id);
			
			dg.columns = cols;
			return dg;
		}
		
		private function createCoverImage():Image {
			var cover:Image = new Image();
			cover.width = this.width - 2;
			cover.height = this.height - 33;
			cover.maxWidth = this.width - 2;
			cover.maxHeight = this.height - 33;
			cover.maintainAspectRatio = false;
			cover.scaleContent = true;
			return cover;
		}
		
		private function populateCover():void {
			var param:Object = new Object();
			param.collection_id = collectionId;
			sdk.sendRequest("collections/show.json", URLRequestMethod.GET, param, false, function(data:Object):void {
				var collection:Object = data.response.collections[0];
				var coverPhoto:Object = collection.cover_photo;
				if(coverPhoto) {
					cover.source = coverPhoto.urls.small_240;
				}
			});
		}
		
		private function populatePhotos():void {
			var param:Object = new Object();
			param.collection_id = collectionId;
			sdk.sendRequest("collections/show/photos.json", URLRequestMethod.GET, param, false, function(data:Object):void {
				var photos:Array = data.response.photos;
				for(var i:int=0; i<photos.length; i++) {
					var photo:Object = photos[i];
					var p:Object = new Object();
					p.name = photo.filename;
					p.url = photo.urls.medium_500;//original;
					p.photo = photo.urls.square_75;
					p.id = photo.id;
					photosArray.addItem(p);
				}
			});
		}
		
		private function openPhoto(event:MouseEvent) {
			var row:Object = event.currentTarget.selectedItem;
			var url:String = row.url;
			var name:String = row.name;
			var window:TitleWindow = new TitleWindow();
			window.title = name;
			window.height = 440;
			window.width = 550;
			window.showCloseButton = true;
			window.setStyle("backgroundColor", "#efefef");
			window.setStyle("horizontalAlign", "center");
			window.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent):void {
				PopUpManager.removePopUp(window);
			});
			
			var box:VBox = new VBox();
			box.height = 360;
			box.width = 535;
			box.setStyle("horizontalAlign", "center");
			box.setStyle("verticalAlign", "middle");
			box.setStyle("backgroundColor", "#efefef");
			var img:Image = new Image();
			img.maxWidth = 490;
			img.maxHeight = 350;
			img.source = url;
			box.addChild(img);
			window.addChild(box);
			
			var removeButton:Button = new Button();
			removeButton.label = "Delete";
			removeButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
				PopUpManager.removePopUp(window);
				deletePhotoCallback(row, photosArray);
			});
			
			window.addChild(removeButton);
			
			PopUpManager.addPopUp(window, this, true);
			PopUpManager.centerPopUp(window);
		}
		
		public function getPhotosArray():ArrayCollection {
			return this.photosArray;
		}
		
		public function refresh():void {
			photosArray.removeAll();
			populatePhotos();
			if(cover.source == null) {
				populateCover();
			}
		}
		
	}
}