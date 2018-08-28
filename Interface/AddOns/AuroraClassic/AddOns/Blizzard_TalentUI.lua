local F, C = unpack(select(2, ...))

C.themes["Blizzard_TalentUI"] = function()
	local r, g, b = C.r, C.g, C.b

	PlayerTalentFrameTalents:DisableDrawLayer("BORDER")
	PlayerTalentFrameTalentsBg:Hide()
	PlayerTalentFrameActiveSpecTabHighlight:SetTexture("")
	PlayerTalentFrameTitleGlowLeft:SetTexture("")
	PlayerTalentFrameTitleGlowRight:SetTexture("")
	PlayerTalentFrameTitleGlowCenter:SetTexture("")

	for i = 1, 6 do
		select(i, PlayerTalentFrameSpecialization:GetRegions()):Hide()
	end

	select(7, PlayerTalentFrameSpecialization:GetChildren()):DisableDrawLayer("OVERLAY")

	for i = 1, 5 do
		select(i, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetColorTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(.2)

	if select(2, UnitClass("player")) == "HUNTER" then
		for i = 1, 6 do
			select(i, PlayerTalentFramePetSpecialization:GetRegions()):Hide()
		end
		select(7, PlayerTalentFramePetSpecialization:GetChildren()):DisableDrawLayer("OVERLAY")
		for i = 1, 5 do
			select(i, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetColorTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(.2)

		for i = 1, GetNumSpecializations(false, true) do
			local _, _, _, icon = GetSpecializationInfo(i, false, true)
			PlayerTalentFramePetSpecialization["specButton"..i].specIcon:SetTexture(icon)
		end
	end

	hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
		for i = 1, NUM_TALENT_FRAME_TABS do
			local tab = _G["PlayerTalentFrameTab"..i]
			local a1, p, a2, x = tab:GetPoint()

			tab:ClearAllPoints()
			tab:SetPoint(a1, p, a2, x, 2)
		end
	end)

	for i = 1, NUM_TALENT_FRAME_TABS do
		F.ReskinTab(_G["PlayerTalentFrameTab"..i])
	end

	for _, frame in pairs({PlayerTalentFrameSpecialization, PlayerTalentFramePetSpecialization}) do
		local scrollChild = frame.spellsScroll.child

		scrollChild.ring:Hide()
		scrollChild.specIcon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(scrollChild.specIcon)

		local roleIcon = scrollChild.roleIcon
		roleIcon:SetTexture(C.media.roleIcons)
		local bg = F.CreateBDFrame(roleIcon, 1)
		bg:SetPoint("TOPLEFT", roleIcon, 3, -2)
		bg:SetPoint("BOTTOMRIGHT", roleIcon, -3, 4)
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1
		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child
		scrollChild.specIcon:SetTexture(icon)

		local index = 1
		local bonuses
		local bonusesIncrement = 1
		if self.isPet then
			bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)}
			bonusesIncrement = 2
		else
			bonuses = C_SpecializationInfo.GetSpellsDisplay(id)
		end

		if bonuses then
			for i = 1, #bonuses, bonusesIncrement do
				local frame = scrollChild["abilityButton"..index]
				local _, icon = GetSpellTexture(bonuses[i])
				frame.icon:SetTexture(icon)
				frame.subText:SetTextColor(.75, .75, .75)

				if not frame.styled then
					frame.ring:Hide()
					frame.icon:SetTexCoord(.08, .92, .08, .92)
					F.CreateBG(frame.icon)

					frame.styled = true
				end
				index = index + 1
			end
		end

		for i = 1, GetNumSpecializations(nil, self.isPet) do
			local bu = self["specButton"..i]

			if bu.disabled then
				bu.roleName:SetTextColor(.5, .5, .5)
			else
				bu.roleName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, GetNumSpecializations(false, nil) do
		local _, _, _, icon = GetSpecializationInfo(i, false, nil)
		PlayerTalentFrameSpecialization["specButton"..i].specIcon:SetTexture(icon)
	end

	local buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]

			bu.bg:SetAlpha(0)
			bu.ring:Hide()
			_G[name..i.."Glow"]:SetTexture("")

			F.Reskin(bu, true)

			bu.learnedTex:SetTexture("")
			bu.selectedTex:SetTexture(C.media.backdrop)
			bu.selectedTex:SetVertexColor(r, g, b, .2)
			bu.selectedTex:SetDrawLayer("BACKGROUND")
			bu.selectedTex:SetAllPoints()

			bu.specIcon:SetTexCoord(.08, .92, .08, .92)
			bu.specIcon:SetSize(58, 58)
			bu.specIcon:SetPoint("LEFT", bu, "LEFT")
			bu.specIcon:SetDrawLayer("OVERLAY")
			local bg = F.CreateBG(bu.specIcon)
			bg:SetDrawLayer("BORDER")

			local roleIcon = bu.roleIcon
			roleIcon:SetTexture(C.media.roleIcons)
			local bg = F.CreateBDFrame(roleIcon, 1)
			bg:SetPoint("TOPLEFT", roleIcon, 2, -1)
			bg:SetPoint("BOTTOMRIGHT", roleIcon, -3, 3)
		end
	end

	for i = 1, MAX_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow"..i]
		_G["PlayerTalentFrameTalentsTalentRow"..i.."Bg"]:Hide()
		row:DisableDrawLayer("BORDER")

		row.TopLine:SetDesaturated(true)
		row.TopLine:SetVertexColor(r, g, b)
		row.BottomLine:SetDesaturated(true)
		row.BottomLine:SetVertexColor(r, g, b)

		for j = 1, NUM_TALENT_COLUMNS do
			local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
			local ic = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j.."IconTexture"]

			bu:SetHighlightTexture("")
			bu.Slot:SetAlpha(0)
			bu.knownSelection:SetAlpha(0)

			ic:SetDrawLayer("ARTWORK")
			ic:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(ic)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetPoint("TOPLEFT", 10, 0)
			bu.bg:SetPoint("BOTTOMRIGHT")
			bu.bg:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bu.bg, .25)
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local _, _, _, selected, _, _, _, _, _, _, known = GetTalentInfo(i, j, 1)
				local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
				if known then
					bu.bg:SetBackdropColor(r, g, b, .6)
				elseif selected then
					bu.bg:SetBackdropColor(r, g, b, .25)
				else
					bu.bg:SetBackdropColor(0, 0, 0, .25)
				end
			end
		end
	end)

	for i = 1, 2 do
		local tab = _G["PlayerSpecTab"..i]
		_G["PlayerSpecTab"..i.."Background"]:Hide()

		tab:SetCheckedTexture(C.media.checked)

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		F.CreateBD(bg)

		select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function()
		PlayerSpecTab1:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 2, -36)
		PlayerSpecTab2:SetPoint("TOP", PlayerSpecTab1, "BOTTOM")
	end)

	PlayerTalentFrameTalentsTutorialButton.Ring:Hide()
	PlayerTalentFrameTalentsTutorialButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)
	PlayerTalentFrameSpecializationTutorialButton.Ring:Hide()
	PlayerTalentFrameSpecializationTutorialButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)
	PlayerTalentFramePetSpecializationTutorialButton.Ring:Hide()
	PlayerTalentFramePetSpecializationTutorialButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)

	F.ReskinPortraitFrame(PlayerTalentFrame, true)
	F.Reskin(PlayerTalentFrameSpecializationLearnButton)
	F.Reskin(PlayerTalentFrameActivateButton)
	F.Reskin(PlayerTalentFramePetSpecializationLearnButton)

	-- PVP Talents

	F.Reskin(PlayerTalentFrameTalentsPvpTalentButton)
	PlayerTalentFrameTalentsPvpTalentButton:SetSize(20, 20)

	local talentList = PlayerTalentFrameTalentsPvpTalentFrameTalentList
	talentList:ClearAllPoints()
	talentList:SetPoint("LEFT", PlayerTalentFrame, "RIGHT", 2, 0)
	F.StripTextures(talentList)
	F.CreateBD(talentList)
	F.CreateSD(talentList)

	PlayerTalentFrameTalentsPvpTalentFrameTalentListInset:SetAlpha(0)
	F.StripTextures(PlayerTalentFrameTalentsPvpTalentFrame)
	F.StripTextures(PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameScrollChild)
	F.ReskinScroll(PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameScrollBar)

	local function updatePVPTalent(self)
		if not self.styled then
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(self.Icon)
			F.CreateBDFrame(self, .25)
			self:GetRegions():SetAlpha(0)
			self:GetHighlightTexture():SetColorTexture(1, 1, 1, .1)
			self.SelectedOtherOverlay:SetAlpha(0)
			self.Selected:SetColorTexture(r, g, b, .25)
			self.Selected:SetDrawLayer("BACKGROUND")
			self.styled = true
		end
	end

	for i = 1, 10 do
		local bu = _G["PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameButton"..i]
		hooksecurefunc(bu, "Update", updatePVPTalent)
	end

	local bu = select(4, PlayerTalentFrameTalentsPvpTalentFrameTalentList:GetChildren())
	F.Reskin(bu)
end