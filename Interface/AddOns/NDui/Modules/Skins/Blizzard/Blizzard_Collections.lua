local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function reskinCollectionButton(child)
	if not child.styled then
		child.background:SetAlpha(0)
		child:GetHighlightTexture():SetColorTexture(1, 1, 1, .15)
		child.iconBorder:SetTexture("")
		child.selectedTexture:SetAlpha(0)

		local bg = B.CreateBDFrame(child, .25)
		bg:SetPoint("TOPLEFT", 3, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		child.bg = bg

		local icon = child.icon
		icon:SetSize(42, 42)
		icon.bg = B.ReskinIcon(icon)
		local dragButton = child.DragButton or child.dragButton
		dragButton.ActiveTexture:SetAlpha(0)
		if dragButton.levelBG then dragButton.levelBG:SetAlpha(0) end
		if dragButton.level then
			dragButton.level:SetFontObject(GameFontNormal)
			dragButton.level:SetTextColor(1, 1, 1)
		end
		dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		dragButton:GetHighlightTexture():SetAllPoints(icon)

		child.styled = true
	end
	if child.selectedTexture:IsShown() then
		child.bg:SetBackdropColor(cr, cg, cb, .25)
	else
		child.bg:SetBackdropColor(0, 0, 0, .25)
	end
	local dragButton = child.DragButton or child.dragButton
	if dragButton.ActiveTexture:IsShown() then
		child.icon.bg:SetBackdropBorderColor(1, .8, 0)
	else
		child.icon.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function reskinFrameButton(self)
	self:ForEachFrame(reskinCollectionButton)
end

local function updateSideTabIcon(tab)
	tab.Icon:SetSize(36, 36)
	tab.Icon:SetTexCoord(unpack(DB.TexCoord))
end

local function reskinSideTab(tab)
	tab.Background:SetAlpha(0)
	tab.Icon:RemoveMaskTexture(tab.Mask)
	B.ReskinIcon(tab.Icon, true)
	tab.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	tab.HighlightTexture:SetAllPoints(tab.Icon)
	tab.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
	tab.SelectedTexture:SetAllPoints(tab.Icon)
	tab.TabGlow:SetColorTexture(cr, cg, cb, .25)
	tab.TabGlow:SetAllPoints(tab.Icon)
	hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
	updateSideTabIcon(tab)
end

local function reskinProgressTracker(tracker)
	B.StripTextures(tracker)
	if not tracker.isCount then
		tracker.text:SetPoint("CENTER", 0, 1)
		tracker:SetStatusBarTexture(DB.bdTex)
	end
	B.CreateBDFrame(tracker, .25)
end

C.themes["Blizzard_Collections"] = function()
	-- [[ General ]]

	CollectionsJournal.bg = B.ReskinPortraitFrame(CollectionsJournal) -- need this for Rematch skin
	if CollectionsJournal.TabContainer then
		for _, tab in ipairs(CollectionsJournal.TabContainer.Tabs) do
			reskinSideTab(tab)
		end
	else
		for i = 1, 6 do
			local tab = _G["CollectionsJournalTab"..i]
			if tab then
				B.ReskinTab(tab)
				if i ~= 1 then
					tab:ClearAllPoints()
					tab:SetPoint("TOPLEFT", _G["CollectionsJournalTab"..(i-1)], "TOPRIGHT", -15, 0)
				end
			end
		end
	end

	-- [[ Mounts and pets ]]

	local PetJournal = PetJournal
	local MountJournal = MountJournal

	MountJournal.LeftInset:Hide()
	MountJournal.RightInset:Hide()
	MountJournal.MountDisplay.YesMountsTex:SetAlpha(0)
	MountJournal.MountDisplay.NoMountsTex:SetAlpha(0)
	MountJournal.MountDisplay.ShadowOverlay:Hide()
	PetJournal.LeftInset:Hide()
	PetJournal.RightInset:SetAlpha(0)
	if PetJournal.PetCardInset then PetJournal.PetCardInset:Hide() end
	if PetJournal.loadoutBorder then PetJournal.loadoutBorder:SetAlpha(0) end
	if PetJournalTutorialButton then PetJournalTutorialButton.Ring:Hide() end

	B.StripTextures(MountJournal.MountCount)
	B.CreateBDFrame(MountJournal.MountCount, .25)
	B.StripTextures(PetJournal.PetCount)
	B.CreateBDFrame(PetJournal.PetCount, .25)
	PetJournal.PetCount:SetWidth(140)
	B.CreateBDFrame(MountJournal.MountDisplay.ModelScene, .25)
	B.ReskinIcon(MountJournal.MountDisplay.InfoButton.Icon)
	B.ReskinModelControl(MountJournal.MountDisplay.ModelScene)

	B.Reskin(MountJournalMountButton)
	B.Reskin(PetJournalSummonButton)
	if PetJournalFindBattle then B.Reskin(PetJournalFindBattle) end

	B.ReskinTrimScroll(MountJournal.ScrollBar)
	hooksecurefunc(MountJournal.ScrollBox, "Update", reskinFrameButton)
	hooksecurefunc("MountJournal_InitMountButton", function(button)
		reskinCollectionButton(button)
		button.icon:SetShown(button.index ~= nil)
	end)

	B.ReskinTrimScroll(PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, "Update", reskinFrameButton)
	hooksecurefunc("PetJournal_InitPetButton", function(button)
		reskinCollectionButton(button)
		local index = button.index
		if not index then return end

		local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)
		if PetJournal.Loadout and petID and isOwned then
			local rarity = select(5, C_PetJournal.GetPetStats(petID))
			if rarity then
				local r, g, b = C_Item.GetItemQualityColor(rarity-1)
				button.name:SetTextColor(r, g, b)
			else
				button.name:SetTextColor(1, 1, 1)
			end
		elseif PetJournal.Loadout then
			button.name:SetTextColor(.5, .5, .5)
		end
	end)

	B.ReskinInput(MountJournalSearchBox)
	B.ReskinInput(PetJournalSearchBox)
	B.ReskinFilterButton(PetJournal.FilterDropdown)
	B.ReskinFilterButton(MountJournal.FilterDropdown)

	local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
	B.ReskinCheck(togglePlayer)
	togglePlayer:SetSize(28, 28)

	B.StripTextures(MountJournal.BottomLeftInset)
	local bg = B.CreateBDFrame(MountJournal.BottomLeftInset, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", -24, 2)
	if PetJournalTutorialButton then PetJournalTutorialButton:SetPoint("TOPLEFT", PetJournal, "TOPLEFT", -14, 14) end

	local function reskinToolButton(button)
		button.Border:Hide()
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIcon(button.Icon)
	end
	if PetJournal.HealPetSpellFrame then reskinToolButton(PetJournal.HealPetSpellFrame.Button) end
	reskinToolButton(PetJournal.SummonRandomPetSpellFrame.Button)

	if PetJournal.Loadout then
		PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
		PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 4)
	end

	-- Favourite mount button

	reskinToolButton(MountJournal.SummonRandomFavoriteSpellFrame.Button)

	local function reskinDynamicButton(button, index)
		if button.Border then button.Border:Hide() end
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIcon(select(index, button:GetRegions()), nil)
		button:SetNormalTexture(0)
	end
	if MountJournal.ToggleDynamicFlightFlyoutButton then
		reskinDynamicButton(MountJournal.ToggleDynamicFlightFlyoutButton, 3)

		local flyout = MountJournal.ToggleDynamicFlightFlyoutButton.popup or MountJournal.DynamicFlightFlyout
		if flyout then
			flyout.Background:Hide()
			reskinDynamicButton(flyout.OpenDynamicFlightSkillTreeButton, 4)
			reskinDynamicButton(flyout.DynamicFlightModeButton, 4)
		end
	end

	-- Pet card

	local card = PetJournalPetCard

	if PetJournal.Loadout then
		PetJournalPetCardBG:Hide()
		card.PetInfo.levelBG:SetAlpha(0)
		card.PetInfo.qualityBorder:SetAlpha(0)
		card.AbilitiesBG1:SetAlpha(0)
		card.AbilitiesBG2:SetAlpha(0)
		card.AbilitiesBG3:SetAlpha(0)

		card.PetInfo.level:SetFontObject(GameFontNormal)
		card.PetInfo.level:SetTextColor(1, 1, 1)

		card.PetInfo.icon.bg = B.ReskinIcon(card.PetInfo.icon)

		B.CreateBDFrame(card, .25)

		for i = 2, 12 do
			select(i, card.xpBar:GetRegions()):Hide()
		end

		card.xpBar:SetStatusBarTexture(DB.bdTex)
		B.CreateBDFrame(card.xpBar, .25)

		PetJournalPetCardHealthFramehealthStatusBarLeft:Hide()
		PetJournalPetCardHealthFramehealthStatusBarRight:Hide()
		PetJournalPetCardHealthFramehealthStatusBarMiddle:Hide()
		PetJournalPetCardHealthFramehealthStatusBarBGMiddle:Hide()

		card.HealthFrame.healthBar:SetStatusBarTexture(DB.bdTex)
		B.CreateBDFrame(card.HealthFrame.healthBar, .25)

		for i = 1, 6 do
			local bu = card["spell"..i]
			B.ReskinIcon(bu.icon)
		end

		hooksecurefunc("PetJournal_UpdatePetCard", function(self)
			local border = self.PetInfo.qualityBorder
			local r, g, b

			if border:IsShown() then
				r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
			else
				r, g, b = 0, 0, 0
			end

			self.PetInfo.icon.bg:SetBackdropBorderColor(r, g, b)
		end)

		-- Pet loadout

		for i = 1, 3 do
			local bu = PetJournal.Loadout["Pet"..i]

			_G["PetJournalLoadoutPet"..i.."BG"]:Hide()

			bu.iconBorder:SetAlpha(0)
			bu.qualityBorder:SetTexture("")
			bu.levelBG:SetAlpha(0)
			bu.helpFrame:GetRegions():Hide()
			bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			bu.level:SetFontObject(GameFontNormal)
			bu.level:SetTextColor(1, 1, 1)

			bu.icon.bg = B.ReskinIcon(bu.icon)

			bu.setButton:GetRegions():SetPoint("TOPLEFT", bu.icon, -5, 5)
			bu.setButton:GetRegions():SetPoint("BOTTOMRIGHT", bu.icon, 5, -5)

			B.CreateBDFrame(bu, .25)

			for i = 2, 12 do
				select(i, bu.xpBar:GetRegions()):Hide()
			end

			bu.xpBar:SetStatusBarTexture(DB.bdTex)
			B.CreateBDFrame(bu.xpBar, .25)

			B.StripTextures(bu.healthFrame.healthBar)
			bu.healthFrame.healthBar:SetStatusBarTexture(DB.bdTex)
			B.CreateBDFrame(bu.healthFrame.healthBar, .25)

			for j = 1, 3 do
				local spell = bu["spell"..j]

				spell:SetPushedTexture(0)
				spell:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				spell.selected:SetTexture(DB.pushedTex)
				spell:GetRegions():Hide()

				local flyoutArrow = spell.FlyoutArrow
				B.SetupArrow(flyoutArrow, "down")
				flyoutArrow:SetSize(14, 14)
				flyoutArrow:SetTexCoord(0, 1, 0, 1)

				B.ReskinIcon(spell.icon)
			end
		end

		hooksecurefunc("PetJournal_UpdatePetLoadOut", function()
			for i = 1, 3 do
				local bu = PetJournal.Loadout["Pet"..i]

				bu.icon.bg:SetShown(not bu.helpFrame:IsShown())
				bu.icon.bg:SetBackdropBorderColor(bu.qualityBorder:GetVertexColor())

				bu.dragButton:SetEnabled(not bu.helpFrame:IsShown())
			end
		end)

		PetJournal.SpellSelect.BgEnd:Hide()
		PetJournal.SpellSelect.BgTiled:Hide()

		for i = 1, 2 do
			local bu = PetJournal.SpellSelect["Spell"..i]

			bu:SetCheckedTexture(DB.pushedTex)
			bu:SetPushedTexture(0)
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			B.ReskinIcon(bu.icon)
		end
	else
		card.PetBackground:SetAlpha(0)
		card.ShadowOverlay:SetAlpha(0)
		B.CreateBDFrame(card, .25)
		B.ReskinIcon(card.PetInfo.icon)
		B.ReskinArrow(card.modelScene.RotateLeftButton, "left")
		B.ReskinArrow(card.modelScene.RotateRightButton, "right")
	end

	-- These lists may already contain rows when the addon is loaded.
	reskinFrameButton(MountJournal.ScrollBox)
	reskinFrameButton(PetJournal.ScrollBox)

	-- [[ Toy box ]]

	local ToyBox = ToyBox
	local iconsFrame = ToyBox.iconsFrame

	B.StripTextures(iconsFrame)
	B.ReskinInput(ToyBox.searchBox)
	B.ReskinFilterButton(ToyBox.FilterDropdown)
	B.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")

	-- Progress bar

	reskinProgressTracker(ToyBox.ProgressTracker or ToyBox.progressBar)

	-- Toys!

	local function changeTextColor(text)
		if text.isSetting then return end
		text.isSetting = true

		local bu = text:GetParent()
		local itemID = bu.itemID

		if itemID and PlayerHasToy(itemID) then
			local quality = select(3, C_Item.GetItemInfo(itemID))
			if quality then
				local r, g, b = C_Item.GetItemQualityColor(quality)
				text:SetTextColor(r, g, b)
			else
				text:SetTextColor(1, 1, 1)
			end
		else
			text:SetTextColor(.5, .5, .5)
		end

		text.isSetting = nil
	end

	local buttons = ToyBox.iconsFrame
	for i = 1, 18 do
		local bu = buttons["spellButton"..i]
		local ic = bu.iconTexture

		bu:SetPushedTexture(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:GetHighlightTexture():SetAllPoints(ic)
		bu.cooldown:SetAllPoints(ic)
		bu.slotFrameCollected:SetTexture("")
		bu.slotFrameUncollected:SetTexture("")
		bu.iconTextureUncollected:SetTexCoord(unpack(DB.TexCoord))
		B.ReskinIcon(ic)

		hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
	end

	-- [[ Heirlooms ]]

	local HeirloomsJournal = HeirloomsJournal
	local icons = HeirloomsJournal.iconsFrame

	B.StripTextures(icons)
	B.ReskinInput(HeirloomsJournalSearchBox)
	B.ReskinDropDown(HeirloomsJournal.ClassDropdown)
	B.ReskinFilterButton(HeirloomsJournal.FilterDropdown)
	B.ReskinArrow(HeirloomsJournal.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(HeirloomsJournal.PagingFrame.NextPageButton, "right")

	-- Progress bar

	reskinProgressTracker(HeirloomsJournal.progressBar)

	-- Buttons

	local function reskinHeirloomButton(_, button)
		button.level:SetFontObject("GameFontWhiteSmall")
		button.special:SetTextColor(1, .8, 0)
		if not button.styled then
			local ic = button.iconTexture

			button.slotFrameCollected:SetTexture("")
			button.slotFrameUncollected:SetTexture("")
			button.levelBackground:SetAlpha(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button:GetHighlightTexture():SetAllPoints(ic)

			button.iconTextureUncollected:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.ReskinIcon(ic)

			button.level:ClearAllPoints()
			button.level:SetPoint("BOTTOM", 0, 1)

			local newLevelBg = button:CreateTexture(nil, "OVERLAY")
			newLevelBg:SetColorTexture(0, 0, 0, .5)
			newLevelBg:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 4, 5)
			newLevelBg:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 5)
			newLevelBg:SetHeight(11)
			button.newLevelBg = newLevelBg

			button.styled = true
		end

		if button.iconTexture:IsShown() then
			button.name:SetTextColor(1, 1, 1)
			button.bg:SetBackdropBorderColor(0, .8, 1)
			button.newLevelBg:Show()
		else
			button.name:SetTextColor(.5, .5, .5)
			button.bg:SetBackdropBorderColor(0, 0, 0)
			button.newLevelBg:Hide()
		end
	end
	hooksecurefunc(HeirloomsJournal, "UpdateButton", reskinHeirloomButton)

	local function reskinHeirloomPage(self)
		for _, header in ipairs(self.heirloomHeaderFrames or {}) do
			if not header.styled then
				header.text:SetTextColor(1, 1, 1)
				B.SetFontSize(header.text, 16)

				header.styled = true
			end
		end

		for _, button in ipairs(self.heirloomEntryFrames or {}) do
			reskinHeirloomButton(self, button)
		end
	end
	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", reskinHeirloomPage)
	reskinHeirloomPage(HeirloomsJournal)

	-- [[ WardrobeCollectionFrame ]]

	local WardrobeCollectionFrame = WardrobeCollectionFrame
	local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

	B.StripTextures(ItemsCollectionFrame)
	B.ReskinFilterButton(WardrobeCollectionFrame.FilterButton)
	B.ReskinInput(WardrobeCollectionFrameSearchBox)
	B.ReskinDropDown(WardrobeCollectionFrame.ClassDropdown)
	B.ReskinDropDown(ItemsCollectionFrame.WeaponDropdown)

	local function updateWardrobeTabs(self, tabID)
		for index = 1, 2 do
			local tab = self.Tabs[index]
			if not tab.bg then
				B.ReskinTab(tab)
			end
			if tabID == index then
				tab.bg:SetBackdropColor(cr, cg, cb, .25)
			else
				tab.bg:SetBackdropColor(0, 0, 0, .25)
			end
		end
	end
	hooksecurefunc(WardrobeCollectionFrame, "SetTab", updateWardrobeTabs)
	updateWardrobeTabs(WardrobeCollectionFrame, WardrobeCollectionFrame.selectedCollectionTab)

	B.ReskinArrow(ItemsCollectionFrame.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ItemsCollectionFrame.PagingFrame.NextPageButton, "right")
	ItemsCollectionFrame.BGCornerTopLeft:SetAlpha(0)
	ItemsCollectionFrame.BGCornerTopRight:SetAlpha(0)

	local function updateAppearanceModels(self)
		for _, model in ipairs(self.Models) do
			if not model.bg then
				model.Border:SetAlpha(0)
				model.bg = B.CreateBDFrame(model, .25)
				model.bg:SetInside(nil, 2, 2)
			end
			local visualInfo = model.visualInfo
			if visualInfo and visualInfo.isCollected then
				if visualInfo.isUsable then
					model.bg:SetBackdropBorderColor(0, .8, 1)
				else
					model.bg:SetBackdropBorderColor(1, .2, .2)
				end
			else
				model.bg:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
	hooksecurefunc(ItemsCollectionFrame, "UpdateItems", updateAppearanceModels)
	updateAppearanceModels(ItemsCollectionFrame)

	reskinProgressTracker(WardrobeCollectionFrame.progressBar)

	-- ItemSetsCollection

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame.LeftInset:Hide()
	SetsCollectionFrame.RightInset:Hide()
	B.CreateBDFrame(SetsCollectionFrame.Model, .25)

	B.ReskinTrimScroll(SetsCollectionFrame.ListContainer.ScrollBar)
	local function reskinSetButtons(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child.Background:SetAlpha(0)
				child.HighlightTexture:SetColorTexture(1, 1, 1, .15)

				local icon = child.IconFrame and child.IconFrame.Icon or child.Icon
				if icon then
					icon:SetSize(42, 42)
					B.ReskinIcon(icon)
					local cover = child.IconFrame and child.IconFrame.Cover or child.IconCover
					if cover then
						cover:SetOutside(icon)
					end
				end

				child.SelectedTexture:SetDrawLayer("BACKGROUND")
				child.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
				child.SelectedTexture:ClearAllPoints()
				child.SelectedTexture:SetPoint("TOPLEFT", 4, -2)
				child.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
				B.CreateBDFrame(child.SelectedTexture, .25)

				child.styled = true
			end
		end
	end
	hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, "Update", reskinSetButtons)
	reskinSetButtons(SetsCollectionFrame.ListContainer.ScrollBox)

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.ModelFadeTexture:Hide()
	DetailsFrame.IconRowBackground:Hide()
	B.ReskinDropDown(DetailsFrame.VariantSetsDropdown)

	hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
		local ic = itemFrame.Icon
		if not ic.bg then
			ic.bg = B.ReskinIcon(ic)
		end
		itemFrame.IconBorder:SetTexture("")

		if itemFrame.collected then
			local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
			local quality = sourceInfo and sourceInfo.quality
			local color = DB.QualityColors[quality or 1]
			ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			ic.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	-- HPetBattleAny
	local reskinHPet
	CollectionsJournal:HookScript("OnShow", function()
		if not C_AddOns.IsAddOnLoaded("HPetBattleAny") then return end
		if not reskinHPet then
			if HPetInitOpenButton then
				B.Reskin(HPetInitOpenButton)
			end
			if HPetAllInfoButton then
				B.StripTextures(HPetAllInfoButton)
				B.Reskin(HPetAllInfoButton)
			end

			if PetJournalBandageButton then
				PetJournalBandageButton:SetPushedTexture(0)
				PetJournalBandageButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				PetJournalBandageButtonBorder:Hide()
				PetJournalBandageButton:SetPoint("TOPRIGHT", PetJournalHealPetButton, "TOPLEFT", -3, 0)
				PetJournalBandageButton:SetPoint("BOTTOMLEFT", PetJournalHealPetButton, "BOTTOMLEFT", -35, 0)
				B.ReskinIcon(PetJournalBandageButtonIcon)
			end
			reskinHPet = true
		end
	end)

	-- WarbandSceneJournal
	if WarbandSceneJournal then
		local iconsFrame = WarbandSceneJournal.IconsFrame
		if iconsFrame then
			B.StripTextures(iconsFrame)

			local controls = iconsFrame.Icons and iconsFrame.Icons.Controls
			if controls then
				local showCheck = controls and controls.ShowOwned and controls.ShowOwned.Checkbox
				if showCheck then
					B.ReskinCheck(showCheck)
					showCheck:SetSize(28, 28)
				end
				if controls.PagingControls then
					B.ReskinArrow(controls.PagingControls.PrevPageButton, "left")
					B.ReskinArrow(controls.PagingControls.NextPageButton, "right")
				end
			end
		end
	end
end
