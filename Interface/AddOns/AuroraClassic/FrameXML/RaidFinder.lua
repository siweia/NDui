local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	RaidFinderFrameBottomInset:DisableDrawLayer("BORDER")
	RaidFinderFrameRoleBackground:Hide()
	RaidFinderFrameRoleInset:DisableDrawLayer("BORDER")
	RaidFinderQueueFrameBackground:Hide()

	-- this fixes right border of second reward being cut off
	RaidFinderQueueFrameScrollFrame:SetWidth(RaidFinderQueueFrameScrollFrame:GetWidth()+1)

	F.ReskinScroll(RaidFinderQueueFrameScrollFrameScrollBar)
	F.ReskinDropDown(RaidFinderQueueFrameSelectionDropDown)
	F.Reskin(RaidFinderFrameFindRaidButton)
	F.Reskin(RaidFinderQueueFrameIneligibleFrameLeaveQueueButton)
	F.Reskin(RaidFinderQueueFramePartyBackfillBackfillButton)
	F.Reskin(RaidFinderQueueFramePartyBackfillNoBackfillButton)
end)