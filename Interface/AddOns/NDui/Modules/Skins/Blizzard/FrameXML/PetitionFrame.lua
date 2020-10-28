local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.ReskinPortraitFrame(PetitionFrame)
	B.Reskin(PetitionFrameSignButton)
	B.Reskin(PetitionFrameRequestButton)
	B.Reskin(PetitionFrameRenameButton)
	B.Reskin(PetitionFrameCancelButton)

	PetitionFrameCharterTitle:SetTextColor(1, .8, 0)
	PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMasterTitle:SetTextColor(1, .8, 0)
	PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMemberTitle:SetTextColor(1, .8, 0)
	PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
end)