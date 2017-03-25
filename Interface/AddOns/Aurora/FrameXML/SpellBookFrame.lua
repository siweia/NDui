local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	SpellBookFrame:DisableDrawLayer("BACKGROUND")
	SpellBookFrame:DisableDrawLayer("BORDER")
	SpellBookFrame:DisableDrawLayer("OVERLAY")
	SpellBookFrameInset:DisableDrawLayer("BORDER")

	F.SetBD(SpellBookFrame)
	F.ReskinClose(SpellBookFrameCloseButton)

	SpellBookFrameTabButton1:ClearAllPoints()
	SpellBookFrameTabButton1:SetPoint("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 2)

	for i = 1, 5 do
		F.ReskinTab(_G["SpellBookFrameTabButton"..i])
	end

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton"..i]
		local ic = _G["SpellButton"..i.."IconTexture"]

		_G["SpellButton"..i.."SlotFrame"]:SetAlpha(0)
		_G["SpellButton"..i.."Highlight"]:SetAlpha(0)

		bu.EmptySlot:SetAlpha(0)
		bu.TextBackground:Hide()
		bu.TextBackground2:Hide()
		bu.UnlearnedFrame:SetAlpha(0)

		bu:SetCheckedTexture("")
		bu:SetPushedTexture("")

		ic:SetTexCoord(.08, .92, .08, .92)

		ic.bg = F.CreateBG(bu)
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then return end

		local slot, slotType = SpellBook_GetSpellBookSlot(self);
		local name = self:GetName();
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
		if not ic.bg then return end
		if ic:IsShown() then
			ic.bg:Show()
		else
			ic.bg:Hide()
		end
	end)

	SpellBookSkillLineTab1:SetPoint("TOPLEFT", SpellBookSideTabsFrame, "TOPRIGHT", 2, -36)

	hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", function()
		for i = 1, GetNumSpellTabs() do
			local tab = _G["SpellBookSkillLineTab"..i]
			local nt = tab:GetNormalTexture()
			if nt then
				nt:SetTexCoord(.08, .92, .08, .92)
			end

			if not tab.styled then
				tab:GetRegions():Hide()
				tab:SetCheckedTexture(C.media.checked)
				F.CreateBG(tab)

				tab.styled = true
			end
		end
	end)

	SpellBookFrameTutorialButton.Ring:Hide()
	SpellBookFrameTutorialButton:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", -12, 12)
end)