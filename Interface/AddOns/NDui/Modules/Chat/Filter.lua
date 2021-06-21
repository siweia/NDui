local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strfind, strmatch, gsub, strrep = string.find, string.match, string.gsub, string.rep
local pairs, ipairs, tonumber = pairs, ipairs, tonumber
local min, max, tremove = math.min, math.max, table.remove
local IsGuildMember, C_FriendList_IsFriend, IsGUIDInGroup, C_Timer_After = IsGuildMember, C_FriendList.IsFriend, IsGUIDInGroup, C_Timer.After
local Ambiguate, UnitIsUnit, GetTime, SetCVar = Ambiguate, UnitIsUnit, GetTime, SetCVar
local GetItemInfo, GetItemStats = GetItemInfo, GetItemStats
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID

local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR
local BN_TOAST_TYPE_CLUB_INVITATION = BN_TOAST_TYPE_CLUB_INVITATION or 6

-- Filter Chat symbols
local msgSymbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~"}

local FilterList = {}
function module:UpdateFilterList()
	B.SplitList(FilterList, NDuiADB["ChatFilterList"], true)
end

local WhiteFilterList = {}
function module:UpdateFilterWhiteList()
	B.SplitList(WhiteFilterList, NDuiADB["ChatFilterWhiteList"], true)
end

-- ECF strings compare
local last, this = {}, {}
function module:CompareStrDiff(sA, sB) -- arrays of bytes
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

function module:GetFilterResult(event, msg, name, flag, guid)
	if name == DB.MyName or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGUIDInGroup(guid)) then
		return
	end

	if C.db["Chat"]["BlockStranger"] and event == "CHAT_MSG_WHISPER" then -- Block strangers
		module.MuteThisTime = true
		return true
	end

	if C.db["Chat"]["BlockSpammer"] and C.BadBoys[name] and C.BadBoys[name] >= 5 then return true end

	local filterMsg = gsub(msg, "|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = gsub(filterMsg, symbol, "")
	end

	if event == "CHAT_MSG_CHANNEL" then
		local matches = 0
		local found
		for keyword in pairs(WhiteFilterList) do
			if keyword ~= "" then
				found = true
				local _, count = gsub(filterMsg, keyword, "")
				if count > 0 then
					matches = matches + 1
				end
			end
		end
		if matches == 0 and found then
			return 0
		end
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

	if matches >= C.db["Chat"]["Matches"] then
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
	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") then return end

	for _, word in ipairs(addonBlockList) do
		if strfind(msg, word) then
			if event == "CHAT_MSG_SAY" or event == "CHAT_MSG_YELL" then
				module:ToggleChatBubble()
			elseif event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
				module:ToggleChatBubble(true)
			elseif event == "CHAT_MSG_WHISPER" then
				module.MuteThisTime = true
			end
			return true
		end
	end
end

-- Block trash clubs
local trashClubs = {"站桩", "致敬我们", "我们一起玩游戏", "部落大杂烩", "小号提升"}
function module:BlockTrashClub()
	if self.toastType == BN_TOAST_TYPE_CLUB_INVITATION then
		local text = self.DoubleLine:GetText() or ""
		for _, name in pairs(trashClubs) do
			if strfind(text, name) then
				self:Hide()
				return
			end
		end
	end
end

-- Show itemlevel on chat hyperlinks
local function isItemHasLevel(link)
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR) then
		local itemLevel = B.GetItemLevel(link)
		return name, itemLevel
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
	["PUNCHCARDBLUE"] = true,
	["PUNCHCARDRED"] = true,
	["PUNCHCARDYELLOW"] = true,
	["DOMINATION"] = true,
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

	hooksecurefunc(BNToastFrame, "ShowToast", self.BlockTrashClub)

	if IsAddOnLoaded("EnhancedChatFilter") then return end

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
end