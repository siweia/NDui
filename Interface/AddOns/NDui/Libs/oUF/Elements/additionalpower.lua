--[[
# Element: Additional Power Bar

Handles the visibility and updating of a status bar that displays the player's additional power, such as Mana for
Balance druids.

## Widget

AdditionalPower - A `StatusBar` that is used to display the player's additional power.

## Sub-Widgets

.CostPrediction - A `StatusBar` used to represent the power cost of spells on top of the AdditionalPower element.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Options

.frequentUpdates - Indicates whether to use UNIT_POWER_FREQUENT instead UNIT_POWER_UPDATE to update the bar (boolean)
.displayPairs    - Use to override display pairs. (table)
.smoothing       - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)

The following options are listed by priority. The first check that returns true decides the color of the bar.

.colorPower       - Use `self.colors.power[token]` to color the bar based on the player's additional power type
                    (boolean)
.colorPowerSmooth - Use color curve from `self.colors.power[token]` to color the bar with a smooth gradient based on the
                    player's current power percentage. Requires `.colorPower` to be enabled (boolean)

## Examples

    -- Position and size
    local AdditionalPower = CreateFrame('StatusBar', nil, self)
    AdditionalPower:SetSize(20, 20)
    AdditionalPower:SetPoint('TOP')
    AdditionalPower:SetPoint('LEFT')
    AdditionalPower:SetPoint('RIGHT')

    -- Optionally add CostPrediction sub-widget
    local CostPrediction = CreateFrame('StatusBar', nil, AdditionalPower)
    CostPrediction:SetReverseFill(true)
    CostPrediction:SetPoint('TOP')
    CostPrediction:SetPoint('BOTTOM')
    CostPrediction:SetPoint('RIGHT', AdditionalPower:GetStatusBarTexture())
    AdditionalPower.CostPrediction = CostPrediction

    -- Register it with oUF
    self.AdditionalPower = AdditionalPower
--]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = UnitClassBase('player')

-- sourced from Blizzard_UnitFrame/AlternatePowerBar.lua
local ALT_POWER_BAR_PAIR_DISPLAY_INFO = _G.ALT_POWER_BAR_PAIR_DISPLAY_INFO

local ADDITIONAL_POWER_BAR_NAME = 'MANA'
local ADDITIONAL_POWER_BAR_INDEX = 0

local function UpdateColor(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == ADDITIONAL_POWER_BAR_NAME)) then return end
	local element = self.AdditionalPower

	local color
	if(element.colorPower) then
		color = self.colors.power[ADDITIONAL_POWER_BAR_INDEX]

		if(element.colorPowerSmooth and color and color:GetCurve()) then
			color = UnitPowerPercent(unit, true, color:GetCurve())
		end
	end

	if(color) then
		element:SetStatusBarColor(color:GetRGB())
	end

	--[[ Callback: AdditionalPower:PostUpdateColor(color)
	Called after the element color has been updated.

	* self  - the AdditionalPower element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(color)
	end
end

local function Update(self, event, unit, powerType)
	if(not (unit and UnitIsUnit(unit, 'player') and powerType == ADDITIONAL_POWER_BAR_NAME)) then return end
	local element = self.AdditionalPower

	--[[ Callback: AdditionalPower:PreUpdate(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local cur, max = UnitPower('player', ADDITIONAL_POWER_BAR_INDEX), UnitPowerMax('player', ADDITIONAL_POWER_BAR_INDEX)
	element:SetMinMaxValues(0, max)
	element:SetValue(cur, element.smoothing)

	element.cur = cur
	element.max = max

	--[[ Callback: AdditionalPower:PostUpdate(cur, max)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* cur  - the current value of the player's additional power (number)
	* max  - the maximum value of the player's additional power (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cur, max)
	end
end

local function UpdatePrediction(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.AdditionalPower

	--[[ Callback: AdditionalPower:PreUpdatePrediction(unit)
	Called before the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdatePrediction) then
		element:PreUpdatePrediction(unit)
	end

	local _, _, _, startTime, endTime, _, _, _, spellID = UnitCastingInfo(unit)
	local cost = 0

	if(event == 'UNIT_SPELLCAST_START' and startTime ~= endTime) then
		local costTable = C_Spell.GetSpellPowerCost(spellID)
		if(not costTable) then return end

		-- hasRequiredAura is always false if there's only 1 subtable
		local checkRequiredAura = #costTable > 1

		for _, costInfo in next, costTable do
			if(not checkRequiredAura or costInfo.hasRequiredAura) then
				if(costInfo.type == ADDITIONAL_POWER_BAR_INDEX) then
					cost = costInfo.cost
					element.cost = cost

					break
				end
			end
		end
	elseif(spellID) then
		-- if we try to cast a spell while casting another one we need to avoid
		-- resetting the element
		cost = element.cost or 0
	else
		element.cost = cost
	end

	element.CostPrediction:SetMinMaxValues(0, UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX))
	element.CostPrediction:SetValue(cost)
	element.CostPrediction:Show()

	--[[ Callback: AdditionalPower:PostUpdatePrediction(unit, cost)
	Called after the element has been updated.

	* self - the AdditionalPower element
	* unit - the unit for which the update has been triggered (string)
	* cost - the power type cost of the cast ability (number)
	--]]
	if(element.PostUpdatePrediction) then
		return element:PostUpdatePrediction(unit, cost)
	end
end

local function UpdatePredictionSize(self, event, unit)
	local element = self.AdditionalPower
	if(element.CostPrediction and element.__size) then
		element.CostPrediction[element.__isHoriz and 'SetWidth' or 'SetHeight'](element.CostPrediction, element.__size)
	end
end

local function shouldUpdatePredictionSize(self)
	local element = self.AdditionalPower

	local isHoriz = element:GetOrientation() == 'HORIZONTAL'
	local newSize = element[isHoriz and 'GetWidth' or 'GetHeight'](element)
	if(isHoriz ~= element.__isHoriz or newSize ~= element.__size) then
		element.__isHoriz = isHoriz
		element.__size = newSize

		return true
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
	do
		(self.AdditionalPower.Override or Update) (self, ...)
	end

	--[[ Override: AdditionalPower.UpdateColor(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' colors.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.AdditionalPower.UpdateColor or UpdateColor) (self, ...)
end

local function PredictionPath(self, ...)
	--[[ Override: AdditionalPower.UpdatePredictionSize(self, event, unit, ...)
	Used to completely override the internal function for updating the cost prediction sub-widget's size.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	if(shouldUpdatePredictionSize(self)) then
		(self.AdditionalPower.UpdatePredictionSize or UpdatePredictionSize) (self, ...)
	end

	--[[ Override: AdditionalPower.OverridePrediction(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	do
		(self.AdditionalPower.OverridePrediction or UpdatePrediction) (self, ...)
	end
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

	if(element.CostPrediction) then
		self:RegisterEvent('UNIT_SPELLCAST_START', PredictionPath)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', PredictionPath)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', PredictionPath)
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', PredictionPath)
	end

	element.__isEnabled = true
	Path(self, 'ElementEnable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function ElementDisable(self)
	local element = self.AdditionalPower

	self:UnregisterEvent('UNIT_MAXPOWER', Path)
	self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	self:UnregisterEvent('UNIT_POWER_UPDATE', Path)

	element:Hide()

	if(element.CostPrediction) then
		element.CostPrediction:Hide()

		self:UnregisterEvent('UNIT_SPELLCAST_START', PredictionPath)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', PredictionPath)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', PredictionPath)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', PredictionPath)
	end

	element.__isEnabled = false
	Path(self, 'ElementDisable', 'player', ADDITIONAL_POWER_BAR_NAME)
end

local function Visibility(self, event, unit)
	local element = self.AdditionalPower
	local shouldEnable

	if(not UnitHasVehicleUI('player')) then
		if(UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX) ~= 0) then
			if(element.displayPairs[playerClass]) then
				local powerType = UnitPowerType(unit)
				shouldEnable = element.displayPairs[playerClass][powerType]
			end
		end
	end

	local isEnabled = element.__isEnabled

	if(shouldEnable and not isEnabled) then
		ElementEnable(self)

		--[[ Callback: AdditionalPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the AdditionalPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(true)
		end
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ElementDisable(self)

		if(element.PostVisibility) then
			element:PostVisibility(false)
		end
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, ADDITIONAL_POWER_BAR_NAME)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: AdditionalPower.OverrideVisibility(self, event, unit)
	Used to completely override the element's visibility update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	(self.AdditionalPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)

	if(element.__isEnabled and element.CostPrediction) then
		PredictionPath(element.__owner, 'ForceUpdate', element.__owner.unit)
	end
end

--[[ Power:SetFrequentUpdates(state, isForced)
Used to toggle frequent updates.

* self  - the Power element
* state - the desired state (boolean)
* isForced - forces the event update even if the state wasn't changed (boolean)
--]]
local function SetFrequentUpdates(element, state, isForced)
	if(element.frequentUpdates ~= state or isForced) then
		element.frequentUpdates = state
		if(state) then
			element.__owner:UnregisterEvent('UNIT_POWER_UPDATE', Path)
			element.__owner:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		else
			element.__owner:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
			element.__owner:RegisterEvent('UNIT_POWER_UPDATE', Path)
		end
	end
end

local function Enable(self, unit)
	local element = self.AdditionalPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetFrequentUpdates = SetFrequentUpdates

		if(not element.smoothing) then
			element.smoothing = Enum.StatusBarInterpolation.Immediate
		end

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)

		if(not element.displayPairs) then
			element.displayPairs = CopyTable(ALT_POWER_BAR_PAIR_DISPLAY_INFO)
		end

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(element.CostPrediction) then
			element.CostPrediction:Hide()

			if(element.CostPrediction:IsObjectType('StatusBar') and not element.CostPrediction:GetStatusBarTexture()) then
				element.CostPrediction:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
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
