--[[
# Element: Focus Indicator

Toggles the visibility of an indicator based on the player's focus target.

## Widget

FocusIndicator - Any UI widget.

## Examples

    -- Position and size
    local FocusIndicator = self:CreateTexture(nil, 'OVERLAY')
    FocusIndicator:SetSize(16, 16)
    FocusIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.FocusIndicator = FocusIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.FocusIndicator

	--[[ Callback: FocusIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the FocusIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isFocused = UnitIsUnit(self.__unit, 'focus')
	element:SetShown(isFocused)

	--[[ Callback: FocusIndicator:PostUpdate(isFocused)
	Called after the element has been updated.

	* self       - the FocusIndicator element
	* isFocused - indicates if the unit is focused (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isFocused)
	end
end

local function Path(self, ...)
	--[[ Override: FocusIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.FocusIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.FocusIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element:Hide()

		self:RegisterEvent('PLAYER_FOCUS_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.FocusIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_FOCUS_CHANGED', Path)
	end
end

oUF:AddElement('FocusIndicator', Path, Enable, Disable)
