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

local _G = getfenv(0)
local DEBUFF_MAX_DISPLAY = _G.DEBUFF_MAX_DISPLAY
local format, strfind = string.format, string.find

local function updateTimer(self)
	local duration = self.expires - GetTime()
	if duration < 0 then
		self:Hide()
	else
		local timer = self.duration - duration
		self:SetValue(timer)
		if self.Text then
			self.Text:SetText(format(self.timerFormat, timer, self.duration))
		end

		if self.endTime and self.endTime - GetTime() >= duration and not self.notInterruptible then
			self:SetStatusBarColor(unpack(self.failColor))
		else
			self:SetStatusBarColor(unpack(self.passColor))
		end
		self:Show()
	end
end

local function onEvent(self, event, unit)
	if not unit or unit ~= "player" then return end
	local element = self.QuakeTimer

	if event == "UNIT_AURA" then
		local found
		for i = 1, DEBUFF_MAX_DISPLAY do
			local name, texture, _, _, duration, expires, _, _, _, spellID = UnitDebuff(unit, i)
			if name and spellID == 240447 then
				element.duration = duration
				element.expires = expires
				element:SetMinMaxValues(0, duration)
				if element.SpellName then element.SpellName:SetText(name) end
				if element.Icon then element.Icon:SetTexture(texture) end

				found = true
				break
			end
		end
		element:SetShown(found)
	elseif strfind(event, "START") then
		local name, _, _, _, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
		if not name then
			name, _, _, _, endTime, _, _, notInterruptible = UnitChannelInfo(unit)
		end
		if not name then return end

		endTime = endTime / 1e3
		element.endTime = endTime
		element.notInterruptible = notInterruptible
	elseif strfind(event, "STOP") then
		element.endTime = nil
		element.notInterruptible = false
	end

	if self.PostUpdate then self:PostUpdate(event, unit) end
end

local function Update(self)
	local name, _, instID = GetInstanceInfo()
	if name and instID == 8 then
		self:RegisterEvent("UNIT_AURA", onEvent)
		self:RegisterEvent("UNIT_SPELLCAST_START", onEvent)
		self:RegisterEvent("UNIT_SPELLCAST_STOP", onEvent)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", onEvent)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", onEvent)
	else
		self:UnregisterEvent("UNIT_AURA", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_START", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", onEvent)
	end
end

local function checkAffixes(self, event)
	local affixes = C_MythicPlus.GetCurrentAffixes()
	if not affixes then return end
	if affixes[3] and affixes[3].id == 14 then
		Update(self)
		self:RegisterEvent(event, Update, true)
		self:RegisterEvent("CHALLENGE_MODE_START", Update, true)
	end
	self:UnregisterEvent(event, checkAffixes)
end

local function Enable(self)
	local element = self.QuakeTimer

	if element then
		element.failColor = element.failColor or {1, 0, 0}
		element.passColor = element.passColor or {0, 1, 0}
		element.timerFormat = element.timerFormat or "%.2f | %.2f"
		if not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\ChatFrame\ChatFrameBackground]])
		end
		element:SetScript("OnUpdate", updateTimer)

		self:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes, true)
		return true
	end
end

local function Disable(self)
	local element = self.QuakeTimer

	if element then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("CHALLENGE_MODE_START", Update)
		self:UnregisterEvent("UNIT_AURA", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_START", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", onEvent)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", onEvent)
	end
end

oUF:AddElement("QuakeTimer", nil, Enable, Disable)