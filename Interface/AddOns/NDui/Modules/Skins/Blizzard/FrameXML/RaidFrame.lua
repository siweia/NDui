local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.StripTextures(RaidInfoFrame)
	B.SetBD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)

	B.Reskin(RaidFrameRaidInfoButton)
	B.Reskin(RaidFrameConvertToRaidButton)
	if RaidInfoExtendButton then
		B.Reskin(RaidInfoExtendButton)
		B.Reskin(RaidInfoCancelButton)
	end
	B.ReskinClose(RaidInfoCloseButton)
	B.ReskinTrimScroll(RaidInfoFrame.ScrollBar)
	B.ReskinClose(RaidParentFrameCloseButton)
	B.ReskinPortraitFrame(RaidParentFrame)
end)