local _, ns = ...
local B, C, DB = unpack(ns)

local function reskinSocialCard(card)
	if not card.Background then return end

	if not card.styled then
		card.Background:SetAlpha(0)
		B.CreateBDFrame(card, .25):SetInside(card, 2, 2)
		card:SetHighlightTexture(DB.bdTex)
		card:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)
		card.styled = true
	end

	local gameIcon = card.GameIconHolder and card.GameIconHolder.Icon
	if gameIcon and not gameIcon.styled then
		B.ReskinIcon(gameIcon)
		gameIcon.styled = true
	end
	if card.PartyButton and not card.PartyButton.styled then
		B.Reskin(card.PartyButton)
		card.PartyButton.styled = true
	end
	if card.RAFSummonButton and not card.RAFSummonButton.styled then
		B.Reskin(card.RAFSummonButton)
		card.RAFSummonButton.styled = true
	end
end

local function reskinSocialContent(content)
	if content.FilterBar and not content.FilterBar.styled then
		local filterBar = content.FilterBar
		B.ReskinEditBox(filterBar.SearchBar)
		B.ReskinDropDown(filterBar.SearchFilterDropdown)
		if content.TopDivider then content.TopDivider:SetAlpha(.25) end
		if content.BottomDivider then content.BottomDivider:SetAlpha(.25) end
		filterBar.styled = true
	end

	if content.ActionButton and not content.ActionButton.styled then
		B.Reskin(content.ActionButton)
		content.ActionButton.styled = true
	end

	if content.ScrollBar and not content.ScrollBar.styled then
		B.ReskinTrimScroll(content.ScrollBar)
		content.ScrollBar.styled = true
	end

	local scrollBox = content.ScrollBox
	if scrollBox then
		local function updateCards(self)
			self:ForEachFrame(reskinSocialCard)
		end

		updateCards(scrollBox)
		if not scrollBox.styled then
			hooksecurefunc(scrollBox, "Update", updateCards)
			scrollBox.styled = true
		end
	end
end

local function reskinSocialUI(frame)
	if not frame.styled then
		B.ReskinPortraitFrame(frame)
		frame.TopFade:Hide()
		frame.BottomFade:Hide()

		local controls = frame.BattleNetBar.ControlsContainer
		frame.BattleNetBar.Background:Hide()
		controls.BattleNetBackground:Hide()
		B.CreateBDFrame(frame.BattleNetBar, .25)
		B.ReskinDropDown(controls.OnlineStatusDropdown)
		B.Reskin(controls.BattleNetMenuButton)

		local personalTag = controls.PersonalBattleTagDisplay
		if personalTag.CopyBattleTagToClipboardButton then
			personalTag.CopyBattleTagToClipboardButton:SetHighlightTexture(DB.bdTex)
			personalTag.CopyBattleTagToClipboardButton:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		end

		B.StripTextures(frame.IgnoreListFrame)
		B.SetBD(frame.IgnoreListFrame)
		B.Reskin(frame.IgnoreListFrame.BlockButton)
		B.Reskin(frame.IgnoreListFrame.UnblockButton)
		B.ReskinTrimScroll(frame.IgnoreListFrame.ScrollBar)

		local broadcast = frame.BattleNetBroadcastFrame
		B.StripTextures(broadcast)
		B.SetBD(broadcast)
		B.ReskinEditBox(broadcast.EditBox)
		B.Reskin(broadcast.UpdateButton)
		B.Reskin(broadcast.CancelButton)

		local unavailable = frame.BattleNetUnavailableNoticeFrame
		B.StripTextures(unavailable)
		B.SetBD(unavailable)

		frame.styled = true
	end

	for tab in frame:EnumerateTabs() do
		if not tab.styled then
			B.ReskinIcon(tab.Icon)
			local highlight = tab:GetHighlightTexture()
			if highlight then
				highlight:SetColorTexture(1, 1, 1, .2)
				highlight:SetAllPoints(tab.Icon)
			end
			tab.styled = true
		end
	end

	for _, key in ipairs({"FriendsList", "RecentAlliesList", "QuickJoinFrame", "FriendRequestsList", "RecruitAFriendFrame", "RaidFrame"}) do
		local content = frame[key]
		if content then reskinSocialContent(content) end
	end
end

C.themes["Blizzard_SocialUI"] = function()
	local frame = SocialUIFrame
	hooksecurefunc(frame, "Reset", reskinSocialUI)
	reskinSocialUI(frame)
end
