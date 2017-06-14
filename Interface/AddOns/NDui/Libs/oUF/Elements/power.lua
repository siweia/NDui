local _, ns = ...
local oUF = ns.oUF

-- sourced from FrameXML/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX or 10

local function getDisplayPower(unit)
	local _, min, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(showOnRaid) then
		return ALTERNATE_POWER_INDEX, min
	end
end

local function UpdateColor(element, unit, cur, min, max, displayType)
	local parent = element.__owner
	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)

	local r, g, b, t
	if(element.colorTapping and element.tapped) then
		t = parent.colors.tapped
	elseif(element.colorDisconnected and element.disconnected) then
		t = parent.colors.disconnected
	elseif(displayType == ALTERNATE_POWER_INDEX and element.altPowerColor) then
		t = element.altPowerColor
	elseif(element.colorPower) then
		t = parent.colors.power[ptoken]
		if(not t) then
			if(element.GetAlternativeColor) then
				r, g, b = element:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
			elseif(altR) then
				r, g, b = altR, altG, altB

				if(r > 1 or g > 1 or b > 1) then
					-- BUG: As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
					r, g, b = r / 255, g / 255, b / 255
				end
			else
				t = parent.colors.power[ptype]
			end
		end
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = parent.colors.class[class]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		t = parent.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		local adjust = 0 - (min or 0)
		r, g, b = parent.ColorGradient(cur + adjust, max + adjust, unpack(element.smoothGradient or parent.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	t = parent.colors.power[ptoken or ptype]

	local atlas = element.atlas or (t and t.atlas)
	if(element.useAtlas and atlas and displayType ~= ALTERNATE_POWER_INDEX) then
		element:SetStatusBarAtlas(atlas)
		element:SetStatusBarColor(1, 1, 1)

		if(element.colorTapping or element.colorDisconnected) then
			t = element.disconnected and parent.colors.disconnected or parent.colors.tapped
			element:GetStatusBarTexture():SetDesaturated(element.disconnected or element.tapped)
		end

		if(t and (r or g or b)) then
			r, g, b = t[1], t[2], t[3]
		end
	else
		element:SetStatusBarTexture(element.texture)

		if(r or g or b) then
			element:SetStatusBarColor(r, g, b)
		end
	end

	local bg = element.bg
	if(bg and b) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end
	local element = self.Power

	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local displayType, min
	if(element.displayAltPower) then
		displayType, min = getDisplayPower(unit)
	end

	local cur, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	local disconnected = not UnitIsConnected(unit)
	local tapped = not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)
	element:SetMinMaxValues(min or 0, max)

	if(disconnected) then
		element:SetValue(max)
	else
		element:SetValue(cur)
	end

	element.disconnected = disconnected
	element.tapped = tapped

	element:UpdateColor(unit, cur, min, max, displayType)

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, min, max)
	end
end

local function Path(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Power
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(element.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_POWER', Path)
		end

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)
		self:RegisterEvent('UNIT_FACTION', Path) -- For tapping

		if(element:IsObjectType('StatusBar')) then
			element.texture = element:GetStatusBarTexture() and element:GetStatusBarTexture():GetTexture() or [[Interface\TargetingFrame\UI-StatusBar]]
			element:SetStatusBarTexture(element.texture)
		end

		if(not element.UpdateColor) then
			element.UpdateColor = UpdateColor
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Power
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)