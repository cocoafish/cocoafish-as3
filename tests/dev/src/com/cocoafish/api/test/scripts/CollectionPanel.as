package com.cocoafish.api.test.scripts
{
	import com.cocoafish.api.Cocoafish;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.containers.TitleWindow;
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
		private var uploadButton:Button = new Button();
		private var sdk:Cocoafish = null;
		public function CollectionPanel(collectionId:String, sdk:Cocoafish, uploadCallback:Function)
		{
			super();
			this.collectionId = collectionId;
			this.sdk = sdk;
			uploadButton.label = "+";
			uploadButton.addEventListener(MouseEvent.CLICK, uploadCallback);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			super.titleBar.addChild(uploadButton);
			var dg:DataGrid = createPhotoGrid();
			super.addChild(dg);
			populatePhotos();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			uploadButton.x = super.titleBar.width - 30;
			uploadButton.y = 6;
			uploadButton.width = 24;
			uploadButton.height = 20;
		}
		
		private function createPhotoGrid():DataGrid {
			var dg:DataGrid = new DataGrid();
			dg.width = this.width - 2;
			dg.height = this.height - 33;
			dg.showHeaders = false;
			dg.doubleClickEnabled = true;
			dg.addEventListener(MouseEvent.DOUBLE_CLICK, openPhoto);
			
			var column:DataGridColumn = new DataGridColumn();
			column.dataField = "photo";
			dg.columns.push(column);
			
			column = new DataGridColumn();
			column.dataField = "name";
			dg.columns.push(column);
			
			column = new DataGridColumn();
			column.dataField = "url";
			column.visible = false;
			dg.columns.push(column);
			
			dg.dataProvider = photosArray;
			return dg;
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
					p.url = photo.urls.original;
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
			window.minHeight = 300;
			window.minWidth = 400;
			window.showCloseButton = true;
			window.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent):void {
				PopUpManager.removePopUp(window);
			});
			var img:Image = new Image();
			img.source = url;
			window.addChild(img);
			PopUpManager.addPopUp(window, this, true);
			PopUpManager.centerPopUp(window);
		}
	}
}