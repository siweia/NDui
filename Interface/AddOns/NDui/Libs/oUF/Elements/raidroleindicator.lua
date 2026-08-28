--[[
# Element: Raid Role Indicator

Handles the visibility and updating of an indicator based on the unit's raid assignment (main tank or main assist).

## Widget

RaidRoleIndicator - A `Texture` representing the unit's raid assignment.

## Notes

This element updates by changing the texture.

## Options

.useAtlasSize - Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)

## Examples

    -- Position and size
    local RaidRoleIndicator = self:CreateTexture(nil, 'OVERLAY')
    RaidRoleIndicator:SetSize(16, 16)
    RaidRoleIndicator:SetPoint('TOPLEFT')

    -- Register it with oUF
    self.RaidRoleIndicator = RaidRoleIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local STATE = {}

local function Update(self, event)
	local element = self.RaidRoleIndicator
	local unit = self.__unit

	--[[ Callback: RaidRoleIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the RaidRoleIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	if(event == 'OnShow') then
		STATE[element] = {}
	end

	local role, shouldShow
	if(UnitInRaid(unit) ~= nil and not UnitHasVehicleUI(unit)) then
		local isMainTank = GetPartyAssignment('MAINTANK', unit)
		if(issecretvalue(isMainTank)) then
			isMainTank = STATE[element].isMainTank
		else
			STATE[element].isMainTank = isMainTank
		end

		local isMainAssist = GetPartyAssignment('MAINASSIST', unit)
		if(issecretvalue(isMainAssist)) then
			isMainAssist = STATE[element].isMainAssist
		else
			STATE[element].isMainAssist = isMainAssist
		end

		if(isMainTank) then
			role = 'MAINTANK'
			shouldShow = true
			element:SetAtlas('RaidFrame-Icon-MainTank', element.useAtlasSize)
		elseif(isMainAssist) then
			role = 'MAINASSIST'
			shouldShow = true
			element:SetAtlas('RaidFrame-Icon-MainAssist', element.useAtlasSize)
		end
	end

	element:SetShown(shouldShow)

	--[[ Callback: RaidRoleIndicator:PostUpdate(role)
	Called after the element has been updated.

	* self - the RaidRoleIndicator element
	* role - the unit's raid assignment (string?)['MAINTANK', 'MAINASSIST']
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(role)
	end
end

local function Path(self, ...)
	--[[ Override: RaidRoleIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.RaidRoleIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		STATE[element] = {}

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)
		self:RegisterEvent('PLAYER_REGEN_ENABLED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Path)
	end
end

oUF:AddElement('RaidRoleIndicator', Path, Enable, Disable)