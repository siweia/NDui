local _, ns = ...
local oUF = ns.oUF

local roleTexCoord = {
	["TANK"] = {.5, .75, 0, 1},
	["HEALER"] = {.75, 1, 0, 1},
	["DAMAGER"] = {.25, .5, 0, 1},
}

local function Update(self, event)
	local element = self.GroupRoleIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local role = UnitGroupRolesAssigned(self.unit)
	if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') then
		--element:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
		element:SetTexCoord(unpack(roleTexCoord[role]))
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(role)
	end
end

local function Path(self, ...)
	return (self.GroupRoleIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.GroupRoleIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(self.unit == 'player') then
			self:RegisterEvent('PLAYER_ROLES_ASSIGNED', Path, true)
		else
			self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)
		end

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			--element:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
			element:SetTexture([[Interface\LFGFrame\LFGROLE]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.GroupRoleIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_ROLES_ASSIGNED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('GroupRoleIndicator', Path, Enable, Disable)