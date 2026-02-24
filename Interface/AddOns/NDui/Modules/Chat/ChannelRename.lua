local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local gsub, strfind, strmatch = string.gsub, string.find, string.match
local BetterDate, time, date, GetCVarBool = BetterDate, time, date, GetCVarBool
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local isCNClient = strlen(HEADER_COLON) > 1

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

local function AddAuthorLogo(link, unitName)
    if unitName and DB.Devs[unitName] then
        return "|T"..DB.chatLogo..":12:24|t"..link
    end
end

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

--local WHISPER_FROM = format(CHAT_WHISPER_GET, "(|Hplayer:.-)%[(.-)%]")
--local WHISPER_TELL = format(CHAT_BN_WHISPER_INFORM_GET, "(|Hplayer:.-)%[(.-)%]")

local WHISPER_FROM = gsub(CHAT_WHISPER_GET, "%%s", "")
WHISPER_FROM = gsub(WHISPER_FROM, HEADER_COLON, "")
local WHISPER_TELL = gsub(CHAT_WHISPER_INFORM_GET, "%%s", "")
WHISPER_TELL = gsub(WHISPER_TELL, HEADER_COLON, "")



function module:UpdateChannelNames(text, r, g, b, ...)
	if not text or B:IsSecretValue(text) then
		return self:oldAddMsg(text, r, g, b, ...)
	end

	if strfind(text, INTERFACE_ACTION_BLOCKED) and not DB.isDeveloper then return end

	-- Diff whisper color
	if C.db["Chat"]["WhisperColor"] and strfind(text, L["Tell"].." |H[BN]*player.+%]") then
		r, g, b = r*.7, g*.7, b*.7
	end

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

--[[	text = gsub(text, "|H(%w+):(.-)|h", function(...)
		print(...)
	end)]]
	text = gsub(text, "(%s.-)(|Hplayer:.-%])", function(whisper, link)
		if strfind(whisper, WHISPER_TELL) then
			return L["Tell"]..link
		elseif strfind(WHISPER_TELL, whisper) then
			return L["Tell"]..link
		end
	end)
	text = gsub(text, "(|Hplayer:([^|:]+))", AddAuthorLogo)
	text = gsub(text, "(|Hplayer.-):%s", "%1 ") -- 干掉半角冒号
	if isCNClient then
		text = gsub(text, "(|Hplayer.-)"..HEADER_COLON, "%1") -- 干掉全角冒号
	end
	text = gsub(text, "(|Hplayer:.-)%[(.-)%]", "%1%2") -- 干掉名字方括号
	text = gsub(text, matchPattern, AbbrChannelName)
	--[[text = gsub(text, "(|Hplayer:.-%])(.-%s)", function(link, whisper)
		if strfind(whisper, WHISPER_FROM) then
			return L["From"]..link
		end
	end)]]
--	text = gsub(text, WHISPER_TELL, function() print(2) end)

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