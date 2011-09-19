import com.cocoafish.sdk.Cocoafish;
import com.cocoafish.sdk.test.components.CheckinForm;
import com.cocoafish.sdk.test.components.ImgLoader;
import com.cocoafish.sdk.test.components.PlaceMarker;
import com.google.maps.InfoWindowOptions;
import com.google.maps.LatLng;
import com.google.maps.LatLngBounds;
import com.google.maps.MapMouseEvent;
import com.google.maps.MapOptions;
import com.google.maps.MapType;
import com.google.maps.controls.PositionControl;
import com.google.maps.controls.ZoomControl;
import com.google.maps.overlays.Marker;
import com.google.maps.overlays.MarkerOptions;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequestMethod;
import flash.text.TextFormatAlign;

import flashx.textLayout.formats.TextJustify;
import flashx.textLayout.tlf_internal;

import mx.controls.Alert;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import spark.components.HGroup;
import spark.components.Label;
import spark.components.TextArea;
import spark.components.TextInput;

private function onMapPreinitialize(event:Event):void {
	showLoading();
	var options:MapOptions = new MapOptions();
	options.zoom = 14;
	options.center = new LatLng(40.736072,-73.992062);
	options.mapType = MapType.NORMAL_MAP_TYPE;
	map.setInitOptions(options);
	loadPlaces();
}

protected function onMapReady(event:Event):void {
	map.addControl(new ZoomControl());
	map.addControl(new PositionControl());
}

protected function loadPlaces():void {
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	sdk.sendRequest("places/search.json", URLRequestMethod.GET, param, false, function(data:Object):void {
		hideLoading();
		drawPlaces(data);
	});
//	showLoading();
}

protected function drawPlaces(data:Object):void {
	var bounds:LatLngBounds = new LatLngBounds();
	var places:Array = data.response.places;
	if(places && places.length) {
		for(var i:int=0;i<places.length;i++) {
			var latlng:LatLng = new LatLng(places[i].latitude, places[i].longitude);
			bounds.extend(latlng);
			var marker:Marker = createMarker(latlng, places[i]);
			map.addOverlay(marker);
		}
	}
	map.setCenter(bounds.getCenter());
}

protected function createMarker(latlng:LatLng, place:Object):Marker {
	var marker:Marker = new Marker(latlng);
	var options:MarkerOptions = new MarkerOptions();
//	options.label = place.name;
	options.clickable = true;
	options.tooltip = place.name;
	marker.setOptions(options);
	marker.addEventListener(MapMouseEvent.CLICK, function(event:MapMouseEvent):void {
		markerClicked(marker, place);
	});
	return marker;
}

protected function markerClicked(marker:Marker, place:Object):void {
	var window:PlaceMarker = new PlaceMarker();
	window.initialize();
	window.placeName.text = place.name;
	window.address.text = place.address + " " + place.city + ", " + place.state;
	window.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent):void{
		marker.closeInfoWindow();
	});
	window.checkin.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){
		loadCheckinForm(window, place);
	});
	
	var options:InfoWindowOptions = new InfoWindowOptions();
	options.customContent = window;
	marker.openInfoWindow(options, true);
	
	loadReviews(window, place.id);
}

protected function loadReviews(window:PlaceMarker, placeId:String):void {
	var loader:ImgLoader = new ImgLoader();
	loader.initialize();
	window.reviewList.addElement(loader);
	
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.place_id = placeId;
	sdk.sendRequest("checkins/search.json", URLRequestMethod.GET, param, false, function(data:Object):void {
		window.reviewList.removeAllElements();
		drawReviewList(window, data);
	});
}

protected function drawReviewList(window:PlaceMarker, data:Object):void {
	var checkins:Array = data.response.checkins;
	if(checkins && checkins.length) {
		for(var i:int=0;i<checkins.length;i++) {
			var review:String = checkins[i].message;
			if(review) {
				var user:Object = checkins[i].user;
				var group:HGroup = new HGroup();
				var name:Label = new Label();
				name.setStyle("fontWeight", "bold");
				name.text = user.first_name + ":";
				group.addElement(name);

				var rev:Label = new Label();
				rev.toolTip = review;
				rev.text = review;
				rev.width = 250;
				group.addElement(rev);
				window.reviewList.addElement(group);
			}
		}
	} else {
		var noReview:Label = new Label();
		noReview.text = "(Currently no reviews for this place)";
		window.reviewList.addElement(noReview);
	}
}

protected function loadCheckinForm(window:PlaceMarker, place:Object):void {
	var form:CheckinForm = new CheckinForm();
	form.initialize();
	form.placeName.text = place.name;
	form.address.text = place.address + " " + place.city + ", " + place.state;
	form.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent){
		PopUpManager.removePopUp(form);
	});
	form.checkinButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent){
		checkinPlace(place.id, form.review.text, window);
		PopUpManager.removePopUp(form);
	});	
	PopUpManager.addPopUp(form, this, true);
	PopUpManager.centerPopUp(form);
}

protected function checkinPlace(id:String, review:String, window:PlaceMarker):void {
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.place_id = id;
	param.message = review;
	showLoading();
	sdk.sendRequest("checkins/create.json", URLRequestMethod.POST, param, false, function(data:Object):void {
		hideLoading();
		if(data) {
			if(data.meta) {
				if(data.meta.code == 200) {
					Alert.show("Check in successful!");
					loadReviews(window, id);
					return;
				} else {
					Alert.show(data.meta.message);
					return;
				}
			}
		}
		Alert.show("Sorry, check in failed.");
	});
}