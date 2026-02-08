local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local format, floor = string.format, math.floor
local AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL = AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX or 10
local UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer = UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer
local UnitHealth, UnitHealthMax, UnitPower, UnitPowerType = UnitHealth, UnitHealthMax, UnitPower, UnitPowerType
local UnitClass, UnitReaction, UnitLevel, UnitClassification = UnitClass, UnitReaction, UnitLevel, UnitClassification
local UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost = UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetSpellInfo, UnitIsFeignDeath = GetSpellInfo, UnitIsFeignDeath

local FEIGN_DEATH
local function GetFeignDeathTag()
	if not FEIGN_DEATH then
		FEIGN_DEATH = GetSpellInfo(5384)
	end
	return FEIGN_DEATH
end

local function ColorPercent(value)
	local r, g, b
	if value < 20 then
		r, g, b = 1, .1, .1
	elseif value < 35 then
		r, g, b = 1, .5, 0
	elseif value < 80 then
		r, g, b = 1, .9, .3
	else
		r, g, b = 1, 1, 1
	end
	return B.HexRGB(r, g, b)..value
end

local function ValueAndPercent(cur, per)
	if per < 100 then
		return B.Numb(cur).." | "..ColorPercent(per)
	else
		return B.Numb(cur)
	end
end

local function GetCurrentAndMax(cur, max)
	if cur == max then
		return B.Numb(max)
	else
		return B.Numb(cur).." | "..B.Numb(max)
	end
end

oUF.Tags.Methods["VariousHP"] = function(unit, _, arg1)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or UnitIsFeignDeath(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	end

	if not arg1 then return end
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local per = max == 0 and 0 or B:Round(cur/max * 100, 1)

	if arg1 == "currentpercent" then
		return ValueAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return GetCurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return B.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and ColorPercent(per)
	elseif arg1 == "loss" then
		local loss = max - cur
		return loss ~= 0 and B.Numb(loss)
	elseif arg1 == "losspercent" then
		local loss = max - cur
		return loss ~= 0 and B:Round(loss/max*100, 1)
	end
end
oUF.Tags.Events["VariousHP"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["VariousMP"] = function(unit, _, arg1)
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local per = max == 0 and 0 or B:Round(cur/max * 100)

	if arg1 == "currentpercent" then
		return ValueAndPercent(cur, per)
	elseif arg1 == "currentmax" then
		return GetCurrentAndMax(cur, max)
	elseif arg1 == "current" then
		return B.Numb(cur)
	elseif arg1 == "percent" then
		return per < 100 and ColorPercent(per)
	elseif arg1 == "loss" then
		local loss = max - cur
		return loss ~= 0 and B.Numb(loss)
	elseif arg1 == "losspercent" then
		local loss = max - cur
		return loss ~= 0 and B:Round(loss/max*100, 1)
    end
end
oUF.Tags.Events["VariousMP"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	else
		return B.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["afkdnd"] = function(unit)
	if UnitIsAFK(unit) then
		return "|cffCFCFCF <"..AFK..">|r"
	elseif UnitIsDND(unit) then
		return "|cffCFCFCF <"..DND..">|r"
	else
		return ""
	end
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(unit)
	if UnitIsFeignDeath(unit) then
		return "|cff99ccff"..GetFeignDeathTag().."|r"
	elseif UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	local level = UnitLevel(unit)
	local color = B.HexRGB(GetCreatureDifficultyColor(level))
	if level > 0 then
		level = color..level.."|r"
	else
		level = "|cffff0000??|r"
	end
	local str = level

	local class = UnitClassification(unit)
	if not UnitIsConnected(unit) then
		str = "??"
	elseif class == "worldboss" then
		str = "|cffff0000Boss|r"
	elseif class == "rareelite" then
		str = level.."|cff0080ffR|r+"
	elseif class == "elite" then
		str = level.."+"
	elseif class == "rare" then
		str = level.."|cff0080ffR|r"
	end

	return str
end
oUF.Tags.Events["fulllevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- RaidFrame tags
local healthModeType = {
	[2] = "percent",
	[3] = "current",
	[4] = "loss",
	[5] = "losspercent",
}
oUF.Tags.Methods["raidhp"] = function(unit)
	local healthType = healthModeType[C.db["UFs"]["RaidHPMode"]]
	return oUF.Tags.Methods["VariousHP"](unit, _, healthType)
end
oUF.Tags.Events["raidhp"] = oUF.Tags.Events["VariousHP"]

-- Nameplate tags
oUF.Tags.Methods["nppp"] = function(unit)
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	if per > 85 then
		color = B.HexRGB(1, .1, .1)
	elseif per > 50 then
		color = B.HexRGB(1, 1, .1)
	else
		color = B.HexRGB(.8, .8, 1)
	end
	per = color..per.."|r"

	return per
end
oUF.Tags.Events["nppp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["nplevel"] = function(unit)
	local level = UnitLevel(unit)
	if level and level ~= UnitLevel("player") then
		if level > 0 then
			level = B.HexRGB(GetCreatureDifficultyColor(level))..level.."|r "
		else
			level = "|cffff0000??|r "
		end
	else
		level = ""
	end

	return level
end
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

local NPClassifies = {
	rare = "  ",
	elite = "  ",
	rareelite = "  ",
	worldboss = "  ",
}
oUF.Tags.Methods["nprare"] = function(unit)
	local class = UnitClassification(unit)
	return class and NPClassifies[class]
end
oUF.Tags.Events["nprare"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["pppower"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if UnitPowerType(unit) == 0 then
		return per
	else
		return cur
	end
end
oUF.Tags.Events["pppower"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["npctitle"] = function(unit)
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer and C.db["Nameplate"]["NameOnlyGuild"] then
		local guildName = GetGuildInfo(unit)
		if guildName then
			return "<"..guildName..">"
		end
	elseif not isPlayer and C.db["Nameplate"]["NameOnlyTitle"] then
		B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
		B.ScanTip:SetUnit(unit)

		local title = _G[format("NDui_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]:GetText()
		if title and not strfind(title, "^"..LEVEL) then
			return title
		end
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		return B.HexRGB(B.UnitColor(tarUnit))..UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH_FREQUENT"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if max > 0 and not UnitIsDeadOrGhost(unit) then
		return format("%s%%", floor(cur/max*100 + .5))
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE"