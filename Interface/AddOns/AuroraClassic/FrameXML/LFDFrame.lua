local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	LFDParentFrame:DisableDrawLayer("BACKGROUND")
	LFDParentFrameInset:DisableDrawLayer("BACKGROUND")
	LFDParentFrame:DisableDrawLayer("BORDER")
	LFDParentFrameInset:DisableDrawLayer("BORDER")
	LFDParentFrame:DisableDrawLayer("OVERLAY")

	LFDQueueFrameRandomScrollFrameScrollBackgroundTopLeft:Hide()
	LFDQueueFrameRandomScrollFrameScrollBackgroundBottomRight:Hide()
	LFDQueueFrameBackground:Hide()
	LFDQueueFrameRandomScrollFrameScrollBackground:Hide()
	LFDQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFDQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()

	-- this fixes right border of second reward being cut off
	LFDQueueFrameRandomScrollFrame:SetWidth(LFDQueueFrameRandomScrollFrame:GetWidth()+1)

	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
		if not button.expandOrCollapseButton.styled then
			F.ReskinCheck(button.enableButton)
			F.ReskinExpandOrCollapse(button.expandOrCollapseButton)

			button.expandOrCollapseButton.styled = true
		end

		button.enableButton:GetCheckedTexture():SetDesaturated(true)
	end)

	F.CreateBD(LFDRoleCheckPopup)
	F.CreateSD(LFDRoleCheckPopup)
	F.Reskin(LFDRoleCheckPopupAcceptButton)
	F.Reskin(LFDRoleCheckPopupDeclineButton)
	F.Reskin(LFDQueueFrameRandomScrollFrameChildFrame.bonusRepFrame.ChooseButton)
	F.ReskinScroll(LFDQueueFrameSpecificListScrollFrameScrollBar)
	F.ReskinScroll(LFDQueueFrameRandomScrollFrameScrollBar)
	F.ReskinDropDown(LFDQueueFrameTypeDropDown)
	F.Reskin(LFDQueueFrameFindGroupButton)
	F.Reskin(LFDQueueFramePartyBackfillBackfillButton)
	F.Reskin(LFDQueueFramePartyBackfillNoBackfillButton)
	F.Reskin(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)

	LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameSpecificListScrollFrameScrollBar, "BOTTOM", 0, 2)
	LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameRandomScrollFrameScrollBar, "BOTTOM", 0, 2)
end)