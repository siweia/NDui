local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local ModelPreviewFrame = ModelPreviewFrame
	local Display = ModelPreviewFrame.Display

	Display.YesMountsTex:Hide()
	Display.ShadowOverlay:Hide()

	B.StripTextures(ModelPreviewFrame)
	B.SetBD(ModelPreviewFrame)
	if not DB.isCata then
		B.ReskinArrow(Display.ModelScene.RotateLeftButton, "left")
		B.ReskinArrow(Display.ModelScene.RotateRightButton, "right")
	end
	B.ReskinClose(ModelPreviewFrameCloseButton)
	B.Reskin(ModelPreviewFrame.CloseButton)

	local bg = B.CreateBDFrame(Display.ModelScene, .25)
	bg:SetPoint("TOPLEFT", -1, 0)
	bg:SetPoint("BOTTOMRIGHT", 2, -2)
end)