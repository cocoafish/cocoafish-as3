import com.cocoafish.sdk.Cocoafish;
import com.cocoafish.sdk.test.scripts.KeyValueEvent;

import flash.events.Event;
import flash.net.URLRequestMethod;

import mx.collections.ArrayCollection;

public var keyvalueGridData:ArrayCollection = new ArrayCollection();

protected function addKeyValuePair():void {
	var key:String = keyText.text;
	var value:String = valueText.text;
	
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.name = key;
	param.value = value;
	
	sdk.sendRequest("keyvalues/set.json", URLRequestMethod.PUT, param, false, function(data:Object):void {
		hideLoading();
		var newRow:Object = new Object();
		newRow.keyField = key;
		newRow.valueField = value;
		
		keyvalueGridData.addItem(newRow);
		clearInput();
	});
	showLoading();
}

private function clearInput():void {
	keyText.text = "";
	valueText.text = "";
}

protected function refreshDataGrid():void {
	this.addEventListener("RemoveKeyValue", removeKeyValueHandler);
}

protected function removeKeyValueHandler(event:KeyValueEvent):void {
	var removeData:Object = event.data;
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.name = removeData.keyField;
	sdk.sendRequest("keyvalues/delete.json", URLRequestMethod.DELETE, param, false, function(data:Object):void {
		hideLoading();
		var index:int = keyvalueGridData.getItemIndex(removeData);
		keyvalueGridData.removeItemAt(index);
	});
	showLoading();
}
