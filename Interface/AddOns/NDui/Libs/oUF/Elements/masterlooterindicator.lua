--[[
# Element: Master Looter Indicator

Handles the visibility and updating of an indicator for the unit's master looter status.

## Widget

MasterLooterIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local MasterLooterIndicator = self:CreateTexture(nil, 'OVERLAY')
    MasterLooterIndicator:SetSize(16, 16)
    MasterLooterIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.MasterLooterIndicator = MasterLooterIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local unitIsUnit = Private.unitIsUnit
local GameVersion = Private.GameVersion

local function Update(self, event, unit)
	if(self.__unit ~= unit) then return end

	local element = self.MasterLooterIndicator

	--[[ Callback: MasterLooterIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the MasterLooterIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local shouldShow = false
	if(UnitInParty(unit) or UnitInRaid(unit) ~= nil) then
		local method, partyIndex, raidIndex = C_PartyInfo.GetLootMethod()
		if(method == Enum.LootMethod.Masterlooter) then
			local looterUnit
			if(partyIndex) then
				if(partyIndex == 0) then
					looterUnit = 'player'
				else
					looterUnit = 'party' .. partyIndex
				end
			elseif(raidIndex) then
				looterUnit = 'raid' .. raidIndex
			end

			shouldShow = looterUnit and unitIsUnit(unit, looterUnit)
		end
	end

	element:SetShown(shouldShow)

	--[[ Callback: MasterLooterIndicator:PostUpdate()
	Called after the element has been updated.

	* self - the MasterLooterIndicator element
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate()
	end
end

local function Path(self, ...)
	--[[ Override: MasterLooterIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.MasterLooterIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.__unit)
end

local function Disable(self)
	local element = self.MasterLooterIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path) -- TBD: do we need this or does oUF handle it for us?
	end
end

local function Enable(self, unit)
	if(not GameVersion.Forever) then
		Disable(self)
		return false
	end

	local element = self.MasterLooterIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path) -- TBD: do we need this or does oUF handle it for us?

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

oUF:AddElement('MasterLooterIndicator', Path, Enable, Disable)
