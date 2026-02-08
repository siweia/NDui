local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_RaidUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	for i = 1, NUM_RAID_GROUPS do
		local group = _G["RaidGroup"..i]
		group:GetRegions():SetAlpha(0)
		for j = 1, MEMBERS_PER_RAID_GROUP do
			local slot = _G["RaidGroup"..i.."Slot"..j]
			select(1, slot:GetRegions()):SetAlpha(0)
			select(2, slot:GetRegions()):SetColorTexture(r, g, b, .25)
			B.CreateBDFrame(slot, .2)
		end
	end

	for i = 1, MAX_RAID_MEMBERS do
		local bu = _G["RaidGroupButton"..i]
		B.StripTextures(bu)
		B.CreateBDFrame(bu)
	end

	B.Reskin(RaidFrameReadyCheckButton)

	for class, value in pairs(RAID_CLASS_BUTTONS) do
		local bu = _G["RaidClassButton"..value.button]
		local icon = _G["RaidClassButton"..value.button.."IconTexture"]
		bu:GetRegions():Hide()
		B.CreateBDFrame(bu)
		if value.button > 10 then
			icon:SetTexCoord(unpack(DB.TexCoord))
		else
			B.ClassIconTexCoord(icon, class)
		end
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end
end