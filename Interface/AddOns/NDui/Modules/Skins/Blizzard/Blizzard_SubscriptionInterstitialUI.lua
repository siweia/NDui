local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinSubscribeButton(button)
	B.CreateBDFrame(button, .25)
	button.ButtonText:SetTextColor(1, .8, 0)
end

C.themes["Blizzard_SubscriptionInterstitialUI"] = function()
	local frame = SubscriptionInterstitialFrame

	B.StripTextures(frame)
	frame.ShadowOverlay:Hide()
	B.SetBD(frame)
	B.Reskin(frame.ClosePanelButton)
	B.ReskinClose(frame.CloseButton)

	reskinSubscribeButton(frame.UpgradeButton)
	reskinSubscribeButton(frame.SubscribeButton)
end