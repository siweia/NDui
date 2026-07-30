local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strbyte, strfind, strmatch, gmatch, gsub, strrep, format = string.byte, string.find, string.match, string.gmatch, string.gsub, string.rep, string.format
local pairs, ipairs, tonumber = pairs, ipairs, tonumber
local abs, floor, min, max, tremove = math.abs, math.floor, math.min, math.max, table.remove
local IsGuildMember, C_FriendList_IsFriend, IsGUIDInGroup, C_Timer_After = IsGuildMember, C_FriendList.IsFriend, IsGUIDInGroup, C_Timer.After
local Ambiguate, UnitIsUnit, GetTime, SetCVar = Ambiguate, UnitIsUnit, GetTime, SetCVar
local GetItemInfo = C_Item.GetItemInfo or GetItemInfo
local GetItemStats = C_Item.GetItemStats or GetItemStats

-- Filter Chat symbols
local msgSymbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~"}

local FilterList = {}
local function SplitKeywords(list, variable)
	wipe(list)
	for keyword in gmatch(variable or "", "%S+") do
		list[#list+1] = keyword
	end
end

function module:UpdateFilterList()
	SplitKeywords(FilterList, NDuiADB["ChatFilterList"])
end

local WhiteFilterList = {}
function module:UpdateFilterWhiteList()
	SplitKeywords(WhiteFilterList, NDuiADB["ChatFilterWhiteList"])
end

-- ECF strings compare
local last, this = {}, {}
function module:CompareStrDiff(sA, sB)
	local len_a, len_b = #sA, #sB
	local maxLength = max(len_a, len_b)
	if maxLength == 0 or sA == sB then return 0 end

	local maxDiff = floor(maxLength*.1)
	if maxDiff == 0 or abs(len_a - len_b) > maxDiff then return 1 end

	-- Only the distance threshold matters here, so keep the DP inside its allowed band.
	local limit = maxDiff + 1
	for j = 0, len_b do
		last[j+1] = j <= maxDiff and j or limit
	end

	for i = 1, len_a do
		local from = max(1, i - maxDiff)
		local to = min(len_b, i + maxDiff)
		this[1] = i <= maxDiff and i or limit
		if from > 1 then this[from] = limit end

		local rowMin = from == 1 and this[1] or limit
		local byteA = strbyte(sA, i)
		for j = from, to do
			local cost = byteA == strbyte(sB, j) and 0 or 1
			local value = min(last[j+1] + 1, this[j] + 1, last[j] + cost)
			this[j+1] = value
			if value < rowMin then rowMin = value end
		end
		if to < len_b then this[to+2] = limit end
		if rowMin > maxDiff then return 1 end

		last, this = this, last
	end

	return last[len_b+1] / maxLength
end

C.BadBoys = {} -- debug
local chatLines, prevLineID, filterResult = {}, 0, false

function module:GetFilterResult(event, msg, name, flag, guid)
	if name == DB.MyName or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGUIDInGroup(guid)) then
		return
	end

	if C.db["Chat"]["BlockStranger"] and event == "CHAT_MSG_WHISPER" then -- Block strangers
		module.MuteCache[name] = GetTime()
		return true
	end

	if C.db["Chat"]["BlockSpammer"] and C.BadBoys[name] and C.BadBoys[name] >= 5 then return true end

	local filterMsg = msg
	if strfind(filterMsg, "|H", 1, true) then
		filterMsg = gsub(filterMsg, "|H.-|h(.-)|h", "%1")
	end
	if strfind(filterMsg, "|c", 1, true) then
		filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	end
	if strfind(filterMsg, "|r", 1, true) then
		filterMsg = gsub(filterMsg, "|r", "")
	end

	-- Trash Filter
	for i = 1, #msgSymbols do
		local symbol = msgSymbols[i]
		if strfind(filterMsg, symbol, 1, true) then
			filterMsg = gsub(filterMsg, symbol, "")
		end
	end

	if event == "CHAT_MSG_CHANNEL" and #WhiteFilterList > 0 then
		local found
		for i = 1, #WhiteFilterList do
			if strfind(filterMsg, WhiteFilterList[i]) then
				found = true
				break
			end
		end
		if not found then
			return 0
		end
	end

	local matches = 0
	local requiredMatches = C.db["Chat"]["Matches"]
	for i = 1, #FilterList do
		if strfind(filterMsg, FilterList[i]) then
			matches = matches + 1
			if matches >= requiredMatches then return true end
		end
	end

	-- ECF Repeat Filter
	if filterMsg == "" then filterMsg = msg end
	local msgTable = {name, filterMsg, GetTime()}
	local chatLinesSize = #chatLines
	chatLines[chatLinesSize+1] = msgTable
	for i = 1, chatLinesSize do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" and msgTable[3] - line[3] < .6) or module:CompareStrDiff(line[2], msgTable[2]) <= .1) then
			tremove(chatLines, i)
			return true
		end
	end
	if chatLinesSize >= 30 then tremove(chatLines, 1) end
end

function module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID ~= prevLineID then
		prevLineID = lineID

		local name = Ambiguate(author, "none")
		filterResult = module:GetFilterResult(event, msg, name, flag, guid)
		if filterResult and filterResult ~= 0 then
			C.BadBoys[name] = (C.BadBoys[name] or 0) + 1
		end
		if filterResult == 0 then filterResult = true end
	end

	return filterResult
end

-- Block addon msg
local addonBlockList = {
	"任务进度提示", "%[接受任务%]", "%(任务完成%)", "<大脚", "【爱不易】", "EUI[:_]", "打断:.+|Hspell", "PS 死亡: .+>", "%*%*.+%*%*", "<iLvl>", strrep("%-", 20),
	"<小队物品等级:.+>", "<LFG>", "进度:", "属性通报", "汐寒", "wow.+兑换码", "wow.+验证码", "【有爱插件】", "：.+>", "|Hspell.+=>"
}

local cvar
local function toggleCVar(value)
	value = tonumber(value) or 1
	SetCVar(cvar, value)
end

function module:ToggleChatBubble(party)
	cvar = "chatBubbles"..(party and "Party" or "")
	if not GetCVarBool(cvar) then return end
	toggleCVar(0)
	C_Timer_After(.01, toggleCVar)
end

function module:UpdateAddOnBlocker(event, msg, author)
	for _, word in ipairs(addonBlockList) do
		if strfind(msg, word) then
			local name = Ambiguate(author, "none")
			if UnitIsUnit(name, "player") then return end
			if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
				module:ToggleChatBubble()
			elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
				module:ToggleChatBubble(true)
			elseif event == "CHAT_MSG_WHISPER" then
				module.MuteCache[name] = GetTime()
			end
			return true
		end
	end
end

-- Show itemlevel on chat hyperlinks
local function isItemHasLevel(link)
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) then
		return name, level
	end
end

local socketWatchList = {
	["BLUE"] = true,
	["RED"] = true,
	["YELLOW"] = true,
	["COGWHEEL"] = true,
	["HYDRAULIC"] = true,
	["META"] = true,
	["PRISMATIC"] = true,
}

local function GetSocketTexture(socket, count)
	return strrep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-"..socket..":0|t", count)
end

local function isItemHasGem(link)
	local text = ""
	local stats = GetItemStats(link)
	for stat, count in pairs(stats) do
		local socket = strmatch(stat, "EMPTY_SOCKET_(%S+)")
		if socket and socketWatchList[socket] then
			text = text..GetSocketTexture(socket, count)
		end
	end
	return text
end

local itemCache = {}
local function convertItemLevel(link)
	if itemCache[link] then return itemCache[link] end

	local itemLink = strmatch(link, "|Hitem:.-|h")
	if itemLink then
		local name, itemLevel = isItemHasLevel(itemLink)
		if name and itemLevel then
			link = gsub(link, "|h%[(.-)%]|h", "|h["..name.."("..itemLevel..")]|h"..isItemHasGem(itemLink))
			itemCache[link] = link
		end
	end
	return link
end

function module:UpdateChatItemLevel(_, msg, ...)
	msg = gsub(msg, "(|Hitem:%d+:.-|h.-|h)", convertItemLevel)
	return false, msg, ...
end

function module:ChatFilter()
	if C.db["Chat"]["EnableFilter"] then
		self:UpdateFilterList()
		self:UpdateFilterWhiteList()
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
	end

	if C.db["Chat"]["BlockAddonAlert"] then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateAddOnBlocker)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateAddOnBlocker)
	end

	if C.db["Chat"]["ChatItemLevel"] then
		ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateChatItemLevel)
	end
end