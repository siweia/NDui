local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	F.Reskin(SplashFrame.BottomCloseButton)
	F.ReskinClose(SplashFrame.TopCloseButton)

	SplashFrame.TopCloseButton:ClearAllPoints()
	SplashFrame.TopCloseButton:SetPoint("TOPRIGHT", SplashFrame, "TOPRIGHT", -18, -18)

	SplashFrame.Label:SetTextColor(1, .8, 0)
end)