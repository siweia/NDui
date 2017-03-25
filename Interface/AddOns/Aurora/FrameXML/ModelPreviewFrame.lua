local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local ModelPreviewFrame = ModelPreviewFrame
	local Display = ModelPreviewFrame.Display

	Display.YesMountsTex:Hide()
	Display.ShadowOverlay:Hide()

	F.ReskinPortraitFrame(ModelPreviewFrame, true)
	F.Reskin(ModelPreviewFrame.CloseButton)
	F.ReskinArrow(Display.Model.RotateLeftButton, "left")
	F.ReskinArrow(Display.Model.RotateRightButton, "right")

	local bg = F.CreateBDFrame(Display.Model, .25)
	bg:SetPoint("TOPLEFT", -1, 0)
	bg:SetPoint("BOTTOMRIGHT", 2, -2)

	Display.Model.RotateLeftButton:SetPoint("TOPRIGHT", Display.Model, "BOTTOM", -5, -10)
	Display.Model.RotateRightButton:SetPoint("TOPLEFT", Display.Model, "BOTTOM", 5, -10)
end)