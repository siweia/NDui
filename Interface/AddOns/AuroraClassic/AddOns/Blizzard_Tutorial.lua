local F, C = unpack(select(2, ...))

C.themes["Blizzard_Tutorial"] = function()
	local tutorialFrame = NPE_TutorialKeyboardMouseFrame_Frame
	tutorialFrame.NineSlice:Hide()
	F.SetBD(tutorialFrame)
	tutorialFrame.TitleBg:Hide()
	tutorialFrame.portrait:SetAlpha(0)
	F.ReskinClose(tutorialFrame.CloseButton)
	NPE_TutorialKeyString:SetTextColor(1, 1, 1)
end