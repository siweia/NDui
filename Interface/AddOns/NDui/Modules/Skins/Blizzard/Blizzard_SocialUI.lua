local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function reskinSocialCard(card)
	if card.Background then
		if not card.styled then
			card.Background:SetAlpha(0)
			B.CreateBDFrame(card, .25):SetInside(card, 2, 2)
			card.styled = true
		end

		local gameIcon = card.GameIconHolder and card.GameIconHolder.Icon
		if gameIcon and not gameIcon.styled then
			B.ReskinIcon(gameIcon)
			gameIcon.styled = true
		end
		if card.PartyButton and not card.PartyButton.styled then
			B.Reskin(card.PartyButton)
			card.PartyButton.__bg:SetInside(nil, 3, 3)
			card.PartyButton.styled = true
		end
		if card.RAFSummonButton and not card.RAFSummonButton.styled then
			B.Reskin(card.RAFSummonButton)
			card.RAFSummonButton.styled = true
		end
	end

	if card.ButtonText then
		if not card.styled then
			B.StripTextures(card)
			B.CreateBDFrame(card, .25)
			card.styled = true
		end
	end
end

local function reskinSocialContent(content)
	if content.FilterBar and not content.FilterBar.styled then
		local filterBar = content.FilterBar
		B.ReskinEditBox(filterBar.SearchBar, 26)
		B.StripTextures(filterBar.SearchFilterDropdown, 0)
		B.ReskinDropDown(filterBar.SearchFilterDropdown)
		if content.TopDivider then content.TopDivider:SetAlpha(.25) end
		if content.BottomDivider then content.BottomDivider:SetAlpha(.25) end
		filterBar.styled = true
	end

	if content.ActionButton and not content.ActionButton.styled then
		B.Reskin(content.ActionButton)
		content.ActionButton.styled = true
	end

	if content.RaidInfoButton and not content.RaidInfoButton.styled then
		B.Reskin(content.RaidInfoButton)
		content.RaidInfoButton.styled = true
	end

	if content.ConvertToRaidButton and not content.ConvertToRaidButton.styled then
		B.Reskin(content.ConvertToRaidButton)
		content.ConvertToRaidButton.styled = true
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

local function updateSideTabIcon(tab)
	tab.Icon:SetSize(36, 36)
	tab.Icon:SetTexCoord(unpack(DB.TexCoord))
end

local function reskinSideTab(tab)
	tab.Background:SetAlpha(0)
	tab.Icon:RemoveMaskTexture(tab.Mask)
	tab.bg = B.ReskinIcon(tab.Icon, true)
	local hl = tab.HighlightTexture
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetAllPoints(tab.Icon)
	tab.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
	tab.SelectedTexture:SetAllPoints(tab.Icon)
	tab.TabGlow:SetColorTexture(cr, cg, cb, .25)
	tab.TabGlow:SetAllPoints(tab.Icon)
	hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
	updateSideTabIcon(tab)
end

C.themes["Blizzard_SocialUI"] = function()
	local frame = SocialUIFrame

	B.ReskinPortraitFrame(frame)
	frame.TopFade:Hide()
	frame.BottomFade:Hide()

	local controls = frame.BattleNetBar.ControlsContainer
	frame.BattleNetBar.Background:Hide()
	controls.BattleNetBackground:SetAlpha(0)
	local bg = B.CreateBDFrame(frame.BattleNetBar, .25)
	bg:SetPoint("TOPLEFT", 8, -4)
	bg:SetPoint("BOTTOMRIGHT", -8, 12)
	bg:SetBackdropColor(.24, .56, 1, .2)
	B.ReskinDropDown(controls.OnlineStatusDropdown)
	B.Reskin(controls.BattleNetMenuButton)
	controls.BattleNetMenuButton.__bg:SetInside(nil, 3, 3)

	hooksecurefunc(frame, "RefreshTabs", function(self)
		for tab in self:EnumerateTabs() do
			reskinSideTab(tab)
		end
	end)

	local personalTag = controls.PersonalBattleTagDisplay
	if personalTag.CopyBattleTagToClipboardButton then
	--	personalTag.CopyBattleTagToClipboardButton:SetHighlightTexture(DB.bdTex)
	--	personalTag.CopyBattleTagToClipboardButton:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
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
