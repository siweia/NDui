local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_EncounterJournal"] = function()
	local r, g, b = DB.r, DB.g, DB.b

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

		B.StripTextures(tab)
		tab:SetHeight(tab.storedHeight)
		tab.grayBox:GetRegions():SetAllPoints(tab)
		text:SetPoint("CENTER")
		text:SetTextColor(1, 1, 1)
		B.Reskin(tab)

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
			bgFile = DB.bdTex,
			edgeFile = DB.bdTex,
			edgeSize = C.mult / .75,
		})
		tab:SetBackdropColor(0, 0, 0, .5)
		tab:SetBackdropBorderColor(0, 0, 0)

		tab:SetNormalTexture("")
		tab:SetPushedTexture("")
		tab:SetDisabledTexture("")
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(r, g, b, .2)
		hl:SetInside()

		if name == "overviewTab" then
			tab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 13, -35)
		end
	end

	-- [[ Instance select ]]

	B.ReskinDropDown(EncounterJournalInstanceSelectTierDropDown)

	local index = 1
	local function listInstances()
		while true do
			local bu = EncounterJournal.instanceSelect.scroll.child["instance"..index]
			if not bu then return end

			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")
			bu:SetPushedTexture("")

			local bg = B.CreateBDFrame(bu.bgImage)
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

	B.CreateBDFrame(EncounterJournalEncounterFrameInfoModelFrame, .25)
	EncounterJournalEncounterFrameInfoCreatureButton1:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoModelFrame, 0, -35)

	do
		local numBossButtons = 1
		local bossButton

		hooksecurefunc("EncounterJournal_DisplayInstance", function()
			bossButton = _G["EncounterJournalBossButton"..numBossButtons]
			while bossButton do
				B.Reskin(bossButton, true)

				bossButton.text:SetTextColor(1, 1, 1)
				bossButton.text.SetTextColor = B.Dummy

				local hl = bossButton:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .2)
				hl:SetAllPoints(bossButton.bgTex)

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
		header.flashAnim.Play = B.Dummy
		for i = 4, 18 do
			select(i, header.button:GetRegions()):SetTexture("")
		end
		B.Reskin(header.button)
		header.descriptionBG:SetAlpha(0)
		header.descriptionBGBottom:SetAlpha(0)
		header.description:SetTextColor(1, 1, 1)
		header.button.title:SetTextColor(1, 1, 1)
		header.button.title.SetTextColor = B.Dummy
		header.button.expandedIcon:SetTextColor(1, 1, 1)
		header.button.expandedIcon.SetTextColor = B.Dummy
	end

	hooksecurefunc("EncounterJournal_ToggleHeaders", function()
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.styled then
				reskinHeader(header)
				header.button.bg = B.ReskinIcon(header.button.abilityIcon)
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
		B.ReskinIcon(item.icon)

		local bg = B.CreateBDFrame(item, .25)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
	end

	-- [[ Search results ]]

	for i = 1, 5 do
		B.StyleSearchButton(EncounterJournalSearchBox["sbutton"..i])
	end
	B.StyleSearchButton(EncounterJournalSearchBox.showAllResults)
	B.StripTextures(EncounterJournalSearchBox.searchPreviewContainer)

	do
		local result = EncounterJournalSearchResults
		result:SetPoint("BOTTOMLEFT", EncounterJournal, "BOTTOMRIGHT", 15, -1)
		B.StripTextures(result)
		local bg = B.CreateBDFrame(result, nil, true)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")

		for i = 1, 9 do
			local bu = _G["EncounterJournalSearchResultsScrollFrameButton"..i]
			B.StripTextures(bu)
			B.ReskinIcon(bu.icon)
			bu.icon.SetTexCoord = B.Dummy
			B.CreateBD(bu, .25)
			bu:SetHighlightTexture(DB.bdTex)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .25)
			hl:SetInside()
		end
	end

	B.ReskinClose(EncounterJournalSearchResultsCloseButton)
	B.ReskinScroll(EncounterJournalSearchResultsScrollFrameScrollBar)

	-- [[ Various controls ]]

	B.ReskinPortraitFrame(EncounterJournal)
	B.Reskin(EncounterJournalEncounterFrameInfoResetButton)
	B.ReskinInput(EncounterJournalSearchBox)
	B.ReskinScroll(EncounterJournalInstanceSelectScrollFrameScrollBar)
	B.ReskinScroll(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	B.ReskinScroll(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar)
	B.ReskinScroll(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar)
	B.ReskinScroll(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar)
	B.ReskinScroll(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar)

	-- [[ Suggest frame ]]

	local suggestFrame = EncounterJournal.suggestFrame

	-- Suggestion 1

	local suggestion = suggestFrame.Suggestion1

	suggestion.bg:Hide()
	B.CreateBD(suggestion, .25)
	suggestion.icon:SetPoint("TOPLEFT", 135, -15)
	B.CreateBDFrame(suggestion.icon)

	local centerDisplay = suggestion.centerDisplay

	centerDisplay.title.text:SetTextColor(1, 1, 1)
	centerDisplay.description.text:SetTextColor(.9, .9, .9)
	B.Reskin(suggestion.button)

	local reward = suggestion.reward

	reward.text:SetTextColor(.9, .9, .9)
	reward.iconRing:Hide()
	reward.iconRingHighlight:SetTexture("")
	B.CreateBDFrame(reward.icon)
	B.ReskinArrow(suggestion.prevButton, "left")
	B.ReskinArrow(suggestion.nextButton, "right")

	-- Suggestion 2 and 3

	for i = 2, 3 do
		local suggestion = suggestFrame["Suggestion"..i]

		suggestion.bg:Hide()
		B.CreateBD(suggestion, .25)
		suggestion.icon:SetPoint("TOPLEFT", 10, -10)
		B.CreateBDFrame(suggestion.icon)

		local centerDisplay = suggestion.centerDisplay

		centerDisplay:ClearAllPoints()
		centerDisplay:SetPoint("TOPLEFT", 85, -10)
		centerDisplay.title.text:SetTextColor(1, 1, 1)
		centerDisplay.description.text:SetTextColor(.9, .9, .9)
		B.Reskin(centerDisplay.button)

		local reward = suggestion.reward
		reward.iconRing:Hide()
		reward.iconRingHighlight:SetTexture("")
		B.CreateBDFrame(reward.icon)
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
				suggestion.icon:SetTexCoord(unpack(DB.TexCoord))
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
					suggestion.icon:SetTexCoord(unpack(DB.TexCoord))
				end
			end
		end
	end)

	hooksecurefunc("EJSuggestFrame_UpdateRewards", function(suggestion)
		local rewardData = suggestion.reward.data
		if rewardData then
			suggestion.reward.icon:SetMask("")
			suggestion.reward.icon:SetTexCoord(unpack(DB.TexCoord))
		end
	end)

	-- [[ Loot Journal ]]

	EncounterJournal.LootJournal:GetRegions():Hide()
	B.ReskinScroll(EncounterJournal.LootJournal.ItemSetsFrame.scrollBar)

	local buttons = {
		EncounterJournalEncounterFrameInfoDifficulty,
		EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle,
		EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle,
		EncounterJournal.LootJournal.ItemSetsFrame.ClassButton,
	}
	for _, btn in pairs(buttons) do
		B.StripTextures(btn)
		B.Reskin(btn)
	end

	-- ItemSetsFrame

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "UpdateList", function(self)
		local buttons = self.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.styled then
				button.ItemLevel:SetTextColor(1, 1, 1)
				button.Background:Hide()
				B.CreateBDFrame(button, .25)

				button.styled = true
			end
		end
	end)

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "ConfigureItemButton", function(_, button)
		if not button.bg then
			button.Border:SetAlpha(0)
			button.bg = B.ReskinIcon(button.Icon)
		end

		local quality = select(3, GetItemInfo(button.itemID))
		local color = DB.QualityColors[quality or 1]
		button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end)
end