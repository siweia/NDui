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
		slot:SetNormalTexture(0)
		slot:SetPushedTexture(0)
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.icon:SetTexCoord(.08, .92, .08, .92)
		slot.bg = B.CreateBDFrame(slot, .25)
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		local icon = button.icon
		if icon then icon:SetShown(button.hasItem) end
	end)

	B.ReskinPortraitFrame(InspectFrame)
	B.StripTextures(InspectPaperDollFrame)

	for i = 1, 4 do
		local tab = _G["InspectFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end

	B.ReskinRotationButtons(InspectModelFrame)

	for i = 1, 6 do
		local row = InspectTalentFrame.InspectTalents["tier"..i]
		for j = 1, 3 do
			local bu = row["talent"..j]

			bu.Slot:Hide()
			bu.border:SetTexture("")

			B.ReskinIcon(bu.icon)
		end
	end

	-- PVP,
	B.StripTextures(InspectPVPFrame)
	B.StripTextures(InspectTalentFrame)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i]
		local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
		if talent then
			talent:GetPushedTexture():SetAlpha(0)
			talent:GetHighlightTexture():SetAlpha(0)
			B.StripTextures(talent)
			B.ReskinIcon(icon)
		end
	end
end