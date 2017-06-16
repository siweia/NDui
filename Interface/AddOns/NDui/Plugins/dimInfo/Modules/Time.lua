local addon, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Time == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:SetHitRectInsets(0, 0, -10, 0)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.TimePoint))
	Stat:SetAllPoints(Text)

	local int = 1
	local Hr24, Hr, Min
	local function Update(self, t)
		local pendingCalendarInvites = CalendarGetNumPendingInvites()
		int = int - t
		if int < 0 then
			if GetCVar("timeMgrUseLocalTime") == "1" then
				Hr24 = tonumber(date("%H"))
				Hr = tonumber(date("%I"))
				Min = date("%M")
				if GetCVar("timeMgrUseMilitaryTime") == "1" then
					if pendingCalendarInvites > 0 then
					Text:SetText("|cffFF0000"..Hr24..":"..Min)
				else
					Text:SetText(Hr24..":"..Min)
				end
			else
				if Hr24 >= 12 then
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min..init.Colored.."pm|r")
					else
						Text:SetText(Hr..":"..Min..init.Colored.."pm|r")
					end
				else
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min..init.Colored.."am|r")
					else
						Text:SetText(Hr..":"..Min..init.Colored.."am|r")
					end
				end
			end
		else
			Hr, Min = GetGameTime()
			if Min < 10 then Min = "0"..Min end
			if GetCVar("timeMgrUseMilitaryTime") == "1" then
				if pendingCalendarInvites > 0 then			
					Text:SetText("|cffFF0000"..Hr..":"..Min.."|cffffffff|r")
				else
					Text:SetText(Hr..":"..Min.."|cffffffff|r")
				end
			else
				if Hr >= 12 then
					if Hr > 12 then Hr = Hr - 12 end
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min..init.Colored.."pm|r")
					else
						Text:SetText(Hr..":"..Min..init.Colored.."pm|r")
					end
				else
					if Hr == 0 then Hr = 12 end
					if pendingCalendarInvites > 0 then
						Text:SetText("|cffFF0000"..Hr..":"..Min..init.Colored.."am|r")
					else
						Text:SetText(Hr..":"..Min..init.Colored.."am|r")
					end
				end
			end
		end
		int = 1
		end
	end

	-- Data
	local months = {
		MONTH_JANUARY, MONTH_FEBRUARY, MONTH_MARCH,	MONTH_APRIL, MONTH_MAY, MONTH_JUNE,
		MONTH_JULY, MONTH_AUGUST, MONTH_SEPTEMBER, MONTH_OCTOBER, MONTH_NOVEMBER, MONTH_DECEMBER,
	}

	local bonus = {
		43892, 43893, 43894,	-- Order Resources
		43895, 43896, 43897,	-- Gold
		47851, 47864, 47865,	-- Honor Coins
		43510,					-- Orderhall
	}
	local bonusname = GetCurrencyInfo(1273)

	local keystone = GetItemInfo(138019)
	local questlist = {
		{name = keystone, id = 44554},
		{name = infoL["Blingtron"], id = 34774},
		{name = infoL["Mean One"], id = 6983},
		{name = "TBC"..infoL["Timewarped"], id = 40168},
		{name = "WLK"..infoL["Timewarped"], id = 40173},
		{name = "CTM"..infoL["Timewarped"], id = 40786},
		{name = "MOP"..infoL["Timewarped"], id = 45799},
	}

	local invas = {
		{quest = 38482, name = infoL["Platinum Invasion"]},
		{quest = 37640, name = infoL["Gold Invasion"]},
		{quest = 37639, name = infoL["Silver Invasion"]},
		{quest = 37638, name = infoL["Bronze Invasion"]},
	}

	local tanaan = {
		{name = infoL["Deathtalon"], id = 39287},
		{name = infoL["Terrorfist"], id = 39288},
		{name = infoL["Doomroller"], id = 39289},
		{name = infoL["Vengeance"], id = 39290},
	}

	-- Check Invasion Status
	local GetAreaPOITimeLeft = C_WorldMap.GetAreaPOITimeLeft
	local zonePOIIds = {5177, 5178, 5210, 5175}
	local zoneNames = {1024, 1017, 1018, 1015}
	local function OnInvasion()
		for i = 1, #zonePOIIds do
			local timeLeftMinutes = GetAreaPOITimeLeft(zonePOIIds[i])
			if timeLeftMinutes and timeLeftMinutes > 0 and timeLeftMinutes < 361 then
				return timeLeftMinutes, GetMapNameByID(zoneNames[i])
			end
		end
	end

	Stat:SetScript("OnEnter", function(self)
		RequestRaidInfo()

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, -15, 30)
		GameTooltip:ClearLines()
		local w, m, d, y = CalendarGetDate()
		GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], months[m], d, y), 0,.6,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), .6,.8,1 ,1,1,1)
		GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), .6,.8,1 ,1,1,1)

		local title
		local function AddTitle(text)
			if not title then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(text, .6,.8,1)
				title = true
			end
		end

		-- World bosses
		for i = 1, GetNumSavedWorldBosses() do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				AddTitle(RAID_INFO_WORLD_BOSS)
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1,1,1, 1,1,1)
			end
		end

		-- Mythic Dungeons
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
			if diff == 23 and (locked or extended) then
				AddTitle(DUNGEON_DIFFICULTY3..DUNGEONS)
				local r,g,b
				if extended then r,g,b = .3,1,.3 else r,g,b = 1,1,1 end
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1,1,1, r,g,b)
			end
		end

		-- Raids
		title = false
		for i = 1, GetNumSavedInstances() do
			local name, _, reset, _, locked, extended, _, isRaid, _, diffName = GetSavedInstanceInfo(i)
			if isRaid and (locked or extended) then
				AddTitle(RAID_INFO)
				local r,g,b
				if extended then r,g,b = .3,1,.3 else r,g,b = 1,1,1 end
				GameTooltip:AddDoubleLine(name.." - "..diffName, SecondsToTime(reset, true, nil, 3), 1,1,1, r,g,b)
			end
		end

		-- Quests
		title = false
		local count = 0
		for _, id in pairs(bonus) do
			if IsQuestFlaggedCompleted(id) then
				count = count + 1
			end
		end
		if count > 0 then
			AddTitle(QUESTS_LABEL)
			local r,g,b
			if count == 3 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
			GameTooltip:AddDoubleLine(bonusname, count.." / 3", 1,1,1, r,g,b)
		end

		for _, index in pairs(questlist) do
			if index.name and IsQuestFlaggedCompleted(index.id) then
				AddTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(index.name, QUEST_COMPLETE, 1,1,1, 1,0,0)
			end
		end

		for _, v in pairs(invas) do
			if v.quest and IsQuestFlaggedCompleted(v.quest) then
				AddTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(v.name, QUEST_COMPLETE, 1,1,1, 1,0,0)
				break
			end
		end

		-- Tanaan rares
		title = false
		for _, boss in pairs(tanaan) do
			if boss.name and IsQuestFlaggedCompleted(boss.id) then
				AddTitle(infoL["Tanaan"])
				GameTooltip:AddDoubleLine(boss.name, BOSS_DEAD, 1,1,1, 1,0,0)
			end
		end

		-- Legion Invasion
		title = false

		local nextTime
		if OnInvasion() then
			local timeLeft = OnInvasion()
			local elapsed = 360 - timeLeft
			local startTime = time() - elapsed*60
			nextTime = date("%m/%d %H:%M", startTime + 66600)
			diminfo.prevInvasion = startTime
		elseif diminfo.prevInvasion then
			local elapsed = time() - diminfo.prevInvasion
			while elapsed > 66600 do
				elapsed = elapsed - 66600
			end
			nextTime = date("%m/%d %H:%M", 66600 - elapsed + time())
		end

		if nextTime then
			AddTitle(infoL["Legion Invasion"])
			if OnInvasion() then
				local timeLeft, zoneName = OnInvasion()
				local r,g,b
				if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
				GameTooltip:AddDoubleLine(zoneName, format("%.2d:%.2d", timeLeft/60, timeLeft%60), 1,1,1, r,g,b)
			end
			GameTooltip:AddDoubleLine(infoL["Next Invasion"], nextTime, 1,1,1, 1,1,1)
		end

		-- Help Info
		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..infoL["Toggle Calendar"], 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", init.RightButton..infoL["Toggle Clock"], 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)

	Stat:SetScript("OnLeave", GameTooltip_Hide)
	Stat:SetScript("OnUpdate", Update)
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton"  then				
			ToggleTimeManager()
		else
			GameTimeFrame:Click()
		end
	end)
	Update(Stat, 10)
end