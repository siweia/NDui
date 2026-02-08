local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Tutorial"] = function()
	local tutorialFrame = NPE_TutorialKeyboardMouseFrame_Frame
	tutorialFrame.NineSlice:Hide()
	B.SetBD(tutorialFrame)
	tutorialFrame.TitleBg:Hide()
	tutorialFrame.portrait:SetAlpha(0)
	B.ReskinClose(tutorialFrame.CloseButton)
	NPE_TutorialKeyString:SetTextColor(1, 1, 1)
end