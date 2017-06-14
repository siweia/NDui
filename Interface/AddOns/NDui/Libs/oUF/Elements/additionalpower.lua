local _, ns = ...
local oUF = ns.oUF

local _, playerClass = UnitClass('player')

-- sourced from FrameXML/AlternatePowerBar.lua
local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME or 'MANA'
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX or 0
local ALT_MANA_BAR_PAIR_DISPLAY_INFO = ALT_MANA_BAR_PAIR_DISPLAY_INFO

local function UpdateColor(element, cur, max)
	local parent = element.__owner

	local r, g, b, t
	if(element.colorClass) then
		t = parent.colors.class[playerClass]
	elseif(element.colorSmooth) then
		r, g, b = parent.ColorGradient(cur, max, unpack(element.smoothGradient or parent.colors.smooth))
	elseif(element.colorPower) then
		t = parent.colors.power[ADDITIONAL_POWER_BAR_NAME]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

local function Update(self, event, unit, powertype)
	if(unit ~= 'player' or (powertype and powertype ~= ADDITIONAL_POWER_BAR_NAME)) then return end

	local element = self.AdditionalPower
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	element:UpdateColor(cur, max)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	return (self.AdditionalPower.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Show()

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Hide()

	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0) then
			if(ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass]) then
				local powerType = UnitPowerType(unit)
				shouldEnable = ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass][powerType]
			end
		end
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	return (self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		return true
	end
end

local function Disable(self)
	local element = self.AdditionalPower
	if(element) then
		ElementDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('AdditionalPower', VisibilityPath, Enable, Disable)