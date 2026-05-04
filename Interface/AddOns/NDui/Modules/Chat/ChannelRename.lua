local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local gsub, strfind, strmatch, format, strsub, strlen = string.gsub, string.find, string.match, string.format, string.sub, string.len
local BetterDate, time, date, GetCVarBool = BetterDate, time, date, GetCVarBool
local RemoveExtraSpaces = RemoveExtraSpaces
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local colon = HEADER_COLON
local isCN = strlen(colon) > 1

-- Timestamp
local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

local function GetCurrentTime()
	local locTime = time()
	local realmTime = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()
	if realmTime then
		realmTime.day = realmTime.monthDay
		realmTime.min = realmTime.minute
		realmTime.sec = date("%S") -- no sec value for realm time
		realmTime = time(realmTime)
	end

	return locTime, realmTime
end

-- Author Logo
local function AddAuthorLogo(link, unitName)
	if unitName and DB.Devs[unitName] then
		return "|T"..DB.chatLogo..":12:24|t"..link
	end
	return link
end

-- Channel name abbr
local LEADERSHIP = {
	PartyLeader = strmatch(CHAT_PARTY_LEADER_GET, "|h%[(.-)%]|h"),
	PartyGuide = strmatch(CHAT_PARTY_GUIDE_GET, "|h%[(.-)%]|h"),
	RaidLeader = strmatch(CHAT_RAID_LEADER_GET, "|h%[(.-)%]|h"),
	InstLeader = strmatch(CHAT_INSTANCE_CHAT_LEADER_GET, "|h%[(.-)%]|h"),
}

local CHANNEL_ABBR = {
	PARTY = {
		abbr = "P",
		leaders = {
			[LEADERSHIP.PartyLeader] = "PL",
			[LEADERSHIP.PartyGuide] = "PG",
		},
	},
	RAID = {
		abbr = "R",
		leaders = {
			[LEADERSHIP.RaidLeader] = "RL",
		},
	},
	INSTANCE_CHAT = {
		abbr = "I",
		leaders = {
			[LEADERSHIP.InstLeader] = "IL",
		},
	},
	GUILD = { abbr = "G" },
	OFFICER = { abbr = "O" },
}

local CHANNEL_ABBR_LOCALES = {
	PARTY = {
		abbr = L["PartyAbbr"],
		leaders = {
			[LEADERSHIP.PartyLeader] = L["PartyLeaderAbbr"],
			[LEADERSHIP.PartyGuide]  = L["PartyGuideAbbr"],
		},
	},
	RAID = {
		abbr = L["RaidAbbr"],
		leaders = {
			[LEADERSHIP.RaidLeader] = L["RaidLeaderAbbr"],
		},
	},
	INSTANCE_CHAT = {
		abbr = L["InstAbbr"],
		leaders = {
			[LEADERSHIP.InstLeader] = L["InstLeaderAbbr"],
		},
	},
	GUILD = { abbr = L["GuildAbbr"] },
	OFFICER = { abbr = L["OfficerAbbr"] },
}

local matchPattern = "(|H(%w+):?([^:]+):?(%d*)|h)%[(.-)%]|h"

local function AbbrChannelName(prefix, linkType, channel, channelID, channelName)
	if C.db["Chat"]["ChannelAbbr"] == 1 then return end

	if linkType ~= "channel" then return end

	if channel == "channel" then
		return prefix.."["..channelID.."]|h"
	end

	local channels = C.db["Chat"]["ChannelAbbr"] == 2 and CHANNEL_ABBR or CHANNEL_ABBR_LOCALES
	local data = channels[channel]
	if not data then
		return prefix.."["..channelName.."]|h"
	end

	local abbr = data.abbr
	local isLeader = data.leaders and data.leaders[channelName]
	if isLeader then
		abbr = isLeader
	end

	return prefix.."["..abbr.."]|h"
end

-- Kill colon before message
local channels = {
	SAY = not isCN,
	YELL = not isCN,
	WHISPER = not isCN,
	GUILD = not isCN,
	OFFICER = not isCN,
	CHANNEL = not isCN,
	PARTY = true,
	RAID = true,
	INSTANCE_CHAT = not isCN,
}

local cnColonChannels = {
	SAY = true,
	YELL = true,
	WHISPER = true,
	GUILD = true,
	OFFICER = true,
	CHANNEL = true,
	PARTY = true,
	RAID = true,
	INSTANCE_CHAT = true,
}

local cnPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%].-)"..colon.."%s"
local enPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%].-):%s"

local function KillColon(link, tag)
	if channels[tag] then
		return link.." "
	end
end

local function KillCNColon(link, tag)
	if cnColonChannels[tag] then
		return link.." "
	end
end

local function convertLink(text, value)
	return "|Hurl:"..tostring(value).."|h"..DB.InfoColor..text.."|r|h"
end

local function highlightURL(_, url)
	return " "..convertLink("["..url.."]", url).." "
end

-- Filter: intercept chat events, build formatted msg, apply modifications, call AddMessage securely
local function ChatMsgFilter(self, event,
	msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID,
	lineID, senderGUID, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, suppressRaidIcons)

	if not msg or B:IsSecretValue(msg) then
		return
	end

	if strfind(msg, INTERFACE_ACTION_BLOCKED) and not DB.isDeveloper then
		return true
	end

	-- URL highlighting (inline, avoid separate filter pass)
	msg = gsub(msg, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)

	-- 1. Get format key (e.g. CHAT_SAY_GET = "%s:\32")
	local chatType = strsub(event, 10)
	local formatKey = _G["CHAT_"..chatType.."_GET"]
	if not formatKey then return end

	-- 2. Get colored name (with class colors etc.)
	local coloredName = ChatFrameUtil.GetDecoratedSenderName(event, msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile)

	-- 3. Get player flags (AFK/DND/GM icons)
	local pflag = ChatFrameUtil.GetPFlag(flags, zoneChannelID, channelIndex)

	-- 4. Build player link
	local playerLink
	if chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
		playerLink = GetBNPlayerLink(sender, "["..coloredName.."]", bnSenderID, lineID, ChatFrameUtil.GetChatCategory(chatType), 0)
	else
		playerLink = GetPlayerLink(sender, "["..coloredName.."]", lineID, ChatFrameUtil.GetChatCategory(chatType), 0)
	end

	-- 5. Build the base message (same as Blizzard's MessageFormatter)
	local msgText = msg
	-- Escape % signs
	msgText = gsub(msgText, "%%", "%%%%")
	-- Replace icon/group expressions
	msgText = C_ChatInfo.ReplaceIconAndGroupExpressions(msgText, suppressRaidIcons)
	-- Remove extra spaces
	msgText = RemoveExtraSpaces(msgText)

	local outMsg = format(formatKey..msgText, pflag..playerLink)

	-- 6. Add channel prefix for custom channels (channelString non-empty)
	local channelLength = strlen(channelString)
	if channelLength > 0 then
		local channelName = ChatFrameUtil.ResolvePrefixedChannelName(channelString)
		if channelName then
			outMsg = "|Hchannel:channel:"..(channelIndex or 0).."|h["..channelName.."]|h "..outMsg
		end
	end

	-- 7. Apply modifications on the formatted text
	-- Timestamp (prefix)
	if NDuiADB["TimestampFormat"] > 1 then
		local locTime, realmTime = GetCurrentTime()
		local timeStamp = BetterDate(DB.GreyColor..timestampFormat[NDuiADB["TimestampFormat"]].."|r", realmTime or locTime)
		outMsg = timeStamp..outMsg
	end

	-- Author Logo
	outMsg = gsub(outMsg, "(|Hplayer:([^|:]+))", AddAuthorLogo)
	-- Kill colon
	if isCN then
		outMsg = gsub(outMsg, cnPattern, KillCNColon)
	end
	outMsg = gsub(outMsg, enPattern, KillColon)
	-- Channel abbreviation
	outMsg = gsub(outMsg, matchPattern, AbbrChannelName)

	-- 8. Get color info and display
	local info = ChatTypeInfo[chatType] or ChatTypeInfo["SYSTEM"]
	self:AddMessage(outMsg, info.r, info.g, info.b, info.id)

	return true
end

function module:ChannelRename()
	local events = {
		"CHAT_MSG_SAY", "CHAT_MSG_YELL",
		"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
		"CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_PARTY_GUIDE",
		"CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
		"CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
		"CHAT_MSG_CHANNEL",
	}
	for _, event in ipairs(events) do
		ChatFrame_AddMessageEventFilter(event, ChatMsgFilter)
	end
end