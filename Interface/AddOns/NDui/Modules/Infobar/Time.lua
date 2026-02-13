local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Time then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Time", C.Infobar.TimePos)
local time, date = time, date
local strfind, format, floor, strmatch = strfind, format, floor, strmatch
local mod, tonumber, pairs, ipairs = mod, tonumber, pairs, ipairs
local IsShiftKeyDown = IsShiftKeyDown
local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_Calendar_GetDayEvent = C_Calendar.GetDayEvent
local C_Calendar_SetAbsMonth = C_Calendar.SetAbsMonth
local C_Calendar_OpenCalendar = C_Calendar.OpenCalendar
local C_Calendar_GetNumDayEvents = C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_AreaPoiInfo_GetAreaPOISecondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft
local TIMEMANAGER_TICKER_24HOUR, TIMEMANAGER_TICKER_12HOUR = TIMEMANAGER_TICKER_24HOUR, TIMEMANAGER_TICKER_12HOUR
local FULLDATE, CALENDAR_WEEKDAY_NAMES, CALENDAR_FULLDATE_MONTH_NAMES = FULLDATE, CALENDAR_WEEKDAY_NAMES, CALENDAR_FULLDATE_MONTH_NAMES
local PLAYER_DIFFICULTY_TIMEWALKER, RAID_INFO_WORLD_BOSS, DUNGEON_DIFFICULTY3 = PLAYER_DIFFICULTY_TIMEWALKER, RAID_INFO_WORLD_BOSS, DUNGEON_DIFFICULTY3
local DUNGEONS, RAID_INFO, QUESTS_LABEL, QUEST_COMPLETE = DUNGEONS, RAID_INFO, QUESTS_LABEL, QUEST_COMPLETE
local QUEUE_TIME_UNAVAILABLE, RATED_PVP_WEEKLY_VAULT = QUEUE_TIME_UNAVAILABLE, RATED_PVP_WEEKLY_VAULT
local RequestRaidInfo, GetNumSavedWorldBosses, GetSavedWorldBossInfo = RequestRaidInfo, GetNumSavedWorldBosses, GetSavedWorldBossInfo
local GetCVarBool, GetGameTime, GameTime_GetLocalTime, GameTime_GetGameTime, SecondsToTime = GetCVarBool, GetGameTime, GameTime_GetLocalTime, GameTime_GetGameTime, SecondsToTime
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_AreaPoiInfo_GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
-- Localized
local COMMUNITY_FEAST = C_Spell.GetSpellName(388961)
local PROGRESS_FORMAT = " |cff%s(%s/%s)|r"

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = DB.MyColor..(hour < 12 and "AM" or "PM")
		if hour > 12 then hour = hour - 12 end
		return format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 3) + elapsed
	if self.timer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""

		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		self.text:SetText(updateTimerFormat(color, hour, minute))

		self.timer = 0
	end
end

-- Data
local isTimeWalker, walkerTexture
local function checkTimeWalker(event)
	local date = C_DateAndTime_GetCurrentCalendarTime()
	C_Calendar_SetAbsMonth(date.month, date.year)
	C_Calendar_OpenCalendar()

	local today = date.monthDay
	local numEvents = C_Calendar_GetNumDayEvents(0, today)
	if numEvents <= 0 then return end

	for i = 1, numEvents do
		local info = C_Calendar_GetDayEvent(0, today, i)
		if info and B:NotSecretValue(info.title) and strfind(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= "END" then
			isTimeWalker = true
			walkerTexture = info.iconTexture
			break
		end
	end
	B:UnregisterEvent(event, checkTimeWalker)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", checkTimeWalker)

local function checkTexture(texture)
	if not walkerTexture then return end
	if walkerTexture == texture or walkerTexture == texture - 1 then
		return true
	end
end

local questlist = {
	{name = L["Mean One"], id = 6983},
	{name = L["Blingtron"], id = 34774},
	{name = L["Timewarped"], id = 83285, texture = 6006158},	-- Vanilla
	{name = L["Timewarped"], id = 40168, texture = 1129674},	-- TBC
	{name = L["Timewarped"], id = 40173, texture = 1129686},	-- WotLK
	{name = L["Timewarped"], id = 40786, texture = 1304688},	-- Cata
	{name = L["Timewarped"], id = 45563, texture = 1530590},	-- MoP
	{name = L["Timewarped"], id = 55499, texture = 1129683},	-- WoD
	{name = L["Timewarped"], id = 64710, texture = 1467047},	-- Legion
	{name = C_Spell.GetSpellName(388945), id = 70866},	-- SoDK
	{name = "", id = 70906, itemID = 200468},	-- Grand hunt
	{name = "", id = 70893, questName = true},	-- Community feast
	{name = "", id = 79226, questName = true},	-- The big dig
	{name = "", id = 78319, questName = true},	-- The superbloom
	{name = "", id = 76586, questName = true},	-- 散步圣光
	{name = "", id = 82946, questName = true},	-- 蜡团
	{name = "", id = 83240, questName = true},	-- 剧场
	{name = C_Map.GetAreaInfo(15141), id = 83333},	-- 觉醒主机
}

local delvesKeys = {91175, 91176, 91177, 91178}
local keyName = C_CurrencyInfo.GetCurrencyInfo(3028).name

-- Check Invasion Status
local region = GetCVar("portal")
local legionZoneTime = {
	["EU"] = 1762434000, -- 2025-11-06 13:00 UTC+0
	["US"] = 1762421400, -- 2025-11-06 01:30 UTC-8
	["CN"] = 1762450200, -- CN time 11/7/2025 01:30 [1]
}
local bfaZoneTime = {
	["CN"] = 1546743600, -- CN time 1/6/2019 11:00 [1]
	["EU"] = 1546768800, -- CN+7
	["US"] = 1546769340, -- CN+16
}

local invIndex = {
	[1] = {title = L["Legion Invasion"], duration = 52200, maps = {630, 641, 650, 634}, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"]},
	[2] = {title = L["BfA Invasion"], duration = 68400, maps = {862, 863, 864, 896, 942, 895}, timeTable = {4, 1, 6, 2, 5, 3}, baseTime = bfaZoneTime[region] or bfaZoneTime["CN"]},
}

local mapAreaPoiIDs = {
	[630] = 5175,
	[641] = 5210,
	[650] = 5177,
	[634] = 5178,
	[862] = 5973,
	[863] = 5969,
	[864] = 5970,
	[896] = 5964,
	[942] = 5966,
	[895] = 5896,
}

local function getInvasionInfo(mapID)
	local areaPoiID = mapAreaPoiIDs[mapID]
	local seconds = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID)
	local mapInfo = C_Map_GetMapInfo(mapID)
	return seconds, mapInfo.name
end

local function CheckInvasion(index)
	for _, mapID in pairs(invIndex[index].maps) do
		local timeLeft, name = getInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, name
		end
	end
end

local function GetNextTime(baseTime, index)
	local currentTime = time()
	local duration = invIndex[index].duration
	local elapsed = mod(currentTime - baseTime, duration)
	return duration - elapsed + currentTime
end

local function GetNextLocation(nextTime, index)
	local inv = invIndex[index]
	local count = #inv.timeTable
	if count == 0 then return QUEUE_TIME_UNAVAILABLE end

	local elapsed = nextTime - inv.baseTime
	local round = mod(floor(elapsed / inv.duration) + 1, count)
	if round == 0 then round = count end
	return C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

-- Grant hunts
local huntAreaToMapID = { -- 狩猎区域ID转换为地图ID
	[7342] = 2023, -- 欧恩哈拉平原
	[7343] = 2022, -- 觉醒海岸
	[7344] = 2025, -- 索德拉苏斯
	[7345] = 2024, -- 碧蓝林海
}

-- Elemental invasion
local stormPoiIDs = {
	[2022] = {
		{7249, 7250, 7251, 7252},
		{7253, 7254, 7255, 7256},
		{7257, 7258, 7259, 7260},
	},
	[2023] = {
		{7221, 7222, 7223, 7224},
		{7225, 7226, 7227, 7228},
	},
	[2024] = {
		{7229, 7230, 7231, 7232},
		{7233, 7234, 7235, 7236},
		{7237, 7238, 7239, 7240},
	},
	[2025] = {
		{7245, 7246, 7247, 7248},
		{7298, 7299, 7300, 7301},
	},
	--[2085] = {
	--	{7241, 7242, 7243, 7244},
	--},
}

local atlasCache = {}
local function GetElementalType(element) -- 获取入侵类型图标
	local str = atlasCache[element]
	if not str then
		local info = C_Texture.GetAtlasInfo("ElementalStorm-Lesser-"..element)
		if info then
			str = B:GetTextureStrByAtlas(info, 16, 16)
			atlasCache[element] = str
		end
	end
	return str
end

local function GetFormattedTimeLeft(timeLeft)
	return format("%.2d:%.2d", timeLeft/60, timeLeft%60)
end

local itemCache = {}
local function GetItemLink(itemID)
	local link = itemCache[itemID]
	if not link then
		link = select(2, C_Item.GetItemInfo(itemID))
		itemCache[itemID] = link
	end
	return link
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text..":", .6,.8,1)
		title = true
	end
end

info.onShiftDown = function()
	if info.entered then
		info:onEnter()
	end
end

local communityFeastTime = {
	["CN"] = 1679747400, -- 20:30
	["TW"] = 1679747400, -- 20:30
	["KR"] = 1679747400, -- 20:30
	["EU"] = 1679749200, -- 21:00
	["US"] = 1679751000, -- 21:30
}

local delveList = {
	{uiMapID = 2248, delveID = 7787}, -- Earthcrawl Mines
	{uiMapID = 2248, delveID = 7781}, -- Kriegval's Rest
	{uiMapID = 2248, delveID = 7779}, -- Fungal Folly
	{uiMapID = 2215, delveID = 7789}, -- Skittering Breach
	{uiMapID = 2215, delveID = 7785}, -- Nightfall Sanctum
	{uiMapID = 2215, delveID = 7783}, -- The Sinkhole
	{uiMapID = 2215, delveID = 7780}, -- Mycomancer Cavern
	{uiMapID = 2214, delveID = 7782}, -- The Waterworks
	{uiMapID = 2214, delveID = 7788}, -- The Dread Pit
	{uiMapID = 2214, delveID = 8181}, -- Excavation Site 9
	{uiMapID = 2255, delveID = 7790}, -- The Spiral Weave
	{uiMapID = 2255, delveID = 7784}, -- Tak-Rethan Abyss
	{uiMapID = 2255, delveID = 7786}, -- The Underkeep
	{uiMapID = 2346, delveID = 8246}, -- Sidestree Sluice
	{uiMapID = 2371, delveID = 8273}, -- Archival Assault
}

info.onEnter = function(self)
	self.entered = true

	RequestRaidInfo()

	local r,g,b
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0,.6,1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), .6,.8,1 ,1,1,1)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), .6,.8,1 ,1,1,1)

	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1,1,1, 1,1,1)
		end
	end

	-- Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
		if diff == 23 and (locked or extended) then
			addTitle(DUNGEON_DIFFICULTY3..DUNGEONS)
			if extended then r,g,b = .3,1,.3 else r,g,b = 1,1,1 end
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1,1,1, r,g,b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numBosses, progress = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			addTitle(RAID_INFO)
			if extended then r,g,b = .3,1,.3 else r,g,b = 1,1,1 end
			local progressColor = (numBosses == progress) and "ff0000" or "00ff00"
			local progressStr = format(PROGRESS_FORMAT, progressColor, progress, numBosses)
			GameTooltip:AddDoubleLine(name.." - "..diffName..progressStr, SecondsToTime(reset, true, nil, 3), 1,1,1, r,g,b)
		end
	end

	-- Quests
	title = false
	for _, v in pairs(questlist) do
		if v.name and IsQuestFlaggedCompleted(v.id) then
			if v.name == L["Timewarped"] and isTimeWalker and checkTexture(v.texture) or v.name ~= L["Timewarped"] then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine((v.itemID and GetItemLink(v.itemID)) or (v.questName and QuestUtils_GetQuestName(v.id)) or v.name, QUEST_COMPLETE, 1,1,1, 1,0,0)
			end
		end
	end
	local currentKeys, maxKeys = 0, #delvesKeys
	for _, questID in pairs(delvesKeys) do
		if IsQuestFlaggedCompleted(questID) then
			currentKeys = currentKeys + 1
		end
	end
	if currentKeys > 0 then
		addTitle(QUESTS_LABEL)
		if currentKeys == maxKeys then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
		GameTooltip:AddDoubleLine(keyName, format("%d/%d", currentKeys, #delvesKeys), 1,1,1, r,g,b)
	end

	-- Delves
	title = false
	for _, v in pairs(delveList) do
		local delveInfo = C_AreaPoiInfo_GetAreaPOIInfo(v.uiMapID, v.delveID)
		if delveInfo then
			addTitle(delveInfo.description)
			local mapInfo = C_Map_GetMapInfo(v.uiMapID)
			GameTooltip:AddDoubleLine(mapInfo.name.." - "..delveInfo.name, SecondsToTime(GetQuestResetTime(), true, nil, 3), 1,1,1, 1,1,1)
		end
	end

	if IsShiftKeyDown() then
		-- Elemental threats
		title = false
		for mapID, stormGroup in next, stormPoiIDs do
			for _, areaPoiIDs in next, stormGroup do
				for _, areaPoiID in next, areaPoiIDs do
					local poiInfo = C_AreaPoiInfo_GetAreaPOIInfo(mapID, areaPoiID)
					local elementType = poiInfo and poiInfo.atlasName and strmatch(poiInfo.atlasName, "ElementalStorm%-Lesser%-(.+)")
					if elementType then
						addTitle(poiInfo.name)
						local mapInfo = C_Map_GetMapInfo(mapID)
						local timeLeft = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID) or 0
						timeLeft = timeLeft/60
						if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
						GameTooltip:AddDoubleLine(mapInfo.name..GetElementalType(elementType), GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
						break
					end
				end
			end
		end
	
		-- Grand hunts
		title = false
		for areaPoiID, mapID in pairs(huntAreaToMapID) do
			local poiInfo = C_AreaPoiInfo_GetAreaPOIInfo(1978, areaPoiID) -- Dragon isles
			if poiInfo then
				addTitle(poiInfo.name)
				local mapInfo = C_Map_GetMapInfo(mapID)
				local timeLeft = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID) or 0
				timeLeft = timeLeft/60
				if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
				GameTooltip:AddDoubleLine(mapInfo.name, GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
				break
			end
		end
	
		-- Community feast
		title = false
		local feastTime = communityFeastTime[region]
		if feastTime then
			local currentTime = time()
			local duration = 5400 -- 1.5hrs
			local elapsed = mod(currentTime - feastTime, duration)
			local nextTime = duration - elapsed + currentTime
	
			addTitle(COMMUNITY_FEAST)
			if currentTime - (nextTime-duration) < 900 then r,g,b = 0,1,0 else r,g,b = .6,.6,.6 end -- green text if progressing
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime-duration*2), date("%m/%d %H:%M", nextTime-duration), .6,.6,.6, r,g,b)
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime), date("%m/%d %H:%M", nextTime+duration), 1,1,1, 1,1,1)
		end

		-- Invasions
		for index, value in ipairs(invIndex) do
			title = false
			addTitle(value.title)
			local timeLeft, zoneName = CheckInvasion(index)
			local nextTime = GetNextTime(value.baseTime, index)
			if timeLeft then
				timeLeft = timeLeft/60
				if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
				GameTooltip:AddDoubleLine(L["Current Invasion"]..zoneName, GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
			end
			local nextLocation = GetNextLocation(nextTime, index)
			GameTooltip:AddDoubleLine(L["Next Invasion"]..nextLocation, date("%m/%d %H:%M", nextTime), 1,1,1, 1,1,1)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Hold Shift"], .6,.8,1)
	end

	-- Help Info
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Toggle Calendar"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..RATED_PVP_WEEKLY_VAULT.." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Toggle Clock"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()

	B:RegisterEvent("MODIFIER_STATE_CHANGED", info.onShiftDown)
end

info.onLeave = function(self)
	self.entered = true
	B.HideTooltip()
	B:UnregisterEvent("MODIFIER_STATE_CHANGED", info.onShiftDown)
end

info.onMouseUp = function(_, btn)
	if btn == "RightButton" then
		ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not WeeklyRewardsFrame then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end
		if InCombatLockdown() then
			B:TogglePanel(WeeklyRewardsFrame)
		else
			ToggleFrame(WeeklyRewardsFrame)
		end
		local dialog = WeeklyRewardExpirationWarningDialog
		if dialog and dialog:IsShown() then
			dialog:Hide()
		end
	else
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleCalendar()
	end
end