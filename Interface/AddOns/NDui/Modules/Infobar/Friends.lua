local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Friends then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Friend", C.Infobar.FriendsPos)

local strfind, format, sort, wipe, unpack, tinsert = string.find, string.format, table.sort, table.wipe, unpack, table.insert
local C_Timer_After = C_Timer.After
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local FriendsFrame_GetFormattedCharacterName = FriendsFrame_GetFormattedCharacterName
local BNGetNumFriends, GetRealZoneText, GetQuestDifficultyColor = BNGetNumFriends, GetRealZoneText, GetQuestDifficultyColor
local HybridScrollFrame_GetOffset, HybridScrollFrame_Update = HybridScrollFrame_GetOffset, HybridScrollFrame_Update
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local InviteToGroup = C_PartyInfo.InviteUnit

local BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL = BNET_CLIENT_WOW, UNKNOWN, GUILD_ONLINE_LABEL
local FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND
local RAF_RECRUIT_FRIEND, RAF_RECRUITER_FRIEND = RAF_RECRUIT_FRIEND, RAF_RECRUITER_FRIEND
local EXPANSION_NAME0, EXPANSION_NAME3 = EXPANSION_NAME0, EXPANSION_NAME3
local WOW_PROJECT_ID = WOW_PROJECT_ID or 1
local WOW_PROJECT_60 = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_CATA = WOW_PROJECT_CATACLYSM_CLASSIC or 14
local CLIENT_WOW_DIFF = "WoV" -- for sorting

local r, g, b = DB.r, DB.g, DB.b
local infoFrame, updateRequest, prevTime
local friendTable, bnetTable = {}, {}
local activeZone, inactiveZone = "|cff4cff4c", DB.GreyColor
local noteString = "|T"..DB.copyTex..":12|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"
local onlineString = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineString = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")

local menuList = {
	[1] = {text = L["Join or Invite"], isTitle = true, notCheckable = true}
}

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
			tinsert(friendTable, {info.name, info.level, class, info.area, status, info.notes})
		end
	end

	sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	if DB.MyFaction == "Alliance" then
		return a[5] == b[5] and a[4] < b[4] or a[5] > b[5]
	else
		return a[5] == b[5] and a[4] > b[4] or a[5] > b[5]
	end
end

local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText or locationText == "" then
		return UNKNOWN
	end
	if isMobile then
		return "APP"
	end
	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return format(RAF_RECRUIT_FRIEND, locationText)
		else
			return format(RAF_RECRUITER_FRIEND, locationText)
		end
	end

	return locationText
end

local function buildBNetTable(num)
	wipe(bnetTable)

	for i = 1, num do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo then
			local accountName = accountInfo.accountName
			local battleTag = accountInfo.battleTag
			local isAFK = accountInfo.isAFK
			local isDND = accountInfo.isDND
			local note = accountInfo.note
			local broadcastText = accountInfo.customMessage
			local broadcastTime = accountInfo.customMessageTime
			local rafLinkType = accountInfo.rafLinkType

			local gameAccountInfo = accountInfo.gameAccountInfo
			local isOnline = gameAccountInfo.isOnline
			local gameID = gameAccountInfo.gameAccountID

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				local class = gameAccountInfo.className or UNKNOWN
				local zoneName = gameAccountInfo.areaName
				local level = gameAccountInfo.characterLevel
				local gameText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local wowProjectID = gameAccountInfo.wowProjectID
				local isMobile = gameAccountInfo.isWowMobile
				local factionName = gameAccountInfo.factionName or UNKNOWN
				local timerunningSeasonID = gameAccountInfo.timerunningSeasonID

				charName = FriendsFrame_GetFormattedCharacterName(charName, battleTag, client, timerunningSeasonID)
				class = DB.ClassList[class]

				local status = FRIENDS_TEXTURE_ONLINE
				if isAFK or isGameAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif isDND or isGameBusy then
					status = FRIENDS_TEXTURE_DND
				end

				if wowProjectID == WOW_PROJECT_60 then
					gameText = EXPANSION_NAME0
				elseif wowProjectID == WOW_PROJECT_CATA then
					gameText = EXPANSION_NAME3
				end

				local infoText = GetOnlineInfoText(client, isMobile, rafLinkType, gameText)
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = GetOnlineInfoText(client, isMobile, rafLinkType, zoneName or gameText)
				end

				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then client = CLIENT_WOW_DIFF end

				tinsert(bnetTable, {i, accountName, charName, factionName, client, status, class, level, infoText, note, broadcastText, broadcastTime})
			end
		end
	end

	sort(bnetTable, sortBNFriends)
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not infoFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function updateInfoFrameAnchor(frame)
	local relFrom, relTo, offset = module:GetTooltipAnchor(info)
	frame:ClearAllPoints()
	frame:SetPoint(relFrom, info, relTo, 0, offset)
end

function info:FriendsPanel_Init()
	if infoFrame then
		infoFrame:Show()
		updateInfoFrameAnchor(infoFrame)
		return
	end

	infoFrame = CreateFrame("Frame", "NDuiFriendsFrame", info)
	infoFrame:SetSize(400, 495)
	updateInfoFrameAnchor(infoFrame)
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("DIALOG")
	local bg = B.SetBD(infoFrame)
	bg:SetBackdropColor(0, 0, 0, .7)

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)

	B.CreateFS(infoFrame, 16, "|cff0099ff"..FRIENDS_LIST, nil, "TOPLEFT", 15, -10)
	infoFrame.friendCountText = B.CreateFS(infoFrame, 14, "-/-", nil, "TOPRIGHT", -15, -12)
	infoFrame.friendCountText:SetTextColor(0, .6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", "NDuiFriendsInfobarScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(370, 400)
	scrollFrame:SetPoint("TOPLEFT", 10, -35)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	B.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 20 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = info:FriendsPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = info.FriendsPanel_Update
	scrollFrame:SetScript("OnMouseWheel", info.FriendsPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)

	B.CreateFS(infoFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 42)
	local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
	B.CreateFS(infoFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
	B.CreateFS(infoFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 10)
end

local function inviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local inviteTypeToButtonText = {
	["INVITE"] = _G.TRAVEL_PASS_INVITE,
	["SUGGEST_INVITE"] = _G.SUGGEST_INVITE,
	["REQUEST_INVITE"] = _G.REQUEST_INVITE,
	["INVITE_CROSS_FACTION"] = _G.TRAVEL_PASS_INVITE_CROSS_FACTION,
	["SUGGEST_INVITE_CROSS_FACTION"] = _G.SUGGEST_INVITE_CROSS_FACTION,
	["REQUEST_INVITE_CROSS_FACTION"] = _G.REQUEST_INVITE_CROSS_FACTION,
}

local function GetButtonTexFromInviteType(guid, factionName)
	local inviteType = GetDisplayedInviteType(guid)
	if factionName and factionName ~= DB.MyFaction then
		inviteType = inviteType.."_CROSS_FACTION"
	end
	return inviteTypeToButtonText[inviteType]
end

local function GetNameAndInviteType(class, charName, guid, factionName)
	return format("%s%s|r %s", B.HexRGB(B.ClassColor(DB.ClassList[class])), charName, GetButtonTexFromInviteType(guid, factionName))
end

local function buttonOnClick(self, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do
						wipe(menuList[i])
					end
				end
				menuList[1].text = DB.InfoColor..self.data[2]

				local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(self.data[1])
				if numGameAccounts > 0 then
					for i = 1, numGameAccounts do
						local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(self.data[1], i)
						local charName = gameAccountInfo.characterName
						local client = gameAccountInfo.clientProgram
						local class = gameAccountInfo.className or UNKNOWN
						local factionName = gameAccountInfo.factionName or UNKNOWN
						local bnetIDGameAccount = gameAccountInfo.gameAccountID
						local guid = gameAccountInfo.playerGuid
						local wowProjectID = gameAccountInfo.wowProjectID
						if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and guid then
							if not menuList[index] then menuList[index] = {} end
							menuList[index].text = GetNameAndInviteType(class, charName, guid, factionName)
							menuList[index].notCheckable = true
							menuList[index].arg1 = bnetIDGameAccount
							menuList[index].arg2 = guid
							menuList[index].func = inviteFunc

							index = index + 1
						end
					end
				end

				if index == 2 then return end
				EasyMenu(menuList, B.EasyMenu, self, 0, 0, "MENU", 1)
			else
				InviteToGroup(self.data[1])
			end
		elseif IsShiftKeyDown() then
			local name = self.isBNet and self.data[3] or self.data[1]
			if name then
				if MailFrame:IsShown() then
					MailFrameTab_OnClick(nil, 2)
					SendMailNameEditBox:SetText(name)
					SendMailNameEditBox:HighlightText()
				else
					local editBox = ChatEdit_ChooseBoxForSend()
					local hasText = (editBox:GetText() ~= "")
					ChatEdit_ActivateChat(editBox)
					editBox:Insert(name)
					if not hasText then editBox:HighlightText() end
				end
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
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()
	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0,.6,1)
		GameTooltip:AddLine(" ")

		local index, accountName, _, _, _, _, _, _, _, note, broadcastText, broadcastTime = unpack(self.data)
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(index)
		for i = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(index, i)
			local charName = gameAccountInfo.characterName
			local client = gameAccountInfo.clientProgram
			local realmName = gameAccountInfo.realmName or ""
			local faction = gameAccountInfo.factionName
			local class = gameAccountInfo.className or UNKNOWN
			local zoneName = gameAccountInfo.areaName or UNKNOWN
			local level = gameAccountInfo.characterLevel
			local gameText = gameAccountInfo.richPresence or ""
			local wowProjectID = gameAccountInfo.wowProjectID
			local clientString = ""
			local timerunningSeasonID = gameAccountInfo.timerunningSeasonID
			if client == BNET_CLIENT_WOW then
				if charName ~= "" then -- fix for weird account
					if timerunningSeasonID then
						charName = TimerunningUtil.AddSmallIcon(charName) -- add timerunning tag on name
					end
					realmName = (DB.MyRealm == realmName or realmName == "") and "" or "-"..realmName

					-- Get TBC realm name from richPresence
					if wowProjectID == WOW_PROJECT_CATA then
						local realm, count = gsub(gameText, "^.-%-%s", "")
						if count > 0 then
							realmName = "-"..realm
						end
					end

					class = DB.ClassList[class]
					local classColor = B.HexRGB(B.ClassColor(class))
					if faction == "Horde" then
						clientString = "|TInterface\\FriendsFrame\\PlusManz-Horde:16:|t"
					elseif faction == "Alliance" then
						clientString = "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:|t"
					end
					GameTooltip:AddLine(format("%s%s %s%s%s", clientString, level, classColor, charName, realmName))

					if wowProjectID ~= WOW_PROJECT_ID then zoneName = "*"..zoneName end
					GameTooltip:AddLine(format("%s%s", inactiveZone, zoneName))
				end
			else
				if C_Texture.IsTitleIconTextureReady(client, Enum.TitleIconVersion.Small) then
					C_Texture.GetTitleIconTexture(client, Enum.TitleIconVersion.Small, function(success, texture)
						if success then
							clientString = BNet_GetClientEmbeddedTexture(texture, 32, 32, 0)
						end
					end)
				end
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
		local name, level, class, area, _, note = unpack(self.data)
		local classColor = B.HexRGB(B.ClassColor(class))
		GameTooltip:AddLine(format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(format("%s%s", inactiveZone, area))

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(noteString, note), 1,.8,0)
		end
	end
	GameTooltip:Show()
end

function info:FriendsPanel_CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(370, 20)
	button:SetPoint("TOPLEFT", 0, - (index-1) *20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)

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
	--button.gameIcon:SetTexCoord(.17, .83, .17, .83)
	--B.CreateBDFrame(button.gameIcon)

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", buttonOnClick)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", B.HideTooltip)

	return button
end

function info:FriendsPanel_UpdateButton(button)
	local index = button.index
	local onlineFriends = info.onlineFriends

	if index <= onlineFriends then
		local name, level, class, area, status = unpack(friendTable[index])
		button.status:SetTexture(status)
		local zoneColor = GetAreaText() == area and activeZone or inactiveZone
		local levelColor = B.HexRGB(GetQuestDifficultyColor(level))
		local classColor = DB.ClassColors[class] or levelColor
		button.name:SetText(format("%s%s|r %s%s", levelColor, level, B.HexRGB(classColor), name))
		button.zone:SetText(format("%s%s", zoneColor, area))
		C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)

		button.isBNet = nil
		button.data = friendTable[index]
	else
		local bnetIndex = index-onlineFriends
		local _, accountName, charName, factionName, client, status, class, _, infoText = unpack(bnetTable[bnetIndex])

		button.status:SetTexture(status)
		local zoneColor = inactiveZone
		local name = inactiveZone..charName
		if client == BNET_CLIENT_WOW then
			local color = DB.ClassColors[class] or GetQuestDifficultyColor(1)
			name = B.HexRGB(color)..charName
			zoneColor = GetAreaText() == infoText and activeZone or inactiveZone
		end
		button.name:SetText(format("%s%s|r (%s|r)", DB.InfoColor, accountName, name))
		button.zone:SetText(format("%s%s", zoneColor, infoText))

		if client == CLIENT_WOW_DIFF then
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
		elseif client == BNET_CLIENT_WOW then
			button.gameIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-"..factionName)
		else
			C_Texture.SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium)
		end

		button.isBNet = true
		button.data = bnetTable[bnetIndex]
	end
end

function info:FriendsPanel_Update()
	local scrollFrame = NDuiFriendsInfobarScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = info.totalOnline
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numFriendButtons then
			button.index = index
			info:FriendsPanel_UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numFriendButtons*height, usedHeight)
end

function info:FriendsPanel_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta*self.buttonHeight
	if IsShiftKeyDown() then
		step = step*19
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	info:FriendsPanel_Update()
end

function info:FriendsPanel_Refresh()
	local numFriends = C_FriendList_GetNumFriends()
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local numBNet, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	local totalFriends = numFriends + numBNet

	info.numFriends = numFriends
	info.onlineFriends = onlineFriends
	info.numBNet = numBNet
	info.onlineBNet = onlineBNet
	info.totalOnline = totalOnline
	info.totalFriends = totalFriends
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
		if not strfind(arg1, onlineString) and not strfind(arg1, offlineString) then return end
	end

	info:FriendsPanel_Refresh()
	self.text:SetText(format("%s: "..DB.MyColor.."%d", FRIENDS, info.totalOnline))

	updateRequest = false
	if infoFrame and infoFrame:IsShown() then
		info:onEnter()
	end
end

info.onEnter = function(self)
	local thisTime = GetTime()
	if not prevTime or (thisTime-prevTime > 5) then
		info:FriendsPanel_Refresh()
		prevTime = thisTime
	end

	local numFriends = info.numFriends
	local numBNet = info.numBNet
	local totalOnline = info.totalOnline
	local totalFriends = info.totalFriends

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

	if NDuiGuildInfobar and NDuiGuildInfobar:IsShown() then
		NDuiGuildInfobar:Hide()
	end

	info:FriendsPanel_Init()
	info:FriendsPanel_Update()
	infoFrame.friendCountText:SetText(format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
end

local function delayLeave()
	if MouseIsOver(infoFrame) then return end
	infoFrame:Hide()
end

info.onLeave = function()
	GameTooltip:Hide()
	if not infoFrame then return end
	C_Timer_After(.1, delayLeave)
end

info.onMouseUp = function(_, btn)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel

	if btn ~= "LeftButton" then return end
	if infoFrame then infoFrame:Hide() end
	ToggleFriendsFrame()
end