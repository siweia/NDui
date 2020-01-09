local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = DB.r, DB.g, DB.b

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
		self.AzeriteTexture:SetPoint("TOPLEFT", C.mult, -C.mult)
		self.AzeriteTexture:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		self.AzeriteTexture:SetDrawLayer("BORDER", 1)
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
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.icon:SetPoint("TOPLEFT", C.mult, -C.mult)
		slot.icon:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		B.CreateBD(slot, .25)
		cooldown:SetPoint("TOPLEFT", C.mult, -C.mult)
		cooldown:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = B.Dummy
		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")

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

		tab.Highlight:SetColorTexture(1, 1, 1, .25)
		tab.Highlight:SetPoint("TOPLEFT", 3, -4)
		tab.Highlight:SetPoint("BOTTOMRIGHT", -1, 0)
		tab.Hider:SetColorTexture(.3, .3, .3, .4)
		tab.TabBg:SetAlpha(0)

		select(2, tab:GetRegions()):ClearAllPoints()
		if i == 1 then
			select(2, tab:GetRegions()):SetPoint("TOPLEFT", 3, -4)
			select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, 0)
		else
			select(2, tab:GetRegions()):SetPoint("TOPLEFT", 2, -4)
			select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, -1)
		end

		tab.bg = B.CreateBDFrame(tab)
		tab.bg:SetPoint("TOPLEFT", 2, -3)
		tab.bg:SetPoint("BOTTOMRIGHT", 0, -2)

		tab.Hider:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		tab.Hider:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
	end

	-- [[ Equipment manager ]]

	B.StripTextures(GearManagerDialogPopup.BorderBox)
	GearManagerDialogPopup.BG:Hide()
	B.CreateBD(GearManagerDialogPopup)
	B.CreateSD(GearManagerDialogPopup)
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

		bu:SetCheckedTexture(DB.textures.checked)
		select(2, bu:GetRegions()):Hide()
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(ic)

		ic:SetPoint("TOPLEFT", C.mult, -C.mult)
		ic:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		ic:SetTexCoord(.08, .92, .08, .92)
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
end)