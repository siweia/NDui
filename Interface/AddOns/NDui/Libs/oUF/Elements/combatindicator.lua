local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.CombatIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local inCombat = UnitAffectingCombat('player')
	if(inCombat) then
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(inCombat)
	end
end

local function Path(self, ...)
	return (self.CombatIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.CombatIndicator
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_REGEN_DISABLED', Path, true)
		self:RegisterEvent('PLAYER_REGEN_ENABLED', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
			element:SetTexCoord(.5, 1, 0, .49)
		end

		return true
	end
end

local function Disable(self)
	local element = self.CombatIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_REGEN_DISABLED', Path)
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Path)
	end
end

oUF:AddElement('CombatIndicator', Path, Enable, Disable)