local _, ns = ...
local B, C, L, DB = unpack(ns)

local function replaceBlueColor(bar, r, g, b)
	if r == 0 and g == 0 and b > .99 then
		bar:SetStatusBarColor(0, .6, 1, .5)
	end
end

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(CharacterFrame, 15, -15, -35, 73)
	B.ReskinRotationButtons(CharacterModelFrame)

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

	HonorFrameProgressBar:SetWidth(320)
	HonorFrameProgressBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(HonorFrameProgressBar, .25)
	HonorFrameProgressBar:SetPoint("TOPLEFT", 22, -73)

	local bg = B.CreateBDFrame(HonorFrame, .25)
	bg:SetPoint("TOPLEFT", 21, -105)
	bg:SetPoint("BOTTOMRIGHT", -41, 80)

	B.StripTextures(PaperDollFrame)
	B.StripTextures(CharacterAttributesFrame)
	local bg = B.CreateBDFrame(CharacterAttributesFrame, .25)
	bg:SetPoint("BOTTOMRIGHT", 0, -8)

	-- [[ Item buttons ]]

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]

		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = B.Dummy
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = B.CreateBDFrame(slot, .25)
	end

	B.StripTextures(CharacterAmmoSlot)
	CharacterAmmoSlotIconTexture:SetTexCoord(.08, .92, .08, .92)
	CharacterAmmoSlot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.CreateBDFrame(CharacterAmmoSlot, .25)

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		local icon = button.icon
		if icon then icon:SetShown(button.hasItem) end
	end)

	local newResIcons = {136116, 135826, 136074, 135843, 135945}
	for i = 1, 5 do
		local bu = _G["MagicResFrame"..i]
		bu:SetSize(25, 25)
		local icon = bu:GetRegions()
		B.ReskinIcon(icon)
		icon:SetTexture(newResIcons[i])
		icon:SetAlpha(.5)
	end

	-- Reputation
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	ReputationListScrollFrame:GetRegions():Hide()
	select(2, ReputationListScrollFrame:GetRegions()):Hide()

	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", -32, -16)

	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local bar = _G["ReputationBar"..i]
			local check = _G["ReputationBar"..i.."AtWarCheck"]
			if bar and not bar.styled then
				B.StripTextures(bar)
				bar:SetStatusBarTexture(DB.bdTex)
				B.CreateBDFrame(bar, .25)

				local icon = check:GetRegions()
				icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
				icon:SetTexCoord(0, 1, 0, 1)
				icon:ClearAllPoints()
				icon:SetPoint("LEFT", check, 0, -3)

				bar.styled = true
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	for i = 1, NUM_FACTIONS_DISPLAYED do
		B.ReskinCollapse(_G["ReputationHeader"..i])
	end

	B.StripTextures(ReputationFrame)
	B.StripTextures(ReputationDetailFrame)
	B.SetBD(ReputationDetailFrame)
	B.ReskinClose(ReputationDetailCloseButton)
	B.ReskinCheck(ReputationDetailAtWarCheckBox)
	B.ReskinCheck(ReputationDetailInactiveCheckBox)
	B.ReskinCheck(ReputationDetailMainScreenCheckBox)
	B.ReskinScroll(ReputationListScrollFrameScrollBar)
	select(3, ReputationDetailFrame:GetRegions()):Hide()

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
	PetPaperDollCloseButton:Hide()
	B.StripTextures(PetPaperDollFrameExpBar)
	PetPaperDollFrameExpBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(PetPaperDollFrameExpBar, .25)
	B.StripTextures(PetAttributesFrame)
	B.CreateBDFrame(PetAttributesFrame, .25)
	B.ReskinRotationButtons(PetModelFrame)

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

	-- HonorFrame
	B.StripTextures(HonorFrame)
end)