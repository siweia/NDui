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

		local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)
		if petID and isOwned then
			button.name:SetTextColor(1, 1, 1)
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
	if DB.isNewPatch then
		B.ReskinFilterButton(PetJournal.FilterDropdown)
		B.ReskinFilterButton(MountJournal.FilterDropdown)
	else
		B.ReskinFilterButton(PetJournalFilterButton)
		B.ReskinFilterButton(MountJournalFilterButton)

		MountJournalFilterButton:SetPoint("TOPRIGHT", MountJournal.LeftInset, -5, -8)
		PetJournalFilterButton:SetPoint("TOPRIGHT", PetJournalLeftInset, -5, -8)
	end

	local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
	if togglePlayer then
		B.ReskinCheck(togglePlayer)
		togglePlayer:SetSize(28, 28)
	end

	-- Pet card

	local card = PetJournalPetCard
	B.CreateBDFrame(card, .25)
	card.PetBackground:Hide()
	card.ShadowOverlay:Hide()
	B.ReskinArrow(card.modelScene.RotateLeftButton, "left")
	B.ReskinArrow(card.modelScene.RotateRightButton, "right")

	local petIcon = card.PetInfo.icon
	petIcon.bg = B.ReskinIcon(petIcon)

	-- [[ Toy box ]]

	local ToyBox = ToyBox
	local iconsFrame = ToyBox.iconsFrame

	B.StripTextures(iconsFrame)
	B.ReskinInput(ToyBox.searchBox)
	B.ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
	B.ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")
	if DB.isNewPatch then
		B.ReskinFilterButton(ToyBox.FilterDropdown)
	else
		B.ReskinFilterButton(ToyBoxFilterButton)
	end

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
	if DB.isNewPatch then
		B.ReskinDropDown(HeirloomsJournal.ClassDropdown)
		B.ReskinFilterButton(HeirloomsJournal.FilterDropdown)
	else
		B.ReskinDropDown(HeirloomsJournalClassDropDown)
		B.ReskinFilterButton(HeirloomsJournal.FilterButton)
	end
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
	if DB.isNewPatch then
		B.ReskinDropDown(ItemsCollectionFrame.WeaponDropdown)
	else
		B.ReskinDropDown(WardrobeCollectionFrameWeaponDropDown)
	end
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

	if DB.isNewPatch then
		-- Outfit Frame
		B.ReskinDropDown(WardrobeTransmogFrame.OutfitDropdown)
		B.Reskin(WardrobeTransmogFrame.OutfitDropdown.SaveButton)
	end
end