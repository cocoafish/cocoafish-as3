package com.cocoafish.sdk.test.scripts
{
	import flash.events.Event;

	public class KeyValueEvent extends Event
	{
		public var data:Object;
		public function KeyValueEvent(data:Object, type:String)
		{
			this.data = data;
			super(type);
		}
	}
}