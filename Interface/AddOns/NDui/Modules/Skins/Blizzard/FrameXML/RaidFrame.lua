local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(RaidInfoFrame)
	B.SetBD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)
	B.StripTextures(RaidInfoFrame.Header)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)
	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()
	RaidInfoDetailCorner:Hide()

	B.Reskin(RaidFrameRaidInfoButton)
	B.Reskin(RaidFrameConvertToRaidButton)
	B.Reskin(RaidInfoExtendButton)
	B.Reskin(RaidInfoCancelButton)
	B.ReskinClose(RaidInfoCloseButton)
	if DB.isNewPatch then
		B.ReskinTrimScroll(RaidInfoFrame.ScrollBar)
	else
		B.ReskinScroll(RaidInfoScrollFrameScrollBar)
	end
	B.ReskinClose(RaidParentFrameCloseButton)

	B.ReskinPortraitFrame(RaidParentFrame)
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")
end)