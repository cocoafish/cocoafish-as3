import com.cocoafish.api.Cocoafish;

protected function getSDK():Cocoafish {
	var sdk:Cocoafish = null;
	if(appKey.selected) {
		sdk = new Cocoafish(appKeyTextField.text);
	}
	if(oauth.selected) {
		sdk = new Cocoafish(oauthKeyTextField.text, oauthSecretTextField.text);
	}
	return sdk;
}

