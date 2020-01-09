local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_IslandsQueueUI"] = function()
	B.ReskinPortraitFrame(IslandsQueueFrame)
	IslandsQueueFrame.ArtOverlayFrame.PortraitFrame:SetAlpha(0)
	IslandsQueueFrame.ArtOverlayFrame.portrait:SetAlpha(0)
	B.Reskin(IslandsQueueFrame.DifficultySelectorFrame.QueueButton)
	IslandsQueueFrame.HelpButton.Ring:SetAlpha(0)

	local tutorial = IslandsQueueFrame.TutorialFrame
	B.ReskinClose(tutorial.CloseButton)
	local closeButton = tutorial:GetChildren()
	B.Reskin(closeButton)
	tutorial.TutorialText:SetTextColor(1, 1, 1)
end