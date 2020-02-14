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
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:GetHighlightTexture():SetAllPoints()
	end

	local function UpdateAzeriteEmpoweredItem(self)
		self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
		self.AzeriteTexture:SetInside()
		self.AzeriteTexture:SetDrawLayer("BORDER", 1)
	end

	local function UpdateCorruption(self)
		local itemLink = GetInventoryItemLink("player", self:GetID())
		self.IconOverlay:SetShown(itemLink and IsCorruptedItem(itemLink))
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local cooldown = _G["Character"..slots[i].."SlotCooldown"]
		local border = slot.IconBorder

		B.StripTextures(slot)
		slot.icon:SetTexCoord(unpack(DB.TexCoord))
		slot.icon:SetInside()
		B.CreateBD(slot, .25)
		cooldown:SetInside()

		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = B.Dummy
		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
		slot.CorruptedHighlightTexture:SetAtlas("Nzoth-charactersheet-item-glow")

		slot.IconOverlay:SetAtlas("Nzoth-inventory-icon")
		slot.IconOverlay:SetInside()
		slot:HookScript("OnShow", UpdateCorruption)
		slot:HookScript("OnEvent", UpdateCorruption)

		border:SetAlpha(0)
		hooksecurefunc(border, "SetVertexColor", function(_, r, g, b) slot:SetBackdropBorderColor(r, g, b) end)
		hooksecurefunc(border, "Hide", function() slot:SetBackdropBorderColor(0, 0, 0) end)

		local popout = slot.popoutButton
		popout:SetNormalTexture("")
		popout:SetHighlightTexture("")

		local arrow = popout:CreateTexture(nil, "OVERLAY")
		if slot.verticalFlyout then
			arrow:SetSize(13, 8)
			arrow:SetTexture(DB.arrowDown)
			arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
		else
			arrow:SetSize(8, 14)
			arrow:SetTexture(DB.arrowRight)
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
				region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
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
		hl:SetAllPoints(ic)

		ic:SetInside()
		ic:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBD(bu, .25)
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

	hooksecurefunc("PaperDollFrame_SetLevel", function()
		local primaryTalentTree = GetSpecialization()
		local classDisplayName, class = UnitClass("player")
		local classColor = DB.ClassColors[class]
		local classColorString = classColor.colorStr
		local specName, _

		if primaryTalentTree then
			_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"))
		end

		if specName and specName ~= "" then
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName)
		else
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName)
		end
	end)

	PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
	PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
	GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 1, 0)

	-- Token frame
	TokenFramePopupCorner:Hide()
	TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 1, -28)
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
					bu.expBg = B.CreateBDFrame(bu.expandIcon, .25)
					bu.expBg:SetPoint("TOPLEFT", bu.expandIcon, -3, 3)
					bu.expBg:SetPoint("BOTTOMRIGHT", bu.expandIcon, 3, -3)
					B.CreateGradient(bu.expBg)
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