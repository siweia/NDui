local _, ns = ...
local B, C, L, DB = unpack(ns)

local function handleSpellButton(self)
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then return end

	local slot, slotType = SpellBook_GetSpellBookSlot(self)
	local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType)
	local name = self:GetName()
	local highlightTexture = _G[name.."Highlight"]
	if isPassive then
		highlightTexture:SetColorTexture(1, 1, 1, 0)
	else
		highlightTexture:SetColorTexture(1, 1, 1, .25)
	end

	local subSpellString = _G[name.."SubSpellName"]
	local isOffSpec = self.offSpecID ~= 0 and SpellBookFrame.bookType == BOOKTYPE_SPELL
	subSpellString:SetTextColor(1, 1, 1)

	if slotType == "FUTURESPELL" then
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType)
		if level and level > UnitLevel("player") then
			self.SpellName:SetTextColor(.7, .7, .7)
			subSpellString:SetTextColor(.7, .7, .7)
		end
	else
		if slotType == "SPELL" and isOffSpec then
			subSpellString:SetTextColor(.7, .7, .7)
		end
	end
	self.RequiredLevelString:SetTextColor(.7, .7, .7)

	local ic = _G[name.."IconTexture"]
	if ic.bg then
		ic.bg:SetShown(ic:IsShown())
	end

	if self.ClickBindingIconCover and self.ClickBindingIconCover:IsShown() then
		self.SpellName:SetTextColor(.7, .7, .7)
	end
end

local function handleSkillButton(button)
	if not button then return end
	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)
	button.IconTexture:SetInside()
	button.bg = B.ReskinIcon(button.IconTexture)
	button.highlightTexture:SetInside(bg)

	local nameFrame = _G[button:GetName().."NameFrame"]
	if nameFrame then nameFrame:Hide() end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.ReskinPortraitFrame(SpellBookFrame)
	SpellBookFrame:DisableDrawLayer("BACKGROUND")
	SpellBookFrameTabButton1:ClearAllPoints()
	SpellBookFrameTabButton1:SetPoint("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 2)

	for i = 1, 5 do
		local tab = _G["SpellBookFrameTabButton"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end

	hooksecurefunc("SpellBookFrame_Update", function()
		for i = 2, 5 do
			local tab = _G["SpellBookFrameTabButton"..i]
			if tab then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["SpellBookFrameTabButton"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end)

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton"..i]
		local ic = _G["SpellButton"..i.."IconTexture"]

		_G["SpellButton"..i.."SlotFrame"]:SetAlpha(0)
		bu.EmptySlot:SetAlpha(0)
		bu.TextBackground:Hide()
		bu.TextBackground2:Hide()
		bu.UnlearnedFrame:SetAlpha(0)
		bu:SetCheckedTexture(0)
		bu:SetPushedTexture(0)

		ic.bg = B.ReskinIcon(ic)
		hooksecurefunc(bu, "UpdateButton", handleSpellButton)
	end

	SpellBookSkillLineTab1:SetPoint("TOPLEFT", SpellBookSideTabsFrame, "TOPRIGHT", 2, -36)

	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", function()
		for i = 1, GetNumSpellTabs() do
			local tab = _G["SpellBookSkillLineTab"..i]
			local nt = tab:GetNormalTexture()
			if nt then
				nt:SetTexCoord(unpack(DB.TexCoord))
			end

			if not tab.styled then
				tab:GetRegions():Hide()
				tab:SetCheckedTexture(DB.textures.pushed)
				tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				B.CreateBDFrame(tab, .25)

				tab.styled = true
			end
		end
	end)

	SpellBookFrameTutorialButton.Ring:Hide()
	SpellBookFrameTutorialButton:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", -12, 12)

	-- Professions

	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}

	for i, button in pairs(professions) do
		local bu = _G[button]
		bu.professionName:SetTextColor(1, 1, 1)
		bu.missingHeader:SetTextColor(1, 1, 1)
		bu.missingText:SetTextColor(1, 1, 1)

		B.StripTextures(bu.statusBar)
		bu.statusBar:SetHeight(10)
		bu.statusBar:SetStatusBarTexture(DB.bdTex)
		bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .6, 0, 1), CreateColor(0, .8, 0, 1))
		bu.statusBar.rankText:SetPoint("CENTER")
		B.CreateBDFrame(bu.statusBar, .25)
		if i > 2 then
			bu.statusBar:ClearAllPoints()
			bu.statusBar:SetPoint("BOTTOMLEFT", 16, 3)
		end

		handleSkillButton(bu.SpellButton1)
		handleSkillButton(bu.SpellButton2)
	end

	for i = 1, 2 do
		local bu = _G["PrimaryProfession"..i]
		_G["PrimaryProfession"..i.."IconBorder"]:Hide()

		bu.professionName:ClearAllPoints()
		bu.professionName:SetPoint("TOPLEFT", 100, -4)
		bu.icon:SetAlpha(1)
		bu.icon:SetDesaturated(false)
		B.ReskinIcon(bu.icon)

		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, -5)
	end

	hooksecurefunc("FormatProfession", function(frame, index)
		if index then
			local _, texture = GetProfessionInfo(index)

			if frame.icon and texture then
				frame.icon:SetTexture(texture)
			end
		end
	end)

	B.CreateBDFrame(SecondaryProfession1, .25)
	B.CreateBDFrame(SecondaryProfession2, .25)
	B.CreateBDFrame(SecondaryProfession3, .25)
	B.ReskinArrow(SpellBookPrevPageButton, "left")
	B.ReskinArrow(SpellBookNextPageButton, "right")
	SpellBookPageText:SetTextColor(.8, .8, .8)

	hooksecurefunc("UpdateProfessionButton", function(self)
		local spellIndex = self:GetID() + self:GetParent().spellOffset
		local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType)
		if isPassive then
			self.highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			self.highlightTexture:SetColorTexture(1, 1, 1, .25)
		end
		if self.spellString then
			self.spellString:SetTextColor(1, 1, 1)
		end
		if self.subSpellString then
			self.subSpellString:SetTextColor(1, 1, 1)
		end
	end)
end)