local F, C = unpack(select(2, ...))

C.themes["Blizzard_IslandsQueueUI"] = function()
	F.StripTextures(IslandsQueueFrame)
	F.SetBD(IslandsQueueFrame)
	IslandsQueueFrame.ArtOverlayFrame.PortraitFrame:SetAlpha(0)
	IslandsQueueFrame.ArtOverlayFrame.portrait:SetAlpha(0)
	F.ReskinClose(IslandsQueueFrame.CloseButton)
	IslandsQueueFrame.portrait:Hide()
	F.Reskin(IslandsQueueFrame.DifficultySelectorFrame.QueueButton)
	IslandsQueueFrame.HelpButton.Ring:SetAlpha(0)

	local tutorial = IslandsQueueFrame.TutorialFrame
	F.ReskinClose(tutorial.CloseButton)
	local closeButton = tutorial:GetChildren()
	F.Reskin(closeButton)
	tutorial.TutorialText:SetTextColor(1, 1, 1)
end