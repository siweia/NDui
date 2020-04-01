local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.Reskin(SplashFrame.BottomCloseButton)
	B.ReskinClose(SplashFrame.TopCloseButton)

	SplashFrame.TopCloseButton:ClearAllPoints()
	SplashFrame.TopCloseButton:SetPoint("TOPRIGHT", SplashFrame, "TOPRIGHT", -18, -18)

	SplashFrame.Label:SetTextColor(1, .8, 0)
end)