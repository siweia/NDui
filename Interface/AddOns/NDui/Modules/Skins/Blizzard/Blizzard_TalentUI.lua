local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TalentUI"] = function()
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

	PlayerTalentFrameRoleButton:SetSize(24, 24)

	hooksecurefunc("PlayerTalentFrameRole_UpdateRole", function(button, role)
		B.ReskinSmallRole(button:GetNormalTexture(), role)
	end)
end