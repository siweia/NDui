local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

C.themes["Blizzard_TalentUI"] = function()
	if DB.isCata then

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

	else
		B.ReskinPortraitFrame(PlayerTalentFrame, 20, -10, -33, 75)
		B.ReskinScroll(PlayerTalentFrameScrollFrameScrollBar)
		for i = 1, 4 do
			local tab = _G["PlayerTalentFrameTab"..i]
			if tab then
				B.ReskinTab(tab)
			end
		end
		B.StripTextures(PlayerTalentFrameScrollFrame)
	
		for i = 1, MAX_NUM_TALENTS do
			local talent = _G["PlayerTalentFrameTalent"..i]
			local icon = _G["PlayerTalentFrameTalent"..i.."IconTexture"]
			if talent then
				B.StripTextures(talent)
				icon:SetTexCoord(.08, .92, .08, .92)
				B.CreateBDFrame(icon)
			end
		end
	
		B.StripTextures(PlayerTalentFrameStatusFrame)
		B.StripTextures(PlayerTalentFramePointsBar)
		B.Reskin(PlayerTalentFrameActivateButton)
	
		B.StripTextures(PlayerTalentFramePreviewBar)
		B.StripTextures(PlayerTalentFramePreviewBarFiller)
		B.Reskin(PlayerTalentFrameLearnButton)
		B.Reskin(PlayerTalentFrameResetButton)
		PlayerTalentFrameTalentPointsText:ClearAllPoints()
		PlayerTalentFrameTalentPointsText:SetPoint("RIGHT", PlayerTalentFramePointsBar, "RIGHT", -12, 1)
	
		for i = 1, 3 do
			local tab = _G["PlayerSpecTab"..i]
			if tab then
				tab:GetRegions():Hide()
				tab:SetCheckedTexture(DB.pushedTex)
				tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				tab:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
				B.CreateBDFrame(tab)
			end
		end
	end
end

C.themes["Blizzard_GlyphUI"] = function()
	B.StripTextures(GlyphFrame)
	GlyphFrameBackground:Hide()

	if not DB.isCata then return end

	B.ReskinInput(GlyphFrameSearchBox)
	B.ReskinScroll(GlyphFrameScrollFrameScrollBar)
	B.ReskinDropDown(GlyphFrameFilterDropDown)
	GlyphFrameSideInset:DisableDrawLayer("BACKGROUND")
	GlyphFrameSideInset:DisableDrawLayer("BORDER")
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