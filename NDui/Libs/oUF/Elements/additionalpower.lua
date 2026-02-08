--[[
# Element: Additional Power Bar

Handles the visibility and updating of a status bar that displays the player's additional power, such as Mana for druids.

## Widget

AdditionalPower - A `StatusBar` that is used to display the player's additional power.

## Sub-Widgets

.bg - A `Texture` used as a background. Inherits the widget's color.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.frequentUpdates                  - Indicates whether to use UNIT_POWER_FREQUENT instead UNIT_POWER_UPDATE to update the
                                    bar (boolean)
.smoothGradient                   - 9 color values to be used with the .colorSmooth option (table)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorPower        - Use `self.colors.power[token]` to color the bar based on the player's additional power type
                     (boolean)
.colorClass        - Use `self.colors.class[class]` to color the bar based on unit class. `class` is defined by the
                     second return of [UnitClass](http://wowprogramming.com/docs/api/UnitClass.html) (boolean)
.colorSmooth       - Use `self.colors.smooth` to color the bar with a smooth gradient based on the player's current
                     additional power percentage (boolean)

## Sub-Widget Options

.multiplier - Used to tint the background based on the widget's R, G and B values. Defaults to 1 (number)[0-1]

## Examples

    -- Position and size
    local AdditionalPower = CreateFrame('StatusBar', nil, self)
    AdditionalPower:SetSize(20, 20)
    AdditionalPower:SetPoint('TOP')
    AdditionalPower:SetPoint('LEFT')
    AdditionalPower:SetPoint('RIGHT')

    -- Add a background
    local Background = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(AdditionalPower)
    Background:SetTexture(1, 1, 1, .5)

    -- Register it with oUF
    AdditionalPower.bg = Background
    self.AdditionalPower = AdditionalPower
--]]

if(select(2, UnitClass('player')) ~= 'DRUID') then return end

local _, ns = ...
local oUF = ns.oUF

local function UpdateColor(self, event, unit, powertype)
	if(not (unit and unit == 'player') and powertype == 'MANA') then return end
	local element = self.AdditionalPower

	local r, g, b, t
	if(element.colorPower) then
		t = self.colors.power[0]
	elseif(element.colorClass and UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(element.colorSmooth) then
		r, g, b = self:ColorGradient(element.cur or 1, element.max or 1, unpack(element.smoothGradient or self.colors.smooth))
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

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function ColorPath(self, ...)
	--[[ Override: AdditionalPower.UpdateColor(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AdditionalPower.UpdateColor or UpdateColor) (self, ...)
end

local function Update(self, event, unit, powertype)
	if(not (unit and unit == 'player') and powertype == 'MANA') then return end

	local element = self.AdditionalPower
	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur = UnitPower('player', 0)
	local max = UnitPowerMax('player', 0)

	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	element.cur = cur
	element.max = max

	--[[ Callback: AdditionalPower:PostUpdate(unit, cur, max)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	--[[ Override: AdditionalPower.Override(self, event, unit, ...)
	Used to completely override the element's update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AdditionalPower.Override or Update) (self, ...)

	ColorPath(self, ...)
end

local function ElementEnable(self)
	local element = self.AdditionalPower

	if(element.frequentUpdates) then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	else
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
	end

	self:RegisterEvent('UNIT_MAXPOWER', Path)

	element:Show()

	Path(self, 'ElementEnable', 'player', 'MANA')
end

local function ElementDisable(self)
	local element = self.AdditionalPower

	if(element.frequentUpdates) then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	else
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
	end

	self:UnregisterEvent('UNIT_MAXPOWER', Path)

	self.AdditionalPower:Hide()

	Path(self, 'ElementDisable', 'player', 'MANA')
end

local function Visibility(self)
	local shouldEnable

	if((UnitPowerType('player') ~= 0) and (UnitPowerMax('player', 0) ~= 0)) then
		shouldEnable = true
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: AdditionalPower.OverrideVisibility(self, event, unit)
	Used to completely override the element's visibility update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
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