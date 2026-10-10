--[[
# Element: Raid Role Indicator

Handles the visibility and updating of an indicator based on the unit's raid assignment (main tank or main assist).

## Widget

RaidRoleIndicator - A `Texture` representing the unit's raid assignment.

## Notes

This element updates by changing the texture.

## Options

.useAtlasSize    - (DEPRECATED) Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)
.mainTankAtlas   - Overrides the default atlas texture for main tank (string)
.mainAssistAtlas - Overrides the default atlas texture for main assist (string)

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
local Private = oUF.Private

local GameVersion = Private.GameVersion

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

	local role -- TODO: remove in 12.1.5

	if(GameVersion.PTR or GameVersion.Forever) then
		-- we have to set the unit here, not during Enable, as the unit is not valid then
		STATE[element].unit = unit

		UnitFrameUtil.UpdateUnitFrameRoleIcon(STATE[element])
	else
		if(event == 'OnShow') then
			STATE[element] = {}
		end

		local shouldShow
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
	end

	--[[ Callback: RaidRoleIndicator:PostUpdate(role)
	Called after the element has been updated.

	* self - the RaidRoleIndicator element
	* role - (DEPRECATED) the unit's raid assignment (string?)['MAINTANK', 'MAINASSIST']
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

		if(GameVersion.PTR or GameVersion.Forever) then
			STATE[element] = {
				roleIcon = element,
				optionTable = {
					displayRaidRoleIcon = true,
					textureMap = {
						MAINTANK = element.mainTankAtlas,
						MAINASSIST = element.mainAssistAtlas,
					}
				}
			}

			if(GameVersion.Forever) then
				STATE[element].optionTable.displayVehicleRoleIcon = false
			else
				STATE[element].optionTable.textureMap.VEHICLE = ''
			end

			self:RegisterEvent('PLAYER_ROLES_ASSIGNED', Path, true)
		else
			STATE[element] = {}

			self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)
			self:RegisterEvent('PLAYER_REGEN_ENABLED', Path, true)
		end

		return true
	end
end

local function Disable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element:Hide()

		if(GameVersion.PTR) then
			self:UnregisterEvent('PLAYER_ROLES_ASSIGNED', Path)
		else
			self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
			self:UnregisterEvent('PLAYER_REGEN_ENABLED', Path)
		end
	end
end

oUF:AddElement('RaidRoleIndicator', Path, Enable, Disable)
