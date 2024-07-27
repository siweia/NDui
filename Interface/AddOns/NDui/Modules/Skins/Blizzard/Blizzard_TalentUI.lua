local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function ReanchorTutorial(button)
	button.Ring:Hide()
	button:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)
end

C.themes["Blizzard_TalentUI"] = function()
	PlayerTalentFrameTalents:DisableDrawLayer("BORDER")
	PlayerTalentFrameTalentsBg:Hide()
	ReanchorTutorial(PlayerTalentFrameTalentsTutorialButton)

	PlayerTalentFrameActiveSpecTabHighlight:SetTexture("")
	PlayerTalentFrameTitleGlowLeft:SetTexture("")
	PlayerTalentFrameTitleGlowRight:SetTexture("")
	PlayerTalentFrameTitleGlowCenter:SetTexture("")
	PlayerTalentFrameLockInfoPortraitFrame:Hide()
	PlayerTalentFrameLockInfoPortrait:Hide()

	hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
		for i = 1, NUM_TALENT_FRAME_TABS do
			local tab = _G["PlayerTalentFrameTab"..i]
			local a1, p, a2, x = tab:GetPoint()

			tab:ClearAllPoints()
			tab:SetPoint(a1, p, a2, x, 2)
		end
	end)

	for i = 1, NUM_TALENT_FRAME_TABS do
		B.ReskinTab(_G["PlayerTalentFrameTab"..i])
	end

	for _, frame in pairs({PlayerTalentFrameSpecialization, PlayerTalentFramePetSpecialization}) do
		B.StripTextures(frame)
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			if child:IsObjectType("Frame") and not child:GetName() then
				B.StripTextures(child)
			end
		end
		ReanchorTutorial(_G[frame:GetName().."TutorialButton"])

		for i = 1, 4 do
			local bu = frame["specButton"..i]
			local _, _, _, icon, role = GetSpecializationInfo(i, false, frame.isPet)
			B.StripTextures(bu)
			B.Reskin(bu, true)

			bu.selectedTex:SetColorTexture(r, g, b, .25)
			bu.selectedTex:SetDrawLayer("BACKGROUND")
			bu.selectedTex:SetInside(bu.__bg)

			bu.specIcon:SetTexture(icon)
			bu.specIcon:SetSize(58, 58)
			bu.specIcon:SetPoint("LEFT", bu, "LEFT")
			B.ReskinIcon(bu.specIcon)
		end

		local scrollChild = frame.spellsScroll.child
		B.StripTextures(scrollChild)
		B.ReskinIcon(scrollChild.specIcon)
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, 1)
		local shownSpec = spec or playerTalentSpec or 1
		local numSpecs = GetNumSpecializations(nil, self.isPet)
		local sex = self.isPet and UnitSex("pet") or UnitSex("player")
		local id, _, _, icon, role = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
		if not id then return end

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
				frame.icon:SetTexture(C_Spell.GetSpellTexture(bonuses[i]))
				frame.subText:SetTextColor(.75, .75, .75)

				if not frame.styled then
					frame.ring:Hide()
					B.ReskinIcon(frame.icon)

					frame.styled = true
				end
				index = index + 1
			end
		end

		for i = 1, numSpecs do
			local bu = self["specButton"..i]
			if bu.disabled then
				bu.roleName:SetTextColor(.5, .5, .5)
			else
				bu.roleName:SetTextColor(1, 1, 1)
			end
		end
	end)

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
			bu.Cover:SetAlpha(0)
			bu.Slot:SetAlpha(0)
			bu.knownSelection:SetAlpha(0)

			B.ReskinIcon(ic)

			bu.bg = B.CreateBDFrame(bu, .25)
			bu.bg:SetPoint("TOPLEFT", 10, 0)
			bu.bg:SetPoint("BOTTOMRIGHT")
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

	B.ReskinPortraitFrame(PlayerTalentFrame)
	B.Reskin(PlayerTalentFrameSpecializationLearnButton)
	B.Reskin(PlayerTalentFrameActivateButton)
	B.Reskin(PlayerTalentFramePetSpecializationLearnButton)

	-- PVP Talents

	B.Reskin(PlayerTalentFrameTalentsPvpTalentButton)
	PlayerTalentFrameTalentsPvpTalentButton:SetSize(20, 20)

	local talentList = PlayerTalentFrameTalentsPvpTalentFrameTalentList
	talentList:ClearAllPoints()
	talentList:SetPoint("LEFT", PlayerTalentFrame, "RIGHT", 3, 0)
	B.StripTextures(talentList)
	B.SetBD(talentList)
	talentList.Inset:Hide()
	B.Reskin(select(4, talentList:GetChildren()), nil)

	B.StripTextures(PlayerTalentFrameTalentsPvpTalentFrame)
	B.ReskinTrimScroll(talentList.ScrollBar)
end