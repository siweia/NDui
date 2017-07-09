local addon, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Friends == true then
	-- create a popup
	StaticPopupDialogs.SET_BN_BROADCAST = {
		text = BN_BROADCAST_TOOLTIP,
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		editBoxWidth = 350,
		maxLetters = 127,
		OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
		OnShow = function(self) self.editBox:SetText(select(3, BNGetInfo()) ) self.editBox:SetFocus() end,
		OnHide = ChatEdit_FocusActiveWindow,
		EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
		EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	}

	local format = string.format
	local sort = table.sort

	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:SetHitRectInsets(0, 0, 0, -10)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.FriendsPoint))
	Stat:SetAllPoints(Text)

	local function checkStatus()
		local status = {}
		if IsChatDND() then
			status = {false, true, false}
		elseif IsChatAFK() then
			status = {false, false, true}
		else
			status = {true, false, false}
		end
		return status
	end
	local menuFrame = CreateFrame("Frame", "FriendRightClickMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
		{text = INVITE, hasArrow = true, notCheckable = true},
		{text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true},
		{text = PLAYER_STATUS, hasArrow = true, notCheckable = true,
			menuList = {
				{ text = "|cff2BC226"..AVAILABLE.."|r", checked = function() return checkStatus()[1] end, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end},
				{ text = "|cffE7E716"..DND.."|r", checked = function() return checkStatus()[2] end, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end},
				{ text = "|cffFF0000"..AFK.."|r", checked = function() return checkStatus()[3] end, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end},
			},
		},
		{text = infoL["BN Info"], notCheckable = true, func = function() StaticPopup_Show("SET_BN_BROADCAST") end},
	}

	local function inviteClick(self, arg1, arg2)
		InviteToGroup(arg1)
		DropDownList1:Hide()
	end

	local function whisperClick(self, arg1, arg2)
		SetItemRef("player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
		DropDownList1:Hide()
	end
	
	local function BNwhisperClick(self, arg1, arg2)
		SetItemRef("BNplayer:"..arg1..":"..arg2, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
		DropDownList1:Hide()
	end

	local function HexColor(c)
		return (c.r and format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255))
	end

	local worldOfWarcraftString = infoL["WoW"]
	local battleNetString = infoL["BN"]
	local activezone, inactivezone = {r=.3, g=1, b=.3}, {r=.65, g=.65, b=.65}
	local friendTable, BNTable = {}, {}
	local friendOnline, friendOffline = gsub(ERR_FRIEND_ONLINE_SS,"\124Hplayer:%%s\124h%[%%s%]\124h",""), gsub(ERR_FRIEND_OFFLINE_S,"%%s","")
	local dataValid = false

	local function BuildFriendTable(total)
		wipe(friendTable)
		for i = 1, total do
			local name, level, class, area, connected, status, note = GetFriendInfo(i)
			if connected then
				if status == CHAT_FLAG_AFK then
					status = "|T"..FRIENDS_TEXTURE_AFK..":14:14:-2:-2:16:16:0:16:0:16|t"
				elseif status == CHAT_FLAG_DND then
					status = "|T"..FRIENDS_TEXTURE_DND..":14:14:-2:-2:16:16:0:16:0:16|t"
				else
					status = ""
				end
				for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
				friendTable[i] = { name, level, class, area, connected, status, note }
			end
		end
		sort(friendTable, function(a, b)
			if a[1] and b[1] then
				return a[1] < b[1]
			end
		end)
	end

	local function BuildBNTable(total)
		wipe(BNTable)
		for i = 1, total do
			local bnID, presenceName, battleTag, isBattleTagPresence, charName, gameID, client, isOnline, _, isAFK, isDND = BNGetFriendInfo(i)
			if isOnline then
				local _, _, _, realmName, _, faction, race, class, _, zoneName, level, gameText, _, _, _, _, _, isGameAFK, isGameBusy = BNGetGameAccountInfo(gameID)
				charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
				for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
					if class == v then
						class = k
					end
				end
				local status, account, infoText
				if isAFK or isGameAFK then
					status = " |T"..FRIENDS_TEXTURE_AFK..":14:14:-2:-2:16:16:0:16:0:16|t"
				elseif isDND or isGameBusy then
					status = " |T"..FRIENDS_TEXTURE_DND..":14:14:-2:-2:16:16:0:16:0:16|t"
				else
					status = ""
				end
				if client == BNET_CLIENT_WOW then
					if ( not zoneName or zoneName == "" ) then
						infoText = UNKNOWN
					else
						infoText = zoneName
					end
				else
					infoText = gameText
				end
				BNTable[i] = { bnID, presenceName, battleTag, isBattleTagPresence, charName, gameID, client, isOnline, status, realmName, class, infoText }
			end
		end
		sort(BNTable, function(a, b)
			if a[7] and b[7] then
				return a[7] > b[7]
			end
		end)
	end

	local function Update(self, event, arg1)
		if event == "CHAT_MSG_SYSTEM" then
			if not (string.find(arg1, friendOnline) or string.find(arg1, friendOffline)) then return end
		elseif event == "MODIFIER_STATE_CHANGED" and arg1 == "LSHIFT" then
			self:GetScript("OnEnter")(self)
		end

		local _, onlineFriends = GetNumFriends()
		local _, numBNetOnline = BNGetNumFriends()
		Text:SetText(format("%s: "..init.Colored.."%d", FRIENDS, onlineFriends + numBNetOnline))
		dataValid = false
	end

	Stat:SetScript("OnMouseUp", function(self, btn)
		GameTooltip:Hide()
		if btn == "LeftButton" then ToggleFriendsFrame() end
		if btn ~= "RightButton" then return end

		local menuCountWhispers = 0
		local menuCountInvites = 0
		local classc, levelc, info
		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if #friendTable > 0 then
			for i = 1, #friendTable do
				info = friendTable[i]
				if (info[5]) then
					menuCountInvites = menuCountInvites + 1
					menuCountWhispers = menuCountWhispers + 1
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					if classc == nil then classc = levelc end
					local nametext = HexColor(levelc)..info[2].." "..HexColor(classc)..info[1]
					menuList[2].menuList[menuCountInvites] = {text = nametext, arg1 = info[1], notCheckable = true, func = inviteClick}
					menuList[3].menuList[menuCountWhispers] = {text = nametext, arg1 = info[1], notCheckable = true, func = whisperClick}
				end
			end
		end

		if #BNTable > 0 then
			for i = 1, #BNTable do
				info = BNTable[i]
				if (info[8]) then
					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {text = "|cff70C0F5"..info[2], arg1 = info[2], arg2 = info[1], notCheckable = true, func = BNwhisperClick}
					if info[7] == BNET_CLIENT_WOW and CanCooperateWithGameAccount(info[6]) then
						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {text = "|cff70C0F5"..info[2], arg1 = info[5].."-"..info[10], notCheckable = true, func = inviteClick}
					end
				end
			end
		end

		EasyMenu(menuList, menuFrame, self, 0, -10, "MENU", 2)
	end)

	Stat:SetScript("OnEnter", function(self)
		local numberOfFriends, onlineFriends = GetNumFriends()
		local totalBNet, numBNetOnline = BNGetNumFriends()
		local totalonline = onlineFriends + numBNetOnline
		if not dataValid then
			-- only retrieve information for all on-line members when we actually view the tooltip
			if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
			if totalBNet > 0 then BuildBNTable(totalBNet) end
			dataValid = true
		end

		local totalfriends = numberOfFriends + totalBNet
		local zonec, classc, levelc, realmc, info

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", UIParent, 15, -30)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %s/%s", GUILD_ONLINE_LABEL, totalonline, totalfriends), 0,.6,1, 0,.6,1)
		if totalonline == 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(infoL["No Online"], 1,1,1)
		end
		if onlineFriends > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(worldOfWarcraftString, 0,.6,1)
			for i = 1, #friendTable do
				info = friendTable[i]
				if info[5] then
					if GetRealZoneText() == info[4] then zonec = activezone else zonec = inactivezone end
					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[3]], GetQuestDifficultyColor(info[2])
					if classc == nil then classc = levelc end
					GameTooltip:AddDoubleLine(format(HexColor(levelc)..info[2].."|r "..info[1].." "..info[6]), info[4], classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
				end
			end
		end

		if numBNetOnline > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(battleNetString, 0,.6,1)
			for i = 1, #BNTable do
				info = BNTable[i]
				if info[8] then
					local nametext = FRIENDS_OTHER_NAME_COLOR_CODE.." ("..info[5]..")"
					if info[4] then account = info[3] else account = info[2] end
					if info[7] == BNET_CLIENT_WOW then
						if CanCooperateWithGameAccount(info[6]) then
							classc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[info[11]]
							if not classc then classc = GetQuestDifficultyColor(1) end
							nametext = HexColor(classc).." "..info[5]
						end
						if GetRealZoneText() == info[12] then zonec = activezone else zonec = inactivezone end
						if GetRealmName() == info[10] then realmc = activezone else realmc = inactivezone end
					else
						zonec = inactivezone
						realmc = inactivezone
					end

					local cicon = BNet_GetClientEmbeddedTexture(info[7], 14, 14, 0, -1)
					GameTooltip:AddDoubleLine(cicon..nametext..info[9], account, 1,1,1, .6,.8,1)
					if IsShiftKeyDown() then
						GameTooltip:AddDoubleLine(info[12], info[10], zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
					end
				end
			end
		end
		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..infoL["Show Friends"], 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", init.RightButton..infoL["Show Menus"], 1,1,1, .6,.8,1)
		GameTooltip:Show()

		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end)

	Stat:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	end)

	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Stat:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	Stat:RegisterEvent("BN_FRIEND_TOON_ONLINE")
	Stat:RegisterEvent("BN_FRIEND_TOON_OFFLINE")
	Stat:RegisterEvent("BN_TOON_NAME_UPDATED")
	Stat:RegisterEvent("FRIENDLIST_UPDATE")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:RegisterEvent("CHAT_MSG_SYSTEM")
	Stat:SetScript("OnEvent", Update)
end