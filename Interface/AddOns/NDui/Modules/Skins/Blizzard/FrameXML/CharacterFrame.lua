local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b = DB.r, DB.g, DB.b
local x1, x2, y1, y2 = unpack(DB.TexCoord)

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
	B.ReskinTrimScroll(self.IconSelector.ScrollBar)
	if self.BorderBox.IconTypeDropdown then
		B.ReskinDropDown(self.BorderBox.IconTypeDropdown)
	end

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

local function colourPopout(self)
	self.arrow:SetVertexColor(0, .6, 1)
end

local function clearPopout(self)
	self.arrow:SetVertexColor(1, 1, 1)
end

local function replaceBlueColor(bar, r, g, b)
	if r == 0 and g == 0 and b > .99 then
		bar:SetStatusBarColor(0, .6, 1, .5)
	end
end

local function setupTexture(tex)
	tex:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
	tex:SetTexCoord(0.01562500, 0.53125000, 0.46875000, 0.60546875)
	tex:SetInside()
end

local function updateCheckState(button, state)
	if state then
		button.bg:SetBackdropBorderColor(0, .6, 1)
	else
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function replaceHonorIcon(texture, t1, t2)
	if texture.isCutting then return end
	texture.isCutting = true

	if t1 == 0.03125 and t2 == 0.59375 then
		local faction = UnitFactionGroup("player") or "Horde"
		texture:SetTexture("Interface\\PVPFrame\\PVP-Currency-"..faction)
	end
	texture:SetTexCoord(x1, x2, y1, y2)

	texture.isCutting = nil
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
	B.StripTextures(PaperDollFrame)
	B.ReskinPortraitFrame(CharacterFrame)
	B.StripTextures(CharacterFrameInsetRight)

	B.ReskinModelControl(CharacterModelScene)
	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")

	local expandButton = CharacterFrameExpandButton
	if expandButton then
		B.ReskinArrow(expandButton, "right")

		hooksecurefunc(CharacterFrame, "Collapse", function()
			expandButton:SetNormalTexture(0)
			expandButton:SetPushedTexture(0)
			expandButton:SetDisabledTexture(0)
			B.SetupArrow(expandButton.__texture, "right")
		end)
		hooksecurefunc(CharacterFrame, "Expand", function()
			expandButton:SetNormalTexture(0)
			expandButton:SetPushedTexture(0)
			expandButton:SetDisabledTexture(0)
			B.SetupArrow(expandButton.__texture, "left")
		end)
	end

	local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES or 5

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G["CharacterFrameTab"..i]
		tab.bg = B.ReskinTab(tab)
		if i == 1 then
			tab:SetPoint("CENTER", CharacterFrame, "BOTTOMLEFT", 60, 59)
		end
		local hl = _G["CharacterFrameTab"..i.."HighlightTexture"]
		hl:SetPoint("TOPLEFT", tab.bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", tab.bg, -C.mult, C.mult)
	end

	-- [[ Item buttons ]]

	local function UpdateHighlight(self)
		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, .25)
		highlight:SetInside(self.bg)
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]

		B.StripTextures(slot)
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.icon:SetInside()
		slot.bg = B.CreateBDFrame(slot, .25)

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

		colourPopout(popout)
		popout:HookScript("OnEnter", clearPopout)
		popout:HookScript("OnLeave", colourPopout)
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		-- also fires for bag slots, we don't want that
		if button.popoutButton then
			button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
			colourPopout(button.popoutButton)
		end
		UpdateHighlight(button)
	end)

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

	-- Stats pane
	B.StripTextures(CharacterStatsPane)
	B.ReskinTrimScroll(CharacterStatsPane.ScrollBar)

	for i = 1, 7 do
		local category = _G["CharacterStatsPaneCategory"..i]
		if category then
			for i = 1, 4 do
				select(i, category:GetRegions()):SetAlpha(0)
			end
			B.CreateBDFrame(category, .25)
		end
	end

	for category, statInfo in pairs(PAPERDOLL_STATINFO) do
		hooksecurefunc(statInfo, "updateFunc", function(statFrame)
			if statFrame and not statFrame.styled then
				statFrame.Label:SetFontObject(Game13Font)
				statFrame.Value:SetFontObject(Game13Font)

				statFrame.styled = true
			end
		end)
	end

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

	-- Reputation
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", -32, -16)

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
		B.ReskinCollapse(_G["ReputationBar"..i.."ExpandOrCollapseButton"])
	end

	B.StripTextures(ReputationFrame)
	B.StripTextures(ReputationDetailFrame)
	B.SetBD(ReputationDetailFrame)
	B.ReskinClose(ReputationDetailCloseButton)
	B.ReskinCheck(ReputationDetailInactiveCheckbox)
	B.ReskinCheck(ReputationDetailMainScreenCheckbox)
	B.ReskinScroll(ReputationListScrollFrameScrollBar)
	select(3, ReputationDetailFrame:GetRegions()):Hide()

	local atWarCheck = ReputationDetailAtWarCheckbox
	if atWarCheck then
		B.ReskinCheck(atWarCheck)
		local atWarCheckTex = atWarCheck:GetCheckedTexture()
		atWarCheckTex:ClearAllPoints()
		atWarCheckTex:SetSize(26, 26)
		atWarCheckTex:SetPoint("CENTER")
	end

	-- SkillFrame
	B.StripTextures(SkillFrame)
	B.ReskinScroll(SkillListScrollFrameScrollBar)
	B.Reskin(SkillFrameCancelButton)
	B.ReskinCollapse(SkillFrameCollapseAllButton)
	B.StripTextures(SkillFrameExpandButtonFrame)

	B.ReskinScroll(SkillDetailScrollFrame.ScrollBar)
	B.CreateBDFrame(SkillDetailScrollFrame, .25)
	SkillDetailStatusBarBorder:SetAlpha(0)
	SkillDetailStatusBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(SkillDetailStatusBar, .25)
	hooksecurefunc(SkillDetailStatusBar, "SetStatusBarColor", replaceBlueColor)

	local button = SkillDetailStatusBarUnlearnButton
	B.Reskin(button)
	button.__bg:SetInside(nil, 7, 7)
	button:SetPoint("LEFT", SkillDetailStatusBar, "RIGHT", 2, 0)
	local tex = button:CreateTexture()
	tex:SetTexture(DB.closeTex)
	tex:SetVertexColor(1, 0, 0)
	tex:SetAllPoints(button.__bg)

	for i = 1, 12 do
		B.ReskinCollapse(_G["SkillTypeLabel"..i])
		local name = "SkillRankFrame"..i
		local bar = _G[name]
		local border = _G[name.."Border"]
		bar:SetStatusBarTexture(DB.bdTex)
		B.CreateBDFrame(bar, .25)
		hooksecurefunc(bar, "SetStatusBarColor", replaceBlueColor)
		border:SetAlpha(0)
	end

	-- PetFrame
	B.StripTextures(PetPaperDollFrame)
	B.StripTextures(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(PetPaperDollFrameExpBar, .25)
	B.ReskinRotationButtons(PetModelFrame)

	-- TokenFrame
	B.StripTextures(TokenFrame)

	TokenFramePopupCorner:Hide()
	TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 3, -28)
	B.StripTextures(TokenFramePopup)
	B.SetBD(TokenFramePopup)
	B.ReskinClose(TokenFramePopupCloseButton)
	B.ReskinCheck(TokenFramePopupInactiveCheckbox)
	B.ReskinCheck(TokenFramePopupBackpackCheckbox)
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

				bu.categoryLeft:SetAlpha(0)
				bu.categoryRight:SetAlpha(0)
				if bu.categoryMiddle then
					bu.categoryMiddle:SetAlpha(0)
				end

				bu.bg = B.ReskinIcon(bu.icon)
				hooksecurefunc(bu.icon, "SetTexCoord", replaceHonorIcon)

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
end)