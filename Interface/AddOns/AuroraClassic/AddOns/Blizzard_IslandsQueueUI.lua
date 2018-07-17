local F, C = unpack(select(2, ...))

C.themes["Blizzard_IslandsQueueUI"] = function()
	F.StripTextures(IslandsQueueFrame)
	F.SetBD(IslandsQueueFrame)
	F.ReskinClose(IslandsQueueFrame.CloseButton)
	IslandsQueueFrame.portrait:Hide()
	F.Reskin(IslandsQueueFrame.DifficultySelectorFrame.QueueButton)
end