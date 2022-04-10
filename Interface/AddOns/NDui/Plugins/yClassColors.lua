local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
----------------------------
-- yClassColors, by yleaf
-- NDui MOD
----------------------------
local format, tinsert, strsplit = string.format, table.insert, string.split

-- Colors
local function classColor(class, showRGB)
	local color = DB.ClassColors[DB.ClassList[class] or class]
	if not color then color = DB.ClassColors["PRIEST"] end

	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c"..color.colorStr
	end
end

local function diffColor(level)
	return B.HexRGB(GetQuestDifficultyColor(level))
end

local rankColor = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0
}

-- Guild
hooksecurefunc("GuildStatus_Update", function()
	local guildIndex
	local playerArea = GetRealZoneText()
	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
	if FriendsFrame.playerStatusFrame then
		for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local fullName, _, _, level, class, zone, _, _, online = GetGuildRosterInfo(guildIndex)
			if fullName and online then
				local r, g, b = classColor(class, true)
				_G["GuildFrameButton"..i.."Name"]:SetTextColor(r, g, b)
				if zone == playerArea then
					_G["GuildFrameButton"..i.."Zone"]:SetTextColor(0, 1, 0)
				end
				local color = GetQuestDifficultyColor(level)
				_G["GuildFrameButton"..i.."Level"]:SetTextColor(color.r, color.g, color.b)
				_G["GuildFrameButton"..i.."Class"]:SetTextColor(r, g, b)
			end
		end
	else
		for i = 1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i
			local fullName, _, rankIndex, _, class, _, _, _, online = GetGuildRosterInfo(guildIndex)
			if fullName and online then
				local r, g, b = classColor(class, true)
				_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(r, g, b)
				local lr, lg, lb = oUF:RGBColorGradient(rankIndex, 10, unpack(rankColor))
				if lr then
					_G["GuildFrameGuildStatusButton"..i.."Rank"]:SetTextColor(lr, lg, lb)
				end
			end
		end
	end
end)

-- Friends
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")

local function friendsFrame()
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local playerArea = GetRealZoneText()

	for i = 1, #buttons do
		local nameText, infoText
		local button = buttons[i]
		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList.GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = classColor(info.className)..info.name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, diffColor(info.level)..info.level.."|r", info.className)
					if info.area == playerArea then
						infoText = format("|cff00ff00%s|r", info.area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local _, presenceName, _, _, _, gameID, client, isOnline = BNGetFriendInfo(button.id)
				if isOnline and client == BNET_CLIENT_WOW then
					local _, charName, _, _, _, faction, _, class, _, zoneName = BNGetGameAccountInfo(gameID)
					if presenceName and charName and class and faction == UnitFactionGroup("player") then
						nameText = presenceName.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor(class)..charName..FRIENDS_WOW_NAME_COLOR_CODE..")"
						if zoneName == playerArea then
							infoText = format("|cff00ff00%s|r", zoneName)
						end
					end
				end
			end
		end

		if nameText then button.name:SetText(nameText) end
		if infoText then button.info:SetText(infoText) end
	end
end
hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", friendsFrame)
hooksecurefunc("FriendsFrame_UpdateFriends", friendsFrame)

-- Whoframe
local columnTable = {}
local function updateWhoList()
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
	local playerZone = GetRealZoneText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, WHOS_TO_DISPLAY, 1 do
		local index = whoOffset + i
		local nameText = _G["WhoFrameButton"..i.."Name"]
		local levelText = _G["WhoFrameButton"..i.."Level"]
		local variableText = _G["WhoFrameButton"..i.."Variable"]
		local info = C_FriendList.GetWhoInfo(index)
		if info then
			local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
			if zone == playerZone then zone = "|cff00ff00"..zone end
			if guild == playerGuild then guild = "|cff00ff00"..guild end
			if race == playerRace then race = "|cff00ff00"..race end

			wipe(columnTable)
			tinsert(columnTable, zone)
			tinsert(columnTable, guild)
			tinsert(columnTable, race)

			nameText:SetTextColor(classColor(class, true))
			levelText:SetText(diffColor(level)..level)
			variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
		end
	end
end
hooksecurefunc("WhoList_Update", updateWhoList)

-- Battlefield board
local SCORE_BUTTONS_MAX = SCORE_BUTTONS_MAX or 20

hooksecurefunc("WorldStateScoreFrame_Update", function()
	local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

	for i = 1, SCORE_BUTTONS_MAX do
		local index = offset + i
		local fullName, _, _, _, _, faction, _, _, class = GetBattlefieldScore(index)
		if fullName then
			local name, realm = strsplit(" - ", fullName)
			name = classColor(class)..name.."|r"
			if fullName == DB.MyName then name = "> "..name.." <" end

			if realm then
				local color = "|cffff1919"
				if faction == 1 then color = "|cff00adf0" end
				realm = color..realm.."|r"
				name = name.." - "..realm
			end

			local button = _G["WorldStateScoreButton"..i]
			if button then
				button.name.text:SetText(name)
			end
		end
	end
end)