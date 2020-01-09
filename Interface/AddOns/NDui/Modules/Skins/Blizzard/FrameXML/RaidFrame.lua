local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(RaidInfoFrame)
	B.CreateBD(RaidInfoFrame)
	B.CreateSD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)
	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()
	RaidInfoDetailCorner:Hide()
	RaidInfoFrame.Header = RaidInfoFrame.Header or RaidInfoFrameHeader -- deprecated in 8.3
	if DB.isNewPatch then
		B.StripTextures(RaidInfoFrame.Header)
	else
		RaidInfoFrame.Header:Hide()
	end

	B.Reskin(RaidFrameRaidInfoButton)
	B.Reskin(RaidFrameConvertToRaidButton)
	B.Reskin(RaidInfoExtendButton)
	B.Reskin(RaidInfoCancelButton)
	B.ReskinClose(RaidInfoCloseButton)
	B.ReskinScroll(RaidInfoScrollFrameScrollBar)
	B.ReskinClose(RaidParentFrameCloseButton)

	B.ReskinPortraitFrame(RaidParentFrame)
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")
end)