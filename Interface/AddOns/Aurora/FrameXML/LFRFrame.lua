local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	LFRQueueFrame:DisableDrawLayer("BACKGROUND")
	LFRBrowseFrame:DisableDrawLayer("BACKGROUND")
	LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")
	LFRQueueFrameRoleInset:DisableDrawLayer("BORDER")
	LFRQueueFrameListInset:DisableDrawLayer("BORDER")
	LFRQueueFrameCommentInset:DisableDrawLayer("BORDER")
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
	LFRBrowseFrameRoleInsetBg:Hide()
	LFRQueueFrameRoleInsetBg:Hide()
	LFRQueueFrameListInsetBg:Hide()
	LFRQueueFrameCommentInsetBg:Hide()
	for i = 1, 7 do
		_G["LFRBrowseFrameColumnHeader"..i]:DisableDrawLayer("BACKGROUND")
	end

	F.Reskin(LFRBrowseFrameSendMessageButton)
	F.Reskin(LFRBrowseFrameInviteButton)
	F.Reskin(LFRBrowseFrameRefreshButton)
	F.Reskin(LFRQueueFrameFindGroupButton)
	F.Reskin(LFRQueueFrameAcceptCommentButton)
	F.ReskinPortraitFrame(RaidBrowserFrame)
	F.ReskinScroll(LFRQueueFrameSpecificListScrollFrameScrollBar)
	F.ReskinScroll(LFRQueueFrameCommentScrollFrameScrollBar)
	F.ReskinScroll(LFRBrowseFrameListScrollFrameScrollBar)
	F.ReskinDropDown(LFRBrowseFrameRaidDropDown)

	for i = 1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i]
		tab:GetRegions():Hide()
		tab:SetCheckedTexture(C.media.checked)
		if i == 1 then
			local a1, p, a2, x, y = tab:GetPoint()
			tab:SetPoint(a1, p, a2, x + 2, y)
		end
		F.CreateBG(tab)
		select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local bu = _G["LFRQueueFrameSpecificListButton"..i].enableButton
		F.ReskinCheck(bu)
		bu.SetNormalTexture = F.dummy
		bu.SetPushedTexture = F.dummy

		F.ReskinExpandOrCollapse(_G["LFRQueueFrameSpecificListButton"..i].expandOrCollapseButton)
	end

	hooksecurefunc("LFRQueueFrameSpecificListButton_SetDungeon", function(button, dungeonID)
		if LFGCollapseList[dungeonID] then
			button.expandOrCollapseButton.plus:Show()
		else
			button.expandOrCollapseButton.plus:Hide()
		end

		button.enableButton:GetCheckedTexture():SetDesaturated(true)
	end)
end)