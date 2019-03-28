local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strmatch, strfind, format, gsub = string.match, string.find, string.format, string.gsub
local pairs, ipairs, tonumber = pairs, ipairs, tonumber
local min, max, tremove = math.min, math.max, table.remove
local IsGuildMember, C_FriendList_IsFriend, IsGUIDInGroup, C_Timer_After = IsGuildMember, C_FriendList.IsFriend, IsGUIDInGroup, C_Timer.After
local Ambiguate, UnitIsUnit, BNGetGameAccountInfoByGUID, GetTime, SetCVar = Ambiguate, UnitIsUnit, BNGetGameAccountInfoByGUID, GetTime, SetCVar

-- Filter Chat symbols
local msgSymbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~", "%-", "%."}

local FilterList = {}
function B:GenFilterList()
	B.SplitList(FilterList, NDuiADB["ChatFilterList"], true)
end

-- ECF strings compare
local last, this = {}, {}
local function strDiff(sA, sB) -- arrays of bytes
	local len_a, len_b = #sA, #sB
	for j = 0, len_b do
		last[j+1] = j
	end
	for i = 1, len_a do
		this[1] = i
		for j = 1, len_b do
			this[j+1] = (sA[i] == sB[j]) and last[j] or (min(last[j+1], this[j], last[j]) + 1)
		end
		for j = 0, len_b do
			last[j+1] = this[j+1]
		end
	end
	return this[len_b+1] / max(len_a, len_b)
end

C.BadBoys = {} -- debug
local chatLines, prevLineID, filterResult = {}, 0, false
local function getFilterResult(msg, name)
	if name == DB.MyName or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or (IsInInstance() and IsGUIDInGroup(guid))) then
		return
	end

	if C.BadBoys[name] and C.BadBoys[name] >= 5 then return true end

	local filterMsg = gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = gsub(filterMsg, symbol, "")
	end

	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
			end
		end
	end

	if matches >= NDuiDB["Chat"]["Matches"] then
		return true
	end

	-- ECF Repeat Filter
	local msgTable = {name, {}, GetTime()}
	if filterMsg == "" then filterMsg = msg end
	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end
	local chatLinesSize = #chatLines
	chatLines[chatLinesSize+1] = msgTable
	for i = 1, chatLinesSize do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((msgTable[3] - line[3] < .6) or strDiff(line[2], msgTable[2]) <= .1) then
			tremove(chatLines, i)
			return true
		end
	end
	if chatLinesSize >= 30 then tremove(chatLines, 1) end
end

local function genChatFilter(_, event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID == 0 or lineID ~= prevLineID then
		prevLineID = lineID

		local name = Ambiguate(author, "none")
		filterResult = getFilterResult(msg, name)
		if filterResult then C.BadBoys[name] = (C.BadBoys[name] or 0) + 1 end
	end

	return filterResult
end

local addonBlockList = {
	"任务进度提示", "%[接受任务%]", "%(任务完成%)", "<大脚", "【爱不易】", "EUI[:_]", "打断:.+|Hspell", "PS 死亡: .+>", "%*%*.+%*%*", "<iLvl>", ("%-"):rep(20),
	"<小队物品等级:.+>", "<LFG>", "进度:", "属性通报", "汐寒", "wow.+兑换码", "wow.+验证码"
}

local cvar
local function toggleCVar(value)
	value = tonumber(value) or 1
	SetCVar(cvar, value)
end

local function toggleBubble(party)
	cvar = "chatBubbles"..(party and "Party" or "")
	if not GetCVarBool(cvar) then return end
	toggleCVar(0)
	C_Timer_After(.01, toggleCVar)
end

local function genAddonBlock(_, event, msg, author)
	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") then return end

	for _, word in ipairs(addonBlockList) do
		if strfind(msg, word) then
			if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
				toggleBubble()
			elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
				toggleBubble(true)
			end
			return true
		end
	end
end

--[[
	公会频道有人提到你时通知你
]]
local chatAtList, at = {}, {}
function B:GenChatAtList()
	B.SplitList(chatAtList, NDuiADB["ChatAtList"], true)

	chatAtList[DB.MyName] = true
end

local function chatAtMe(_, _, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid = ...
	author = Ambiguate(author, "short")
	if author == DB.MyName then return end

	for word in pairs(chatAtList) do
		if word ~= "" then
			if strmatch(msg:lower(), word:lower()) then
				at.checker = true
				at.author = author
				at.class = select(2, GetPlayerInfoByGUID(guid))
				BNToastFrame:AddToast(BN_TOAST_TYPE_NEW_INVITE)
			end
		end
	end
end

hooksecurefunc(BNToastFrame, "ShowToast", function(self)
	if at.checker == true then
		self:SetHeight(50)
		self.IconTexture:SetTexCoord(.75, 1, 0, .5)
		self.TopLine:Hide()
		self.MiddleLine:Hide()
		self.BottomLine:Hide()
		self.DoubleLine:Show()

		local hexColor = B.HexRGB(B.ClassColor(at.class))
		self.DoubleLine:SetText(format(L["Mention You"], hexColor..at.author..DB.InfoColor))
		at.checker = false
	end
end)

-- 过滤海岛探险中艾泽里特的获取信息
local azerite = ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS:gsub("%%d/%%d ", "")
local function filterAzeriteGain(_, _, msg)
	if strfind(msg, azerite) then
		return true
	end
end

local function isPlayerOnIslands()
	local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
	if instanceType == "scenario" and maxPlayers == 3 then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filterAzeriteGain)
	else
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", filterAzeriteGain)
	end
end

function module:ChatFilter()
	if NDuiDB["Chat"]["EnableFilter"] then
		B:GenFilterList()
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", genChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", genChatFilter)
	end

	if NDuiDB["Chat"]["BlockAddonAlert"] then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", genAddonBlock)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", genAddonBlock)
	end

	B:GenChatAtList()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", chatAtMe)

	B:RegisterEvent("PLAYER_ENTERING_WORLD", isPlayerOnIslands)
end