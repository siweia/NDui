local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
		if not button.expandOrCollapseButton.styled then
			F.ReskinCheck(button.enableButton)
			F.ReskinExpandOrCollapse(button.expandOrCollapseButton)

			button.expandOrCollapseButton.styled = true
		end

		button.enableButton:GetCheckedTexture():SetDesaturated(true)
	end)

	F.StripTextures(LFDParentFrame)
	LFDQueueFrameBackground:Hide()
	F.CreateBD(LFDRoleCheckPopup)
	F.CreateSD(LFDRoleCheckPopup)
	F.Reskin(LFDRoleCheckPopupAcceptButton)
	F.Reskin(LFDRoleCheckPopupDeclineButton)
	F.Reskin(LFDQueueFrameRandomScrollFrameChildFrame.bonusRepFrame.ChooseButton)
	F.ReskinScroll(LFDQueueFrameSpecificListScrollFrameScrollBar)
	F.StripTextures(LFDQueueFrameRandomScrollFrameScrollBar, 0)
	F.ReskinScroll(LFDQueueFrameRandomScrollFrameScrollBar)
	F.ReskinDropDown(LFDQueueFrameTypeDropDown)
	F.Reskin(LFDQueueFrameFindGroupButton)
	F.Reskin(LFDQueueFramePartyBackfillBackfillButton)
	F.Reskin(LFDQueueFramePartyBackfillNoBackfillButton)
	F.Reskin(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)

	LFDQueueFrameRandomScrollFrame:SetWidth(LFDQueueFrameRandomScrollFrame:GetWidth()+1)
	LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameSpecificListScrollFrameScrollBar, "BOTTOM", 0, 2)
	LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameRandomScrollFrameScrollBar, "BOTTOM", 0, 2)
end)