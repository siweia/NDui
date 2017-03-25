local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2, UnitClass('player'))
local ADDITIONAL_POWER_BAR_NAME = ADDITIONAL_POWER_BAR_NAME
local ADDITIONAL_POWER_BAR_INDEX = ADDITIONAL_POWER_BAR_INDEX

local function Update(self, event, unit, powertype)
	if(unit ~= 'player' or (powertype and powertype ~= ADDITIONAL_POWER_BAR_NAME)) then return end

	local additionalpower = self.AdditionalPower
	if(additionalpower.PreUpdate) then additionalpower:PreUpdate(unit) end

	local cur = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX)
	local max = UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	additionalpower:SetMinMaxValues(0, max)
	additionalpower:SetValue(cur)

	local r, g, b, t
	if(additionalpower.colorClass) then
		t = self.colors.class[playerClass]
	elseif(additionalpower.colorSmooth) then
		r, g, b = self.ColorGradient(cur, max, unpack(additionalpower.smoothGradient or self.colors.smooth))
	elseif(additionalpower.colorPower) then
		t = self.colors.power[ADDITIONAL_POWER_BAR_NAME]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		additionalpower:SetStatusBarColor(r, g, b)

		local bg = additionalpower.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if additionalpower.Text then
		local perc = cur/max * 100
		if perc == 100 then
			perc = ""
			additionalpower:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			additionalpower:SetAlpha(1)
		end
		additionalpower.Text:SetText(perc)
	end

	if(additionalpower.PostUpdate) then
		return additionalpower:PostUpdate(unit, cur, max, event)
	end
end

local function Path(self, ...)
	return (self.AdditionalPower.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Show()

	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(true, not self.AdditionalPower.isEnabled)
	end
	
	self.AdditionalPower.isEnabled = true

	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Hide()
	
	if self.AdditionalPower.PostUpdateVisibility then
		self.AdditionalPower:PostUpdateVisibility(false, self.AdditionalPower.isEnabled)
	end

	self.AdditionalPower.isEnabled = nil

	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local additionalpower = self.AdditionalPower
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

local VisibilityPath = function(self, ...)
	return (self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local additionalpower = self.AdditionalPower
	if(additionalpower and unit == 'player') then
		additionalpower.__owner = self
		additionalpower.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(additionalpower:IsObjectType'StatusBar' and not additionalpower:GetStatusBarTexture()) then
			additionalpower:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local additionalpower = self.AdditionalPower
	if(additionalpower) then
		ElementDisable(self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
	end
end

oUF:AddElement('AdditionalPower', VisibilityPath, Enable, Disable)