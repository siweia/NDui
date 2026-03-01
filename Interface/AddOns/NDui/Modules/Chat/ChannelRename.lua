local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local gsub, strfind, strmatch = string.gsub, string.find, string.match
local BetterDate, time, date, GetCVarBool = BetterDate, time, date, GetCVarBool
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

local PARTY_LEADER = strmatch(CHAT_PARTY_LEADER_GET, "|h%[(.-)%]|h")
local PARTY_GUIDE = strmatch(CHAT_PARTY_GUIDE_GET, "|h%[(.-)%]|h")
local RAID_LEADER = strmatch(CHAT_RAID_LEADER_GET, "|h%[(.-)%]|h")
local INSTANCE_LEADER = strmatch(CHAT_INSTANCE_CHAT_LEADER_GET, "|h%[(.-)%]|h")

local matchPattern = "(|H(%w+):?(%w+):?(%d*)|h)%[(.-)%]|h"

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
	INSTANCE_CHAT = true,
}

local cnColonChannels = {
	SAY = true,
	YELL = true,
	WHISPER = true,
	GUILD = true,
	OFFICER = true,
	CHANNEL = true,
}

local cnPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%])(.-)"..colon.."%s"
local enPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%])(.-):%s"

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

function module:UpdateChannelNames(text, r, g, b, ...)
	if not text or B:IsSecretValue(text) then
		return self:oldAddMsg(text, r, g, b, ...)
	end

	if strfind(text, INTERFACE_ACTION_BLOCKED) and not DB.isDeveloper then return end

	-- Timestamp
	if NDuiADB["TimestampFormat"] > 1 then
		local locTime, realmTime = GetCurrentTime()
		local defaultTimestamp = GetCVar("showTimestamps")
		if defaultTimestamp == "none" then defaultTimestamp = nil end
		local oldTimeStamp = defaultTimestamp and gsub(BetterDate(defaultTimestamp, locTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = gsub(text, oldTimeStamp, "")
		end
		local timeStamp = BetterDate(DB.GreyColor..timestampFormat[NDuiADB["TimestampFormat"]].."|r", realmTime or locTime)
		text = timeStamp..text
	end

	text = gsub(text, "(|Hplayer:([^|:]+))", AddAuthorLogo)
	--if isCN then
	--	text = gsub(text, cnPattern, KillCNColon) -- 干掉全角冒号及说/大喊
	--end
	--text = gsub(text, enPattern, KillColon) -- 干掉半角冒号及说/大喊
	--text = gsub(text, "(|Hplayer:.-)%[(.-)%]", "%1%2") -- 干掉名字方括号
	text = gsub(text, matchPattern, AbbrChannelName)

	return self:oldAddMsg(text, r, g, b, ...)
end

function module:ChannelRename()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame"..i]
			chatFrame.oldAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = module.UpdateChannelNames
		end
	end
end