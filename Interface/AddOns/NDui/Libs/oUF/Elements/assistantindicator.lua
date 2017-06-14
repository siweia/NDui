local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.AssistantIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local unit = self.unit
	local isAssistant = UnitInRaid(unit) and UnitIsGroupAssistant(unit) and not UnitIsGroupLeader(unit)
	if(isAssistant) then
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(isAssistant)
	end
end

local function Path(self, ...)
	return (self.AssistantIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.AssistantIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.AssistantIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('AssistantIndicator', Path, Enable, Disable)