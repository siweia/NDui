local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(PetitionFrame, 15, -15, -30, 65)
	B.Reskin(PetitionFrameSignButton)
	B.Reskin(PetitionFrameRequestButton)
	B.Reskin(PetitionFrameRenameButton)
	B.Reskin(PetitionFrameCancelButton)

	PetitionFrameCharterTitle:SetTextColor(1, 1, 1)
	PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
end)