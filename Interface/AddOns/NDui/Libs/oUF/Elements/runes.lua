if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local parent, ns = ...
local oUF = ns.oUF

oUF.colors.runes = {
	{1, 0, 0},   -- blood
	{0, 1, 1},   -- frost
	{0, .5, 0},  -- unholy
	{.9, .1, 1}, -- death
}

local runemap = { 1, 2, 5, 6, 3, 4 }

local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end

local UpdateType = function(self, event, rid, alt)
	local runes = self.Runes
	local rune = runes[runemap[rid]]
	local colors = self.colors.runes[GetRuneType(rid) or alt]
	local r, g, b = colors[1], colors[2], colors[3]

	rune:SetStatusBarColor(r, g, b)

	if(rune.bg) then
		local mu = rune.bg.multiplier or 1
		rune.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(runes.PostUpdateType) then
		return runes:PostUpdateType(rune, rid, alt)
	end
end

local UpdateRune = function(self, event, rid)
	local runes = self.Runes
	local rune = runes[runemap[rid]]
	if(not rune) then return end

	local start, duration, runeReady = GetRuneCooldown(rid)
	if(runeReady) then
		rune:SetMinMaxValues(0, 1)
		rune:SetValue(1)
		rune:SetScript("OnUpdate", nil)
	else
		rune.duration = GetTime() - start
		rune.max = duration
		rune:SetMinMaxValues(1, duration)
		rune:SetScript("OnUpdate", OnUpdate)
	end

	if(runes.PostUpdateRune) then
		return runes:PostUpdateRune(rune, rid, start, duration, runeReady)
	end
end

local Update = function(self, event)
	for i=1, 6 do
		UpdateRune(self, event, i)
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local runes = self.Runes
	if(runes and unit == 'player') then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate

		for i=1, 6 do
			local rune = runes[runemap[i]]
			if(rune:IsObjectType'StatusBar' and not rune:GetStatusBarTexture()) then
				rune:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
			end

			-- From my minor testing this is a okey solution. A full login always remove
			-- the death runes, or at least the clients knowledge about them.
			UpdateType(self, nil, i, math.floor((i+1)/2))
		end

		self:RegisterEvent("RUNE_POWER_UPDATE", UpdateRune, true)
		self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType, true)

		-- oUF leaves the vehicle events registered on the player frame, so
		-- buffs and such are correctly updated when entering/exiting vehicles.
		--
		-- This however makes the code also show/hide the RuneFrame.
		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local Disable = function(self)
	RuneFrame.Show = nil
	RuneFrame:Show()

	self:UnregisterEvent("RUNE_POWER_UPDATE", UpdateRune)
	self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)
end

oUF:AddElement("Runes", Update, Enable, Disable)