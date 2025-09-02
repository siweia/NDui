local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function reskinFrameButton(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		if not child.styled then
			child:GetRegions():Hide()
			child:SetHighlightTexture(0)
			child.iconBorder:SetTexture("")
			child.selectedTexture:SetTexture("")

			local bg = B.CreateBDFrame(child, .25)
			bg:SetPoint("TOPLEFT", 3, -1)
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			child.bg = bg

			local icon = child.icon
			icon:SetSize(42, 42)
			icon.bg = B.ReskinIcon(icon)
			child.name:SetParent(bg)

			if child.DragButton then
				child.DragButton.ActiveTexture:SetTexture("")
				child.DragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				child.DragButton:GetHighlightTexture():SetAllPoints(icon)
			else
				child.dragButton.ActiveTexture:SetTexture("")
				child.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				child.dragButton:GetHighlightTexture():SetAllPoints(icon)
			end

			child.styled = true
		end
	end
end

C.themes["Blizzard_Collections"] = function()
	-- [[ General ]]

	CollectionsJournal.bg = B.ReskinPortraitFrame(CollectionsJournal) -- need this for Rematch skin
	for i = 1, 5 do
		local tab = _G["CollectionsJournalTab"..i]
		if tab then
			B.ReskinTab(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["CollectionsJournalTab"..(i-1)], "TOPRIGHT", -15, 0)
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
	PetJournal.RightInset:Hide()

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

	B.ReskinTrimScroll(MountJournal.ScrollBar)
	hooksecurefunc(MountJournal.ScrollBox, "Update", reskinFrameButton)
	hooksecurefunc("MountJournal_InitMountButton", function(button)
		if not button.bg then return end

		button.icon:SetShown(button.index ~= nil)

		if button.selectedTexture:IsShown() then
			button.bg:SetBackdropColor(cr, cg, cb, .25)
		else
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end

		if button.DragButton.ActiveTexture:IsShown() then
			button.icon.bg:SetBackdropBorderColor(1, .8, 0)
		else
			button.icon.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	B.ReskinTrimScroll(PetJournal.ScrollBar)
	hooksecurefunc(PetJournal.ScrollBox, "Update", reskinFrameButton)
	hooksecurefunc("PetJournal_InitPetButton", function(button)
		if not button.bg then return end
		local index = button.index
		if not index then return end

		if not button.bg then return end
		local index = button.index
		if not index then return end

		local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)
		if petID and isOwned then
			local rarity = select(5, C_PetJournal.GetPetStats(petID))
			if rarity then
				local r, g, b = C_Item.GetItemQualityColor(rarity-1)
				button.name:SetTextColor(r, g, b)
			else
				button.name:SetTextColor(1, 1, 1)
			end
		else
			button.name:SetTextColor(.5, .5, .5)
		end

		if button.selectedTexture:IsShown() then
			button.bg:SetBackdropColor(cr, cg, cb, .25)
		else
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end

		if button.dragButton.ActiveTexture:IsShown() then
			button.icon.bg:SetBackdropBorderColor(1, .8, 0)
		else
			button.icon.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	B.ReskinInput(MountJournalSearchBox)
	B.ReskinInput(PetJournalSearchBox)
	B.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateLeftButton, "left")
	B.ReskinArrow(MountJournal.MountDisplay.ModelScene.RotateRightButton, "right")
	B.ReskinFilterButton(PetJournal.FilterDropdown)
	B.ReskinFilterButton(MountJournal.FilterDropdown)

	local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
	if togglePlayer then
		B.ReskinCheck(togglePlayer)
		togglePlayer:SetSize(28, 28)
	end

	local function reskinToolButton(button)
		button.Border:Hide()
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		B.ReskinIcon(button.Icon)
	end

	-- Pet card
	reskinToolButton(PetJournal.HealPetSpellFrame.Button)
	reskinToolButton(PetJournal.SummonRandomPetSpellFrame.Button)

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

	-- [[ Toy box ]]

	local ToyBox = ToyBox
	local iconsFrame = ToyBox.iconsFrame

	B.StripTextures(iconsFrame)
	B.ReskinInput(ToyBox.searchBox)
	B.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")
	B.ReskinFilterButton(ToyBox.FilterDropdown)

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
			local quality = select(3, C_Item.GetItemInfo(itemID))
			if quality then
				local r, g, b = GetItemQualityColor(quality)
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

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
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
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			button:GetHighlightTexture():SetAllPoints(ic)

			button.iconTextureUncollected:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.ReskinIcon(ic)

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
				B.SetFontSize(header.text, 16)

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
	if not WardrobeCollectionFrame then return end
	local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

	B.StripTextures(ItemsCollectionFrame)
	B.ReskinFilterButton(WardrobeCollectionFrame.FilterButton)
	B.ReskinDropDown(ItemsCollectionFrame.WeaponDropdown)
	B.ReskinInput(WardrobeCollectionFrameSearchBox)
	B.ReskinTab(WardrobeCollectionFrameTab1)

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

	B.ReskinTab(WardrobeCollectionFrameTab2)

	-- ItemSetsCollection

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame.LeftInset:Hide()
	SetsCollectionFrame.RightInset:Hide()
	B.CreateBDFrame(SetsCollectionFrame.Model, .25)

	B.ReskinTrimScroll(SetsCollectionFrame.ListContainer.ScrollBar)
	hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child.Background:Hide()
				child.HighlightTexture:SetTexture("")

				local icon = child.IconFrame and child.IconFrame.Icon or child.Icon
				if icon then
					icon:SetSize(42, 42)
					B.ReskinIcon(icon)
					if child.IconCover then
						child.IconCover:SetOutside(icon)
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
	end)

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

	B.ReskinPortraitFrame(WardrobeFrame)
	B.StripTextures(WardrobeTransmogFrame)
	B.Reskin(WardrobeTransmogFrame.ApplyButton)
	B.ReskinCheck(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "Shirt", "Tabard", "MainHand", "SecondaryHand", "Ranged"}
	for i = 1, #slots do
		local slot = WardrobeTransmogFrame[slots[i].."Button"]
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
	B.ReskinDropDown(WardrobeTransmogFrame.OutfitDropdown)
	B.Reskin(WardrobeTransmogFrame.OutfitDropdown.SaveButton)
end