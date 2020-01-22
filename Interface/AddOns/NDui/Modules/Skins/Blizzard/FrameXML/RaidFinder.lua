local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	RaidFinderFrameBottomInset:Hide()
	RaidFinderFrameRoleBackground:Hide()
	RaidFinderFrameRoleInset:Hide()
	RaidFinderQueueFrameBackground:Hide()

	-- this fixes right border of second reward being cut off
	RaidFinderQueueFrameScrollFrame:SetWidth(RaidFinderQueueFrameScrollFrame:GetWidth()+1)

	B.ReskinScroll(RaidFinderQueueFrameScrollFrameScrollBar)
	B.ReskinDropDown(RaidFinderQueueFrameSelectionDropDown)
	B.Reskin(RaidFinderFrameFindRaidButton)
	B.Reskin(RaidFinderQueueFrameIneligibleFrameLeaveQueueButton)
	B.Reskin(RaidFinderQueueFramePartyBackfillBackfillButton)
	B.Reskin(RaidFinderQueueFramePartyBackfillNoBackfillButton)
end)