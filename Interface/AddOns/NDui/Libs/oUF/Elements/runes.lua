if(select(2, UnitClass('player')) ~= 'DEATHKNIGHT') then return end

local _, ns = ...
local oUF = ns.oUF

local function onUpdate(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
end

local function UpdateColor(element, runeID)
	local spec = GetSpecialization() or 0

	local color
	if(spec ~= 0 and element.colorSpec) then
		color = element.__owner.colors.runes[spec]
	else
		color = element.__owner.colors.power.RUNES
	end

	local r, g, b = color[1], color[2], color[3]

	element[runeID]:SetStatusBarColor(r, g, b)

	local bg = element[runeID].bg
	if(bg) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
end

local function Update(self, event, runeID, energized)
	local element = self.Runes
	local rune = element[runeID]
	if(not rune) then return end

	local start, duration, runeReady
	if(UnitHasVehicleUI('player')) then
		rune:Hide()
	else
		start, duration, runeReady = GetRuneCooldown(runeID)
		if(not start) then return end

		if(energized or runeReady) then
			rune:SetMinMaxValues(0, 1)
			rune:SetValue(1)
			rune:SetScript('OnUpdate', nil)
			rune:SetAlpha(1)
		else
			rune.duration = GetTime() - start
			rune.max = duration
			rune:SetMinMaxValues(0, duration)
			rune:SetValue(0)
			rune:SetScript('OnUpdate', onUpdate)
			rune:SetAlpha(.7)
		end

		rune:Show()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(rune, runeID, energized and 0 or start, duration, energized or runeReady)
	end
end

local function Path(self, event, ...)
	local element = self.Runes

	local UpdateMethod = element.Override or Update
	if(event == 'RUNE_POWER_UPDATE') then
		return UpdateMethod(self, event, ...)
	else
		local UpdateColorMethod = element.UpdateColor or UpdateColor
		for index = 1, #element do
			UpdateColorMethod(element, index)
			UpdateMethod(self, event, index)
		end
	end
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.Runes
	if(element and unit == 'player') then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			local rune = element[i]
			if(rune:IsObjectType('StatusBar') and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', Path, true)
		self:RegisterEvent('RUNE_POWER_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.Runes
	if(element) then
		for i = 1, #element do
			element[i]:Hide()
		end

		self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', Path)
		self:UnregisterEvent('RUNE_POWER_UPDATE', Path)
	end
end

oUF:AddElement('Runes', Path, Enable, Disable)