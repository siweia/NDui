local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Friends then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Friends", C.Infobar.FriendsPos)

local strfind, format, sort, wipe, unpack = string.find, string.format, table.sort, table.wipe, unpack
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNet_GetClientEmbeddedTexture, BNet_GetValidatedCharacterName = BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNet_GetClientEmbeddedTexture, BNet_GetValidatedCharacterName
local CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor, IsShiftKeyDown = CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor, IsShiftKeyDown
local BNET_CLIENT_WOW, UNKNOWN, FRIENDS_LIST, GUILD_ONLINE_LABEL = BNET_CLIENT_WOW, UNKNOWN, FRIENDS_LIST, GUILD_ONLINE_LABEL
local friendTable, bnetTable, updateRequest = {}, {}
local wowString, bnetString = L["WoW"], L["BN"]
local activeZone, inactiveZone = {r=.3, g=1, b=.3}, {r=.7, g=.7, b=.7}

local function sortFriends(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
end

local function buildFriendTable(num)
	wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local status = ""
			if info.afk then
				status = DB.AFKTex
			elseif info.dnd then
				status = DB.DNDTex
			end
			local class = DB.ClassList[info.className]
			friendTable[i] = {info.name, info.level, class, info.area, info.connected, status}
		end
	end

	sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	if a[5] and b[5] then
		return a[5] > b[5]
	end
end

local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local bnetID, accountName, battleTag, isBattleTagPresence, charName, gameID, client, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)

		if isOnline then
			local _, _, _, realmName, _, _, _, class, _, zoneName, _, gameText, _, _, _, _, _, isGameAFK, isGameBusy = BNGetGameAccountInfo(gameID)

			charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
			class = DB.ClassList[class]
			accountName = isBattleTagPresence and battleTag or accountName

			local status, infoText = ""
			if isAFK or isGameAFK then
				status = DB.AFKTex
			elseif isDND or isGameBusy then
				status = DB.DNDTex
			else
				status = ""
			end
			if client == BNET_CLIENT_WOW then
				if not zoneName or zoneName == "" then
					infoText = UNKNOWN
				else
					infoText = zoneName
				end
			else
				infoText = gameText
			end

			bnetTable[i] = {bnetID, accountName, charName, gameID, client, isOnline, status, realmName, class, infoText}
		end
	end

	sort(bnetTable, sortBNFriends)
end

info.eventList = {
	"BN_FRIEND_ACCOUNT_ONLINE",
	"BN_FRIEND_ACCOUNT_OFFLINE",
	"BN_FRIEND_INFO_CHANGED",
	"FRIENDLIST_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"CHAT_MSG_SYSTEM",
}

info.onEvent = function(self, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		if not strfind(arg1, ERR_FRIEND_ONLINE_SS) and not strfind(arg1, ERR_FRIEND_OFFLINE_S) then return end
	elseif event == "MODIFIER_STATE_CHANGED" and arg1 == "LSHIFT" then
		self:onEnter()
	end

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, onlineBNet = BNGetNumFriends()
	self.text:SetText(format("%s: "..DB.MyColor.."%d", FRIENDS, onlineFriends + onlineBNet))
	updateRequest = false
end

info.onEnter = function(self)
	local numFriends, onlineFriends = C_FriendList_GetNumFriends(), C_FriendList_GetNumOnlineFriends()
	local numBNet, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	local totalFriends = numFriends + numBNet

	if not updateRequest then
		if numFriends > 0 then buildFriendTable(numFriends) end
		if numBNet > 0 then buildBNetTable(numBNet) end
		updateRequest = true
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", UIParent, 15, -30)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0,.6,1, 0,.6,1)

	if totalOnline == 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["No Online"], 1,1,1)
	else
		if onlineFriends > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(wowString, 0,.6,1)
			for i = 1, #friendTable do
				local name, level, class, area, connected, status = unpack(friendTable[i])
				if connected then
					local zoneColor = GetRealZoneText() == area and activeZone or inactiveZone
					local levelColor = B.HexRGB(GetQuestDifficultyColor(level))
					local classColor = DB.ClassColors[class] or levelColor
					GameTooltip:AddDoubleLine(levelColor..level.."|r "..name..status, area, classColor.r, classColor.g, classColor.b, zoneColor.r, zoneColor.g, zoneColor.b)
				end
			end
		end

		if onlineBNet > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(bnetString, 0,.6,1)
			for i = 1, #bnetTable do
				local _, accountName, charName, gameID, client, isOnline, status, realmName, class, infoText = unpack(bnetTable[i])

				if isOnline then
					local zoneColor, realmColor = inactiveZone, inactiveZone
					local name = FRIENDS_OTHER_NAME_COLOR_CODE.." ("..charName..")"

					if client == BNET_CLIENT_WOW then
						if CanCooperateWithGameAccount(gameID) then
							local color = DB.ClassColors[class] or GetQuestDifficultyColor(1)
							name = B.HexRGB(color).." "..charName
						end
						zoneColor = GetRealZoneText() == infoText and activeZone or inactiveZone
						realmColor = DB.MyRealm == realmName and activeZone or inactiveZone
					end

					local cicon = BNet_GetClientEmbeddedTexture(client, 14, 14, 0, -1)
					GameTooltip:AddDoubleLine(cicon..name..status, accountName, 1,1,1, .6,.8,1)
					if IsShiftKeyDown() then
						GameTooltip:AddDoubleLine(infoText, realmName, zoneColor.r, zoneColor.g, zoneColor.b, realmColor.r, realmColor.g, realmColor.b)
					end
				end
			end
		end
	end
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", L["Hold Shift"], 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Show Friends"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end

info.onLeave = function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

info.onMouseUp = function(_, btn)
	if btn ~= "LeftButton" then return end
	GameTooltip:Hide()
	ToggleFriendsFrame()
end