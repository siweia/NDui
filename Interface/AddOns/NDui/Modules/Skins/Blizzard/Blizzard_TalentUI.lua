local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TalentUI"] = function()
	if DB.isCata then

	B.ReskinPortraitFrame(PlayerTalentFrame)
	B.Reskin(PlayerTalentFrameToggleSummariesButton)
	B.Reskin(PlayerTalentFrameLearnButton)
	B.Reskin(PlayerTalentFrameResetButton)
	B.Reskin(PlayerTalentFrameActivateButton)

	for i = 1, 3 do
		local tab = _G["PlayerTalentFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end

		B.Reskin(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])

		for j = 1, 28 do
			local bu = _G["PlayerTalentFramePanel"..i.."Talent"..j]
			if bu then
				bu:GetPushedTexture():SetAlpha(0)
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

	for i = 1, 3 do
		B.StripTextures(_G["GlyphFrameHeader"..i])
	end

	for i = 1, 12 do
		local bu = _G["GlyphFrameScrollFrameButton"..i]
		local ic = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", ic, "TOPRIGHT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -2, 2)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		bu:SetNormalTexture(0)

		B.ReskinIcon(ic)
	end
end