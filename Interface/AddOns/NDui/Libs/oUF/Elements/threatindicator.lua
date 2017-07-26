local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.ThreatIndicator
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local feedbackUnit = element.feedbackUnit
	unit = unit or self.unit

	local status
	if(UnitExists(unit)) then
		if(feedbackUnit and feedbackUnit ~= unit and UnitExists(feedbackUnit)) then
			status = UnitThreatSituation(feedbackUnit, unit)
		else
			status = UnitThreatSituation(unit)
		end
	end

	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)

		if(element.SetVertexColor) then
			element:SetVertexColor(r, g, b)
		end

		element:Show()
	else
		element:Hide()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, status, r, g, b)
	end
end

local function Path(self, ...)
	return (self.ThreatIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ThreatIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', Path)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\Minimap\ObjectIcons]])
			element:SetTexCoord(6/8, 7/8, 1/8, 2/8)
		end

		return true
	end
end

local function Disable(self)
	local element = self.ThreatIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_THREAT_SITUATION_UPDATE', Path)
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', Path)
	end
end

oUF:AddElement('ThreatIndicator', Path, Enable, Disable)