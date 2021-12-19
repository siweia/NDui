--[[
	## Element: QuakeTimer, by Siweia

	Show a timer bar for Quake in Mythic+.

	## Optional:

	element.failColor		- insecure color
	element.passColor		- secure color
	element.timerFormat 	- timer format, eg "%.2f | %.2f", "%.1f"
	element.PostUpdate		- post update when event fired

	## Example:

	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("CENTER")
	bar:SetSize(100, 20)

	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(20, 20)
	icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
	bar.Icon = icon

	self.QuakeTimer = bar
]]
local _, ns = ...
local oUF = ns.oUF

local strfind, GetTime = strfind, GetTime
local UnitCastingInfo, UnitChannelInfo, UnitDebuff = UnitCastingInfo, UnitChannelInfo, UnitDebuff
local C_ChallengeMode_GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo

local DEBUFF_MAX_DISPLAY = _G.DEBUFF_MAX_DISPLAY
local failedColor, passedColor = {1, 0, 0}, {0, 1, 0}
local QUAKE_SPELLID = 240447

local function updateTimer(element)
	local current = GetTime()
	local duration = element.expires - current
	if duration < 0 then
		element:Hide()
	else
		local timer = element.duration - duration
		element:SetValue(timer)
		if element.Text then
			element.Text:SetFormattedText(element.timerFormat, timer, element.duration)
		end

		if element.endTime and element.endTime - current >= duration and not element.notInterruptible then
			element:SetStatusBarColor(element.failColor[1], element.failColor[2], element.failColor[3])
		else
			element:SetStatusBarColor(element.passColor[1], element.passColor[2], element.passColor[3])
		end
		element:Show()
	end
end

local function onEvent(self, event, unit)
	if not unit or unit ~= "player" then return end

	local element = self.QuakeTimer
	if event == "UNIT_AURA" then
		local found
		for i = 1, DEBUFF_MAX_DISPLAY do
			local name, texture, _, _, duration, expires, _, _, _, spellID = UnitDebuff(unit, i)
			if not name then break end
			if spellID == QUAKE_SPELLID then
				element.duration = duration
				element.expires = expires
				element:SetMinMaxValues(0, duration)
				if element.Icon then element.Icon:SetTexture(texture) end
				if element.SpellName then element.SpellName:SetText(name) end

				found = true
				break
			end
		end
		element:SetShown(found)
	elseif strfind(event, "START") then
		local name, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
		if not name then
			name, _, _, _, endTime, _, notInterruptible = UnitChannelInfo(unit)
		end
		if name then
			endTime = endTime / 1e3
			element.endTime = endTime
			element.notInterruptible = notInterruptible
		end
	elseif strfind(event, "STOP") then
		element.endTime = nil
		element.notInterruptible = false
	end

	if self.PostUpdate then self:PostUpdate(event, unit) end
end

local function EnableQuakeTimer(self)
	self:RegisterEvent("UNIT_AURA", onEvent)
	self:RegisterEvent("UNIT_SPELLCAST_START", onEvent)
	self:RegisterEvent("UNIT_SPELLCAST_STOP", onEvent)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", onEvent)
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", onEvent)
end

local function DisableQuakeTimer(self)
	self.QuakeTimer:Hide()
	self:UnregisterEvent("UNIT_AURA", onEvent)
	self:UnregisterEvent("UNIT_SPELLCAST_START", onEvent)
	self:UnregisterEvent("UNIT_SPELLCAST_STOP", onEvent)
	self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", onEvent)
	self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", onEvent)
end

local function CheckCurrentAffixes(self)
	local _, affixes = C_ChallengeMode_GetActiveKeystoneInfo()
	if affixes[3] and affixes[3] == 14 then
		EnableQuakeTimer(self)
	else
		DisableQuakeTimer(self)
	end
end

local function Enable(self)
	local element = self.QuakeTimer

	if element then
		element.failColor = element.failColor or failedColor
		element.passColor = element.passColor or passedColor
		element.timerFormat = element.timerFormat or "%.2f | %.2f"
		if not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
		end
		element:SetScript("OnUpdate", updateTimer)

		CheckCurrentAffixes(self)
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", CheckCurrentAffixes, true)
		self:RegisterEvent("CHALLENGE_MODE_START", CheckCurrentAffixes, true)
		return true
	end
end

local function Disable(self)
	local element = self.QuakeTimer

	if element then
		DisableQuakeTimer(self)
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA", CheckCurrentAffixes)
		self:UnregisterEvent("CHALLENGE_MODE_START", CheckCurrentAffixes)
	end
end

oUF:AddElement("QuakeTimer", nil, Enable, Disable)