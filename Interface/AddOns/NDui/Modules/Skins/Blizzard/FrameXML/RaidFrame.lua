local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.StripTextures(RaidInfoFrame)
	B.SetBD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)

	B.Reskin(RaidFrameRaidInfoButton)
	B.Reskin(RaidFrameConvertToRaidButton)
	B.ReskinClose(RaidInfoCloseButton)
	B.ReskinScroll(RaidInfoScrollFrameScrollBar)
	B.ReskinClose(RaidParentFrameCloseButton)

	B.ReskinPortraitFrame(RaidParentFrame)
end)