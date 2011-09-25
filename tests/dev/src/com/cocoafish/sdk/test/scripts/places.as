import com.cocoafish.sdk.Cocoafish;
import com.cocoafish.sdk.test.components.AddPlaceForm;
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
import com.google.maps.services.ClientGeocoder;
import com.google.maps.services.GeocodingEvent;
import com.google.maps.services.GeocodingResponse;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequestMethod;
import flash.text.TextFormatAlign;

import flashx.textLayout.formats.TextJustify;
import flashx.textLayout.tlf_internal;

import mx.controls.Alert;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import spark.components.HGroup;
import spark.components.Image;
import spark.components.Label;
import spark.components.TextArea;
import spark.components.TextInput;
import spark.events.TextOperationEvent;

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
	addPlaceIcon.visible = true;
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

protected function addMarker(event:MouseEvent):void {
	var pin:Image = new Image();
	pin.source = "com/cocoafish/sdk/test/images/pin.png";
	pin.width = 20;
	pin.height = 40;
	pin.smooth = true;
	pin.buttonMode = true;
	pin.setStyle("smoothingQuality", "high");
	
	var options:MarkerOptions = new MarkerOptions();
	options.draggable = true;
	options.icon = pin;
	options.iconAlignment = MarkerOptions.ALIGN_BOTTOM;
	options.iconOffset = new Point(-10, 0);
	options.hasShadow = true;
	options.gravity = 2;
	
	var marker:Marker = new Marker(map.getCenter(), options);
	
	marker.addEventListener(MapMouseEvent.CLICK, function (event:MapMouseEvent):void {
		var window:AddPlaceForm = new AddPlaceForm();
		window.initialize();
		
		window.addEventListener(CloseEvent.CLOSE, function(event:CloseEvent):void{
			marker.closeInfoWindow();
		});
		
		var options:InfoWindowOptions = new InfoWindowOptions();
		options.customContent = window;
		marker.openInfoWindow(options, true);
		
		loadLocationInfo(window, marker);
	});
	map.addOverlay(marker);
}

protected function loadLocationInfo(window:AddPlaceForm, marker:Marker):void {
	var loader:ImgLoader = new ImgLoader();
	loader.initialize();
	loader.left = 125;
	loader.top = 130;
	window.addElementAt(loader, 0);
	
	var geocoder:ClientGeocoder = new ClientGeocoder();
	geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS, function(event:GeocodingEvent):void {
		geocodingResult(window, marker, event);
	});
	geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE, function(event:GeocodingEvent):void {
		geocodingResult(window, marker, event);
	});
	geocoder.reverseGeocode(marker.getLatLng());
}

protected function geocodingResult(window:AddPlaceForm, marker:Marker, event:GeocodingEvent):void {
	if(event.status == 200) {
		try {
			var res:GeocodingResponse = event.response;
			var place:Object = res.placemarks[0];
			var address:String = place.address;
			address = address.substring(0, address.indexOf(","));
			var city:String = place.AddressDetails.Country.AdministrativeArea.Locality.LocalityName;
			var postal:String = place.AddressDetails.Country.AdministrativeArea.Locality.PostalCode.PostalCodeNumber;
			var state:String = place.AddressDetails.Country.AdministrativeArea.AdministrativeAreaName;
			var country:String = place.AddressDetails.Country.CountryName;
			var lat:String = place.Point.coordinates[1];
			var lng:String = place.Point.coordinates[0];
			
			window.address.text = address;
			window.city.text = city;
			window.state.text = state;
			window.postal.text = postal;
			window.country.text = country;
			window.lat.text = lat;
			window.lng.text = lng;
		} catch(e:Error) {
			trace(e);
		}
	}
	window.removeElementAt(0);
	window.formArea.visible = true;
	window.removePinButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
		removePin(marker);
	});
	window.addPlaceButton.addEventListener(MouseEvent.CLICK, function():void {
		addPlace(marker, window);
	});
}

protected function removePin(marker:Marker):void {
	marker.closeInfoWindow();
	map.removeOverlay(marker);
}

protected function addPlace(marker:Marker, window:AddPlaceForm):void {
	var name:String = window.placeName.text;
	var address:String = window.address.text;
	var city:String = window.city.text;
	var state:String = window.state.text;
	var postal:String = window.postal.text;
	var country:String = window.country.text;
	var lat:String = window.lat.text;
	var lng:String = window.lng.text;
	var phone:String = window.phone.text;
	var website:String = window.website.text;
	
	var sdk:Cocoafish = getSDK();
	var param:Object = new Object();
	param.name = name;
	param.address = address;
	param.city = city;
	param.state = state;
	param.postal_code = postal;
	param.country = country;
	param.latitude = lat;
	param.longitude = lng;
	param.website = website;
	param.phone_number = phone;
	
	showLoading();
	sdk.sendRequest("places/create.json", URLRequestMethod.POST, param, false, function(data:Object):void {
		hideLoading();
		if(data) {
			if(data.hasOwnProperty("meta")) {
				var meta:Object = data.meta;
				if(meta.status == "ok" && meta.code == 200 && meta.method_name == "createPlace") {
					var place:Object = data.response.places[0];
					var latlng:LatLng = new LatLng(place.latitude, place.longitude);
					var newMarker:Marker = createMarker(latlng, place);
					
					removePin(marker);
					
					map.addOverlay(newMarker);
					map.setCenter(latlng);
				}
			}
		}
	});
}