local parent, ns = ...
local oUF = ns.oUF

oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		oUF.colors.power[power] = {color.r, color.g, color.b}
	end
end

oUF.colors.power[0] = oUF.colors.power["MANA"]
oUF.colors.power[1] = oUF.colors.power["RAGE"]
oUF.colors.power[2] = oUF.colors.power["FOCUS"]
oUF.colors.power[3] = oUF.colors.power["ENERGY"]
oUF.colors.power[4] = oUF.colors.power["COMBO_POINTS"]
oUF.colors.power[5] = oUF.colors.power["RUNES"]
oUF.colors.power[6] = oUF.colors.power["RUNIC_POWER"]
oUF.colors.power[7] = oUF.colors.power["SOUL_SHARDS"]
oUF.colors.power[8] = oUF.colors.power["LUNAR_POWER"]
oUF.colors.power[9] = oUF.colors.power["HOLY_POWER"]
oUF.colors.power[11] = oUF.colors.power["MAELSTROM"]
oUF.colors.power[12] = oUF.colors.power["CHI"]
oUF.colors.power[13] = oUF.colors.power["INSANITY"]
oUF.colors.power[16] = oUF.colors.power["ARCANE_CHARGES"]
oUF.colors.power[17] = oUF.colors.power["FURY"]
oUF.colors.power[18] = oUF.colors.power["PAIN"]

local GetDisplayPower = function(unit)
	local _, min, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(showOnRaid) then
		return ALTERNATE_POWER_INDEX, min
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local displayType, min
	if power.displayAltPower then
		displayType, min = GetDisplayPower(unit)
	end
	local cur, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	local disconnected = not UnitIsConnected(unit)
	power:SetMinMaxValues(min or 0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(cur)
	end

	power.disconnected = disconnected

	local r, g, b, t
	if(power.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and disconnected) then
		t = self.colors.disconnected
	elseif(displayType == ALTERNATE_POWER_INDEX and power.altPowerColor) then
		t = power.altPowerColor
	elseif(power.colorPower) then
		local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)

		t = self.colors.power[ptoken]
		if(not t) then
			if(power.GetAlternativeColor) then
				r, g, b = power:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
			elseif(altR) then
				r, g, b = altR, altG, altB
			else
				t = self.colors.power[ptype]
			end
		end
	elseif(power.colorClass and UnitIsPlayer(unit)) or
		(power.colorClassNPC and not UnitIsPlayer(unit)) or
		(power.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(power.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(power.colorSmooth) then
        local adjust = 0 - (min or 0)
		r, g, b = self.ColorGradient(cur + adjust, max + adjust, unpack(power.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		power:SetStatusBarColor(r, g, b)

		local bg = power.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(power.PostUpdate) then
		return power:PostUpdate(unit, cur, max, min)
	end
end

local Path = function(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		if(power.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_POWER', Path)
		end

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(power:IsObjectType'StatusBar' and not power:GetStatusBarTexture()) then
			power:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)