--[[
	## Element: PartyWatcher, by Siweia

	Spell watcher in party for Mythic+.

	## Optional:

	element.PartySpells		- spell list
	element.TalentCDFix		- spell list for talent cd
	element.__max			- max icons for tracking
	element.PostUpdate		- post update when event fired

	## Example:

	local buttons = {}
	buttons.__max = 3
	for i = 1, buttons.__max do
		local bu = CreateFrame("Frame", nil, self)
		bu:SetSize(50, 50)
		bu.CD = CreateFrame("Cooldown", nil, bu, "CooldownFrameTemplate")
		bu.CD:SetAllPoints()
		bu.CD:SetReverse(false)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexCoord(.08, .92, .08, .92)
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -(2+50)*(i-1)-5, 0)
		bu:Hide()

		buttons[i] = bu
	end

	self.PartyWatcher = buttons
]]
local _, ns = ...
local oUF = ns.oUF
local GetTime, GetSpellTexture = GetTime, GetSpellTexture

local function Update(self, event, unit, _, spellID)
	if unit ~= self.unit then return end

	local element = self.PartyWatcher
	local maxButtons = #element
	local index = element.index
	local duration = element.PartySpells[spellID]
	local talentCDFix = element.TalentCDFix[spellID]

	if duration and index <= maxButtons then
		local thisTime = GetTime()
		for i = 1, maxButtons do
			local button = element[i]
			if button.spellID and button.spellID == spellID then
				if talentCDFix and (thisTime-button.lastTime+1) <= duration then -- 1s latency
					duration = talentCDFix
				end
				button.lastTime = thisTime
				button.CD:SetCooldown(thisTime, duration)
				return
			end
		end

		index = index + 1
		if index > maxButtons then return end
		element.index = index

		local button = element[index]
		button.lastTime = thisTime
		button.CD:SetCooldown(thisTime, duration)
		button.Icon:SetTexture(GetSpellTexture(spellID))
		button.spellID = spellID
		button:Show()
	end

	if self.PostUpdate then self:PostUpdate(event, unit, spellID) end
end

local function ResetButtons(self)
	local element = self.PartyWatcher
	element.index = 0
	for i = 1, element.__max do
		local button = element[i]
		button.spellID = nil
		button:Hide()
	end
end

local function Enable(self)
	local element = self.PartyWatcher

	if element then
		element.index = 0
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", ResetButtons, true)
		self:RegisterEvent("GROUP_LEFT", ResetButtons, true)
		self:RegisterEvent("CHALLENGE_MODE_START", ResetButtons, true)
		return true
	end
end

local function Disable(self)
	local element = self.PartyWatcher

	if element then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
		self:UnregisterEvent("GROUP_ROSTER_UPDATE", ResetButtons)
		self:UnregisterEvent("GROUP_LEFT", ResetButtons)
		self:UnregisterEvent("CHALLENGE_MODE_START", ResetButtons)
	end
end

oUF:AddElement("PartyWatcher", nil, Enable, Disable)