local _, ns = ...
local oUF = ns.oUF

-- sourced from FrameXML/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX or 10

local function updateTooltip(self)
	GameTooltip:SetText(self.powerName, 1, 1, 1)
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
	GameTooltip:Show()
end

local function onEnter(self)
	if(not self:IsVisible()) then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local function onLeave()
	GameTooltip:Hide()
end

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= 'ALTERNATE') then return end

	local element = self.AlternativePower

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max
	local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo(unit)
	element.barType = barType
	element.powerName = powerName
	element.powerTooltip = powerTooltip
	if(barType) then
		cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
		max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
		element:SetMinMaxValues(min, max)
		element:SetValue(cur)
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, min, max)
	end
end

local function Path(self, ...)
	return (self.AlternativePower.Override or Update)(self, ...)
end

local function Visibility(self, event, unit)
	if(unit ~= self.unit) then return end
	local element = self.AlternativePower

	local barType, _, _, _, _, hideFromOthers, showOnRaid = UnitAlternatePowerInfo(unit)
	if(barType and (showOnRaid and (UnitInParty(unit) or UnitInRaid(unit)) or not hideFromOthers or unit == 'player' or self.realUnit == 'player')) then
		self:RegisterEvent('UNIT_POWER', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		element:Show()
		Path(self, event, unit, 'ALTERNATE')
	else
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		element:Hide()
		Path(self, event, unit, 'ALTERNATE')
	end
end

local function VisibilityPath(self, ...)
	return (self.AlternativePower.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(element:IsMouseEnabled()) then
			if(not element:GetScript('OnEnter')) then
				element:SetScript('OnEnter', onEnter)
			end

			if(not element:GetScript('OnLeave')) then
				element:SetScript('OnLeave', onLeave)
			end

			if(not element.UpdateTooltip) then
				element.UpdateTooltip = updateTooltip
			end
		end

		if(unit == 'player') then
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:UnregisterEvent('PLAYER_ENTERING_WORLD')
		end

		element:Hide()

		return true
	end
end

local function Disable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(unit == 'player') then
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:RegisterEvent('PLAYER_ENTERING_WORLD')
		end
	end
end

oUF:AddElement('AlternativePower', VisibilityPath, Enable, Disable)