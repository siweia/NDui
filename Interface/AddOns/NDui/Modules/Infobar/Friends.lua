local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Friends then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Friends", C.Infobar.FriendsPos)

local strfind, format, sort, wipe, unpack, tinsert = string.find, string.format, table.sort, table.wipe, unpack, table.insert
local C_Timer_After = C_Timer.After
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local BNet_GetClientEmbeddedTexture, BNet_GetValidatedCharacterName, BNet_GetClientTexture = BNet_GetClientEmbeddedTexture, BNet_GetValidatedCharacterName, BNet_GetClientTexture
local CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor = CanCooperateWithGameAccount, GetRealZoneText, GetQuestDifficultyColor
local BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo = BNGetNumFriends, BNGetFriendInfo, BNGetGameAccountInfo, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo
local BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL = BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL
local FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND
local WOW_PROJECT_ID = WOW_PROJECT_ID or 1

local r, g, b = DB.r, DB.g, DB.b
local friendsFrame, menuFrame, updateRequest
local menuList, buttons, friendTable, bnetTable = {}, {}, {}, {}
local activeZone, inactiveZone = "|cff4cff4c", DB.GreyColor
local noteString = "|T"..DB.copyTex..":12|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"

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
			local status = FRIENDS_TEXTURE_ONLINE
			if info.afk then
				status = FRIENDS_TEXTURE_AFK
			elseif info.dnd then
				status = FRIENDS_TEXTURE_DND
			end
			local class = DB.ClassList[info.className]
			tinsert(friendTable, {info.name, info.level, class, info.area, status})
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
		local _, accountName, battleTag, _, charName, gameID, _, isOnline, _, isAFK, isDND, broadcastText, note, _, broadcastTime = BNGetFriendInfo(i)
		if isOnline then
			local _, _, client, realmName, _, _, _, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy, _, wowProjectID = BNGetGameAccountInfo(gameID)

			charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
			class = DB.ClassList[class]

			local status, infoText
			if isAFK or isGameAFK then
				status = FRIENDS_TEXTURE_AFK
			elseif isDND or isGameBusy then
				status = FRIENDS_TEXTURE_DND
			else
				status = FRIENDS_TEXTURE_ONLINE
			end
			if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
				if not zoneName or zoneName == "" then
					infoText = UNKNOWN
				else
					infoText = zoneName
				end
			else
				infoText = gameText
			end

			tinsert(bnetTable, {i, accountName, charName, gameID, client, realmName, status, class, level, infoText, note, broadcastText, broadcastTime})
		end
	end

	sort(bnetTable, sortBNFriends)
end

local function onUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not friendsFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function setupFriendsFrame()
	if friendsFrame then friendsFrame:Show() return end

	friendsFrame = CreateFrame("Frame", "NDuiFriendsFrame", info)
	friendsFrame:SetSize(400, 495)
	friendsFrame:SetPoint("TOPLEFT", UIParent, 15, -30)
	friendsFrame:SetClampedToScreen(true)
	friendsFrame:SetFrameStrata("DIALOG")
	B.CreateBD(friendsFrame, .7)
	B.CreateSD(friendsFrame)
	B.CreateTex(friendsFrame)

	friendsFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", onUpdate)
	end)
	friendsFrame:SetScript("OnHide", function()
		if menuFrame and menuFrame:IsShown() then menuFrame:Hide() end
	end)

	B.CreateFS(friendsFrame, 16, "|cff0099ff"..FRIENDS_LIST, nil, "TOPLEFT", 15, -10)
	friendsFrame.numFriends = B.CreateFS(friendsFrame, 14, "-/-", nil, "TOPRIGHT", -15, -12)
	friendsFrame.numFriends:SetTextColor(0, .6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", nil, friendsFrame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(380, 400)
	scrollFrame:SetPoint("TOPLEFT", 10, -35)
	module.ReskinScrollBar(scrollFrame)

	local roster = CreateFrame("Frame", nil, scrollFrame)
	roster:SetSize(380, 1)
	scrollFrame:SetScrollChild(roster)
	friendsFrame.roster = roster

	B.CreateFS(friendsFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 42)
	local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
	B.CreateFS(friendsFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
	B.CreateFS(friendsFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 10)
end

local function createInviteMenu()
	if menuFrame then return end

	menuFrame = CreateFrame("Frame", "FriendsInfobarMenu", friendsFrame, "UIDropDownMenuTemplate")
	menuFrame:SetFrameStrata("TOOLTIP")
	menuList[1] = {text = L["Join or Invite"], isTitle = true, notCheckable = true}
end

local function inviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local function buttonOnClick(self, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				createInviteMenu()

				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do menuList[i] = nil end
				end

				local numGameAccounts = BNGetNumFriendGameAccounts(self.data[1])
				local lastGameAccountID, lastGameAccountGUID
				if numGameAccounts > 1 then
					for i = 1, numGameAccounts do
						local _, charName, client, _, _, _, _, class, _, _, _, _, _, _, _, bnetIDGameAccount, _, _, _, guid = BNGetFriendGameAccountInfo(self.data[1], i)
						if client == BNET_CLIENT_WOW and CanCooperateWithGameAccount(bnetIDGameAccount) then
							if not menuList[index] then menuList[index] = {} end
							menuList[index].text = B.HexRGB(B.ClassColor(DB.ClassList[class]))..charName
							menuList[index].notCheckable = true
							menuList[index].arg1 = bnetIDGameAccount
							menuList[index].arg2 = guid
							menuList[index].func = inviteFunc
							lastGameAccountID = bnetIDGameAccount
							lastGameAccountGUID = guid

							index = index + 1
						end
					end
				end

				if index == 2 then return end
				if index == 3 then
					FriendsFrame_InviteOrRequestToJoin(lastGameAccountGUID, lastGameAccountID)
				else
					EasyMenu(menuList, menuFrame, self, 0, 0, "MENU", 1)
				end
			else
				InviteToGroup(self.data[1])
			end
		end
	else
		if self.isBNet then
			ChatFrame_SendBNetTell(self.data[2])
		else
			ChatFrame_SendTell(self.data[1], SELECTED_DOCK_FRAME)
		end
	end
end

local function buttonOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", friendsFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()
	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0,.6,1)
		GameTooltip:AddLine(" ")

		local index, accountName, _, _, _, _, _, _, _, _, note, broadcastText, broadcastTime = unpack(self.data)
		local numGameAccounts = BNGetNumFriendGameAccounts(index)
		for i = 1, numGameAccounts do
			local _, charName, client, realmName, _, _, _, class, _, zoneName, level, gameText, _, _, _, bnetIDGameAccount, _, _, _, _, wowProjectID = BNGetFriendGameAccountInfo(index, i)
			local clientString = BNet_GetClientEmbeddedTexture(client, 16)
			if client == BNET_CLIENT_WOW then
				realmName = DB.MyRealm == realmName and "" or "-"..realmName
				class = DB.ClassList[class]
				local classColor = B.HexRGB(B.ClassColor(class))
				if CanCooperateWithGameAccount(bnetIDGameAccount) then
					GameTooltip:AddLine(format("%s%s %s%s%s", clientString, level, classColor, charName, realmName))
				else
					GameTooltip:AddLine(format("%s%s%s* %s%s%s", clientString, inactiveZone, level, classColor, charName, realmName))
				end
				if wowProjectID ~= WOW_PROJECT_ID then zoneName = gameText end
				GameTooltip:AddLine(format("%s%s", inactiveZone, zoneName))
			else
				GameTooltip:AddLine(format("|cffffffff%s%s", clientString, accountName))
				if gameText ~= "" then
					GameTooltip:AddLine(format("%s%s", inactiveZone, gameText))
				end
			end
		end

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(noteString, note), 1,.8,0)
		end

		if broadcastText and broadcastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(broadcastString, broadcastText, FriendsFrame_GetLastOnline(broadcastTime)), .3,.6,.8, 1)
		end
	else
		GameTooltip:AddLine(L["WoW"], 1,.8,0)
		GameTooltip:AddLine(" ")
		local name, level, class, area = unpack(self.data)
		local classColor = B.HexRGB(B.ClassColor(class))
		GameTooltip:AddLine(format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(format("%s%s", inactiveZone, area))
	end
	GameTooltip:Show()
end

local function createRoster(parent, i)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(380, 20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)
	button.index = i

	button.status = button:CreateTexture(nil, "ARTWORK")
	button.status:SetPoint("LEFT", button, 5, 0)
	button.status:SetSize(16, 16)

	button.name = B.CreateFS(button, 13, "Tag (name)", false, "LEFT", 25, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
	button.name:SetJustifyH("LEFT")
	button.name:SetTextColor(.5, .7, 1)

	button.zone = B.CreateFS(button, 13, "Zone", false, "RIGHT", -28, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -130, 0)
	button.zone:SetJustifyH("RIGHT")

	button.gameIcon = button:CreateTexture(nil, "ARTWORK")
	button.gameIcon:SetPoint("RIGHT", button, -8, 0)
	button.gameIcon:SetSize(16, 16)
	button.gameIcon:SetTexCoord(.17, .83, .17, .83)
	B.CreateBD(B.CreateBG(button.gameIcon))

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", buttonOnClick)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", B.HideTooltip)

	return button
end

local previous = 0
local function updateAnchor()
	for i = 1, previous do
		if i == 1 then
			buttons[i]:SetPoint("TOPLEFT")
		else
			buttons[i]:SetPoint("TOP", buttons[i-1], "BOTTOM")
		end
		buttons[i]:Show()
	end
end

local function updateFriendsFrame()
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	if totalOnline ~= previous then
		if totalOnline > previous then
			for i = previous+1, totalOnline do
				if not buttons[i] then
					buttons[i] = createRoster(friendsFrame.roster, i)
				end
			end
		elseif totalOnline < previous then
			for i = totalOnline+1, previous do
				buttons[i]:Hide()
			end
		end
		previous = totalOnline

		updateAnchor()
	end

	for i = 1, #friendTable do
		local button = buttons[i]
		local name, level, class, area, status = unpack(friendTable[i])
		button.status:SetTexture(status)
		local zoneColor = GetRealZoneText() == area and activeZone or inactiveZone
		local levelColor = B.HexRGB(GetQuestDifficultyColor(level))
		local classColor = DB.ClassColors[class] or levelColor
		button.name:SetText(format("%s%s|r %s%s", levelColor, level, B.HexRGB(classColor), name))
		button.zone:SetText(format("%s%s", zoneColor, area))
		button.gameIcon:SetTexture(BNet_GetClientTexture(BNET_CLIENT_WOW))

		button.isBNet = nil
		button.data = friendTable[i]
	end

	for i = 1, #bnetTable do
		local button = buttons[i+onlineFriends]
		local _, accountName, charName, gameID, client, _, status, class, _, infoText = unpack(bnetTable[i])

		button.status:SetTexture(status)
		local zoneColor = inactiveZone
		local name = inactiveZone..charName
		if client == BNET_CLIENT_WOW then
			if CanCooperateWithGameAccount(gameID) then
				local color = DB.ClassColors[class] or GetQuestDifficultyColor(1)
				name = B.HexRGB(color)..charName
			end
			zoneColor = GetRealZoneText() == infoText and activeZone or inactiveZone
		end
		button.name:SetText(format("%s%s|r (%s|r)", DB.InfoColor, accountName, name))
		button.zone:SetText(format("%s%s", zoneColor, infoText))
		button.gameIcon:SetTexture(BNet_GetClientTexture(client))

		button.isBNet = true
		button.data = bnetTable[i]
	end
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

	if totalOnline == 0 then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", UIParent, 15, -30)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0,.6,1, 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["No Online"], 1,1,1)
		GameTooltip:Show()
		return
	end

	if not updateRequest then
		if numFriends > 0 then buildFriendTable(numFriends) end
		if numBNet > 0 then buildBNetTable(numBNet) end
		updateRequest = true
	end

	if NDuiGuildInfobar and NDuiGuildInfobar:IsShown() then NDuiGuildInfobar:Hide() end
	setupFriendsFrame()
	friendsFrame.numFriends:SetText(format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
	updateFriendsFrame()
end

local function delayLeave()
	if MouseIsOver(friendsFrame) then return end
	friendsFrame:Hide()
end

info.onLeave = function()
	GameTooltip:Hide()
	if not friendsFrame then return end
	C_Timer_After(.1, delayLeave)
end

info.onMouseUp = function(_, btn)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end

	if btn ~= "LeftButton" then return end
	if friendsFrame then friendsFrame:Hide() end
	ToggleFriendsFrame()
end