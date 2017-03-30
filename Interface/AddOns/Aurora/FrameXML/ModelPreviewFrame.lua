local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local ModelPreviewFrame = ModelPreviewFrame
	local Display = ModelPreviewFrame.Display

	Display.YesMountsTex:Hide()
	Display.ShadowOverlay:Hide()

	F.ReskinPortraitFrame(ModelPreviewFrame, true)
	F.Reskin(ModelPreviewFrame.CloseButton)

	F.ReskinArrow(Display.ModelScene.RotateLeftButton, "left")
	F.ReskinArrow(Display.ModelScene.RotateRightButton, "right")

	local bg = F.CreateBDFrame(Display.ModelScene, .25)
	bg:SetPoint("TOPLEFT", -1, 0)
	bg:SetPoint("BOTTOMRIGHT", 2, -2)
end)