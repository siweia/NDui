local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local strmatch, strfind = string.match, string.find
local format, gsub = string.format, string.gsub
local pairs, ipairs = pairs, ipairs

-- Filter Chat symbols
local msgSymbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~", "%-", "%."}

local FilterList = {}
function B:GenFilterList()
	B.SplitList(FilterList, NDuiADB["ChatFilterList"], true)
end

local function genChatFilter(_, event, msg, author, _, _, _, flag, _, _, _, _, _, guid)
	if not NDuiDB["Chat"]["EnableFilter"] then return end

	local name = Ambiguate(author, "none")
	if UnitIsUnit(name, "player") or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		return
	elseif guid and (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or IsCharacterFriend(guid) or IsGUIDInGroup(guid)) then
		return
	end

	for _, symbol in ipairs(msgSymbols) do
		msg = gsub(msg, symbol, "")
	end

	local match = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = gsub(msg, keyword, "")
			if count > 0 then
				match = match + 1
			end
		end
	end

	if match >= NDuiDB["Chat"]["Matches"] then
		return true
	end
end

local addonBlockList = {
	"任务进度提示%s?[:：]", "%[接受任务%]", "%(任务完成%)", "<大脚组队提示>", "<大脚团队提示>", "【爱不易】", "EUI:", "EUI_RaidCD", "打断:.+|Hspell", "PS 死亡: .+>", "%*%*.+%*%*",
	"<iLvl>", ("%-"):rep(30), "<小队物品等级:.+>", "<LFG>", "进度:", "属性通报", "blizzard.+验证码", "汐寒"
}

local function restoreCVar(cvar)
	C_Timer.After(.01, function()
		SetCVar(cvar, 1)
	end)
end

local function toggleBubble(party)
	local cvar = "chatBubbles"..(party and "Party" or "")
	if not GetCVarBool(cvar) then return end
	SetCVar(cvar, 0)
	restoreCVar(cvar)
end

local function genAddonBlock(_, event, msg, author)
	if not NDuiDB["Chat"]["BlockAddonAlert"] then return end

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
	公会频道有人@时提示你
]]
local chatAtList, at = {}, {}
function B:GenChatAtList()
	B.SplitList(chatAtList, NDuiADB["ChatAtList"], true)

	chatAtList[DB.MyName] = true
end

local function chatAtMe(_, _, ...)
	local msg, author, _, _, _, _, _, _, _, _, _, guid = ...
	for word in pairs(chatAtList) do
		if word ~= "" then
			if strmatch(msg:lower(), "@"..word:lower()) then
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
		self.DoubleLine:SetText(format("%s "..DB.InfoColor.."@"..YOU.."! ("..GUILD..")", hexColor..Ambiguate(at.author, "short")))
		at.checker = false
	end
end)

--[[
	过滤WQT的邀请
	Credit: WorldQuestTrackerBlocker, Jordy141
]]
local WQTUsers = {}
local inviteString = _G.ERR_INVITED_TO_GROUP_SS:gsub(".+|h", "")

local function blockInviteString(_, _, msg)
	if strfind(msg, inviteString) then
		local name = strmatch(msg, "%[(.+)%]")
		if WQTUsers[name] then
			return true
		end
	end
end

local function blockWhisperString(_, _, msg, author)
	local name = Ambiguate(author, "none")
	if strfind(msg, "%[World Quest Tracker%]") or strfind(msg, "一起做世界任务吧：") or strfind(msg, "一起来做世界任务<") then
		if not WQTUsers[name] then
			WQTUsers[name] = true
		end
		return true
	end
end

local function hideInvitePopup(_, name)
	if WQTUsers[name] then
		StaticPopup_Hide("PARTY_INVITE")
	end
end

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
	B:GenFilterList()
	B:GenChatAtList()

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", genChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", genChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", genChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", genChatFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", genChatFilter)

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

	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", chatAtMe)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", blockInviteString)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", blockWhisperString)
	B:RegisterEvent("PARTY_INVITE_REQUEST", hideInvitePopup)

	B:RegisterEvent("PLAYER_ENTERING_WORLD", isPlayerOnIslands)
end