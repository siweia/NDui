local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function skinScrollBox(scrollBox, update)
	hooksecurefunc(scrollBox, "Update", update)
	update(scrollBox)
end

function B:ReskinIconSelector()
	B.StripTextures(self)
	B.SetBD(self):SetInside()
	B.StripTextures(self.BorderBox)
	B.StripTextures(self.BorderBox.IconSelectorEditBox, 2)
	B.ReskinEditBox(self.BorderBox.IconSelectorEditBox)
	B.StripTextures(self.BorderBox.SelectedIconArea.SelectedIconButton)
	B.ReskinIcon(self.BorderBox.SelectedIconArea.SelectedIconButton.Icon)
	B.Reskin(self.BorderBox.OkayButton)
	B.Reskin(self.BorderBox.CancelButton)
	B.ReskinDropDown(self.BorderBox.IconTypeDropdown)
	B.ReskinTrimScroll(self.IconSelector.ScrollBar)

	skinScrollBox(self.IconSelector.ScrollBox, function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Icon and not child.styled then
				child:DisableDrawLayer("BACKGROUND")
				child.SelectedTexture:SetColorTexture(1, .8, 0, .5)
				child.SelectedTexture:SetAllPoints(child.Icon)
				local hl = child:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(child.Icon)
				B.ReskinIcon(child.Icon)

				child.styled = true
			end
		end
	end)
end

function B:ReskinModelControl()
	for _, button in ipairs({self.ControlFrame:GetChildren()}) do
		if button.NormalTexture then
			button.NormalTexture:SetAlpha(0)
			button.PushedTexture:SetAlpha(0)
		end
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(CharacterFrame)

	-- New elements in 1.60.1
	if PaperDollFrame.TopBackgroundStripHost then PaperDollFrame.TopBackgroundStripHost:SetAlpha(0) end
	CharacterFrameLeftPaneHost:SetAlpha(0)
	CharacterFrameRightPaneHost:SetAlpha(0)
	B.StripTextures(PaperDollLevelInfo)
	CharacterModelScene:SetFrameLevel(2)
	for _, pane in ipairs({CharacterStatsPaneScrollBox, CharacterStatsPanePetScrollBox}) do
		B.StripTextures(pane)
		B.ReskinTrimScroll(pane.ScrollBar)
	end

	local toggleButton = CharacterFrame.RightPaneToggleButton
	B.ReskinArrow(toggleButton, "left")
	-- Blizzard replaces these textures directly when the pane changes.
	toggleButton:GetNormalTexture():SetAlpha(0)
	toggleButton:GetPushedTexture():SetAlpha(0)
	local function updatePaneToggle(self)
		B.SetupArrow(toggleButton.__texture, self:IsRightPaneCollapsed() and "right" or "left")
	end
	hooksecurefunc(CharacterFrame, "UpdateRightPaneToggleButton", updatePaneToggle)
	updatePaneToggle(CharacterFrame)

	B.ReskinModelControl(CharacterModelScene)
	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")

	-- Side tabs
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
		tab.SelectedTexture:SetColorTexture(r, g, b, .25)
		tab.SelectedTexture:SetAllPoints(tab.Icon)
		tab.TabGlow:SetColorTexture(r, g, b, .25)
		tab.TabGlow:SetAllPoints(tab.Icon)
		hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
		updateSideTabIcon(tab)
	end

	for _, tab in ipairs(CharacterFrame.ModeTabs.Tabs) do
		reskinSideTab(tab)
	end

	-- [[ Item buttons ]]

	local function colourPopout(self)
		local aR, aG, aB
		local glow = self:GetParent().IconBorder

		if glow:IsShown() then
			aR, aG, aB = glow:GetVertexColor()
		else
			aR, aG, aB = r, g, b
		end

		self.arrow:SetVertexColor(aR, aG, aB)
	end

	local function clearPopout(self)
		self.arrow:SetVertexColor(1, 1, 1)
	end

	local function UpdateAzeriteItem(self)
		if not self.styled then
			self.AzeriteTexture:SetAlpha(0)
			self.RankFrame.Texture:SetTexture("")
			self.RankFrame.Label:ClearAllPoints()
			self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
			self.RankFrame.Label:SetTextColor(1, .5, 0)

			self.styled = true
		end
	end

	local function UpdateAzeriteEmpoweredItem(self)
		self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
		self.AzeriteTexture:SetInside()
		self.AzeriteTexture:SetDrawLayer("BORDER", 1)
	end

	local function UpdateHighlight(self)
		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, .25)
		highlight:SetInside(self.bg)
	end

	local function UpdateCosmetic(self)
		local itemLink = GetInventoryItemLink("player", self:GetID())
		self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged"
	}
	local flyoutDirections = {LEFT = "left", RIGHT = "right", UP = "up", DOWN = "down"}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local cooldown = _G["Character"..slots[i].."SlotCooldown"]

		B.StripTextures(slot)
		slot.icon:SetTexCoord(unpack(DB.TexCoord))
		slot.icon:SetInside()
		slot.bg = B.CreateBDFrame(slot.icon, .25)
		slot.bg:SetFrameLevel(3) -- higher than portrait
		cooldown:SetInside()

		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
		slot.IconOverlay:SetAtlas("CosmeticIconFrame")
		slot.IconOverlay:SetInside()
		B.ReskinIconBorder(slot.IconBorder)

		local popout = slot.popoutButton
		B.StripTextures(popout, 0)

		local arrow = popout:CreateTexture(nil, "OVERLAY")
		arrow:SetSize(14, 14)
		B.SetupArrow(arrow, flyoutDirections[slot.flyoutDirection] or "right")
		arrow:SetPoint("CENTER", popout)
		popout.arrow = arrow

		popout:HookScript("OnEnter", clearPopout)
		popout:HookScript("OnLeave", colourPopout)

		hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
		hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		if not button.bg or not button.popoutButton then return end
		button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
		colourPopout(button.popoutButton)
		UpdateCosmetic(button)
		UpdateHighlight(button)
	end)
	for _, name in ipairs(slots) do
		PaperDollItemSlotButton_Update(_G["Character"..name.."Slot"])
	end

	-- [[ Stats pane ]]

	local function updateCategory(category)
		if category.styled then return end
		if category.Title then
			category.Background:Hide()
			category.Title:SetTextColor(r, g, b)
			local line = category:CreateTexture(nil, "ARTWORK")
			line:SetSize(180, C.mult)
			line:SetPoint("BOTTOM", 0, 5)
			line:SetColorTexture(1, 1, 1, .25)
		end
		if category.Label then
			category.Label:SetFontObject(Game13Font)
		end
		if category.Value then
			category.Value:SetFontObject(Game13Font)
		end
		category.styled = true
	end

	for _, pane in ipairs({CharacterStatsPaneScrollBox, CharacterStatsPanePetScrollBox}) do
		skinScrollBox(pane.ScrollBox, function(self)
			self:ForEachFrame(updateCategory)
		end)
	end

	-- [[ Sidebar tabs ]]

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]
		tab:DisableDrawLayer("BORDER")
		tab.bg = B.CreateBDFrame(tab, 1)
		tab.bg:SetInside(tab, 3, 3)
		tab.Icon:SetInside(tab.bg)
		if i == 1 or i == 4 then -- Player and pet portraits.
			tab.Icon:SetTexCoord(.16, .86, .16, .86)
		end

		local checked = tab:GetCheckedTexture()
		checked:SetColorTexture(r, g, b, .25)
		checked:SetInside(tab.bg)
		checked:SetDrawLayer("OVERLAY")

		tab:SetHighlightTexture(DB.bdTex)
		local highlight = tab:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, .25)
		highlight:SetInside(tab.bg)
	end

	-- [[ Equipment manager ]]
	local equipmentPane = PaperDollFrame.EquipmentManagerPane
	B.StripTextures(equipmentPane)
	B.Reskin(equipmentPane.EquipSet)
	B.Reskin(equipmentPane.SaveSet)
	B.Reskin(equipmentPane.NewSet)
	equipmentPane.NewSet.StateTexture:SetAlpha(0)
	B.ReskinTrimScroll(equipmentPane.ScrollBar)

	skinScrollBox(equipmentPane.ScrollBox, function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.icon and not child.styled then
				child.icon.isIgnored = true
				child.SpecIcon.isIgnored = true
				child.SpecRing.isIgnored = true
				B.StripTextures(child)
				B.ReskinIcon(child.icon)

				child.HighlightBar:SetColorTexture(1, 1, 1, .25)
				child.HighlightBar:SetDrawLayer("BACKGROUND")
				child.HighlightBar:SetInside(nil, 2, 2)
				child.SelectedBar:SetColorTexture(r, g, b, .25)
				child.SelectedBar:SetDrawLayer("BACKGROUND")
				child.SelectedBar:SetInside(nil, 2, 2)
				child.Check:SetAtlas("checkmark-minimal")

				child.styled = true
			end
		end
	end)

	B.ReskinIconSelector(GearManagerPopupFrame)

	-- TitlePane
	B.StripTextures(PaperDollFrame.TitleManagerPane)
	B.ReskinTrimScroll(PaperDollFrame.TitleManagerPane.ScrollBar)

	skinScrollBox(PaperDollFrame.TitleManagerPane.ScrollBox, function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child:DisableDrawLayer("BACKGROUND")
				child.Check:SetAtlas("checkmark-minimal")
				child.SelectedBar:SetColorTexture(r, g, b, .25)
				child.SelectedBar:SetAllPoints()
				child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

				child.styled = true
			end
		end
	end)

	local function reskinProgressBar(bar)
		if bar.styled then return end
		bar:DisableDrawLayer("BACKGROUND")
		bar.Fill:RemoveMaskTexture(bar.Mask)
		local bg = B.CreateBDFrame(bar, .25)
		bg:ClearAllPoints()
		bg:SetPoint("LEFT", bar.FillArea, -C.mult, 0)
		bg:SetPoint("RIGHT", bar.FillArea, C.mult, 0)
		bg:SetHeight(bar.Fill:GetHeight() + 2*C.mult)

		bar.styled = true
	end

	local function updateToggleCollapse(button)
		local header = button:GetHeader()
		button:SetNormalTexture(0)
		button.__texture:DoCollapse((header.treeNode or header):IsCollapsed())
	end

	local function reskinCategory(child)
		if child.StateIcon then
			child:DisableDrawLayer("BACKGROUND")
			B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
		end
		local button = child.ToggleCollapseButton
		if button then
			button:GetNormalTexture():SetAlpha(0)
			button:GetPushedTexture():SetAlpha(0)
			B.ReskinCollapse(button, true)
			button.bg:ClearAllPoints()
			button.bg:SetPoint("CENTER", button)
			updateToggleCollapse(button)
			hooksecurefunc(button, "RefreshIcon", updateToggleCollapse)
		end
	end

	local function updateDetailRows(pane)
		for i = 1, pane.Content:GetNumChildren() do
			local row = select(i, pane.Content:GetChildren())
			if row.Label and not row.styled then
				if row.Background then
					row.Background:SetAlpha(0)
					row.Label:SetTextColor(r, g, b)
				end
				if row.Icon then
					row.IconSlot:SetAlpha(0)
					B.ReskinIcon(row.Icon)
				end
				row.Label:SetFontObject(Game13Font)
				if row.Value then row.Value:SetFontObject(Game13Font) end
				row.styled = true
			end
		end
	end

	for _, pane in ipairs(CharacterFrame.SidePanes) do
		pane.Divider:SetColorTexture(1, 1, 1, .25)
		pane.Divider:SetHeight(C.mult)
		B.ReskinTrimScroll(pane.DescriptionScrollBar)
		hooksecurefunc(pane, "AcquireRow", updateDetailRows)
		updateDetailRows(pane)
	end
	reskinProgressBar(PetPaperDollFrameExpBar)

	-- Reputation Frame
	local function updateReputationBars(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				reskinCategory(child)
				local bar = child.Content and child.Content.ReputationBar
				if bar then reskinProgressBar(bar) end
				child.styled = true
			end
		end
	end
	skinScrollBox(ReputationFrame.ScrollBox, updateReputationBars)

	B.ReskinTrimScroll(ReputationFrame.ScrollBar)
	B.ReskinDropDown(ReputationFrame.filterDropdown)

	local detailFrame = ReputationFrame.ReputationDetailFrame
	B.StripTextures(detailFrame)
	if detailFrame.StandingBar then reskinProgressBar(detailFrame.StandingBar) end
	B.ReskinCheck(detailFrame.AtWarCheckbox)
	B.ReskinCheck(detailFrame.MakeInactiveCheckbox)
	B.ReskinCheck(detailFrame.WatchFactionCheckbox)
	B.Reskin(detailFrame.ViewRenownButton)

	-- Token frame
	B.ReskinTrimScroll(TokenFrame.ScrollBar, true) -- taint if touching thumb, needs review

	B.ReskinPortraitFrame(CurrencyTransferLog)
	B.ReskinTrimScroll(CurrencyTransferLog.ScrollBar)

	local function handleCurrencyIcon(button)
		local icon = button.CurrencyIcon
		if icon and not icon.styled then
			B.ReskinIcon(icon)
			icon.styled = true
		end
	end
	skinScrollBox(CurrencyTransferLog.ScrollBox, function(self)
		self:ForEachFrame(handleCurrencyIcon)
	end)

	B.ReskinPortraitFrame(CurrencyTransferMenu)

	local transferMenu = CurrencyTransferMenu.Content
	if transferMenu then
		B.CreateBDFrame(transferMenu.SourceSelector, .25)
		transferMenu.SourceSelector.SourceLabel:SetWidth(56)
		B.ReskinDropDown(transferMenu.SourceSelector.Dropdown)
		B.ReskinIcon(transferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
		B.ReskinIcon(transferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
		B.Reskin(transferMenu.ConfirmButton)
		B.Reskin(transferMenu.CancelButton)

		local amountSelector = transferMenu.AmountSelector
		if amountSelector then
			B.CreateBDFrame(amountSelector, .25)
			B.Reskin(amountSelector.MaxQuantityButton)
			B.ReskinEditBox(amountSelector.InputBox)
			amountSelector.InputBox.__bg:SetInside(nil, 3, 3)
		end
	end

	skinScrollBox(TokenFrame.ScrollBox, function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				reskinCategory(child)
				local icon = child.Content and child.Content.CurrencyIcon
				if icon then
					B.ReskinIcon(icon)
				end

				child.styled = true
			end
		end
	end)
	B.ReskinCheck(TokenDetailFrame.InactiveCheckbox)
	B.ReskinCheck(TokenDetailFrame.BackpackCheckbox)

	-- Quick Join
	B.ReskinTrimScroll(QuickJoinFrame.ScrollBar)
	B.Reskin(QuickJoinFrame.JoinQueueButton)

	B.SetBD(QuickJoinRoleSelectionFrame)
	B.Reskin(QuickJoinRoleSelectionFrame.AcceptButton)
	B.Reskin(QuickJoinRoleSelectionFrame.CancelButton)
	B.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
	B.StripTextures(QuickJoinRoleSelectionFrame)

	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, "TANK")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, "HEALER")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, "DPS")

	-- Skills
	local function updateSkills(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				reskinCategory(child)
				local repbar = child.Content and child.Content.SkillsBar
				if repbar then
					reskinProgressBar(repbar)
				end

				child.styled = true
			end
		end
	end
	skinScrollBox(SkillsFrame.ScrollBox, updateSkills)
	reskinProgressBar(SkillsFrame.SkillDetailFrame.RankBar)
	B.ReskinTrimScroll(SkillsFrame.ScrollBar)

	-- StatisticsFrame
	local function updateFrame(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				reskinCategory(child)

				child.styled = true
			end
		end
	end
	skinScrollBox(StatisticsFrame.ScrollBox, updateFrame)
	B.ReskinTrimScroll(StatisticsFrame.ScrollBar)
end)
