--[[
# Element: Happiness Indicator

Handles the visibility and updating of an indicator for the player's pet happiness.

## Widget

Happiness - A `Texture` used to display pet happiness.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local Happiness = self:CreateTexture(nil, 'OVERLAY')
    Happiness:SetSize(16, 16)
    Happiness:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.Happiness = Happiness
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local GameVersion = Private.GameVersion

local function Update(self, event, unit)
	if(self.__unit ~= unit) then return end

	local element = self.Happiness

	--[[ Callback: Happiness:PreUpdate()
	Called before the element has been updated.

	* self - the Happiness element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local happiness = C_PetInfo.GetPetHappiness()
	if(happiness == 1) then
		element:SetAtlas('UI-PetMad')
		element:Show()
	elseif(happiness == 2) then
		element:SetAtlas('UI-PetNeutral')
		element:Show()
	elseif(happiness == 3) then
		element:SetAtlas('UI-PetHappiness')
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: Happiness:PostUpdate(happiness)
	Called after the element has been updated.

	* self      - the Happiness element
	* happiness - the happiness level of the pet (number?)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(happiness)
	end
end

local function Path(self, ...)
	--[[ Override: Happiness.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.Happiness.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.__unit)
end

local function Disable(self)
	local element = self.Happiness
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_HAPPINESS', Path)
	end
end

local function Enable(self, unit)
	if(not GameVersion.Forever or UnitClassBase('player') ~= 'HUNTER' or unit ~= 'pet') then
		Disable(self)
		return false
	end

	local element = self.Happiness
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_HAPPINESS', Path)

		return true
	end
end

oUF:AddElement('Happiness', Path, Enable, Disable)

-- TODO: consider adding a tooltip to it? with status and diet, like the default UI has
