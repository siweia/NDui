local _, ns = ...
local B = ns[1]
local oUF = ns.oUF
local swingType = Enum.PlayerSwingType

local function Clear(element)
	for _, bar in ipairs({element.Main, element.Offhand}) do
		bar.finish = nil
		bar:Hide()
	end
	element.mode = nil
	element:Hide()
end

local function OnUpdate(element)
	local now = GetTime()
	local visible = false
	for _, bar in ipairs({element.Main, element.Offhand}) do
		if bar.finish then
			local remaining = bar.finish - now
			if remaining > 0 then
				bar:SetValue((bar.duration - remaining) / bar.duration)
				bar.Time:SetFormattedText("%.1f", remaining)
				visible = true
			else
				bar.finish = nil
				bar:Hide()
			end
		end
	end
	if not visible then element:Hide() end
end

local function Update(self, event, duration, hand)
	local element = self.Swing
	if event ~= "PLAYER_SWING" then
		Clear(element)
		return
	end
	if B:IsSecretValue(duration) or B:IsSecretValue(hand) then return end
	if type(duration) ~= "number" or duration <= 0 then return end

	local bar
	if hand == swingType.Ranged then
		if element.mode ~= swingType.Ranged then
			element.Offhand.finish = nil
			element.Offhand:Hide()
		end
		element.mode = swingType.Ranged
		bar = element.Main
	elseif hand == swingType.MainHand or hand == swingType.OffHand then
		if element.mode == swingType.Ranged then
			element.Main.finish = nil
			element.Main:Hide()
		end
		element.mode = swingType.MainHand
		bar = hand == swingType.OffHand and element.Offhand or element.Main
	else
		return
	end

	bar.duration = duration
	bar.finish = GetTime() + duration
	bar:SetValue(0)
	bar.Time:SetFormattedText("%.1f", duration)
	bar:Show()
	element:Show()
end

local function Enable(self, unit)
	local element = self.Swing
	if not element or unit ~= "player" or not swingType then return end
	element:SetScript("OnUpdate", OnUpdate)
	self:RegisterEvent("PLAYER_SWING", Update, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)
	self:RegisterEvent("PLAYER_DEAD", Update, true)
	self:RegisterEvent("WEAPON_SLOT_CHANGED", Update, true)
	return true
end

local function Disable(self)
	self:UnregisterEvent("PLAYER_SWING", Update)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
	self:UnregisterEvent("PLAYER_DEAD", Update)
	self:UnregisterEvent("WEAPON_SLOT_CHANGED", Update)
	self.Swing:SetScript("OnUpdate", nil)
	Clear(self.Swing)
end

oUF:AddElement("Swing", nil, Enable, Disable)
