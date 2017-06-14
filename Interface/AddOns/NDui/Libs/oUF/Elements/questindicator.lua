local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.QuestIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isQuestBoss = UnitIsQuestBoss(unit)
	if(isQuestBoss) then
		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(isQuestBoss)
	end
end

local function Path(self, ...)
	return (self.QuestIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.QuestIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('QuestIndicator', Path, Enable, Disable)