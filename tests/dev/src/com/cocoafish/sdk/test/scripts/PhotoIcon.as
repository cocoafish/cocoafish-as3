package com.cocoafish.sdk.test.scripts
{
	import mx.controls.Image;
	import mx.core.IFactory;
	
	public class PhotoIcon extends Image implements IFactory
	{
		public function PhotoIcon()
		{
			super();
			this.width = 18;
			this.height = 18;
		}
		
		public function newInstance():*
		{
			return new PhotoIcon();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			this.source = value.photo;
		}
	}
}