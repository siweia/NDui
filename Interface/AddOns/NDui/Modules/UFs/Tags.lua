local B, C, L, DB = unpack(select(2, ...))
local oUF = NDui.oUF or oUF

oUF.Tags.Methods["hp"] = function(u)
	if UnitIsDeadOrGhost(u) or not UnitIsConnected(u) then
		return oUF.Tags.Methods["DDG"](u)
	else
		local per = oUF.Tags.Methods["perhp"](u).."%" or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if (u == "player" and not UnitHasVehicleUI(u)) or u == "target" or u == "focus" then
			if min ~= max then 
				return B.Numb(min).." | "..per
			else
				return B.Numb(max)
			end
		else
			return per
		end
	end
end
oUF.Tags.Events["hp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["raidhp"] = function(u)
	if UnitIsDeadOrGhost(u) or not UnitIsConnected(u) then
		return oUF.Tags.Methods["DDG"](u)
	else
		local per = oUF.Tags.Methods["perhp"](u).."%" or 0
		return per
	end
end
oUF.Tags.Events["raidhp"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["power"] = function(u)
	local min, max = UnitPower(u), UnitPowerMax(u)
	local per = oUF.Tags.Methods["perpp"](u).."%" or 0
	if (u == "player" and not UnitHasVehicleUI(u)) or u == "target" or u == "focus" then
		if min ~= max then
			if UnitPowerType("player") == 0 then
				return B.Numb(min).." | "..per
			else
				return B.Numb(min)
			end
		else
			return B.Numb(max)
		end
	else
		return per
    end
end
oUF.Tags.Events["power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER"

oUF.Tags.Methods["color"] = function(u, r)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")
	
	if UnitIsDeadOrGhost(u) or not UnitIsConnected(u) then
		return "|cffA0A0A0"
	elseif UnitIsTapDenied(u) then
		return B.HexRGB(oUF.colors.tapped)
	elseif UnitIsPlayer(u) then
		return B.HexRGB(oUF.colors.class[class])
	elseif reaction then
		return B.HexRGB(oUF.colors.reaction[reaction])
	else
		return B.HexRGB(1, 1, 1)
	end
end
oUF.Tags.Events["color"] = "UNIT_REACTION UNIT_HEALTH UNIT_CONNECTION"

oUF.Tags.Methods["afkdnd"] = function(unit) 
	return UnitIsAFK(unit) and "|cffCFCFCF <"..AFK..">|r" or UnitIsDND(unit) and "|cffCFCFCF <"..DND..">|r" or ""
end
oUF.Tags.Events["afkdnd"] = "PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["DDG"] = function(u)
	if UnitIsDead(u) then
		return "|cffCFCFCF"..DEAD.."|r"
	elseif UnitIsGhost(u) then
		return "|cffCFCFCF"..L["Ghost"].."|r"
	elseif not UnitIsConnected(u) then
		return "|cffCFCFCF"..PLAYER_OFFLINE.."|r"
	end
end
oUF.Tags.Events["DDG"] = "UNIT_HEALTH UNIT_CONNECTION"

-- Level
oUF.Tags.Methods["level"] = function(unit)
	local c = UnitClassification(unit)
	local l
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		l = UnitBattlePetLevel(unit)
	else
		l = UnitLevel(unit)
	end

	local d = GetCreatureDifficultyColor(l)
	local str = l
	if l <= 0 then l = "|cffff0000Boss|r" end

	if c == "worldboss" then
		str = string.format("|cff%02x%02x%02xBoss|r",250,20,0)
	elseif c == "rareelite" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r +",d.r*255,d.g*255,d.b*255,l)
	elseif c == "elite" then
		str = string.format("|cff%02x%02x%02x%s|r +",d.r*255,d.g*255,d.b*255,l)
	elseif c == "rare" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r",d.r*255,d.g*255,d.b*255,l)
	else
		if not UnitIsConnected(unit) then
			str = "??"
		else
			if UnitIsPlayer(unit) then
				str = string.format("|cff%02x%02x%02x%s|r",d.r*255,d.g*255,d.b*255,l)
			elseif UnitPlayerControlled(unit) then
				str = string.format("|cff%02x%02x%02x%s|r",d.r*255,d.g*255,d.b*255,l)
			else
				str = string.format("|cff%02x%02x%02x%s|r",d.r*255,d.g*255,d.b*255,l)
			end
		end
	end

	return str
end
oUF.Tags.Events["level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"

-- AltPower value tag
oUF.Tags.Methods["altpower"] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if(max > 0 and not UnitIsDeadOrGhost(unit)) then
		return ("%s%%"):format(math.floor(cur/max*100+.5))
	end
end
oUF.Tags.Events["altpower"] = "UNIT_POWER"