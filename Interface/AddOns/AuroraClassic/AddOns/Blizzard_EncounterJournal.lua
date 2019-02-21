local F, C = unpack(select(2, ...))

C.themes["Blizzard_EncounterJournal"] = function()
	local r, g, b = C.r, C.g, C.b

	EncounterJournalEncounterFrameInfo:DisableDrawLayer("BACKGROUND")
	EncounterJournalInstanceSelectBG:Hide()
	EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
	EncounterJournalEncounterFrameInfoModelFrame.dungeonBG:Hide()

	-- [[ Dungeon / raid tabs ]]

	local function onEnable(self)
		self:SetHeight(self.storedHeight) -- prevent it from resizing
		self:SetBackdropColor(0, 0, 0, 0)
	end

	local function onDisable(self)
		self:SetBackdropColor(r, g, b, .25)
	end

	local function onClick(self)
		self:GetFontString():SetTextColor(1, 1, 1)
	end

	for _, tabName in pairs({"suggestTab", "dungeonsTab", "raidsTab", "LootJournalTab"}) do
		local tab = EncounterJournal.instanceSelect[tabName]
		local text = tab:GetFontString()

		F.StripTextures(tab)
		tab:SetHeight(tab.storedHeight)
		tab.grayBox:GetRegions():SetAllPoints(tab)
		text:SetPoint("CENTER")
		text:SetTextColor(1, 1, 1)
		F.Reskin(tab)

		tab:HookScript("OnEnable", onEnable)
		tab:HookScript("OnDisable", onDisable)
		tab:HookScript("OnClick", onClick)
	end

	EncounterJournalInstanceSelectSuggestTab:SetBackdropColor(r, g, b, .25)

	-- [[ Side tabs ]]

	local tabs = {"overviewTab", "modelTab", "bossTab", "lootTab"}
	for _, name in pairs(tabs) do
		local tab = EncounterJournal.encounter.info[name]
		tab:SetScale(.75)
		tab:SetBackdrop({
			bgFile = C.media.backdrop,
			edgeFile = C.media.backdrop,
			edgeSize = C.mult / .75,
		})
		tab:SetBackdropColor(0, 0, 0, .5)
		tab:SetBackdropBorderColor(0, 0, 0)

		tab:SetNormalTexture("")
		tab:SetPushedTexture("")
		tab:SetDisabledTexture("")
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(r, g, b, .2)
		hl:SetPoint("TOPLEFT", C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

		if name == "overviewTab" then
			tab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 13, -35)
		end
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

	local function reskinHeader(header)
		header.flashAnim.Play = F.dummy
		for i = 4, 18 do
			select(i, header.button:GetRegions()):SetTexture("")
		end
		F.Reskin(header.button)
		header.descriptionBG:SetAlpha(0)
		header.descriptionBGBottom:SetAlpha(0)
		header.description:SetTextColor(1, 1, 1)
		header.button.title:SetTextColor(1, 1, 1)
		header.button.title.SetTextColor = F.dummy
		header.button.expandedIcon:SetTextColor(1, 1, 1)
		header.button.expandedIcon.SetTextColor = F.dummy
	end

	hooksecurefunc("EncounterJournal_ToggleHeaders", function()
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.styled then
				reskinHeader(header)
				header.button.bg = F.ReskinIcon(header.button.abilityIcon)
				header.styled = true
			end

			if header.button.abilityIcon:IsShown() then
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
			reskinHeader(header)
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

	for i = 1, 5 do
		F.StyleSearchButton(EncounterJournalSearchBox["sbutton"..i])
	end
	F.StyleSearchButton(EncounterJournalSearchBox.showAllResults)
	F.StripTextures(EncounterJournalSearchBox.searchPreviewContainer)

	do
		local result = EncounterJournalSearchResults
		result:SetPoint("BOTTOMLEFT", EncounterJournal, "BOTTOMRIGHT", 15, -1)
		F.StripTextures(result)
		local bg = F.CreateBDFrame(result)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")
		F.CreateSD(bg)

		for i = 1, 9 do
			local bu = _G["EncounterJournalSearchResultsScrollFrameButton"..i]
			F.StripTextures(bu)
			F.ReskinIcon(bu.icon)
			bu.icon.SetTexCoord = F.dummy
			F.CreateBD(bu, .25)
			bu:SetHighlightTexture(C.media.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .25)
			hl:SetPoint("TOPLEFT", C.mult, -C.mult)
			hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		end
	end

	F.ReskinClose(EncounterJournalSearchResultsCloseButton)
	F.ReskinScroll(EncounterJournalSearchResultsScrollFrameScrollBar)

	-- [[ Various controls ]]

	F.ReskinPortraitFrame(EncounterJournal)
	F.Reskin(EncounterJournalEncounterFrameInfoResetButton)
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
		F.ReskinTooltip(EncounterJournalTooltip)
		F.ReskinIcon(EncounterJournalTooltip.Item1.icon)
		F.ReskinIcon(EncounterJournalTooltip.Item2.icon)
		EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
		EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
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
		F.StripTextures(btn)
		F.Reskin(btn)
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