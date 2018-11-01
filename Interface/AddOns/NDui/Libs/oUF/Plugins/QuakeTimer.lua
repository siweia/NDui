local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF or oUF

--[[
	QuakeTimer for Mythic+, Siweia
	Example:

	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("CENTER")
	bar:SetSize(100, 20)
	bar:SetStatusBarTexture(texture_file_name)

	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(20, 20)
	icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
	bar.Icon = icon

	self.QuakeTimer = bar
]]
local _G = getfenv(0)
local DEBUFF_MAX_DISPLAY = _G.DEBUFF_MAX_DISPLAY

local function updateTimer(self, elapsed)
	local duration = self.expires - GetTime()
	if duration < 0 then
		self:Hide()
	else
		local timer = self.duration - duration
		self:SetValue(timer)
		if self.Text then
			self.Text:SetText(format(self.timerFormat, timer, self.duration))
		end

		if self.endTime and self.endTime - GetTime() >= duration then
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
	if not element then return end

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
	elseif event:find("START") then
		local name, _, _, _, endTime = UnitCastingInfo(unit)
		if not name then
			name, _, _, _, endTime = UnitChannelInfo(unit)
		end
		if not name then return end

		endTime = endTime / 1e3
		element.endTime = endTime
	elseif event:find("STOP") then
		element.endTime = nil
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

local function Path(self, ...)
	local element = self.QuakeTimer
	if not element then return end
	return (element.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.QuakeTimer

	if element then
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if not affixes or affixes[3] ~= 14 then return end

		element.failColor = element.failColor or {1, 0, 0}
		element.passColor = element.passColor or {0, 1, 0}
		element.timerFormat = element.timerFormat or "%.2f | %.2f"

		element.ForceUpdate = ForceUpdate
		element:SetScript("OnUpdate", updateTimer)
		element:Hide()

		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
	end

	return true
end

local function Disable(self)
	local element = self.QuakeTimer

	if element then
		element:Hide()
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
	end
end

oUF:AddElement("QuakeTimer", Path, Enable, Disable)