local F, C = unpack(select(2, ...))

C.themes["Blizzard_Collections"] = function()
	local r, g, b = C.r, C.g, C.b

	-- [[ General ]]

	CollectionsJournal.bg = F.ReskinPortraitFrame(CollectionsJournal)
	for i = 1, 5 do
		local tab = _G["CollectionsJournalTab"..i]
		F.ReskinTab(tab)
		if i > 1 then
			tab:SetPoint("LEFT", _G["CollectionsJournalTab"..(i-1)], "RIGHT", -15, 0)
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
	PetJournal.RightInset:Hide()
	PetJournal.PetCardInset:Hide()
	PetJournal.loadoutBorder:Hide()
	PetJournalTutorialButton.Ring:Hide()

	F.StripTextures(MountJournal.MountCount)
	F.CreateBD(MountJournal.MountCount, .25)
	F.StripTextures(PetJournal.PetCount)
	F.CreateBD(PetJournal.PetCount, .25)
	F.CreateBD(MountJournal.MountDisplay.ModelScene, .25)
	F.ReskinIcon(MountJournal.MountDisplay.InfoButton.Icon)

	F.Reskin(MountJournalMountButton)
	F.Reskin(PetJournalSummonButton)
	F.Reskin(PetJournalFindBattle)
	F.ReskinScroll(MountJournalListScrollFrameScrollBar)
	F.ReskinScroll(PetJournalListScrollFrameScrollBar)
	F.ReskinInput(MountJournalSearchBox)
	F.ReskinInput(PetJournalSearchBox)
	F.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateLeftButton, "left")
	F.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateRightButton, "right")
	F.ReskinFilterButton(PetJournalFilterButton)
	F.ReskinFilterButton(MountJournalFilterButton)

	local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
	F.ReskinCheck(togglePlayer)
	togglePlayer:SetSize(28, 28)

	F.StripTextures(MountJournal.BottomLeftInset)
	local bg = F.CreateBDFrame(MountJournal.BottomLeftInset, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", -24, 2)

	MountJournalFilterButton:SetPoint("TOPRIGHT", MountJournal.LeftInset, -5, -8)
	PetJournalFilterButton:SetPoint("TOPRIGHT", PetJournalLeftInset, -5, -8)
	PetJournalTutorialButton:SetPoint("TOPLEFT", PetJournal, "TOPLEFT", -14, 14)

	local scrollFrames = {MountJournal.ListScrollFrame.buttons, PetJournal.listScroll.buttons}
	for _, scrollFrame in pairs(scrollFrames) do
		for i = 1, #scrollFrame do
			local bu = scrollFrame[i]
			local ic = bu.icon

			bu:GetRegions():Hide()
			bu:SetHighlightTexture("")
			bu.iconBorder:SetTexture("")
			bu.selectedTexture:SetTexture("")

			local bg = F.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", 0, -1)
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			bu.bg = bg

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)

			bu.name:SetParent(bg)

			if bu.DragButton then
				bu.DragButton.ActiveTexture:SetTexture(C.media.checked)
				bu.DragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				bu.DragButton:GetHighlightTexture():SetAllPoints(ic)
			else
				bu.dragButton.ActiveTexture:SetTexture(C.media.checked)
				bu.dragButton.levelBG:SetAlpha(0)
				bu.dragButton.level:SetFontObject(GameFontNormal)
				bu.dragButton.level:SetTextColor(1, 1, 1)
				bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				bu.dragButton:GetHighlightTexture():SetAllPoints(ic)
			end
		end
	end

	local function updateMountScroll()
		local buttons = MountJournal.ListScrollFrame.buttons
		for i = 1, #buttons do
			local bu = buttons[i]
			if bu.bg then
				if bu.index ~= nil then
					bu.bg:Show()
					bu.icon:Show()
					bu.icon.bg:Show()

					if bu.selectedTexture:IsShown() then
						bu.bg:SetBackdropColor(r, g, b, .25)
					else
						bu.bg:SetBackdropColor(0, 0, 0, .25)
					end
				else
					bu.bg:Hide()
					bu.icon:Hide()
					bu.icon.bg:Hide()
				end
			end
		end
	end

	hooksecurefunc("MountJournal_UpdateMountList", updateMountScroll)
	hooksecurefunc(MountJournalListScrollFrame, "update", updateMountScroll)

	local function updatePetScroll()
		local petButtons = PetJournal.listScroll.buttons
		if petButtons then
			for i = 1, #petButtons do
				local bu = petButtons[i]

				local index = bu.index
				if index then
					local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)

					if petID and isOwned then
						local _, _, _, _, rarity = C_PetJournal.GetPetStats(petID)

						if rarity then
							local color = ITEM_QUALITY_COLORS[rarity-1]
							bu.name:SetTextColor(color.r, color.g, color.b)
						else
							bu.name:SetTextColor(1, 1, 1)
						end
					else
						bu.name:SetTextColor(.5, .5, .5)
					end

					if bu.selectedTexture:IsShown() then
						bu.bg:SetBackdropColor(r, g, b, .25)
					else
						bu.bg:SetBackdropColor(0, 0, 0, .25)
					end
				end
			end
		end
	end

	hooksecurefunc("PetJournal_UpdatePetList", updatePetScroll)
	hooksecurefunc(PetJournalListScrollFrame, "update", updatePetScroll)

	PetJournalHealPetButtonBorder:Hide()
	PetJournalHealPetButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	PetJournal.HealPetButton:SetPushedTexture("")
	PetJournal.HealPetButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	F.CreateBG(PetJournal.HealPetButton)

	if AuroraConfig.tooltips then
		F.ReskinTooltip(PetJournalPrimaryAbilityTooltip)
		F.ReskinTooltip(PetJournalSecondaryAbilityTooltip)
	end

	PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
	PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 4)

	PetJournalSummonRandomFavoritePetButtonBorder:Hide()
	PetJournalSummonRandomFavoritePetButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	PetJournalSummonRandomFavoritePetButton:SetPushedTexture("")
	PetJournalSummonRandomFavoritePetButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	F.CreateBG(PetJournalSummonRandomFavoritePetButton)

	-- Favourite mount button

	MountJournalSummonRandomFavoriteButtonBorder:Hide()
	MountJournalSummonRandomFavoriteButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	MountJournalSummonRandomFavoriteButton:SetPushedTexture("")
	MountJournalSummonRandomFavoriteButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	F.CreateBG(MountJournalSummonRandomFavoriteButton)

	local movedButton
	MountJournal:HookScript("OnShow", function()
		if not InCombatLockdown() and not movedButton then
			MountJournalSummonRandomFavoriteButton:SetPoint("TOPRIGHT", -10, -26)
			movedButton = true
		end
	end)

	-- Pet card

	local card = PetJournalPetCard

	PetJournalPetCardBG:Hide()
	card.PetInfo.levelBG:SetAlpha(0)
	card.PetInfo.qualityBorder:SetAlpha(0)
	card.AbilitiesBG1:SetAlpha(0)
	card.AbilitiesBG2:SetAlpha(0)
	card.AbilitiesBG3:SetAlpha(0)

	card.PetInfo.level:SetFontObject(GameFontNormal)
	card.PetInfo.level:SetTextColor(1, 1, 1)

	card.PetInfo.icon:SetTexCoord(.08, .92, .08, .92)
	card.PetInfo.icon.bg = F.CreateBG(card.PetInfo.icon)

	F.CreateBD(card, .25)

	for i = 2, 12 do
		select(i, card.xpBar:GetRegions()):Hide()
	end

	card.xpBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(card.xpBar, .25)

	PetJournalPetCardHealthFramehealthStatusBarLeft:Hide()
	PetJournalPetCardHealthFramehealthStatusBarRight:Hide()
	PetJournalPetCardHealthFramehealthStatusBarMiddle:Hide()
	PetJournalPetCardHealthFramehealthStatusBarBGMiddle:Hide()

	card.HealthFrame.healthBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(card.HealthFrame.healthBar, .25)

	for i = 1, 6 do
		local bu = card["spell"..i]
		F.ReskinIcon(bu.icon)
	end

	hooksecurefunc("PetJournal_UpdatePetCard", function(self)
		local border = self.PetInfo.qualityBorder
		local r, g, b

		if border:IsShown() then
			r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
		else
			r, g, b = 0, 0, 0
		end

		self.PetInfo.icon.bg:SetVertexColor(r, g, b)
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

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		bu.icon.bg = F.CreateBDFrame(bu.icon, .25)

		bu.setButton:GetRegions():SetPoint("TOPLEFT", bu.icon, -5, 5)
		bu.setButton:GetRegions():SetPoint("BOTTOMRIGHT", bu.icon, 5, -5)

		F.CreateBD(bu, .25)

		for i = 2, 12 do
			select(i, bu.xpBar:GetRegions()):Hide()
		end

		bu.xpBar:SetStatusBarTexture(C.media.backdrop)
		F.CreateBDFrame(bu.xpBar, .25)

		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarLeft"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarRight"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarMiddle"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarBGMiddle"]:Hide()

		bu.healthFrame.healthBar:SetStatusBarTexture(C.media.backdrop)
		F.CreateBDFrame(bu.healthFrame.healthBar, .25)

		for j = 1, 3 do
			local spell = bu["spell"..j]

			spell:SetPushedTexture("")
			spell:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			spell.selected:SetTexture(C.media.checked)
			spell:GetRegions():Hide()

			spell.FlyoutArrow:SetTexture(C.media.arrowDown)
			spell.FlyoutArrow:SetSize(8, 8)
			spell.FlyoutArrow:SetTexCoord(0, 1, 0, 1)

			spell.icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(spell.icon)
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

		bu:SetCheckedTexture(C.media.checked)
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		bu.icon:SetDrawLayer("ARTWORK")
		bu.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon)
	end

	-- [[ Toy box ]]

	local ToyBox = ToyBox
	local iconsFrame = ToyBox.iconsFrame

	F.StripTextures(iconsFrame)
	F.ReskinInput(ToyBox.searchBox)
	F.ReskinFilterButton(ToyBoxFilterButton)
	F.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
	F.ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")

	-- Progress bar

	local progressBar = ToyBox.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(C.media.backdrop)

	F.CreateBDFrame(progressBar, .25)

	-- Toys!

	local shouldChangeTextColor = true

	local changeTextColor = function(toyString)
		if shouldChangeTextColor then
			shouldChangeTextColor = false

			local self = toyString:GetParent()

			if PlayerHasToy(self.itemID) then
				local _, _, quality = GetItemInfo(self.itemID)
				if quality then
					toyString:SetTextColor(GetItemQualityColor(quality))
				else
					toyString:SetTextColor(1, 1, 1)
				end
			else
				toyString:SetTextColor(.5, .5, .5)
			end

			shouldChangeTextColor = true
		end
	end

	local buttons = ToyBox.iconsFrame
	for i = 1, 18 do
		local bu = buttons["spellButton"..i]
		local ic = bu.iconTexture

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:GetHighlightTexture():SetAllPoints(ic)
		bu.cooldown:SetAllPoints(ic)
		bu.slotFrameCollected:SetTexture("")
		bu.slotFrameUncollected:SetTexture("")
		F.ReskinIcon(ic)

		hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
	end

	-- [[ Heirlooms ]]

	local HeirloomsJournal = HeirloomsJournal
	local icons = HeirloomsJournal.iconsFrame

	F.StripTextures(icons)
	F.ReskinInput(HeirloomsJournalSearchBox)
	F.ReskinDropDown(HeirloomsJournalClassDropDown)
	F.ReskinFilterButton(HeirloomsJournalFilterButton)
	F.ReskinArrow(HeirloomsJournal.PagingFrame.PrevPageButton, "left")
	F.ReskinArrow(HeirloomsJournal.PagingFrame.NextPageButton, "right")

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
		button.level:SetFontObject("GameFontWhiteSmall")
		button.special:SetTextColor(1, .8, 0)
	end)

	-- Progress bar

	local progressBar = HeirloomsJournal.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(C.media.backdrop)

	F.CreateBDFrame(progressBar, .25)

	-- Buttons

	hooksecurefunc("HeirloomsJournal_UpdateButton", function(button)
		if not button.styled then
			local ic = button.iconTexture

			button.slotFrameCollected:SetTexture("")
			button.slotFrameUncollected:SetTexture("")
			button.levelBackground:SetAlpha(0)
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button:GetHighlightTexture():SetAllPoints(ic)

			button.iconTextureUncollected:SetTexCoord(.08, .92, .08, .92)
			button.bg = F.ReskinIcon(ic)

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
			button.bg:SetVertexColor(0, .8, 1)
			button.newLevelBg:Show()
		else
			button.name:SetTextColor(.5, .5, .5)
			button.bg:SetVertexColor(0, 0, 0)
			button.newLevelBg:Hide()
		end
	end)

	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
		for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			if not header.styled then
				header.text:SetTextColor(1, 1, 1)
				header.text:SetFont(C.media.font, 16, "OUTLINE")

				header.styled = true
			end
		end

		for i = 1, #HeirloomsJournal.heirloomEntryFrames do
			local button = HeirloomsJournal.heirloomEntryFrames[i]

			if button.iconTexture:IsShown() then
				button.name:SetTextColor(1, 1, 1)
				if button.bg then button.bg:SetVertexColor(0, .8, 1) end
				if button.newLevelBg then button.newLevelBg:Show() end
			else
				button.name:SetTextColor(.5, .5, .5)
				if button.bg then button.bg:SetVertexColor(0, 0, 0) end
				if button.newLevelBg then button.newLevelBg:Hide() end
			end
		end
	end)

	-- [[ WardrobeCollectionFrame ]]

	local WardrobeCollectionFrame = WardrobeCollectionFrame
	local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

	F.StripTextures(ItemsCollectionFrame)
	F.ReskinFilterButton(WardrobeCollectionFrame.FilterButton)
	F.ReskinDropDown(WardrobeCollectionFrameWeaponDropDown)
	F.ReskinInput(WardrobeCollectionFrameSearchBox)

	for index = 1, 2 do
		local tab = _G["WardrobeCollectionFrameTab"..index]
		for i = 1, 6 do
			select(i, tab:GetRegions()):SetAlpha(0)
		end
		tab:SetHighlightTexture("")
		tab.bg = F.CreateBDFrame(tab, .25)
		tab.bg:SetPoint("TOPLEFT", 3, -3)
		tab.bg:SetPoint("BOTTOMRIGHT", -3, -1)
	end

	hooksecurefunc("WardrobeCollectionFrame_SetTab", function(tabID)
		for index = 1, 2 do
			local tab = _G["WardrobeCollectionFrameTab"..index]
			if tabID == index then
				tab.bg:SetBackdropColor(r, g, b, .2)
			else
				tab.bg:SetBackdropColor(0, 0, 0, .2)
			end
		end
	end)

	F.ReskinArrow(ItemsCollectionFrame.PagingFrame.PrevPageButton, "left")
	F.ReskinArrow(ItemsCollectionFrame.PagingFrame.NextPageButton, "right")
	ItemsCollectionFrame.BGCornerTopLeft:SetAlpha(0)
	ItemsCollectionFrame.BGCornerTopRight:SetAlpha(0)

	local progressBar = WardrobeCollectionFrame.progressBar
	progressBar:DisableDrawLayer("BACKGROUND")
	select(2, progressBar:GetRegions()):Hide()
	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(progressBar, .25)

	-- ItemSetsCollection

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame.LeftInset:Hide()
	SetsCollectionFrame.RightInset:Hide()
	F.CreateBDFrame(SetsCollectionFrame.Model, .25)

	local ScrollFrame = SetsCollectionFrame.ScrollFrame
	F.ReskinScroll(ScrollFrame.scrollBar)
	for i = 1, #ScrollFrame.buttons do
		local bu = ScrollFrame.buttons[i]
		bu.Background:Hide()
		bu.HighlightTexture:SetTexture("")
		F.ReskinIcon(bu.Icon)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(r, g, b, .25)
		bu.SelectedTexture:ClearAllPoints()
		bu.SelectedTexture:SetPoint("TOPLEFT", 1, -2)
		bu.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
		F.CreateBDFrame(bu.SelectedTexture, .25)
	end

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.ModelFadeTexture:Hide()
	DetailsFrame.IconRowBackground:Hide()
	F.ReskinFilterButton(DetailsFrame.VariantSetsButton, "Down")

	hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
		local ic = itemFrame.Icon
		if not ic.bg then
			ic:SetTexCoord(.08, .92, .08, .92)
			itemFrame.IconBorder:Hide()
			itemFrame.IconBorder.Show = F.dummy
			ic.bg = F.CreateBDFrame(ic)
		end

		if itemFrame.collected then
			local quality = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID).quality
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			ic.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	local SetsTransmogFrame = WardrobeCollectionFrame.SetsTransmogFrame
	F.StripTextures(SetsTransmogFrame)
	F.ReskinArrow(SetsTransmogFrame.PagingFrame.PrevPageButton, "left")
	F.ReskinArrow(SetsTransmogFrame.PagingFrame.NextPageButton, "right")

	-- [[ Wardrobe ]]

	local WardrobeFrame = WardrobeFrame
	local WardrobeTransmogFrame = WardrobeTransmogFrame

	F.StripTextures(WardrobeTransmogFrame)
	F.ReskinPortraitFrame(WardrobeFrame)
	F.Reskin(WardrobeTransmogFrame.ApplyButton)
	F.StripTextures(WardrobeTransmogFrame.SpecButton)
	F.ReskinArrow(WardrobeTransmogFrame.SpecButton, "down")
	WardrobeTransmogFrame.SpecButton:SetPoint("RIGHT", WardrobeTransmogFrame.ApplyButton, "LEFT", -3, 0)
	for i = 1, 10 do
		select(i, WardrobeTransmogFrame.Model.ClearAllPendingButton:GetRegions()):Hide()
	end

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "Shirt", "Tabard", "MainHand", "SecondaryHand"}
	for i = 1, #slots do
		local slot = WardrobeTransmogFrame.Model[slots[i].."Button"]
		if slot then
			slot.Border:Hide()
			slot.Icon:SetDrawLayer("BACKGROUND", 1)
			F.ReskinIcon(slot.Icon)
			slot:SetHighlightTexture(C.media.backdrop)
			local hl = slot:GetHighlightTexture()
			hl:SetVertexColor(1, 1, 1, .25)
			hl:SetAllPoints(slot.Icon)
		end
	end

	-- Outfit Frame
	F.Reskin(WardrobeOutfitDropDown.SaveButton)
	F.ReskinDropDown(WardrobeOutfitDropDown)
	WardrobeOutfitDropDown:SetHeight(32)
	WardrobeOutfitDropDown.SaveButton:SetPoint("LEFT", WardrobeOutfitDropDown, "RIGHT", -13, 2)
	F.StripTextures(WardrobeOutfitFrame)
	F.CreateBDFrame(WardrobeOutfitFrame, .7)
	F.CreateSD(WardrobeOutfitFrame)

	hooksecurefunc(WardrobeOutfitFrame, "Update", function(self)
		for i = 1, C_TransmogCollection.GetNumMaxOutfits() do
			local button = self.Buttons[i]
			if button and button:IsShown() and not button.styled then
				F.ReskinIcon(button.Icon)
				button.Selection:SetColorTexture(1, 1, 1, .25)
				button.Highlight:SetColorTexture(r, g, b, .25)

				button.styled = true
			end
		end
	end)

	F.StripTextures(WardrobeOutfitEditFrame)
	WardrobeOutfitEditFrame.EditBox:DisableDrawLayer("BACKGROUND")
	F.CreateBD(WardrobeOutfitEditFrame)
	F.CreateSD(WardrobeOutfitEditFrame)
	local bg = F.CreateBDFrame(WardrobeOutfitEditFrame.EditBox, .25)
	bg:SetPoint("TOPLEFT", -5, -3)
	bg:SetPoint("BOTTOMRIGHT", 5, 3)
	F.CreateGradient(bg)
	F.Reskin(WardrobeOutfitEditFrame.AcceptButton)
	F.Reskin(WardrobeOutfitEditFrame.CancelButton)
	F.Reskin(WardrobeOutfitEditFrame.DeleteButton)

	-- HPetBattleAny
	local reskinHPet
	CollectionsJournal:HookScript("OnShow", function()
		if not IsAddOnLoaded("HPetBattleAny") then return end
		if not reskinHPet then
			F.Reskin(HPetInitOpenButton)
			F.Reskin(HPetAllInfoButton)
			for i = 1, 9 do
				select(i, HPetAllInfoButton:GetRegions()):Hide()
			end

			if PetJournalBandageButton then
				PetJournalBandageButton:SetPushedTexture("")
				PetJournalBandageButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				PetJournalBandageButtonBorder:Hide()
				PetJournalBandageButtonIcon:SetTexCoord(.08, .92, .08, .92)
				PetJournalBandageButton:SetPoint("TOPRIGHT", PetJournalHealPetButton, "TOPLEFT", -3, 0)
				PetJournalBandageButton:SetPoint("BOTTOMLEFT", PetJournalHealPetButton, "BOTTOMLEFT", -35, 0)
				F.CreateBDFrame(PetJournalBandageButtonIcon)
			end
			reskinHPet = true
		end
	end)
end