local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	RaidFinderFrameBottomInset:DisableDrawLayer("BORDER")
	RaidFinderFrameBottomInsetBg:Hide()
	RaidFinderFrameBtnCornerRight:Hide()
	RaidFinderFrameButtonBottomBorder:Hide()
	RaidFinderQueueFrameScrollFrameScrollBackground:Hide()
	RaidFinderQueueFrameScrollFrameScrollBackgroundTopLeft:Hide()
	RaidFinderQueueFrameScrollFrameScrollBackgroundBottomRight:Hide()

	-- this fixes right border of second reward being cut off
	RaidFinderQueueFrameScrollFrame:SetWidth(RaidFinderQueueFrameScrollFrame:GetWidth()+1)

	F.ReskinScroll(RaidFinderQueueFrameScrollFrameScrollBar)
end)