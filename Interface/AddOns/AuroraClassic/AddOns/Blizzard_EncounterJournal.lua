local F, C = unpack(select(2, ...))

C.themes["Blizzard_EncounterJournal"] = function()
	local r, g, b = C.r, C.g, C.b

	EncounterJournalEncounterFrameInfo:DisableDrawLayer("BACKGROUND")
	EncounterJournal:DisableDrawLayer("BORDER")
	EncounterJournalInset:DisableDrawLayer("BORDER")
	EncounterJournal:DisableDrawLayer("OVERLAY")

	EncounterJournalPortrait:Hide()
	EncounterJournalInstanceSelectBG:Hide()
	EncounterJournalBg:Hide()
	EncounterJournalTitleBg:Hide()
	EncounterJournalInsetBg:Hide()
	EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
	EncounterJournalEncounterFrameInfoModelFrame.dungeonBG:Hide()

	F.SetBD(EncounterJournal)

	-- [[ Dungeon / raid tabs ]]

	local function onEnable(self)
		self:SetHeight(self.storedHeight) -- prevent it from resizing
		self:SetBackdropColor(0, 0, 0, 0)
	end

	local function onDisable(self)
		self:SetBackdropColor(r, g, b, .2)
	end

	local function onClick(self)
		self:GetFontString():SetTextColor(1, 1, 1)
	end

	for _, tabName in pairs({"EncounterJournalInstanceSelectSuggestTab", "EncounterJournalInstanceSelectDungeonTab", "EncounterJournalInstanceSelectRaidTab", "EncounterJournalInstanceSelectLootJournalTab"}) do
		local tab = _G[tabName]
		local text = tab:GetFontString()

		tab:DisableDrawLayer("OVERLAY")

		tab.mid:Hide()
		tab.left:Hide()
		tab.right:Hide()

		tab.midHighlight:SetAlpha(0)
		tab.leftHighlight:SetAlpha(0)
		tab.rightHighlight:SetAlpha(0)

		tab:SetHeight(tab.storedHeight)
		tab.grayBox:GetRegions():SetAllPoints(tab)

		text:SetPoint("CENTER")
		text:SetTextColor(1, 1, 1)

		tab:HookScript("OnEnable", onEnable)
		tab:HookScript("OnDisable", onDisable)
		tab:HookScript("OnClick", onClick)

		F.Reskin(tab)
	end

	EncounterJournalInstanceSelectSuggestTab:SetBackdropColor(r, g, b, .2)

	-- [[ Side tabs ]]

	EncounterJournalEncounterFrameInfoOverviewTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoOverviewTab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 9, -35)
	EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoLootTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoOverviewTab, "BOTTOM", 0, 1)
	EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoBossTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoLootTab, "BOTTOM", 0, 1)

	local tabs = {EncounterJournalEncounterFrameInfoOverviewTab, EncounterJournalEncounterFrameInfoLootTab, EncounterJournalEncounterFrameInfoBossTab, EncounterJournalEncounterFrameInfoModelTab}
	for _, tab in pairs(tabs) do
		tab:SetScale(.75)

		tab:SetBackdrop({
			bgFile = C.media.backdrop,
			edgeFile = C.media.backdrop,
			edgeSize = 1 / .75,
		})

		tab:SetBackdropColor(0, 0, 0, .5)
		tab:SetBackdropBorderColor(0, 0, 0)

		tab:SetNormalTexture("")
		tab:SetPushedTexture("")
		tab:SetDisabledTexture("")
		tab:SetHighlightTexture("")
	end

	-- [[ Instance select ]]

	F.ReskinDropDown(EncounterJournalInstanceSelectTierDropDown)

	local index = 1

	local function listInstances()
		while true do
			local bu = EncounterJournal.instanceSelect.scroll.child["instance"..index]
			if not bu then return end

			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")
			bu:SetPushedTexture("")

			bu.bgImage:SetDrawLayer("BACKGROUND", 1)

			local bg = F.CreateBG(bu.bgImage)
			bg:SetPoint("TOPLEFT", 3, -3)
			bg:SetPoint("BOTTOMRIGHT", -4, 2)

			index = index + 1
		end
	end

	hooksecurefunc("EncounterJournal_ListInstances", listInstances)
	listInstances()

	-- [[ Encounter frame ]]

	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")

	EncounterJournalEncounterFrameInfoEncounterTitle:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor(1, 1, 1)

	F.CreateBDFrame(EncounterJournalEncounterFrameInfoModelFrame, .25)

	EncounterJournalEncounterFrameInfoCreatureButton1:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoModelFrame, 0, -35)

	do
		local numBossButtons = 1
		local bossButton

		hooksecurefunc("EncounterJournal_DisplayInstance", function()
			bossButton = _G["EncounterJournalBossButton"..numBossButtons]
			while bossButton do
				F.Reskin(bossButton, true)

				bossButton.text:SetTextColor(1, 1, 1)
				bossButton.text.SetTextColor = F.dummy

				local hl = bossButton:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .2)
				hl:SetPoint("TOPLEFT", 2, -1)
				hl:SetPoint("BOTTOMRIGHT", 0, 1)

				bossButton.creature:SetPoint("TOPLEFT", 0, -4)

				numBossButtons = numBossButtons + 1
				bossButton = _G["EncounterJournalBossButton"..numBossButtons]
			end

			-- move last tab
			local _, point = EncounterJournalEncounterFrameInfoModelTab:GetPoint()
			EncounterJournalEncounterFrameInfoModelTab:SetPoint("TOP", point, "BOTTOM", 0, 1)
		end)
	end

	hooksecurefunc("EncounterJournal_ToggleHeaders", function()
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.styled then
				header.flashAnim.Play = F.dummy

				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)
				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture("")
				end

				header.description:SetTextColor(1, 1, 1)
				header.button.title:SetTextColor(1, 1, 1)
				header.button.title.SetTextColor = F.dummy
				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = F.dummy

				F.Reskin(header.button)

				header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)
				header.button.bg = F.CreateBG(header.button.abilityIcon)

				header.styled = true
			end

			if header.button.abilityIcon:GetTexture() then
				header.button.bg:Show()
			else
				header.button.bg:Hide()
			end

			index = index + 1
			header = _G["EncounterJournalInfoHeader"..index]
		end
	end)

	hooksecurefunc("EncounterJournal_SetUpOverview", function(self, _, index)
		local header = self.overviews[index]
		if not header.styled then
			header.flashAnim.Play = F.dummy

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture("")
			end

			header.button.title:SetTextColor(1, 1, 1)
			header.button.title.SetTextColor = F.dummy
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = F.dummy

			F.Reskin(header.button)

			header.styled = true
		end
	end)

	hooksecurefunc("EncounterJournal_SetBullets", function(object)
		local parent = object:GetParent()

		if parent.Bullets then
			for _, bullet in pairs(parent.Bullets) do
				if not bullet.styled then
					bullet.Text:SetTextColor(1, 1, 1)
					bullet.styled = true
				end
			end
		end
	end)

	local items = EncounterJournal.encounter.info.lootScroll.buttons

	for i = 1, #items do
		local item = items[i]

		item.boss:SetTextColor(1, 1, 1)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)
		item.IconBorder:SetAlpha(0)

		item.icon:SetPoint("TOPLEFT", 1, -1)

		item.icon:SetTexCoord(.08, .92, .08, .92)
		item.icon:SetDrawLayer("OVERLAY")
		F.CreateBG(item.icon)

		local bg = F.CreateBDFrame(item, .25)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
	end

	-- [[ Search results ]]

	for i = 1, 6 do
		select(i, EncounterJournalSearchBox.searchPreviewContainer:GetRegions()):Hide()
	end

	local function styleSearchButton(result)
		select(1, result:GetRegions()):SetAlpha(0)
		if result.icon then
			select(2, result:GetRegions()):SetAlpha(0)
			select(3, result:GetRegions()):SetTexCoord(.08, .92, .08, .92)
			F.ReskinIcon(select(3, result:GetRegions()))
			select(5, result:GetRegions()):SetAlpha(0)
			select(6, result:GetRegions()):SetAlpha(0)
		else
			select(3, result:GetRegions()):SetAlpha(0)
			select(4, result:GetRegions()):SetAlpha(0)
		end
		F.CreateBD(result)
		F.CreateSD(result)

		result:SetHighlightTexture(C.media.backdrop)
		local hl = result:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .2)
		hl:SetPoint("TOPLEFT", 1, -2)
		hl:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	for i = 1, 5 do
		styleSearchButton(EncounterJournalSearchBox["sbutton"..i])
	end
	styleSearchButton(EncounterJournalSearchBox.showAllResults)

	do
		local result = EncounterJournalSearchResults
		result:SetPoint("BOTTOMLEFT", EncounterJournal, "BOTTOMRIGHT", 30, 0)

		for i = 3, 11 do
			select(i, EncounterJournalSearchResults:GetRegions()):Hide()
		end
		local bg = F.CreateBDFrame(result)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")
		F.CreateSD(bg)

		for i = 1, 9 do
			local bu = _G["EncounterJournalSearchResultsScrollFrameButton"..i]
			F.CreateBD(bu, .25)
			bu:SetNormalTexture("")
			bu:GetRegions():Hide()
			F.ReskinIcon(bu.icon)
			bu.icon.SetTexCoord = F.dummy

			bu:SetHighlightTexture(C.media.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:SetPoint("TOPLEFT", 1, -2)
			hl:SetPoint("BOTTOMRIGHT", -1, 1)
		end
	end

	EncounterJournalSearchResultsBg:Hide()
	F.ReskinClose(EncounterJournalSearchResultsCloseButton)
	F.ReskinScroll(EncounterJournalSearchResultsScrollFrameScrollBar)

	-- [[ Various controls ]]

	F.Reskin(EncounterJournalEncounterFrameInfoResetButton)
	F.ReskinClose(EncounterJournalCloseButton)
	F.ReskinInput(EncounterJournalSearchBox)
	F.ReskinScroll(EncounterJournalInstanceSelectScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar)

	-- [[ Suggest frame ]]

	local suggestFrame = EncounterJournal.suggestFrame

	-- Tooltip

	if AuroraConfig.tooltips then
		local EncounterJournalTooltip = EncounterJournalTooltip
		F.CreateBD(EncounterJournalTooltip)
		F.CreateSD(EncounterJournalTooltip)
		EncounterJournalTooltip.Item1.newBg = F.ReskinIcon(EncounterJournalTooltip.Item1.icon)
		EncounterJournalTooltip.Item2.newBg = F.ReskinIcon(EncounterJournalTooltip.Item2.icon)
	end

	-- Suggestion 1

	local suggestion = suggestFrame.Suggestion1

	suggestion.bg:Hide()

	F.CreateBD(suggestion, .25)

	suggestion.icon:SetPoint("TOPLEFT", 135, -15)
	F.CreateBG(suggestion.icon)

	local centerDisplay = suggestion.centerDisplay

	centerDisplay.title.text:SetTextColor(1, 1, 1)
	centerDisplay.description.text:SetTextColor(.9, .9, .9)

	F.Reskin(suggestion.button)

	local reward = suggestion.reward

	reward.text:SetTextColor(.9, .9, .9)
	reward.iconRing:Hide()
	reward.iconRingHighlight:SetTexture("")
	F.CreateBG(reward.icon)

	F.ReskinArrow(suggestion.prevButton, "left")
	F.ReskinArrow(suggestion.nextButton, "right")

	-- Suggestion 2 and 3

	for i = 2, 3 do
		local suggestion = suggestFrame["Suggestion"..i]

		suggestion.bg:Hide()

		F.CreateBD(suggestion, .25)

		suggestion.icon:SetPoint("TOPLEFT", 10, -10)
		F.CreateBG(suggestion.icon)

		local centerDisplay = suggestion.centerDisplay

		centerDisplay:ClearAllPoints()
		centerDisplay:SetPoint("TOPLEFT", 85, -10)
		centerDisplay.title.text:SetTextColor(1, 1, 1)
		centerDisplay.description.text:SetTextColor(.9, .9, .9)

		F.Reskin(centerDisplay.button)

		local reward = suggestion.reward

		reward.iconRing:Hide()
		reward.iconRingHighlight:SetTexture("")
		F.CreateBG(reward.icon)
	end

	-- Hook functions

	hooksecurefunc("EJSuggestFrame_RefreshDisplay", function()
		local self = suggestFrame

		if #self.suggestions > 0 then
			local suggestion = self.Suggestion1
			local data = self.suggestions[1]

			suggestion.iconRing:Hide()

			if data.iconPath then
				suggestion.icon:SetMask(nil)
				suggestion.icon:SetTexCoord(.08, .92, .08, .92)
			end
		end

		if #self.suggestions > 1 then
			for i = 2, #self.suggestions do
				local suggestion = self["Suggestion"..i]
				if not suggestion then break end

				local data = self.suggestions[i]

				suggestion.iconRing:Hide()

				if data.iconPath then
					suggestion.icon:SetMask(nil)
					suggestion.icon:SetTexCoord(.08, .92, .08, .92)
				end
			end
		end
	end)

	hooksecurefunc("EJSuggestFrame_UpdateRewards", function(suggestion)
		local rewardData = suggestion.reward.data
		if rewardData then
			suggestion.reward.icon:SetMask("")
			suggestion.reward.icon:SetTexCoord(.08, .92, .08, .92)
		end
	end)

	-- [[ Loot Journal ]]

	EncounterJournal.LootJournal:GetRegions():Hide()
	F.ReskinScroll(EncounterJournal.LootJournal.ItemSetsFrame.scrollBar)

	local buttons = {
		EncounterJournalEncounterFrameInfoDifficulty,
		EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle,
		EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle,
		EncounterJournal.LootJournal.ItemSetsFrame.ClassButton,
	}
	for _, btn in pairs(buttons) do
		F.Reskin(btn)
		btn.UpLeft:SetAlpha(0)
		btn.UpRight:SetAlpha(0)
		btn.DownLeft:SetAlpha(0)
		btn.DownRight:SetAlpha(0)
		btn.HighLeft:SetAlpha(0)
		btn.HighRight:SetAlpha(0)
	end

	-- ItemSetsFrame

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "UpdateList", function(self)
		local buttons = self.buttons
		for i = 1, #buttons do
			local button = buttons[i]

			if not button.styled then
				button.ItemLevel:SetTextColor(1, 1, 1)
				button.Background:Hide()
				F.CreateBDFrame(button, .25)

				button.styled = true
			end
		end
	end)

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "ConfigureItemButton", function(_, button)
		if not button.bg then
			button.Border:SetAlpha(0)
			button.Icon:SetTexCoord(.08, .92, .08, .92)
			button.bg = F.CreateBDFrame(button.Icon)
		end

		local quality = select(3, GetItemInfo(button.itemID))
		local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
		button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end)
end