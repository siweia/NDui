local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AzeriteUI"] = function()
	B.ReskinPortraitFrame(AzeriteEmpoweredItemUI)
	AzeriteEmpoweredItemUIBg:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
end