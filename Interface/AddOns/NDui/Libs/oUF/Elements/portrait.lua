local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Portrait

	if(element.PreUpdate) then element:PreUpdate(unit) end

	if(element:IsObjectType('PlayerModel')) then
		local guid = UnitGUID(unit)
		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
			element:SetCamDistanceScale(0.25)
			element:SetPortraitZoom(0)
			element:SetPosition(0, 0, 0.5)
			element:ClearModel()
			element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			element.guid = nil
		elseif(element.guid ~= guid or event == 'UNIT_MODEL_CHANGED') then
			element:SetCamDistanceScale(1)
			element:SetPortraitZoom(1)
			element:SetPosition(0, 0, 0)
			element:ClearModel()
			element:SetUnit(unit)
			element.guid = guid
		end
	else
		SetPortraitTexture(element, unit)
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit)
	end
end

local function Path(self, ...)
	return (self.Portrait.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Portrait
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_PORTRAIT_UPDATE', Path)
		self:RegisterEvent('UNIT_MODEL_CHANGED', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)

		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Portrait
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_PORTRAIT_UPDATE', Path)
		self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)