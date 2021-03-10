local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Collections"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	-- [[ General ]]

	CollectionsJournal.bg = B.ReskinPortraitFrame(CollectionsJournal) -- need this for Rematch skin
	for i = 1, 5 do
		local tab = _G["CollectionsJournalTab"..i]
		B.ReskinTab(tab)
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

	B.StripTextures(MountJournal.MountCount)
	B.CreateBDFrame(MountJournal.MountCount, .25)
	B.StripTextures(PetJournal.PetCount)
	B.CreateBDFrame(PetJournal.PetCount, .25)
	PetJournal.PetCount:SetWidth(140)
	B.CreateBDFrame(MountJournal.MountDisplay.ModelScene, .25)
	B.ReskinIcon(MountJournal.MountDisplay.InfoButton.Icon)

	B.Reskin(MountJournalMountButton)
	B.Reskin(PetJournalSummonButton)
	B.Reskin(PetJournalFindBattle)
	B.ReskinScroll(MountJournalListScrollFrameScrollBar)
	B.ReskinScroll(PetJournalListScrollFrameScrollBar)
	B.ReskinInput(MountJournalSearchBox)
	B.ReskinInput(PetJournalSearchBox)
	B.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateLeftButton, "left")
	B.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateRightButton, "right")
	B.ReskinFilterButton(PetJournalFilterButton)
	B.ReskinFilterButton(MountJournalFilterButton)

	local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
	B.ReskinCheck(togglePlayer)
	togglePlayer:SetSize(28, 28)

	B.StripTextures(MountJournal.BottomLeftInset)
	local bg = B.CreateBDFrame(MountJournal.BottomLeftInset, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", -24, 2)

	MountJournalFilterButton:SetPoint("TOPRIGHT", MountJournal.LeftInset, -5, -8)
	PetJournalFilterButton:SetPoint("TOPRIGHT", PetJournalLeftInset, -5, -8)
	PetJournalTutorialButton:SetPoint("TOPLEFT", PetJournal, "TOPLEFT", -14, 14)

	local scrollFrames = {MountJournal.ListScrollFrame.buttons, PetJournal.listScroll.buttons}
	for _, scrollFrame in pairs(scrollFrames) do
		for i = 1, #scrollFrame do
			local bu = scrollFrame[i]
			local icon = bu.icon

			bu:GetRegions():Hide()
			bu:SetHighlightTexture("")
			bu.iconBorder:SetTexture("")
			bu.selectedTexture:SetTexture("")

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", 3, -1)
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			bu.bg = bg

			icon:SetSize(42, 42)
			icon.bg = B.ReskinIcon(icon)
			bu.name:SetParent(bg)

			if bu.DragButton then
				bu.DragButton.ActiveTexture:SetTexture("")
				bu.DragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				bu.DragButton:GetHighlightTexture():SetAllPoints(icon)
			else
				bu.dragButton.ActiveTexture:SetTexture("")
				bu.dragButton.levelBG:SetAlpha(0)
				bu.dragButton.level:SetFontObject(GameFontNormal)
				bu.dragButton.level:SetTextColor(1, 1, 1)
				bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				bu.dragButton:GetHighlightTexture():SetAllPoints(icon)
			end
		end
	end

	local function updateMountScroll()
		local buttons = MountJournal.ListScrollFrame.buttons
		for i = 1, #buttons do
			local bu = buttons[i]
			if bu.bg then
				bu.icon:SetShown(bu.index ~= nil)

				if bu.selectedTexture:IsShown() then
					bu.bg:SetBackdropColor(r, g, b, .25)
				else
					bu.bg:SetBackdropColor(0, 0, 0, .25)
				end

				if bu.DragButton.ActiveTexture:IsShown() then
					bu.icon.bg:SetBackdropBorderColor(1, .8, 0)
				else
					bu.icon.bg:SetBackdropBorderColor(0, 0, 0)
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
						local rarity = select(5, C_PetJournal.GetPetStats(petID))
						if rarity then
							bu.name:SetTextColor(GetItemQualityColor(rarity-1))
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

					if bu.dragButton.ActiveTexture:IsShown() then
						bu.icon.bg:SetBackdropBorderColor(1, .8, 0)
					else
						bu.icon.bg:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end

	hooksecurefunc("PetJournal_UpdatePetList", updatePetScroll)
	hooksecurefunc(PetJournalListScrollFrame, "update", updatePetScroll)

	local function reskinToolButton(button)
		local border = _G[button:GetName().."Border"]
		if border then border:Hide() end
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIcon(button.texture)
	end

	reskinToolButton(PetJournalHealPetButton)

	PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
	PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 4)

	reskinToolButton(PetJournalSummonRandomFavoritePetButton)

	-- Favourite mount button

	reskinToolButton(MountJournalSummonRandomFavoriteButton)

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

			spell:SetPushedTexture("")
			spell:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			spell.selected:SetTexture(DB.textures.pushed)
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

		bu:SetCheckedTexture(DB.textures.pushed)
		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		B.ReskinIcon(bu.icon)
	end

	-- [[ Toy box ]]

	local ToyBox = ToyBox
	local iconsFrame = ToyBox.iconsFrame

	B.StripTextures(iconsFrame)
	B.ReskinInput(ToyBox.searchBox)
	B.ReskinFilterButton(ToyBoxFilterButton)
	B.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")

	-- Progress bar

	local progressBar = ToyBox.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(DB.bdTex)

	B.CreateBDFrame(progressBar, .25)

	-- Toys!

	local function changeTextColor(text)
		if text.isSetting then return end
		text.isSetting = true

		local bu = text:GetParent()
		local itemID = bu.itemID

		if PlayerHasToy(itemID) then
			local quality = select(3, GetItemInfo(itemID))
			if quality then
				text:SetTextColor(GetItemQualityColor(quality))
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

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:GetHighlightTexture():SetAllPoints(ic)
		bu.cooldown:SetAllPoints(ic)
		bu.slotFrameCollected:SetTexture("")
		bu.slotFrameUncollected:SetTexture("")
		B.ReskinIcon(ic)

		hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
	end

	-- [[ Heirlooms ]]

	local HeirloomsJournal = HeirloomsJournal
	local icons = HeirloomsJournal.iconsFrame

	B.StripTextures(icons)
	B.ReskinInput(HeirloomsJournalSearchBox)
	B.ReskinDropDown(HeirloomsJournalClassDropDown)
	B.ReskinFilterButton(HeirloomsJournalFilterButton)
	B.ReskinArrow(HeirloomsJournal.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(HeirloomsJournal.PagingFrame.NextPageButton, "right")

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
		button.level:SetFontObject("GameFontWhiteSmall")
		button.special:SetTextColor(1, .8, 0)
	end)

	-- Progress bar

	local progressBar = HeirloomsJournal.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(DB.bdTex)

	B.CreateBDFrame(progressBar, .25)

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
	end)

	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
		for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			if not header.styled then
				header.text:SetTextColor(1, 1, 1)
				header.text:SetFont(DB.Font[1], 16, DB.Font[3])

				header.styled = true
			end
		end

		for i = 1, #HeirloomsJournal.heirloomEntryFrames do
			local button = HeirloomsJournal.heirloomEntryFrames[i]

			if button.iconTexture:IsShown() then
				button.name:SetTextColor(1, 1, 1)
				if button.bg then button.bg:SetBackdropBorderColor(0, .8, 1) end
				if button.newLevelBg then button.newLevelBg:Show() end
			else
				button.name:SetTextColor(.5, .5, .5)
				if button.bg then button.bg:SetBackdropBorderColor(0, 0, 0) end
				if button.newLevelBg then button.newLevelBg:Hide() end
			end
		end
	end)

	-- [[ WardrobeCollectionFrame ]]

	local WardrobeCollectionFrame = WardrobeCollectionFrame
	local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

	B.StripTextures(ItemsCollectionFrame)
	B.ReskinFilterButton(WardrobeCollectionFrame.FilterButton)
	B.ReskinDropDown(WardrobeCollectionFrameWeaponDropDown)
	B.ReskinInput(WardrobeCollectionFrameSearchBox)

	for index = 1, 2 do
		local tab = _G["WardrobeCollectionFrameTab"..index]
		for i = 1, 6 do
			select(i, tab:GetRegions()):SetAlpha(0)
		end
		tab:SetHighlightTexture("")
		tab.bg = B.CreateBDFrame(tab, .25)
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

	B.ReskinArrow(ItemsCollectionFrame.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ItemsCollectionFrame.PagingFrame.NextPageButton, "right")
	ItemsCollectionFrame.BGCornerTopLeft:SetAlpha(0)
	ItemsCollectionFrame.BGCornerTopRight:SetAlpha(0)

	local progressBar = WardrobeCollectionFrame.progressBar
	progressBar:DisableDrawLayer("BACKGROUND")
	select(2, progressBar:GetRegions()):Hide()
	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(progressBar, .25)

	-- ItemSetsCollection

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame.LeftInset:Hide()
	SetsCollectionFrame.RightInset:Hide()
	B.CreateBDFrame(SetsCollectionFrame.Model, .25)

	local ScrollFrame = SetsCollectionFrame.ScrollFrame
	B.ReskinScroll(ScrollFrame.scrollBar)
	for i = 1, #ScrollFrame.buttons do
		local bu = ScrollFrame.buttons[i]
		bu.Background:Hide()
		bu.HighlightTexture:SetTexture("")
		bu.Icon:SetSize(42, 42)
		B.ReskinIcon(bu.Icon)
		bu.IconCover:SetOutside(bu.Icon)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(r, g, b, .25)
		bu.SelectedTexture:ClearAllPoints()
		bu.SelectedTexture:SetPoint("TOPLEFT", 4, -2)
		bu.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
		B.CreateBDFrame(bu.SelectedTexture, .25)
	end

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.ModelFadeTexture:Hide()
	DetailsFrame.IconRowBackground:Hide()
	B.ReskinFilterButton(DetailsFrame.VariantSetsButton, "Down")

	hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
		local ic = itemFrame.Icon
		if not ic.bg then
			ic.bg = B.ReskinIcon(ic)
		end
		itemFrame.IconBorder:SetTexture("")

		if itemFrame.collected then
			local quality = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID).quality
			local color = DB.QualityColors[quality or 1]
			ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			ic.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	local SetsTransmogFrame = WardrobeCollectionFrame.SetsTransmogFrame
	B.StripTextures(SetsTransmogFrame)
	B.ReskinArrow(SetsTransmogFrame.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(SetsTransmogFrame.PagingFrame.NextPageButton, "right")

	-- [[ Wardrobe ]]

	local WardrobeFrame = WardrobeFrame
	local WardrobeTransmogFrame = WardrobeTransmogFrame

	B.StripTextures(WardrobeTransmogFrame)
	B.ReskinPortraitFrame(WardrobeFrame)
	B.Reskin(WardrobeTransmogFrame.ApplyButton)
	B.StripTextures(WardrobeTransmogFrame.SpecButton)
	B.ReskinArrow(WardrobeTransmogFrame.SpecButton, "down")
	WardrobeTransmogFrame.SpecButton:SetPoint("RIGHT", WardrobeTransmogFrame.ApplyButton, "LEFT", -3, 0)

	local modelScene = WardrobeTransmogFrame.ModelScene
	modelScene.ClearAllPendingButton:DisableDrawLayer("BACKGROUND")

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "Shirt", "Tabard", "MainHand", "SecondaryHand"}
	for i = 1, #slots do
		local slot = modelScene[slots[i].."Button"]
		if slot then
			slot.Border:Hide()
			B.ReskinIcon(slot.Icon)
			slot:SetHighlightTexture(DB.bdTex)
			local hl = slot:GetHighlightTexture()
			hl:SetVertexColor(1, 1, 1, .25)
			hl:SetAllPoints(slot.Icon)
		end
	end

	-- Outfit Frame
	B.Reskin(WardrobeOutfitDropDown.SaveButton)
	B.ReskinDropDown(WardrobeOutfitDropDown)
	WardrobeOutfitDropDown:SetHeight(32)
	WardrobeOutfitDropDown.SaveButton:SetPoint("LEFT", WardrobeOutfitDropDown, "RIGHT", -13, 2)

	-- HPetBattleAny
	local reskinHPet
	CollectionsJournal:HookScript("OnShow", function()
		if not IsAddOnLoaded("HPetBattleAny") then return end
		if not reskinHPet then
			if HPetInitOpenButton then
				B.Reskin(HPetInitOpenButton)
			end
			if HPetAllInfoButton then
				B.StripTextures(HPetAllInfoButton)
				B.Reskin(HPetAllInfoButton)
			end

			if PetJournalBandageButton then
				PetJournalBandageButton:SetPushedTexture("")
				PetJournalBandageButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				PetJournalBandageButtonBorder:Hide()
				PetJournalBandageButton:SetPoint("TOPRIGHT", PetJournalHealPetButton, "TOPLEFT", -3, 0)
				PetJournalBandageButton:SetPoint("BOTTOMLEFT", PetJournalHealPetButton, "BOTTOMLEFT", -35, 0)
				B.ReskinIcon(PetJournalBandageButtonIcon)
			end
			reskinHPet = true
		end
	end)
end