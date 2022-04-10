local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	SpellBookFrameCloseButton = SpellBookCloseButton
	B.ReskinPortraitFrame(SpellBookFrame, 10, -10, -32, 70)
	for i = 1, 3 do
		local bu = _G["SpellBookFrameTabButton"..i]
		B.StripTextures(bu)
		local bg = B.CreateBDFrame(bu)
		bg:SetPoint("TOPLEFT", 12, -15)
		bg:SetPoint("BOTTOMRIGHT", -12, 20)
		if i == 1 then
			bu:SetPoint("CENTER", SpellBookFrame, "BOTTOMLEFT", 79, 54)
		end
	end

	for i = 1, 8 do
		local tab = _G["SpellBookSkillLineTab"..i]
		B.CreateBDFrame(tab)
		tab:DisableDrawLayer("BACKGROUND")
		tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
		tab:GetCheckedTexture():SetTexture(DB.textures.pushed)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints()
	end

	B.ReskinArrow(SpellBookPrevPageButton, "left")
	B.ReskinArrow(SpellBookNextPageButton, "right")

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton"..i]
		local ic = _G["SpellButton"..i.."IconTexture"]

		B.StripTextures(bu)
		bu:DisableDrawLayer("BACKGROUND")

		ic:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(ic, .25)
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
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

		local ic = _G[name.."IconTexture"]
		if ic.bg then
			ic.bg:SetShown(ic:IsShown())
		end
	end)
end)