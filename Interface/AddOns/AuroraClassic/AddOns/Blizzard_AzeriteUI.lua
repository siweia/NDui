local F, C = unpack(select(2, ...))

C.themes["Blizzard_AzeriteUI"] = function()
	F.StripTextures(AzeriteEmpoweredItemUI)
	F.SetBD(AzeriteEmpoweredItemUI)
	F.ReskinClose(AzeriteEmpoweredItemUICloseButton)
	AzeriteEmpoweredItemUIPortrait:Hide()
	F.StripTextures(AzeriteEmpoweredItemUI.BorderFrame)
	AzeriteEmpoweredItemUITopBorder:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.KeyOverlay.Shadow:Hide()
end