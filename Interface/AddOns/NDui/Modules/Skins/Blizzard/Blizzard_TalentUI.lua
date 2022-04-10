local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TalentUI"] = function()
	B.ReskinPortraitFrame(PlayerTalentFrame, 20, -10, -33, 75)
	B.Reskin(PlayerTalentFrameCancelButton)
	B.ReskinScroll(PlayerTalentFrameScrollFrameScrollBar)
	for i = 1, 3 do
		local tab = _G["PlayerTalentFrameTab"..i]
		B.ReskinTab(tab)
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
end