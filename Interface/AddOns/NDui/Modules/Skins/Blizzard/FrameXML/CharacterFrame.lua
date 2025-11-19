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
	B.ReskinDropDown(self.BorderBox.IconTypeDropdown)

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

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)
	B.StripTextures(PaperDollFrame)

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

	B.ReskinRotationButtons(CharacterModelFrame)
	B.ReskinDropDown(PlayerStatFrameLeftDropdown)
	B.ReskinDropDown(PlayerStatFrameRightDropdown)
	B.ReskinDropDown(PlayerTitleDropdown)
	PlayerTitleDropdown.Text:SetPoint("LEFT", 27, 2) -- needs review

	B.StripTextures(CharacterAttributesFrame)
	local bg = B.CreateBDFrame(CharacterAttributesFrame, .25)
	bg:SetPoint("BOTTOMRIGHT", 0, -8)

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
		slot:SetNormalTexture(0)
		slot:SetPushedTexture(0)
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = B.Dummy
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

	B.StripTextures(CharacterAmmoSlot)
	CharacterAmmoSlotIconTexture:SetTexCoord(.08, .92, .08, .92)
	CharacterAmmoSlot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.CreateBDFrame(CharacterAmmoSlot, .25)

	local newResIcons = {136116, 135826, 136074, 135843, 135945}
	for i = 1, 5 do
		local bu = _G["MagicResFrame"..i]
		bu:SetSize(25, 25)
		local icon = bu:GetRegions()
		B.ReskinIcon(icon)
		icon:SetTexture(newResIcons[i])
		icon:SetAlpha(.5)
	end

	-- needs review
	for _, direc in pairs({"Left", "Right"}) do
		for i = 1, 6 do
			local frameName = "PlayerStatFrame"..direc..i
			local label = _G[frameName.."Label"]
			local text = _G[frameName.."StatText"]
			label:SetFontObject(Game13Font)
			text:SetFontObject(Game13Font)
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		if button.icon then
			button.icon:SetShown(button.hasItem)
		end
	end)

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
	B.ReskinCheck(atWarCheck)
	local atWarCheckTex = atWarCheck:GetCheckedTexture()
	atWarCheckTex:ClearAllPoints()
	atWarCheckTex:SetSize(26, 26)
	atWarCheckTex:SetPoint("CENTER")

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

	PetPaperDollCloseButton:Hide()
	B.StripTextures(PetAttributesFrame)
	B.CreateBDFrame(PetAttributesFrame, .25)

	for i = 1, 3 do
		local tab = _G["PetPaperDollFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end

	B.StripTextures(PetPaperDollFrameCompanionFrame)
	B.Reskin(CompanionSummonButton)
	B.ReskinRotationButtons(CompanionModelFrame)
	B.ReskinArrow(CompanionPrevPageButton, "left")
	B.ReskinArrow(CompanionNextPageButton, "right")

	for i = 1, 12 do
		local button = _G["CompanionButton"..i]
		button.bg = B.CreateBDFrame(button, .25)
		button:SetCheckedTexture(0)
		_G["CompanionButton"..i.."ActiveTexture"]:SetAlpha(0)

		button:SetNormalTexture(136243)
		local nt = button:GetNormalTexture()
		nt:SetTexCoord(x1, x2, y1, y2)
		nt:SetInside(button.bg)

		local dt = button:GetDisabledTexture()
		dt:SetTexCoord(.22, .75, .22, .75)
		dt:SetInside(button.bg)

		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)

		hooksecurefunc(button, "SetChecked", updateCheckState)
	end

	for i = 1, 5 do
		local bu = _G["PetMagicResFrame"..i]
		bu:SetSize(25, 25)
		local icon = bu:GetRegions()
		local a, b, _, _, _, _, c, d = icon:GetTexCoord()
		icon:SetTexCoord(a+.2, c-.2, b+.018, d-.018)
	end

	local function updateHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not happiness or not isHunterPet then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(.41, .53, .06, .3)
		elseif happiness == 2 then
			texture:SetTexCoord(.22, .345, .06, .3)
		elseif happiness == 3 then
			texture:SetTexCoord(.04, .15, .06, .3)
		end
	end

	PetPaperDollPetInfo:GetRegions():SetTexCoord(.04, .15, .06, .3)
	B.CreateBDFrame(PetPaperDollPetInfo)
	PetPaperDollPetInfo:RegisterEvent("UNIT_HAPPINESS")
	PetPaperDollPetInfo:SetScript("OnEvent", updateHappiness)
	PetPaperDollPetInfo:SetScript("OnShow", updateHappiness)

	-- PVP
	if not PVPFrame.CloseButton then
		PVPFrame.CloseButton = PVPParentFrameCloseButton
	end
	B.ReskinPortraitFrame(PVPFrame, 15, -15, -35, 73)

	B.ReskinArrow(PVPFrameToggleButton, "right")

	for i = 1, 2 do
		local tab = _G["PVPParentFrameTab"..i]
		if tab then B.ReskinTab(tab) end
	end

	for i = 1, 3 do
		local tName = "PVPTeam"..i
		B.StripTextures(_G[tName])
		B.CreateBDFrame(_G[tName.."Background"], .25)
	end

	B.ReskinPortraitFrame(PVPTeamDetails, 12, -12, -5, 5)
	B.Reskin(PVPTeamDetailsAddTeamMember)
	B.ReskinArrow(PVPTeamDetailsToggleButton, "right")

	for i = 1, 5 do
		B.StripTextures(_G["PVPTeamDetailsFrameColumnHeader"..i])
	end

	-- GearManager
	local toggleButton = GearManagerToggleButton
	B.StripTextures(toggleButton)
	local icon = toggleButton:CreateTexture(nil, "ARTWORK")
	setupTexture(icon)
	local hl = toggleButton:CreateTexture(nil, "HIGHLIGHT")
	setupTexture(hl)
	hl:SetVertexColor(1, .8, 0)

	B.StripTextures(GearManagerDialog)
	B.SetBD(GearManagerDialog, nil, 5, -5, 0, 5)
	B.ReskinClose(GearManagerDialogClose, nil, -6, -9)
	B.Reskin(GearManagerDialogDeleteSet)
	B.Reskin(GearManagerDialogEquipSet)
	B.Reskin(GearManagerDialogSaveSet)

	for i = 1, _G.MAX_EQUIPMENT_SETS_PER_PLAYER do
		local button = _G["GearSetButton"..i]
		button.bg = B.CreateBDFrame(button, .25)
		button:DisableDrawLayer("BACKGROUND")
		button:SetCheckedTexture(0)
		hooksecurefunc(button, "SetChecked", updateCheckState)

		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(button.bg)

		local icon = button.icon
		icon:SetTexCoord(x1, x2, y1, y2)
		icon:SetInside(button.bg)

		_G["GearSetButton"..i.."Name"]:SetFontObject(Game12Font)
		_G["GearSetButton"..i.."Name"]:SetWidth(50)
	end

	hooksecurefunc("PaperDollFrameItemFlyout_CreateButton", function()
		local button = PaperDollFrameItemFlyout.buttons[#PaperDollFrameItemFlyout.buttons]
		if button.bg then return end

		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button.bg = B.ReskinIcon(button.icon)
		B.ReskinIconBorder(button.IconBorder, true)
	end)

	PaperDollFrameItemFlyoutButtons.bg1:SetAlpha(0)
	PaperDollFrameItemFlyoutButtons:DisableDrawLayer("ARTWORK")
	B.SetBD(PaperDollFrameItemFlyoutButtons)
	hooksecurefunc(PaperDollFrameItemFlyoutButtons, "SetWidth", function(self, width, force)
		if force then return end
		self:SetWidth(width + 3, true)
	end)

	B.StripTextures(GearManagerDialogPopup)
	B.SetBD(GearManagerDialogPopup, nil, 5, -6, 0, 5)
	GearManagerDialogPopup:SetHeight(525)
	B.StripTextures(GearManagerDialogPopupScrollFrame)
	B.CreateBDFrame(GearManagerDialogPopupScrollFrame, .25)
	B.ReskinScroll(GearManagerDialogPopupScrollFrameScrollBar)
	B.Reskin(GearManagerDialogPopup.OkayButton)
	B.Reskin(GearManagerDialogPopup.CancelButton)
	B.ReskinInput(GearManagerDialogPopupEditBox)

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local bu = _G["GearManagerDialogPopupButton"..i]
		bu:SetCheckedTexture(DB.pushedTex)
		select(2, bu:GetRegions()):Hide()
		bu.icon:SetInside()
		B.ReskinIcon(bu.icon)
		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()
	end

	-- TokenFrame
	B.StripTextures(TokenFrame)
	B.Reskin(TokenFrameCancelButton)
	select(4, TokenFrame:GetChildren()):Hide() -- weird close button

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