local _, addon = ...;

local module = addon:NewModule("SubscriptionInterstitial");

function module:OnInitialize()
	self:RegisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");
end

function module:SHOW_SUBSCRIPTION_INTERSTITIAL()
	HideUIPanel(SubscriptionInterstitialFrame);

	SubscriptionInterstitialFrame:UnregisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");
	self:UnregisterEvent("SHOW_SUBSCRIPTION_INTERSTITIAL");
end
