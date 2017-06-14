local _, ns = ...
local oUF = ns.oUF

local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local function Update(self, event)
	local element = self.RaidTargetIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local index = GetRaidTargetIndex(self.unit)
	if(index) then
		SetRaidTargetIconTexture(element, index)
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(index)
	end
end

local function Path(self, ...)
	return (self.RaidTargetIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	if(not element.__owner.unit) then return end
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.RaidTargetIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('RAID_TARGET_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.RaidTargetIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('RAID_TARGET_UPDATE', Path)
	end
end

oUF:AddElement('RaidTargetIndicator', Path, Enable, Disable)