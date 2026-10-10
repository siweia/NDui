--[[
# Element: Group Role Indicator

Toggles the visibility of an indicator based on the unit's current group role (tank, healer or damager).

## Widget

GroupRoleIndicator - A `Texture` used to display the group role icon.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Options

.useAtlasSize - (DEPRECATED) Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)
.tankAtlas    - Overrides the default atlas texture for tank (string)
.healerAtlas  - Overrides the default atlas texture for healer (string)
.damageAtlas  - Overrides the default atlas texture for damage (string)

## Examples

    -- Position and size
    local GroupRoleIndicator = self:CreateTexture(nil, 'OVERLAY')
    GroupRoleIndicator:SetSize(16, 16)
    GroupRoleIndicator:SetPoint('LEFT', self)

    -- Register it with oUF
    self.GroupRoleIndicator = GroupRoleIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local GameVersion = Private.GameVersion

local STATE = {}

local function Update(self, event)
	local element = self.GroupRoleIndicator

	--[[ Callback: GroupRoleIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the GroupRoleIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local role -- TODO: remove in 12.1.5

	if(GameVersion.PTR or GameVersion.Forever) then
		-- we have to set the unit here, not during Enable, as the unit is not valid then
		STATE[element].unit = self.__unit

		UnitFrameUtil.UpdateUnitFrameRoleIcon(STATE[element])
	else
		role = UnitGroupRolesAssignedEnum(self.__unit)
		if(issecretvalue(role)) then
			role = nil
		end

		if(role == Enum.LFGRole.Tank) then
			element:SetAtlas('UI-LFG-RoleIcon-Tank-Micro-Raid', element.useAtlasSize)
			element:Show()
		elseif(role == Enum.LFGRole.Healer) then
			element:SetAtlas('UI-LFG-RoleIcon-Healer-Micro-Raid', element.useAtlasSize)
			element:Show()
		elseif(role == Enum.LFGRole.Damage) then
			element:SetAtlas('UI-LFG-RoleIcon-DPS-Micro-Raid', element.useAtlasSize)
			element:Show()
		else
			element:Hide()
		end
	end

	--[[ Callback: GroupRoleIndicator:PostUpdate(role)
	Called after the element has been updated.

	* self - the GroupRoleIndicator element
	* role - (DEPRECATED) the role as returned by [UnitGroupRolesAssignedEnum](https://warcraft.wiki.gg/wiki/API_UnitGroupRolesAssignedEnum) (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(role)
	end
end

local function Path(self, ...)
	--[[ Override: GroupRoleIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.GroupRoleIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.GroupRoleIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(GameVersion.PTR or GameVersion.Forever) then
			STATE[element] = {
				roleIcon = element,
				optionTable = {
					displayRoleIcon = true,
					textureMap = {
						TANK = element.tankAtlas or 'UI-LFG-RoleIcon-Tank-Micro-Raid',
						HEALER = element.healerAtlas or 'UI-LFG-RoleIcon-Healer-Micro-Raid',
						DAMAGER = element.damageAtlas or 'UI-LFG-RoleIcon-DPS-Micro-Raid',
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
			if(unit == 'player') then
				self:RegisterEvent('PLAYER_ROLES_ASSIGNED', Path, true)
			else
				self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.GroupRoleIndicator
	if(element) then
		element:Hide()

		if(GameVersion.PTR) then
			self:UnregisterEvent('PLAYER_ROLES_ASSIGNED', Path)
		else
			self:UnregisterEvent('PLAYER_ROLES_ASSIGNED', Path)
			self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path, true)
		end
	end
end

oUF:AddElement('GroupRoleIndicator', Path, Enable, Disable)
