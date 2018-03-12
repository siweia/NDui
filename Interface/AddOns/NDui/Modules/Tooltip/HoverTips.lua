local B, C, L, DB = unpack(select(2, ...))

local orig1, orig2, GameTooltip = {}, {}, GameTooltip
local linktypes = {
	item = true,
	enchant = true,
	spell = true,
	quest = true,
	unit = true,
	talent = true,
	achievement = true,
	glyph = true,
	instancelock = true,
	currency = true,
	keystone = true,
}

local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktype == "battlepet" then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT", -3, 5)
		GameTooltip:Show()
		local _, speciesID, level, breedQuality, maxHealth, power, speed = strsplit(":", link)
		BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
	elseif linktype and linktype == "journal" then
		local _, idType, id, diffID = strsplit(":", link)
		local name, description, icon, _, idString
		if idType == "0" then
			name, description = EJ_GetInstanceInfo(id)
			idString = "InstanceID:"
		elseif idType == "1" then
			name, description = EJ_GetEncounterInfo(id)
			idString = "EncounterID:"
		elseif idType == "2" then
			name, description, _, icon = EJ_GetSectionInfo(id)
			if icon then
				name = "|T"..icon..":20:20:0:0:64:64:5:59:5:59:20|t "..name
			end
			idString = "SectionID:"
		end
		if not name then return end

		GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT", -3, 5)
		GameTooltip:AddDoubleLine(name, GetDifficultyInfo(diffID))
		GameTooltip:AddLine(description, 1,1,1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(idString, DB.InfoColor..id)
		GameTooltip:Show()
	elseif linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT", -3, 5)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, link, ...)
	BattlePetTooltip:Hide()
	GameTooltip:Hide()

	if orig2[frame] then return orig2[frame](frame, ...) end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
end