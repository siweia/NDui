local _, ns = ...
local oUF = ns.oUF

local MAINTANK_ICON = [[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]
local MAINASSIST_ICON = [[Interface\GROUPFRAME\UI-GROUP-MAINASSISTICON]]

local function Update(self, event)
	local unit = self.unit

	local element = self.RaidRoleIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local role, isShown
	if(UnitInRaid(unit) and not UnitHasVehicleUI(unit)) then
		if(GetPartyAssignment('MAINTANK', unit)) then
			isShown = true
			element:SetTexture(MAINTANK_ICON)
			role = 'MAINTANK'
		elseif(GetPartyAssignment('MAINASSIST', unit)) then
			isShown = true
			element:SetTexture(MAINASSIST_ICON)
			role = 'MAINASSIST'
		end
	end

	element:SetShown(isShown)

	if(element.PostUpdate) then
		return element:PostUpdate(role)
	end
end

local function Path(self, ...)
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

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('RaidRoleIndicator', Path, Enable, Disable)