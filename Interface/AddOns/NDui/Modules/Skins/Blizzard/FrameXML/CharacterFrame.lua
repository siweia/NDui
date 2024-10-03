local _, ns = ...
local B, C, L, DB = unpack(ns)

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

local function NoTaintArrow(self, direction) -- needs review
	B.StripTextures(self)

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	B.SetupArrow(tex, direction)
	self.__texture = tex

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(CharacterFrame)
	B.StripTextures(CharacterFrameInsetRight)

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
		"SecondaryHand", "Tabard",
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

	local pane = CharacterStatsPane
	pane.ClassBackground:Hide()
	pane.ItemLevelFrame.Corruption:SetPoint("RIGHT", 22, -8)

	local categories = {pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory}
	for _, category in pairs(categories) do
		category.Background:Hide()
		category.Title:SetTextColor(r, g, b)
		local line = category:CreateTexture(nil, "ARTWORK")
		line:SetSize(180, C.mult)
		line:SetPoint("BOTTOM", 0, 5)
		line:SetColorTexture(1, 1, 1, .25)
	end

	-- [[ Sidebar tabs ]]
	if PaperDollSidebarTabs.DecorRight then
		PaperDollSidebarTabs.DecorRight:Hide()
	end

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]

		if i == 1 then
			for i = 1, 4 do
				local region = select(i, tab:GetRegions())
				region:SetTexCoord(.16, .86, .16, .86)
				region.SetTexCoord = B.Dummy
			end
		end

		tab.bg = B.CreateBDFrame(tab)
		tab.bg:SetPoint("TOPLEFT", 2, -3)
		tab.bg:SetPoint("BOTTOMRIGHT", 0, -2)

		tab.Icon:SetInside(tab.bg)
		tab.Hider:SetInside(tab.bg)
		tab.Highlight:SetInside(tab.bg)
		tab.Highlight:SetColorTexture(1, 1, 1, .25)
		tab.Hider:SetColorTexture(.3, .3, .3, .4)
		tab.TabBg:SetAlpha(0)
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

	local function updateReputationBars(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.Right then
					B.StripTextures(child)
					hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
					hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
					updateCollapse(child.Right)
					updateCollapse(child.HighlightRight)
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local repbar = child.Content and child.Content.ReputationBar
				if repbar then
					B.StripTextures(repbar)
					repbar:SetStatusBarTexture(DB.bdTex)
					B.CreateBDFrame(repbar, .25)
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
	hooksecurefunc(ReputationFrame.ScrollBox, "Update", updateReputationBars)

	B.ReskinTrimScroll(ReputationFrame.ScrollBar)
	B.ReskinDropDown(ReputationFrame.filterDropdown)

	local detailFrame = ReputationFrame.ReputationDetailFrame
	B.StripTextures(detailFrame)
	B.SetBD(detailFrame)
	B.ReskinClose(detailFrame.CloseButton)
	B.ReskinCheck(detailFrame.AtWarCheckbox)
	B.ReskinCheck(detailFrame.MakeInactiveCheckbox)
	B.ReskinCheck(detailFrame.WatchFactionCheckbox)
	B.Reskin(detailFrame.ViewRenownButton)

	-- Token frame
	B.ReskinTrimScroll(TokenFrame.ScrollBar, true) -- taint if touching thumb, needs review
	if DB.isNewPatch then
		B.ReskinDropDown(TokenFrame.filterDropdown)
	end
	if TokenFramePopup.CloseButton then -- blizz typo by parentKey "CloseButton" into "$parent.CloseButton"
		B.ReskinClose(TokenFramePopup.CloseButton)
	else
		B.ReskinClose((select(5, TokenFramePopup:GetChildren())))
	end

	B.Reskin(TokenFramePopup.CurrencyTransferToggleButton)
	B.ReskinCheck(TokenFramePopup.InactiveCheckbox)
	B.ReskinCheck(TokenFramePopup.BackpackCheckbox)

	NoTaintArrow(TokenFrame.CurrencyTransferLogToggleButton, "right") -- taint control, needs review
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
	B.CreateBDFrame(CurrencyTransferMenu.SourceSelector, .25)
	CurrencyTransferMenu.SourceSelector.SourceLabel:SetWidth(56)
	B.ReskinDropDown(CurrencyTransferMenu.SourceSelector.Dropdown)
	B.ReskinIcon(CurrencyTransferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
	B.ReskinIcon(CurrencyTransferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
	B.Reskin(CurrencyTransferMenu.ConfirmButton)
	B.Reskin(CurrencyTransferMenu.CancelButton)

	local amountSelector = CurrencyTransferMenu.AmountSelector
	if amountSelector then
		B.CreateBDFrame(amountSelector, .25)
		if DB.isNewPatch then
			B.Reskin(amountSelector.MaxQuantityButton)
		end
		B.ReskinEditBox(amountSelector.InputBox)
		amountSelector.InputBox.__bg:SetInside(nil, 3, 3)
	end

	hooksecurefunc(TokenFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				if child.Right then
					B.StripTextures(child)
					hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
					hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
					updateCollapse(child.Right)
					updateCollapse(child.HighlightRight)
					B.CreateBDFrame(child, .25):SetInside(nil, 2, 2)
				end
				local icon = child.Content and child.Content.CurrencyIcon
				if icon then
					B.ReskinIcon(icon)
				end
				if child.ToggleCollapseButton then
					B.ReskinCollapse(child.ToggleCollapseButton, true)
					updateToggleCollapse(child.ToggleCollapseButton)
					hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
				end

				child.styled = true
			end
		end
	end)

	B.StripTextures(TokenFramePopup)
	B.SetBD(TokenFramePopup)

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
end)