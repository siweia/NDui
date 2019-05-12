local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local ModelPreviewFrame = ModelPreviewFrame
	local Display = ModelPreviewFrame.Display

	Display.YesMountsTex:Hide()
	Display.ShadowOverlay:Hide()

	F.StripTextures(ModelPreviewFrame)
	F.SetBD(ModelPreviewFrame)
	F.ReskinArrow(Display.ModelScene.RotateLeftButton, "left")
	F.ReskinArrow(Display.ModelScene.RotateRightButton, "right")
	F.ReskinClose(ModelPreviewFrameCloseButton)
	F.Reskin(ModelPreviewFrame.CloseButton)

	local bg = F.CreateBDFrame(Display.ModelScene, .25)
	bg:SetPoint("TOPLEFT", -1, 0)
	bg:SetPoint("BOTTOMRIGHT", 2, -2)
end)