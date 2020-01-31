local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF or oUF
local format, floor = string.format, math.floor
local AFK, DND, DEAD, PLAYER_OFFLINE = AFK, DND, DEAD, PLAYER_OFFLINE
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local UnitAlternatePowerTextureInfo = UnitAlternatePowerTextureInfo
local UnitIsDeadOrGhost, UnitIsConnected, UnitHasVehicleUI, UnitIsTapDenied, UnitIsPlayer = UnitIsDeadOrGhost, UnitIsConnected, UnitHasVehicleUI, UnitIsTapDenied, UnitIsPlayer
local UnitHealth, UnitHealthMax, UnitPower, UnitPowerType, UnitStagger = UnitHealth, UnitHealthMax, UnitPower, UnitPowerType, UnitStagger
local UnitClass, UnitReaction, UnitLevel, UnitClassification = UnitClass, UnitReaction, UnitLevel, UnitClassification
local UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost = UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local GetNumArenaOpponentSpecs, GetCreatureDifficultyColor = GetNumArenaOpponentSpecs, GetCreatureDifficultyColor

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

oUF.Tags.Methods["hp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	else
		local per = oUF.Tags.Methods["perhp"](unit) or 0
		local cur = UnitHealth(unit)
		if (unit == "player" and not UnitHasVehicleUI(unit)) or unit == "target" or unit == "focus" then
			return ValueAndPercent(cur, per)
		else
			return ColorPercent(per)
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["power"] = function(unit)
	local cur = UnitPower(unit)
	local per = oUF.Tags.Methods["perpp"](unit) or 0
	if (unit == "player" and not UnitHasVehicleUI(unit)) or unit == "target" or unit == "focus" then
		if per < 100 and UnitPowerType(unit) == 0 then
			return B.Numb(cur).." | "..per
		else
			return B.Numb(cur)
		end
	else
		return per
    end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(unit)
	local class = select(2, UnitClass(unit))
	local reaction = UnitReaction(unit, "player")

	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return "|cffA0A0A0"
	elseif UnitIsTapDenied(unit) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	else
		return B.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

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
	if UnitIsDead(unit) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(unit) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(unit) and GetNumArenaOpponentSpecs() == 0 then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	local level = UnitLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

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
oUF.Tags.Methods["raidhp"] = function(unit)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	elseif NDuiDB["UFs"]["RaidHPMode"] == 2 then
		local per = oUF.Tags.Methods["perhp"](unit) or 0
		return ColorPercent(per)
	elseif NDuiDB["UFs"]["RaidHPMode"] == 3 then
		local cur = UnitHealth(unit)
		return B.Numb(cur)
	elseif NDuiDB["UFs"]["RaidHPMode"] == 4 then
		local loss = UnitHealthMax(unit) - UnitHealth(unit)
		if loss == 0 then return end
		return B.Numb(loss)
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Nameplate tags
oUF.Tags.Methods["nphp"] = function(unit)
	local per = oUF.Tags.Methods["perhp"](unit) or 0
	if NDuiDB["Nameplate"]["FullHealth"] then
		local cur = UnitHealth(unit)
		return ValueAndPercent(cur, per)
	elseif per < 100 then
		return ColorPercent(per)
	end
end
oUF.Tags.Events["nphp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

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
oUF.Tags.Events["nplevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

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

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	if cur > 0 then
		local _, r, g, b = UnitAlternatePowerTextureInfo(unit, 2)
		if not r then r, g, b = 1, 1, 1 end
		return B.HexRGB(r, g, b)..cur
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- Monk stagger
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" then return end
	local cur = UnitStagger(unit) or 0
	local perc = cur / UnitHealthMax(unit)
	if cur == 0 then return end
	return B.Numb(cur).." | "..DB.MyColor..floor(perc*100 + .5).."%"
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"