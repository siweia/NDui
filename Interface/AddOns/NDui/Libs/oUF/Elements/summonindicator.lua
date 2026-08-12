--[[
# Element: SummonIndicator

Handles the visibility and updating of an indicator based on the unit's incoming summon status.

## Widget

SummonIndicator - A `Texture` used to display if the unit has an incoming summon.

## Notes

This element updates by changing the texture.

## Options

.useAtlasSize - Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)

## Examples

    -- Position and size
    local SummonIndicator = self:CreateTexture(nil, 'OVERLAY')
    SummonIndicator:SetSize(32, 32)
    SummonIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.SummonIndicator = SummonIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(self.__unit ~= unit) then return end

	local element = self.SummonIndicator

	--[[ Callback: SummonIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the SummonIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local status = C_IncomingSummon.IncomingSummonStatus(unit)
	if(status ~= Enum.SummonStatus.None) then
		if(status == Enum.SummonStatus.Pending) then
			element:SetAtlas('RaidFrame-Icon-SummonPending', element.useAtlasSize)
		elseif(status == Enum.SummonStatus.Accepted) then
			element:SetAtlas('RaidFrame-Icon-SummonAccepted', element.useAtlasSize)
		elseif(status == Enum.SummonStatus.Declined) then
			element:SetAtlas('RaidFrame-Icon-SummonDeclined', element.useAtlasSize)
		end

		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: SummonIndicator:PostUpdate(status)
	Called after the element has been updated.

	* self  - the SummonIndicator element
	* status - the unit's incoming summon status (number)[0-3]
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(status)
	end
end

local function Path(self, ...)
	--[[ Override: SummonIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.SummonIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.__unit)
end

local function Enable(self)
	local element = self.SummonIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('INCOMING_SUMMON_CHANGED', Path)

		return true
	end
end

local function Disable(self)
	local element = self.SummonIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('INCOMING_SUMMON_CHANGED', Path)
	end
end

oUF:AddElement('SummonIndicator', Path, Enable, Disable)
