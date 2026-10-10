--[[
# Element: Target Indicator

Toggles the visibility of an indicator based on the player's target.

## Widget

TargetIndicator - Any UI widget.

## Examples

    -- Position and size
    local TargetIndicator = self:CreateTexture(nil, 'OVERLAY')
    TargetIndicator:SetSize(16, 16)
    TargetIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.TargetIndicator = TargetIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.TargetIndicator

	--[[ Callback: TargetIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the TargetIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isTargeted = UnitIsUnit(self.__unit, 'target')
	element:SetShown(isTargeted)

	--[[ Callback: TargetIndicator:PostUpdate(isTargeted)
	Called after the element has been updated.

	* self       - the TargetIndicator element
	* isTargeted - indicates if the unit is targeted (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isTargeted)
	end
end

local function Path(self, ...)
	--[[ Override: TargetIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.TargetIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.TargetIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element:Hide()

		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

oUF:AddElement('TargetIndicator', Path, Enable, Disable)
