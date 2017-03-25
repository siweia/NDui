local parent, ns = ...
local oUF = ns.oUF

local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

local UpdateTooltip = function(self)
	GameTooltip:SetText(self.powerName, 1, 1, 1)
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
	GameTooltip:Show()
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local UpdatePower = function(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= 'ALTERNATE') or not unit then return end

	local altpowerbar = self.AltPowerBar
	if(altpowerbar.PreUpdate) then
		altpowerbar:PreUpdate()
	end

	local _, r, g, b
	if(altpowerbar.colorTexture) then
		_, r, g, b = UnitAlternatePowerTextureInfo(unit, 2)
	end

	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

	local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo(unit)
	altpowerbar.barType = barType
	altpowerbar.powerName = powerName
	altpowerbar.powerTooltip = powerTooltip
	altpowerbar:SetMinMaxValues(min, max)
	altpowerbar:SetValue(math.min(math.max(cur, min), max))

	if(b) then
		altpowerbar:SetStatusBarColor(r, g, b)
	end

	if(altpowerbar.PostUpdate) then
		return altpowerbar:PostUpdate(min, cur, max)
	end
end

local Path = function(self, ...)
	return (self.AltPowerBar.Override or UpdatePower)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'ALTERNATE')
end

local Toggler = function(self, event, unit)
	if(unit ~= self.unit) or not unit then return end
	local altpowerbar = self.AltPowerBar

	local barType, _, _, _, _, hideFromOthers, showOnRaid = UnitAlternatePowerInfo(unit)
	if(barType and (showOnRaid and (UnitInParty(unit) or UnitInRaid(unit)) or not hideFromOthers or unit == 'player' or self.realUnit == 'player')) then
		self:RegisterEvent('UNIT_POWER', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		ForceUpdate(altpowerbar)
		altpowerbar:Show()
	else
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		altpowerbar:Hide()
	end
end

local Enable = function(self, unit)
	local altpowerbar = self.AltPowerBar
	if(altpowerbar) then
		altpowerbar.__owner = self
		altpowerbar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Toggler)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Toggler)

		altpowerbar:Hide()

		if(altpowerbar:IsMouseEnabled()) then
			if(not altpowerbar:GetScript('OnEnter')) then
				altpowerbar:SetScript('OnEnter', OnEnter)
			end

			if(not altpowerbar:GetScript('OnLeave')) then
				altpowerbar:SetScript('OnLeave', OnLeave)
			end

			if(not altpowerbar.UpdateTooltip) then
				altpowerbar.UpdateTooltip = UpdateTooltip
			end
		end

		if(unit == 'player') then
			PlayerPowerBarAlt:UnregisterEvent'UNIT_POWER_BAR_SHOW'
			PlayerPowerBarAlt:UnregisterEvent'UNIT_POWER_BAR_HIDE'
			PlayerPowerBarAlt:UnregisterEvent'PLAYER_ENTERING_WORLD'
		end

		return true
	end
end

local Disable = function(self, unit)
	local altpowerbar = self.AltPowerBar
	if(altpowerbar) then
		altpowerbar:Hide()
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Toggler)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Toggler)

		if(unit == 'player') then
			PlayerPowerBarAlt:RegisterEvent'UNIT_POWER_BAR_SHOW'
			PlayerPowerBarAlt:RegisterEvent'UNIT_POWER_BAR_HIDE'
			PlayerPowerBarAlt:RegisterEvent'PLAYER_ENTERING_WORLD'
		end
	end
end

oUF:AddElement('AltPowerBar', Toggler, Enable, Disable)