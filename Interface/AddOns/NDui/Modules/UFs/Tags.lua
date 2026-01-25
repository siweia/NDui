local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL = AFK, DND, DEAD, PLAYER_OFFLINE, LEVEL
local select, format, strfind, GetCVarBool = select, format, strfind, GetCVarBool
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer = UnitIsDeadOrGhost, UnitIsConnected, UnitIsTapDenied, UnitIsPlayer
local UnitHealth, UnitHealthMax, UnitPower, UnitPowerType, UnitStagger = UnitHealth, UnitHealthMax, UnitPower, UnitPowerType, UnitStagger
local UnitReaction, UnitLevel, UnitClassification, UnitEffectiveLevel = UnitReaction, UnitLevel, UnitClassification, UnitEffectiveLevel
local UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost, UnitName, UnitExists = UnitIsAFK, UnitIsDND, UnitIsDead, UnitIsGhost, UnitName, UnitExists
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local GetNumArenaOpponentSpecs, GetCreatureDifficultyColor = GetNumArenaOpponentSpecs, GetCreatureDifficultyColor
local UnitClassBase = UnitClassBase
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

-- Add scantip back, due to issue on ColorMixin
local scanTip = CreateFrame("GameTooltip", "NDui_ScanTooltip", nil, "GameTooltipTemplate")

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
--	if per < 100 then
		return B.Numb(cur).." | "..per
	--else
	--	return B.Numb(cur)
	--end
end

local function GetCurrentAndMax(cur, max)
	if cur == max then
		return B.Numb(max)
	else
		return B.Numb(cur).." | "..B.Numb(max)
	end
end

oUF.Tags.Methods["VariousHP"] = function(unit, _, arg1)
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return oUF.Tags.Methods["DDG"](unit)
	end

	if not arg1 then return end
	local max = B.Numb(UnitHealthMax(unit))
	local cur = B.Numb(UnitHealth(unit))
	local per = format("%d", UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))

	if arg1 == "currentpercent" then
		return cur.." | "..per
	elseif arg1 == "currentmax" then
		return cur.." | "..max
	elseif arg1 == "current" then
		return cur
	elseif arg1 == "percent" then
		return per
	elseif arg1 == "loss" then
		return TruncateWhenZero(UnitHealthMissing(unit))
	elseif arg1 == "losspercent" then -- broken in 12.0
		local loss = max - cur
		return loss ~= 0 and B:Round(loss/max*100, 1)
	elseif arg1 == "absorb" then
		local absorb = UnitGetTotalAbsorbs(unit) or 0
		return (absorb > 0 and DB.InfoColor or "")..B.Numb(cur+absorb)
	end
end
oUF.Tags.Events["VariousHP"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods["VariousMP"] = function(unit, _, arg1)
	local max = B.Numb(UnitPowerMax(unit))
	local cur = B.Numb(UnitPower(unit))
	local per = format("%d", UnitPowerPercent(unit, nil, true, CurveConstants.ScaleTo100))

	if arg1 == "currentpercent" then
		return cur.." | "..per
	elseif arg1 == "currentmax" then
		return cur.." | "..max
	elseif arg1 == "current" then
		return cur
	elseif arg1 == "percent" then
		return per
	elseif arg1 == "loss" then
		return TruncateWhenZero(UnitPowerMissing(unit))
	elseif arg1 == "losspercent" then
		local loss = max - cur
		return loss ~= 0 and B:Round(loss/max*100, 1)
	end
end
oUF.Tags.Events["VariousMP"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["curAbsorb"] = function(unit)
	local value = TruncateWhenZero(UnitGetTotalAbsorbs(unit))
	return DB.InfoColor..value.."|r"
end
oUF.Tags.Events["curAbsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["color"] = function(unit)
	if not unit then return end
	local class = UnitClassBase(unit)
	local reaction = UnitReaction(unit, "player")

	if UnitIsTapDenied(unit) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	else
		return B.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

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
oUF.Tags.Events["DDG"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

-- Level tags
oUF.Tags.Methods["fulllevel"] = function(unit)
	if not UnitIsConnected(unit) then
		return "??"
	end

	local realLevel = UnitLevel(unit)
	local level = UnitEffectiveLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
		realLevel = level
	end

	local color = B.HexRGB(GetCreatureDifficultyColor(level))
	local str
	if level > 0 then
		local realTag = level ~= realLevel and "*" or ""
		str = color..level..realTag.."|r"
	else
		str = "|cffff0000??|r"
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		str = "|cffff0000Boss|r"
	elseif class == "rareelite" then
		str = str.."|cff0080ffR|r+"
	elseif class == "elite" then
		str = str.."+"
	elseif class == "rare" then
		str = str.."|cff0080ffR|r"
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
	[6] = "absorb",
}
oUF.Tags.Methods["raidhp"] = function(unit)
	local healthType = healthModeType[C.db["UFs"]["RaidHPMode"]]
	return oUF.Tags.Methods["VariousHP"](unit, _, healthType)
end
oUF.Tags.Events["raidhp"] = oUF.Tags.Events["VariousHP"].." UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

-- Nameplate tags
local colorCurve = C_CurveUtil.CreateColorCurve()
colorCurve:SetType(Enum.LuaCurveType.Step)
colorCurve:AddPoint(0, CreateColor(.8, .8, 1))
colorCurve:AddPoint(.5, CreateColor(1, 1, .1))
colorCurve:AddPoint(.85, CreateColor(1, .1, .1))

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
		scanTip:SetOwner(UIParent, "ANCHOR_NONE")
		scanTip:SetUnit(unit)

		local textLine = _G[format("NDui_ScanTooltipTextLeft%d", GetCVarBool("colorblindmode") and 3 or 2)]
		local title = textLine and textLine:GetText()
		if title and B:NotSecretValue(title) and not strfind(title, "^"..LEVEL) then
			return title
		end
--[[
		local data = C_TooltipInfo.GetUnit(unit) -- FIXME: ColorMixin error
		if not data then return "" end

		local lineData = data.lines[GetCVarBool("colorblindmode") and 3 or 2]
		if lineData then
			local title = lineData.leftText
			if title and not strfind(title, "^"..LEVEL) then
				return title
			end
		end
]]
	end
end
oUF.Tags.Events["npctitle"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["tarname"] = function(unit)
	local tarUnit = unit.."target"
	if UnitExists(tarUnit) then
		local tarClass = UnitClassBase(tarUnit)
		return B.HexRGB(oUF.colors.class[tarClass])..UnitName(tarUnit)
	end
end
oUF.Tags.Events["tarname"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	return TruncateWhenZero(UnitPower(unit, ALTERNATE_POWER_INDEX))
end
oUF.Tags.Events["altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

-- Monk stagger
oUF.Tags.Methods["monkstagger"] = function(unit)
	if unit ~= "player" then return end
	local cur = UnitStagger(unit) or 0
	local perc = cur / UnitHealthMax(unit)
	if cur == 0 then return end
	return B.Numb(cur).." | "..DB.MyColor..B:Round(perc*100).."%"
end
oUF.Tags.Events["monkstagger"] = "UNIT_MAXHEALTH UNIT_AURA"