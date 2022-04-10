local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_InspectUI"] = function()
	B.StripTextures(InspectModelFrame, true)

	-- Character
	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard", "Ranged",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]

		B.StripTextures(slot)
		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = B.CreateBDFrame(slot, .25)
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		local icon = button.icon
		if icon then icon:SetShown(button.hasItem) end
	end)

	B.ReskinPortraitFrame(InspectFrame, 15, -15, -35, 73)
	B.StripTextures(InspectPaperDollFrame)

	for i = 1, 3 do
		B.ReskinTab(_G["InspectFrameTab"..i])
	end

	B.ReskinRotationButtons(InspectModelFrame)

	-- PVP,
	B.StripTextures(InspectPVPFrame)

	for i = 1, 3 do
		local tName = "InspectPVPTeam"..i
		B.StripTextures(_G[tName])
		B.CreateBDFrame(_G[tName.."Background"], .25)
	end

	-- Talent
	B.StripTextures(InspectTalentFrame)
	B.Reskin(InspectTalentFrameCancelButton)
	B.ReskinScroll(InspectTalentFrameScrollFrameScrollBar)
	if InspectTalentFrameCloseButton then
		InspectTalentFrameCloseButton:Hide() -- should be removed by blizzard in future builds
	end

	for i = 1, 3 do
		B.ReskinTab(_G["InspectTalentFrameTab"..i])
	end

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i]
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
		if talent then
			B.StripTextures(talent)
			icon:SetTexCoord(.08, .92, .08, .92)
			B.CreateBDFrame(icon)
		end
	end
end