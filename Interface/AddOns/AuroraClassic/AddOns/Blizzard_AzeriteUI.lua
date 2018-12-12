local F, C = unpack(select(2, ...))

C.themes["Blizzard_AzeriteUI"] = function()
	F.ReskinPortraitFrame(AzeriteEmpoweredItemUI.BorderFrame)
	F.SetBD(AzeriteEmpoweredItemUI)
	AzeriteEmpoweredItemUIBg:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
end