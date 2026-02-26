--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

**WARNING**: this element is deprecated, please use sub-widgets of Health element instead.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

healingAll                - A `StatusBar` used to represent incoming heals from all sources.
healingPlayer             - A `StatusBar` used to represent incoming heals from the player.
healingOther              - A `StatusBar` used to represent incoming heals from others.
overHealIndicator         - A `Texture` used to indicate that the incoming healing is greater than the configured limits.
damageAbsorb              - A `StatusBar` used to represent damage absorbs.
overDamageAbsorbIndicator - A `Texture` used to signify that the amount of damage absorb is greater than the configured limits.
healAbsorb                - A `StatusBar` used to represent heal absorbs.
overHealAbsorbIndicator   - A `Texture` used to signify that the amount of heal absorb is greater than the configured limits.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.damageAbsorbClampMode - Defines how damage absorbs should clamp. See [Enum.UnitDamageAbsorbClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitDamageAbsorbClampMode).
.healAbsorbClampMode   - Defines how healing absorbs should clamp. See [Enum.UnitHealAbsorbClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitHealAbsorbClampMode).
.healAbsorbMode        - Defines how healing absorbs should be treated. See [Enum.UnitHealAbsorbMode](https://warcraft.wiki.gg/wiki/Enum.UnitHealAbsorbMode).
.incomingHealClampMode - Defines how incoming healing should clamp. See [Enum.UnitIncomingHealClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitIncomingHealClampMode).
.incomingHealOverflow  - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                         Defaults to 1.05 (number)

## Attributes

.values - A [unit heal prediction calculator](https://warcraft.wiki.gg/wiki/API_CreateUnitHealPredictionCalculator) used to calculate the values used in this element.

## Examples

This example does not contain all widgets or options, just a selection.

    -- Position and size
    local healingAll = CreateFrame('StatusBar', nil, self.Health)
    healingAll:SetPoint('TOP')
    healingAll:SetPoint('BOTTOM')
    healingAll:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    healingAll:SetWidth(200)
    healingAll:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

    local damageAbsorb = CreateFrame('StatusBar', nil, self.Health)
    damageAbsorb:SetPoint('TOP')
    damageAbsorb:SetPoint('BOTTOM')
    damageAbsorb:SetPoint('LEFT', healingAll:GetStatusBarTexture(), 'RIGHT')
    damageAbsorb:SetWidth(200)

    local healAbsorb = CreateFrame('StatusBar', nil, self.Health)
    healAbsorb:SetPoint('TOP')
    healAbsorb:SetPoint('BOTTOM')
    healAbsorb:SetPoint('RIGHT', self.Health:GetStatusBarTexture())
    healAbsorb:SetWidth(200)
    healAbsorb:SetReverseFill(true)

    local overDamageAbsorbIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    overDamageAbsorbIndicator:SetPoint('TOP')
    overDamageAbsorbIndicator:SetPoint('BOTTOM')
    overDamageAbsorbIndicator:SetPoint('LEFT', self.Health, 'RIGHT')
    overDamageAbsorbIndicator:SetWidth(10)

    local overHealAbsorbIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    overHealAbsorbIndicator:SetPoint('TOP')
    overHealAbsorbIndicator:SetPoint('BOTTOM')
    overHealAbsorbIndicator:SetPoint('RIGHT', self.Health, 'LEFT')
    overHealAbsorbIndicator:SetWidth(10)

    -- Register with oUF
    self.HealthPrediction = {
        healingAll = healingAll,
        damageAbsorb = damageAbsorb,
        healAbsorb = healAbsorb,
        overDamageAbsorbIndicator = overDamageAbsorbIndicator,
        overHealAbsorbIndicator = overHealAbsorbIndicator,

        -- extra options
        incomingHealOverflow = 1.2,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local function UpdateSize(self, event, unit)
	local element = self.HealthPrediction

	if(element.healingAll) then
		element.healingAll[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingAll, element.size)
	end

	if(element.healingPlayer) then
		element.healingPlayer[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingPlayer, element.size)
	end

	if(element.healingOther) then
		element.healingOther[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingOther, element.size)
	end

	if(element.damageAbsorb) then
		element.damageAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.damageAbsorb, element.size)
	end

	if(element.healAbsorb) then
		element.healAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healAbsorb, element.size)
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.HealthPrediction

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local maxHealth = UnitHealthMax(unit)
	UnitGetDetailedHealPrediction(unit, 'player', element.values)

	local allHeal, playerHeal, otherHeal, healClamped = element.values:GetIncomingHeals()
	if(element.healingAll) then
		element.healingAll:SetMinMaxValues(0, maxHealth)
		element.healingAll:SetValue(allHeal)
	end
	if(element.healingPlayer) then
		element.healingPlayer:SetMinMaxValues(0, maxHealth)
		element.healingPlayer:SetValue(playerHeal)
	end
	if(element.healingOther) then
		element.healingOther:SetMinMaxValues(0, maxHealth)
		element.healingOther:SetValue(otherHeal)
	end
	if(element.overHealIndicator) then
		element.overHealIndicator:SetAlphaFromBoolean(healClamped, 1, 0)
	end

	local damageAbsorbAmount, damageAbsorbClamped = element.values:GetDamageAbsorbs()
	if(element.damageAbsorb) then
		element.damageAbsorb:SetMinMaxValues(0, maxHealth)
		element.damageAbsorb:SetValue(damageAbsorbAmount)
	end
	if(element.overDamageAbsorbIndicator) then
		element.overDamageAbsorbIndicator:SetAlphaFromBoolean(damageAbsorbClamped, 1, 0)
	end

	local healAbsorbAmount, healAbsorbClamped = element.values:GetHealAbsorbs()
	if(element.healAbsorb) then
		element.healAbsorb:SetMinMaxValues(0, maxHealth)
		element.healAbsorb:SetValue(healAbsorbAmount)
	end
	if(element.overHealAbsorbIndicator) then
		element.overHealAbsorbIndicator:SetAlphaFromBoolean(healAbsorbClamped, 1, 0)
	end

	--[[ Callback: HealthPrediction:PostUpdate(unit)
	Called after the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit)
	end
end

local function shouldUpdateSize(self)
	if(not self.Health) then return end

	local isHoriz = self.Health:GetOrientation() == 'HORIZONTAL'
	local newSize = self.Health[isHoriz and 'GetWidth' or 'GetHeight'](self.Health)
	if(isHoriz ~= self.HealthPrediction.isHoriz or newSize ~= self.HealthPrediction.size) then
		self.HealthPrediction.isHoriz = isHoriz
		self.HealthPrediction.size = newSize

		return true
	end
end

local function Path(self, ...)
	--[[ Override: HealthPrediction.UpdateSize(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' size.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	if(shouldUpdateSize(self)) then
		(self.HealthPrediction.UpdateSize or UpdateSize) (self, ...)
	end

	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.HealthPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	element.isHoriz = nil
	element.size = nil

	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.HealthPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(element.values) then
			element.values:Reset()
		else
			element.values = CreateUnitHealPredictionCalculator()
		end

		if(element.damageAbsorbClampMode) then
			element.values:SetDamageAbsorbClampMode(element.damageAbsorbClampMode)
		end

		if(element.healAbsorbClampMode) then
			element.values:SetHealAbsorbClampMode(element.healAbsorbClampMode)
		end

		if(element.healAbsorbMode) then
			element.values:SetHealAbsorbMode(element.healAbsorbMode)
		end

		if(element.incomingHealClampMode) then
			element.values:SetIncomingHealClampMode(element.incomingHealClampMode)
		end

		if(element.incomingHealOverflow) then
			element.values:SetIncomingHealOverflowPercent(element.incomingHealOverflow)
		end

		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
		self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
		self:RegisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)

		if(element.healingAll) then
			if(element.healingAll:IsObjectType('StatusBar') and not element.healingAll:GetStatusBarTexture()) then
				element.healingAll:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healingPlayer) then
			if(element.healingPlayer:IsObjectType('StatusBar') and not element.healingPlayer:GetStatusBarTexture()) then
				element.healingPlayer:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healingOther) then
			if(element.healingOther:IsObjectType('StatusBar') and not element.healingOther:GetStatusBarTexture()) then
				element.healingOther:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overHealIndicator) then
			if(element.overHealIndicator:IsObjectType('Texture') and not element.overHealIndicator:GetTexture()) then
				element.overHealIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overHealIndicator:SetBlendMode('ADD')
			end
		end

		if(element.damageAbsorb) then
			if(element.damageAbsorb:IsObjectType('StatusBar') and not element.damageAbsorb:GetStatusBarTexture()) then
				element.damageAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healAbsorb) then
			if(element.healAbsorb:IsObjectType('StatusBar') and not element.healAbsorb:GetStatusBarTexture()) then
				element.healAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overDamageAbsorbIndicator) then
			if(element.overDamageAbsorbIndicator:IsObjectType('Texture') and not element.overDamageAbsorbIndicator:GetTexture()) then
				element.overDamageAbsorbIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overDamageAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		if(element.overHealAbsorbIndicator) then
			if(element.overHealAbsorbIndicator:IsObjectType('Texture') and not element.overHealAbsorbIndicator:GetTexture()) then
				element.overHealAbsorbIndicator:SetTexture([[Interface\RaidFrame\Absorb-Overabsorb]])
				element.overHealAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.HealthPrediction
	if(element) then
		if(element.healingAll) then
			element.healingAll:Hide()
		end

		if(element.healingPlayer) then
			element.healingPlayer:Hide()
		end

		if(element.healingOther) then
			element.healingOther:Hide()
		end

		if(element.overHealIndicator) then
			element.overHealIndicator:Hide()
		end

		if(element.damageAbsorb) then
			element.damageAbsorb:Hide()
		end

		if(element.healAbsorb) then
			element.healAbsorb:Hide()
		end

		if(element.overDamageAbsorbIndicator) then
			element.overDamageAbsorbIndicator:Hide()
		end

		if(element.overHealAbsorbIndicator) then
			element.overHealAbsorbIndicator:Hide()
		end

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
		self:UnregisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
		self:UnregisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
	end
end

oUF:AddElement('HealthPrediction', Path, Enable, Disable)
