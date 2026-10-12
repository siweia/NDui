local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

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

	hooksecurefunc(self.IconSelector.ScrollBox, "Update", function(self)
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
	for i = 1, 5 do
		local button = select(i, self.ControlFrame:GetChildren())
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
	PaperDollFrame.TopBackgroundStripHost:SetAlpha(0)
	CharacterFrameLeftPaneHost:SetAlpha(0)
	CharacterFrameRightPaneHost:SetAlpha(0)
	CharacterModelScene:SetFrameLevel(2)
	B.StripTextures(CharacterStatsPaneScrollBox)
	B.ReskinTrimScroll(CharacterStatsPaneScrollBox.ScrollBar)

	B.ReskinCollapse(CharacterFrameRightPaneToggleButton, "left")
	CharacterFrameRightPaneToggleButton:GetRegions():SetAlpha(0)
	CharacterFrameRightPaneToggleButton:GetPushedTexture():SetAlpha(0)

	hooksecurefunc(CharacterFrame, "UpdateRightPaneToggleButton", function(self)
		if self:IsRightPaneCollapsed() then
			CharacterFrameRightPaneToggleButton.__texture:DoCollapse(true)
		else
			CharacterFrameRightPaneToggleButton.__texture:DoCollapse(false)
		end
	end)

	for i = 1, 3 do
		local tab = _G["CharacterFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["CharacterFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end

	B.ReskinModelControl(CharacterModelScene)
	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")

	-- Side tabs
	local function resetTexCoords(self, x1, x2, y1, y2)
		if x1 ~= .08 or x2 ~= .92 or y1 ~= .08 or y2 ~= .92 then
			self:SetTexCoord(.08, .92, .08, .92)
		end
	end

	local function reskinSideTab(tab)
		if not tab then return end

		tab:DisableDrawLayer("BACKGROUND")
		tab.Mask:Hide()
		tab.bg = B.SetBD(tab, 1)
		tab.bg:SetInside(nil, 3, 3)
		local hl = tab.HighlightTexture
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(tab.bg)
		tab.Icon:SetTexCoord(.08, .92, .08, .92)
		hooksecurefunc(tab.Icon, "SetTexCoord", resetTexCoords)
		tab.Icon:SetInside(tab.bg)
		tab.SelectedTexture:SetColorTexture(1, .8, 0, .25)
		tab.SelectedTexture:SetInside(tab.bg)
	end

	for i = 1, 10 do
		local tab = _G["CharacterFrameModeTab"..i]
		if not tab then break end
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
		popout:SetNormalTexture(0)
		popout:SetHighlightTexture(0)

		local arrow = popout:CreateTexture(nil, "OVERLAY")
		arrow:SetSize(14, 14)
		if slot.verticalFlyout then
			B.SetupArrow(arrow, "down")
			arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
		else
			B.SetupArrow(arrow, "right")
			arrow:SetPoint("LEFT", slot, "RIGHT", -1, 0)
		end
		popout.arrow = arrow

		popout:HookScript("OnEnter", clearPopout)
		popout:HookScript("OnLeave", colourPopout)

		hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
		hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		-- also fires for bag slots, we don't want that
		if button.popoutButton then
			button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
			colourPopout(button.popoutButton)
		end
		UpdateCosmetic(button)
		UpdateHighlight(button)
	end)

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

	hooksecurefunc(CharacterStatsPaneScrollBox.ScrollBox, "Update", function(self)
		self:ForEachFrame(updateCategory)
	end)

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
	B.Reskin(PaperDollFrameEquipSet)
	B.Reskin(PaperDollFrameSaveSet)
	B.ReskinTrimScroll(PaperDollFrame.EquipmentManagerPane.ScrollBar)

	hooksecurefunc(PaperDollFrame.EquipmentManagerPane.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.icon and not child.styled then
				B.HideObject(child.Stripe)
				child.BgTop:SetTexture("")
				child.BgMiddle:SetTexture("")
				child.BgBottom:SetTexture("")
				B.ReskinIcon(child.icon)

				child.HighlightBar:SetColorTexture(1, 1, 1, .25)
				child.HighlightBar:SetDrawLayer("BACKGROUND")
				child.SelectedBar:SetColorTexture(r, g, b, .25)
				child.SelectedBar:SetDrawLayer("BACKGROUND")
				child.Check:SetAtlas("checkmark-minimal")

				child.styled = true
			end
		end
	end)

	B.ReskinIconSelector(GearManagerPopupFrame)

	-- TitlePane
	B.ReskinTrimScroll(PaperDollFrame.TitleManagerPane.ScrollBar)

	hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child:DisableDrawLayer("BACKGROUND")
				child.Check:SetAtlas("checkmark-minimal")

				child.styled = true
			end
		end
	end)

	-- Reputation Frame
	local oldAtlas = {
		["Options_ListExpand_Right"] = 1,
		["Options_ListExpand_Right_Expanded"] = 1,
	}
	local function updateCollapse(texture, atlas)
		if (not atlas) or oldAtlas[atlas] then
			if not texture.__owner then
				texture.__owner = texture:GetParent()
			end
			if texture.__owner:IsCollapsed() then
				texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
			else
				texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
			end
		end
	end

	local function updateToggleCollapse(button)
		button:SetNormalTexture(0)
		button.__texture:DoCollapse(button:GetHeader():IsCollapsed())
	end

	local function reskinReputationBar(bar)
		bar:DisableDrawLayer("BACKGROUND")
		if bar.Mask then bar.Fill:RemoveMaskTexture(bar.Mask) end
		bar.Fill:SetTexture(DB.bdTex)

		-- Keep Fill's left anchor and width under SetFillPercent's control.
		local bg = B.CreateBDFrame(bar, .25)
		bg:ClearAllPoints()
		bg:SetPoint("LEFT", bar, -C.mult, 0)
		bg:SetPoint("RIGHT", bar, C.mult, 0)
		bg:SetHeight(bar.Fill:GetHeight() + 2*C.mult)
	end

	local function updateReputationBars(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.StateIcon then
					child:DisableDrawLayer("BACKGROUND")
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local repbar = child.Content and child.Content.ReputationBar
				if repbar then
					reskinReputationBar(repbar)
				end

				child.styled = true
			end
		end
	end
	hooksecurefunc(ReputationFrame.ScrollBox, "Update", updateReputationBars)

	B.ReskinTrimScroll(ReputationFrame.ScrollBar)
	B.ReskinDropDown(ReputationFrame.filterDropdown)

	local detailFrame = ReputationFrame.ReputationDetailFrame
	B.StripTextures(detailFrame)
	if detailFrame.StandingBar then reskinReputationBar(detailFrame.StandingBar) end
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
		if icon then
			B.ReskinIcon(icon)
		end
	end
	hooksecurefunc(CurrencyTransferLog.ScrollBox, "Update", function(self)
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

	hooksecurefunc(TokenFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.StateIcon then
					child:DisableDrawLayer("BACKGROUND")
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
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
				if child.StateIcon then
					child:DisableDrawLayer("BACKGROUND")
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local repbar = child.Content and child.Content.SkillsBar
				if repbar then
					reskinReputationBar(repbar)
				end

				child.styled = true
			end
		end
	end
	hooksecurefunc(SkillsFrame.ScrollBox, "Update", updateSkills)
	reskinReputationBar(SkillsFrame.SkillDetailFrame.RankBar)
	B.ReskinTrimScroll(SkillsFrame.ScrollBar)

	-- StatisticsFrame
	local function updateFrame(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.StateIcon then
					child:DisableDrawLayer("BACKGROUND")
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				if child.ToggleCollapseButton then
					child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
					B.ReskinCollapse(child.ToggleCollapseButton, true)
					updateToggleCollapse(child.ToggleCollapseButton)
					hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
				end

				child.styled = true
			end
		end
	end
	hooksecurefunc(StatisticsFrame.ScrollBox, "Update", updateFrame)
	B.ReskinTrimScroll(StatisticsFrame.ScrollBar)
end)
