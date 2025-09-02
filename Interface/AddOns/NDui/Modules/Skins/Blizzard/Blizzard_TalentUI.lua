local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function ReanchorTutorial(button)
	button.Ring:Hide()
	button:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)
end

C.themes["Blizzard_TalentUI"] = function()
	if DB.isMop then
		local GetTalentInfo = C_SpecializationInfo.GetTalentInfo
		local GetSpecialization = C_SpecializationInfo.GetSpecialization
		local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo
		local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS or 3

		PlayerTalentFrameTalents:DisableDrawLayer("BORDER")
		PlayerTalentFrameTalentsBg:Hide()
		ReanchorTutorial(PlayerTalentFrameTalentsTutorialButton)

		PlayerTalentFrameTitleGlowLeft:SetTexture("")
		PlayerTalentFrameTitleGlowRight:SetTexture("")
		PlayerTalentFrameTitleGlowCenter:SetTexture("")
		B.ReskinIcon(PlayerTalentFrameTalentsClearInfoFrameIcon)

		local function updateTab(tab)
			if not tab.styled then
				tab:GetRegions():Hide()
				tab:SetCheckedTexture(DB.pushedTex)
				tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				B.ReskinIcon(tab:GetNormalTexture(), .25)

				tab.styled = true
			end
		end
		updateTab(PlayerSpecTab1)
		updateTab(PlayerSpecTab2)

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
			local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
			local shownSpec = spec or playerTalentSpec or 1
			local numSpecs = GetNumSpecializations(nil, self.isPet)
			local sex = self.isPet and UnitSex("pet") or UnitSex("player")
			local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
			if not id then return end

			local scrollChild = self.spellsScroll.child
			scrollChild.specIcon:SetTexture(icon)

			local index = 1
			local bonuses
			if self.isPet then
				bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)}
			else
				bonuses = SPEC_SPELLS_DISPLAY[id]
			end

			if bonuses then
				for i = 1, #bonuses, 2 do
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

		local function updateSelection(bu)
			local selection = bu:GetID()
			local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1
			local _, _, _, selected, _, _, _, _, _, isKnown = GetTalentInfoByID(selection, talentGroup)
			if selected then
				bu.bg:SetBackdropColor(r, g, b, .25)
			elseif isKnown then
				bu.bg:SetBackdropColor(r, g, b, .4)
			else
				bu.bg:SetBackdropColor(0, 0, 0, .25)
			end
		end

		for i = 1, MAX_NUM_TALENT_TIERS do
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

				B.ReskinIcon(ic)

				bu.bg = B.CreateBDFrame(bu, .25)
				bu.bg:SetPoint("TOPLEFT", 10, 0)
				bu.bg:SetPoint("BOTTOMRIGHT")

				hooksecurefunc(bu, "Show", updateSelection)
				hooksecurefunc(bu, "Hide", updateSelection)
			end
		end

		B.ReskinPortraitFrame(PlayerTalentFrame)
		B.Reskin(PlayerTalentFrameSpecializationLearnButton)
		B.Reskin(PlayerTalentFrameActivateButton)
		B.Reskin(PlayerTalentFramePetSpecializationLearnButton)
		B.Reskin(PlayerTalentFrameTalentsLearnButton)

		return
	end

	B.ReskinPortraitFrame(PlayerTalentFrame)
	B.Reskin(PlayerTalentFrameToggleSummariesButton)
	B.Reskin(PlayerTalentFrameLearnButton)
	B.Reskin(PlayerTalentFrameResetButton)
	B.Reskin(PlayerTalentFrameActivateButton)

	local function updateBorder(border)
		if border:IsShown() then
			border.__owner.bg:SetBackdropBorderColor(1, .8, 0)
		else
			border.__owner.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local function reskinTalentButton(bu, icon)
		B.StripTextures(bu)
		bu:GetPushedTexture():SetAlpha(0)
		bu:GetHighlightTexture():SetAlpha(0)
		bu.bg = B.ReskinIcon(icon)

		bu.GoldBorder.__owner = bu
		hooksecurefunc(bu.GoldBorder, "Show", updateBorder)
		hooksecurefunc(bu.GoldBorder, "Hide", updateBorder)
	end

	for i = 1, 3 do
		local tab = _G["PlayerTalentFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end

		local panelName = "PlayerTalentFramePanel"..i
		_G[panelName]:DisableDrawLayer("BORDER")
		_G[panelName.."HeaderBorder"]:SetAlpha(0)
		_G[panelName.."HeaderBackground"]:SetAlpha(0)
		B.StripTextures(_G[panelName.."HeaderIcon"])
		B.ReskinIcon(_G[panelName.."HeaderIconIcon"])
		B.CreateBDFrame(_G[panelName.."HeaderBackground"], .25)
		B.CreateBDFrame(_G[panelName.."InactiveShadow"], .25)
		B.Reskin(_G[panelName.."SelectTreeButton"])

		for j = 1, 28 do
			local bu = _G[panelName.."Talent"..j]
			local icon = _G[panelName.."Talent"..j.."IconTexture"]
			if bu then
				reskinTalentButton(bu, icon)
			end
		end

		local tab = _G["PlayerSpecTab"..i]
		if tab then
			tab:GetRegions():Hide()
			tab:SetCheckedTexture(DB.pushedTex)
			tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			B.CreateBDFrame(tab, .25)
		end
	end

	if DB.MyClass == "HUNTER" then
		B.ReskinRotationButtons(PlayerTalentFramePetModel)
		PlayerTalentFramePetModelBg:Hide()
		PlayerTalentFramePetShadowOverlay:Hide()
		PlayerTalentFramePetIconBorder:Hide()
		B.ReskinIcon(PlayerTalentFramePetIcon)
		local dietIcon = PlayerTalentFramePetDiet:GetRegions()
		B.ReskinIcon(dietIcon)
		dietIcon:SetTexture(132165)
		PlayerTalentFramePetDiet:SetSize(18, 18)
		B.CreateBDFrame(PlayerTalentFramePetModel, .25)

		PlayerTalentFramePetPanel:DisableDrawLayer("BORDER")
		PlayerTalentFramePetPanelHeaderBorder:SetAlpha(0)
		PlayerTalentFramePetPanelHeaderBackground:SetAlpha(0)
		B.StripTextures(PlayerTalentFramePetPanelHeaderIcon)
		B.ReskinIcon(PlayerTalentFramePetPanelHeaderIconIcon)
		PlayerTalentFramePetPanelHeaderIconIcon:SetSize(40, 40)
		B.CreateBDFrame(PlayerTalentFramePetPanel, .25)

		for i = 1, 24 do
			local bu = _G["PlayerTalentFramePetPanelTalent"..i]
			local icon = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]
			if bu then
				reskinTalentButton(bu, icon)
			end
		end
	end
end

C.themes["Blizzard_GlyphUI"] = function()
	B.StripTextures(GlyphFrame)
	GlyphFrameBackground:Hide()

	B.ReskinInput(GlyphFrameSearchBox)
	B.ReskinScroll(GlyphFrameScrollFrameScrollBar)
	B.ReskinFilterButton(GlyphFrame.FilterDropdown)
	GlyphFrameSideInset:DisableDrawLayer("BACKGROUND")
	GlyphFrameSideInset:DisableDrawLayer("BORDER")
	GlyphFrameSideInset:Hide()
	B.ReskinIcon(GlyphFrameClearInfoFrameIcon)

	for i = 1, 3 do
		local name = "GlyphFrameHeader"..i
		local header = _G[name]
		if header then
			_G[name.."Left"]:Hide()
			_G[name.."Middle"]:Hide()
			_G[name.."Right"]:Hide()
			local bg = B.CreateBDFrame(header, .25)
			bg:SetInside()
			bg:SetBackdropColor(r, g, b, .25)
		end
	end

	for i = 1, 12 do
		local bu = _G["GlyphFrameScrollFrameButton"..i]
		local ic = _G["GlyphFrameScrollFrameButton"..i.."Icon"]
		if bu then
			bu:SetNormalTexture(0)
			B.ReskinIcon(ic)

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", ic, "TOPRIGHT", 2, 0)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)
			local hl = bu:GetHighlightTexture()
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetInside()
			local selected = bu.selectedTex
			selected:SetInside(bg)
			selected:SetColorTexture(r, g, b, .2)
		end
	end
end