local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.LeaderIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local unit = self.unit
	local isLeader = (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit)
	if(isLeader) then
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(isLeader)
	end
end

local function Path(self, ...)
	return (self.LeaderIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.LeaderIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LEADER_CHANGED', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.LeaderIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PARTY_LEADER_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('LeaderIndicator', Path, Enable, Disable)