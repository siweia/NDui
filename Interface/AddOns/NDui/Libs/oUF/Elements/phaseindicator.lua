local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.PhaseIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isInSamePhase = UnitInPhase(self.unit)
	if(isInSamePhase) then
		element:Hide()
	else
		element:Show()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(isInSamePhase)
	end
end

local function Path(self, ...)
	return (self.PhaseIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.PhaseIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_PHASE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\UI-PhasingIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.PhaseIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_PHASE', Path)
	end
end

oUF:AddElement('PhaseIndicator', Path, Enable, Disable)