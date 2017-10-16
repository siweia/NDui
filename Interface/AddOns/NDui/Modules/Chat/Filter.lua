local B, C, L, DB = unpack(select(2, ...))

--[[
	修改自NoGoldSeller，强迫症患者只能接受这个低占用的。
]]
local FilterList = {}
local function genChatFilter(self, event, msg, author, _, _, _, flag)
	if not NDuiDB["Chat"]["EnableFilter"] then return end

	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") then
		return
	elseif B.UnitInGuild(author) or UnitInRaid(author) or UnitInParty(author) then
		return
	elseif event == "CHAT_MSG_WHISPER" and flag == "GM" then
		return
	else
		for i = 1, GetNumFriends() do
			if author == GetFriendInfo(i) then
				return
			end
		end
		for i = 1, BNGetNumFriends() do
			local _, _, battleTag, _, charName, _, client = BNGetFriendInfo(i)
			if author == BNet_GetValidatedCharacterName(charName, battleTag, client) then
				return
			end
		end
	end

	for _, symbol in ipairs(DB.Symbols) do
		msg = gsub(msg, symbol, "")
	end

	local keywords = {string.split(" ", NDuiDB["Chat"]["FilterList"])}
	for _, value in pairs(keywords) do
		if value ~= "" then
			if not FilterList[value] then
				FilterList[value] = true
			end
		end
	end

	local match = 0
	for keyword, _ in pairs(FilterList) do
		local _, count = gsub(msg, keyword, "")
		if count > 0 then
			match = match + 1
		end
	end

	if match >= NDuiDB["Chat"]["Matches"] then
		return true
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", genChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", genChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", genChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", genChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_ADDON", genChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", genChatFilter)

--[[
	公会频道有人@时提示你
]]
local at = NDui:EventFrame("CHAT_MSG_GUILD")
at:SetScript("OnEvent", function(self, event, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid = ...
	local list = {string.split(" ", NDuiDB["Chat"]["AtList"])}
	local name = UnitName("player")
	tinsert(list, name)

	for _, word in pairs(list) do
		if word ~= "" then
			if msg:lower():match("@"..word:lower()) then
				at.checker = true
				at.author = author
				at.class = select(2, GetPlayerInfoByGUID(guid))
				BNToastFrame_AddToast()
			end
		end
	end
end)
hooksecurefunc("BNToastFrame_Show", function()
	if at.checker == true then
		BNToastFrame:SetHeight(50)
		BNToastFrameIconTexture:SetTexCoord(.75, 1, 0, .5)
		BNToastFrameTopLine:Hide()
		BNToastFrameMiddleLine:Hide()
		BNToastFrameBottomLine:Hide()
		BNToastFrameDoubleLine:Show()
		local hexColor = B.HexRGB(B.ClassColor(at.class))
		BNToastFrameDoubleLine:SetText(format("%s "..DB.InfoColor.."@"..YOU.."! ("..GUILD..")", hexColor..Ambiguate(at.author, "short")))
		at.checker = false
	end
end)

-- Savedvariables Accountwide
local f = NDui:EventFrame({"PLAYER_LOGIN", "PLAYER_LOGOUT"})
f:SetScript("OnEvent", function(self, event)
	if not NDuiADB["ChatFilter"] then NDuiADB["ChatFilter"] = "" end
	if not NDuiADB["ChatAt"] then NDuiADB["ChatAt"] = "" end
	if not NDuiADB["Timestamp"] then NDuiADB["Timestamp"] = false end

	if event == "PLAYER_LOGIN" then
		NDuiDB["Chat"]["FilterList"] = NDuiADB["ChatFilter"]
		NDuiDB["Chat"]["AtList"] = NDuiADB["ChatAt"]
		NDuiDB["Chat"]["Timestamp"] = NDuiADB["Timestamp"]
	elseif event == "PLAYER_LOGOUT" then
		NDuiADB["ChatFilter"] = NDuiDB["Chat"]["FilterList"]
		NDuiADB["ChatAt"] = NDuiDB["Chat"]["AtList"]
		NDuiADB["Timestamp"] = NDuiDB["Chat"]["Timestamp"]
	end

	-- Timestamp
	local greyStamp = DB.GreyColor.."[%H:%M:%S]|r "
	if NDuiDB["Chat"]["Timestamp"] then
		SetCVar("showTimestamps", greyStamp)
	else
		if GetCVar("showTimestamps") == greyStamp then
			SetCVar("showTimestamps", "none")
		end
	end
end)