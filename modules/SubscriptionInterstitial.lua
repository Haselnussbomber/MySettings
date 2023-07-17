EventUtil.RegisterOnceFrameEventAndCallback("SHOW_SUBSCRIPTION_INTERSTITIAL", function()
	HideUIPanel(SubscriptionInterstitialFrame);
	SubscriptionInterstitialFrame:UnregisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");
end);
