local _, ns = ...
local B = ns[1]
local oUF = ns.oUF

-- On WoW Forever the swing timer is driven by the native PLAYER_SWING event.
-- Its payload (duration, hand) stays readable in restricted content, while
-- UnitAttackSpeed returns secret values and CLEU is refused by the client.
-- hand is normally an Enum.PlayerSwingType value, but that enum may be missing
-- on some clients, so both the enum and plain strings are accepted.
local swingType = Enum and Enum.PlayerSwingType

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
	local nextSwing, visible = nil, false
	for _, bar in ipairs({element.Main, element.Offhand}) do
		if bar.finish then
			local remaining = bar.finish - now
			if remaining > 0 then
				bar:SetValue((bar.duration - remaining) / bar.duration)
				if not nextSwing or remaining < nextSwing then
					nextSwing = remaining
				end
				visible = true
			else
				bar.finish = nil
				bar:Hide()
			end
		end
	end

	if not visible then
		element:Hide()
	elseif element.Time then
		-- One shared text: the time until the next swing, whichever hand is closer.
		element.Time:SetFormattedText("%.1f", nextSwing)
	end
end

-- Returns "ranged", "mainhand", "offhand" or nil, tolerant of both the enum and
-- string representations of the hand argument.
local function DetectHand(hand)
	if type(hand) == "string" then
		local h = hand:lower()
		if h == "ranged" then return "ranged" end
		if h:find("off") then return "offhand" end
		if h:find("main") then return "mainhand" end
	end
	if swingType then
		if hand == swingType.Ranged then return "ranged" end
		if hand == swingType.MainHand then return "mainhand" end
		if hand == swingType.OffHand then return "offhand" end
	end
end

local function Update(self, event, duration, hand)
	local element = self.Swing
	if event ~= "PLAYER_SWING" then
		Clear(element)
		return
	end
	if B:IsSecretValue(duration) or B:IsSecretValue(hand) then return end
	if type(duration) ~= "number" or duration <= 0 then return end

	local handType = DetectHand(hand)
	if not handType then
		-- Keep the raw value around, so an unexpected payload can be inspected.
		element.lastHand = hand
		return
	end

	local bar
	if handType == "ranged" then
		if element.mode ~= "ranged" then
			element.Offhand.finish = nil
			element.Offhand:Hide()
		end
		element.mode = "ranged"
		bar = element.Main
	else
		if element.mode == "ranged" then
			element.Main.finish = nil
			element.Main:Hide()
		end
		element.mode = "melee"
		bar = handType == "offhand" and element.Offhand or element.Main
	end

	bar.duration = duration
	bar.finish = GetTime() + duration
	bar:SetValue(0)
	bar:Show()
	element:Show()
end

local function Enable(self, unit)
	local element = self.Swing
	if not element or unit ~= "player" then return end
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
