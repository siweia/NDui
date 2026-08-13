local _, ns = ...
local B, C, L, DB = unpack(ns)
----------------------------
-- yClassColors, by yleaf
-- NDui MOD
----------------------------
local format, ipairs = string.format, ipairs
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

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

local repColor = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0,
	0, 1, 1,
	0, 0, 1,
}

local function smoothColor(cur, max, color)
	local r, g, b = B:RGBColorGradient(cur, max, unpack(color))
	return B.HexRGB(r, g, b)
end

-- Guild
local currentView
local function setView(view)
	currentView = view
end

local function updateGuildView()
	currentView = currentView or GetCVar("guildRosterView")

	local playerArea = GetAreaText()
	local buttons = GuildRosterContainer.buttons

	for _, button in ipairs(buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			if currentView == "tradeskill" then
				local _, _, _, headerName, _, _, _, _, _, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
				if not headerName and zone == playerArea then
					button.string2:SetText("|cff00ff00"..zone)
				end
			else
				local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
				if currentView == "playerStatus" then
					button.string1:SetText(diffColor(level)..level)
					if zone == playerArea then
						button.string3:SetText("|cff00ff00"..zone)
					end
				elseif currentView == "guildStatus" then
					if rankIndex and rank then
						button.string2:SetText(smoothColor(rankIndex, 10, rankColor)..rank)
					end
				elseif currentView == "achievement" then
					button.string1:SetText(diffColor(level)..level)
				elseif currentView == "reputation" then
					button.string1:SetText(diffColor(level)..level)
					if repStanding then
						button.string3:SetText(smoothColor(repStanding-4, 5, repColor).._G["FACTION_STANDING_LABEL"..repStanding])
					end
				end
			end
		end
	end
end

local function updateGuildUI(event, addon)
	if addon ~= "Blizzard_GuildUI" then return end
	hooksecurefunc("GuildRoster_SetView", setView)
	hooksecurefunc("GuildRoster_Update", updateGuildView)
	hooksecurefunc(GuildRosterContainer, "update", updateGuildView)

	B:UnregisterEvent(event, updateGuildUI)
end
B:RegisterEvent("ADDON_LOADED", updateGuildUI)

-- Friends
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")

hooksecurefunc(FriendsListFrame.ScrollBox, "Update", function(self)
	local playerArea = GetAreaText()

	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		local nameText, infoText
		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList_GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = classColor(info.className)..info.name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, diffColor(info.level)..info.level.."|r", info.className)
					if info.area == playerArea then
						infoText = format("|cff00ff00%s|r", info.area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local accountInfo = C_BattleNet_GetFriendAccountInfo(button.id)
				if accountInfo then
					local accountName = accountInfo.accountName
					local gameAccountInfo = accountInfo.gameAccountInfo
					if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						local charName = gameAccountInfo.characterName
						local class = gameAccountInfo.className or UNKNOWN
						local zoneName = gameAccountInfo.areaName or UNKNOWN
						if accountName and charName and class then
							nameText = accountName.." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor(class)..charName..FRIENDS_WOW_NAME_COLOR_CODE..")"
							if zoneName == playerArea then
								infoText = format("|cff00ff00%s|r", zoneName)
							end
						end
					end
				end
			end
		end

		if nameText then button.name:SetText(nameText) end
		if infoText then button.info:SetText(infoText) end
	end
end)

if FriendsListSocialCardMixin then
	local function getSocialFriendInfo(self)
		local accountInfo = self.elementData and self.elementData.accountInfo
		local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo
		if not gameAccountInfo or not gameAccountInfo.isOnline or gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW then return end

		return accountInfo, gameAccountInfo
	end

	hooksecurefunc(FriendsListSocialCardMixin, "RefreshFriendCharacterDataDisplayText", function(self)
		local accountInfo, gameAccountInfo = getSocialFriendInfo(self)
		if not accountInfo then return end

		local class = gameAccountInfo.classFilename
		if not class or class == "" then class = gameAccountInfo.className end
		local name = FriendsListUtil.GetFormattedCharacterName(accountInfo)
		if name and class then
			self.Name:SetText(classColor(class)..name.."|r")
		end
		if gameAccountInfo.characterLevel then
			local level = gameAccountInfo.characterLevel
			self.Level:SetText(diffColor(level)..format(SOCIAL_UI_RECENT_ALLIES_CARD_LEVEL_DISPLAY_FORMAT, level).."|r")
		end
		if gameAccountInfo.className and class then
			self.Class:SetText(classColor(class)..gameAccountInfo.className.."|r")
		end
	end)

	hooksecurefunc(FriendsListSocialCardMixin, "RefreshLocationDisplayText", function(self)
		local _, gameAccountInfo = getSocialFriendInfo(self)
		if gameAccountInfo and gameAccountInfo.areaName == GetAreaText() then
			self.Location:SetText(format("|cff00ff00%s|r", gameAccountInfo.areaName))
		end
	end)
end

-- Whoframe
local columnTable = {
	["zone"] = "",
	["guild"] = "",
	["race"] = "",
}

local currentType = "zone"
hooksecurefunc(C_FriendList, "SortWho", function(sortType)
	currentType = sortType
end)

hooksecurefunc(WhoFrame.ScrollBox, "Update", function(self)
	local playerZone = GetAreaText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())

		local nameText = button.Name
		local levelText = button.Level
		local variableText = button.Variable

		local info = C_FriendList_GetWhoInfo(button.index)
		if info then
			local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
			if zone == playerZone then zone = "|cff00ff00"..zone end
			if guild == playerGuild then guild = "|cff00ff00"..guild end
			if race == playerRace then race = "|cff00ff00"..race end

			columnTable.zone = zone or ""
			columnTable.guild = guild or ""
			columnTable.race = race or ""

			nameText:SetTextColor(classColor(class, true))
			levelText:SetText(diffColor(level)..level)
			variableText:SetText(columnTable[currentType])
		end
	end
end)
