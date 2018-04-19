local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local unit = self.unit
	local element = self.MasterLooterIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isShown = false
	if(UnitInParty(unit) or UnitInRaid(unit)) then
		local method, partyIndex, raidIndex = GetLootMethod()
		if(method == 'master') then
			local mlUnit
			if(partyIndex) then
				if(partyIndex == 0) then
					mlUnit = 'player'
				else
					mlUnit = 'party' .. partyIndex
				end
			elseif(raidIndex) then
				mlUnit = 'raid' .. raidIndex
			end

			isShown = mlUnit and UnitIsUnit(unit, mlUnit)
		end
	end

	element:SetShown(isShown)

	if(element.PostUpdate) then
		return element:PostUpdate(isShown)
	end
end

local function Path(self, ...)
	return (self.MasterLooterIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.MasterLooterIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.MasterLooterIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('MasterLooterIndicator', Path, Enable, Disable)