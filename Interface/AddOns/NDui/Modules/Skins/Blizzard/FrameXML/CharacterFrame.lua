local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(CharacterFrame)
	B.StripTextures(CharacterFrameInsetRight)

	for i = 1, 3 do
		B.ReskinTab(_G["CharacterFrameTab"..i])
	end

	CharacterModelFrame:DisableDrawLayer("BACKGROUND")
	CharacterModelFrame:DisableDrawLayer("BORDER")
	CharacterModelFrame:DisableDrawLayer("OVERLAY")

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
		highlight:SetInside()
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
		cooldown:SetInside()

		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
		slot.CorruptedHighlightTexture:SetAtlas("Nzoth-charactersheet-item-glow")
		slot.IconOverlay:SetInside()
		B.ReskinIconBorder(slot.IconBorder)

		local popout = slot.popoutButton
		popout:SetNormalTexture("")
		popout:SetHighlightTexture("")

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

	B.StripTextures(GearManagerDialogPopup.BorderBox)
	GearManagerDialogPopup.BG:Hide()
	B.SetBD(GearManagerDialogPopup)
	GearManagerDialogPopup:SetHeight(525)
	B.StripTextures(GearManagerDialogPopupScrollFrame)
	B.ReskinScroll(GearManagerDialogPopupScrollFrameScrollBar)
	B.Reskin(GearManagerDialogPopupOkay)
	B.Reskin(GearManagerDialogPopupCancel)
	B.ReskinInput(GearManagerDialogPopupEditBox)
	B.ReskinScroll(PaperDollTitlesPaneScrollBar)
	B.ReskinScroll(PaperDollEquipmentManagerPaneScrollBar)
	B.StripTextures(PaperDollSidebarTabs)
	B.Reskin(PaperDollEquipmentManagerPaneEquipSet)
	B.Reskin(PaperDollEquipmentManagerPaneSaveSet)

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local bu = _G["GearManagerDialogPopupButton"..i]
		local ic = _G["GearManagerDialogPopupButton"..i.."Icon"]

		bu:SetCheckedTexture(DB.textures.pushed)
		select(2, bu:GetRegions()):Hide()
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		ic:SetInside()
		B.ReskinIcon(ic)
	end

	for _, bu in pairs(PaperDollEquipmentManagerPane.buttons) do
		B.HideObject(bu.Stripe)
		bu.BgTop:SetTexture("")
		bu.BgMiddle:SetTexture("")
		bu.BgBottom:SetTexture("")
		B.ReskinIcon(bu.icon)

		bu.HighlightBar:SetColorTexture(1, 1, 1, .25)
		bu.HighlightBar:SetDrawLayer("BACKGROUND")
		bu.SelectedBar:SetColorTexture(r, g, b, .25)
		bu.SelectedBar:SetDrawLayer("BACKGROUND")
	end

	local titles = false
	hooksecurefunc("PaperDollTitlesPane_Update", function()
		if titles == false then
			for i = 1, 17 do
				_G["PaperDollTitlesPaneButton"..i]:DisableDrawLayer("BACKGROUND")
			end
			titles = true
		end
	end)

	PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
	PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
	GearManagerDialogPopup:HookScript("OnShow", function(self)
		self:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", 3, 0)
	end)

	-- Reputation Frame
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 3, -28)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]
			if statusbar then
				statusbar:SetStatusBarTexture(DB.bdTex)

				if not statusbar.reskinned then
					B.CreateBDFrame(statusbar, .25)
					statusbar.reskinned = true
				end

				_G["ReputationBar"..i.."Background"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
			end
		end
	end
	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local bu = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
		B.ReskinCollapse(bu)
	end

	B.StripTextures(ReputationDetailFrame)
	B.SetBD(ReputationDetailFrame)
	B.ReskinClose(ReputationDetailCloseButton)
	B.ReskinCheck(ReputationDetailAtWarCheckBox)
	B.ReskinCheck(ReputationDetailInactiveCheckBox)
	B.ReskinCheck(ReputationDetailMainScreenCheckBox)
	B.ReskinScroll(ReputationListScrollFrameScrollBar)

	-- Token frame
	TokenFramePopupCorner:Hide()
	TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 3, -28)
	B.StripTextures(TokenFramePopup)
	B.SetBD(TokenFramePopup)
	B.ReskinClose(TokenFramePopupCloseButton)
	B.ReskinCheck(TokenFramePopupInactiveCheckBox)
	B.ReskinCheck(TokenFramePopupBackpackCheckBox)
	B.ReskinScroll(TokenFrameContainerScrollBar)

	local function updateButtons()
		local buttons = TokenFrameContainer.buttons
		if not buttons then return end

		for i = 1, #buttons do
			local bu = buttons[i]

			if not bu.styled then
				bu.highlight:SetPoint("TOPLEFT", 1, 0)
				bu.highlight:SetPoint("BOTTOMRIGHT", -1, 0)
				bu.highlight.SetPoint = B.Dummy
				bu.highlight:SetColorTexture(r, g, b, .2)
				bu.highlight.SetTexture = B.Dummy

				bu.categoryMiddle:SetAlpha(0)
				bu.categoryLeft:SetAlpha(0)
				bu.categoryRight:SetAlpha(0)

				bu.bg = B.ReskinIcon(bu.icon)

				if bu.expandIcon then
					bu.expBg = B.CreateBDFrame(bu.expandIcon, 0, true)
					bu.expBg:SetPoint("TOPLEFT", bu.expandIcon, -3, 3)
					bu.expBg:SetPoint("BOTTOMRIGHT", bu.expandIcon, 3, -3)
				end

				bu.styled = true
			end

			if bu.isHeader then
				bu.bg:Hide()
				bu.expBg:Show()
			else
				bu.bg:Show()
				bu.expBg:Hide()
			end
		end
	end

	TokenFrame:HookScript("OnShow", updateButtons)
	hooksecurefunc("TokenFrame_Update", updateButtons)
	hooksecurefunc(TokenFrameContainer, "update", updateButtons)

	-- Quick Join
	B.ReskinScroll(QuickJoinScrollFrame.scrollBar)
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