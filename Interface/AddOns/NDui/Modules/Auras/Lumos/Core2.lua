local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

A.LumosMap = {
	[1] = {
		[1] = {Type = "Cooldown", SpellID = 34026},
		[2] = {Type = "Cooldown", SpellID = 217200},
		[3] = {Type = "Auras", SpellID = 272790, Texture = GetSpellTexture(106785), Unit = "pet", Flash = "End"},
		[4] = {Type = "Auras", SpellID = 19574, InactiveSpellID = 19574, Unit = "player", Flash = "Active"},
		[5] = {Type = "Auras", SpellID = 193530, InactiveSpellID = 193530, Unit = "player", Flash = "Active"},
	},
	[2] = {
	},
	[3] = {
	},
}

A.WatchedUnits = {}
A.WatchedAuras = {}
A.ActiveLumos = {}

local function RefreshState()
	wipe(A.WatchedAuras)

	local data = A.LumosMap[A.LumosSpec]
	for i = 1, 5 do
		local value = data[i]
		if value then
			local button = A.Lumos[i]
			button.Icon:SetTexture(value.Texture or GetSpellTexture(value.SpellID))
			button.Icon:SetDesaturated(true)

			if value.Type == "Auras" then
				A.WatchedUnits[value.Unit] = true
				A.WatchedAuras[value.SpellID] = i
			end
		end
	end
end

local function CheckCurrentSpec()
	A.LumosSpec = GetSpecialization()
	RefreshState()
end

function A:GlowOnEnd()
	local elapsed = self.expire - GetTime()
	if elapsed < 3 then
		B.ShowOverlayGlow(self.glowFrame)
	else
		B.HideOverlayGlow(self.glowFrame)
	end
end

local function UpdateLumosAura(index, name, count, duration, expire, spellID, value)
	local button = A.Lumos[index]
	local data = A.LumosMap[A.LumosSpec][index]

	if button.Count then
		button.Count:SetText(count == 0 and "" or count)
	end

	button.CD:SetCooldown(expire-duration, duration)
	button.CD:Show()
	button.Icon:SetDesaturated(false)

	if data.Flash then
		if data.Flash == "End" then
			button.expire = expire
			button:SetScript("OnUpdate", A.GlowOnEnd)
		else
			B.ShowOverlayGlow(button.glowFrame)
		end
	end
end

local function GetAuraValues(unit, i)
	local filter = unit == "target" and "HARMFUL" or "HELPFUL"
	return unit, i, filter
end

local lastUpdate = 0

local function UpdateAuras(_, unit)
	if not A.WatchedUnits[unit] then return end

	local now = GetTime()
	if now - lastUpdate < .1 then return end
	lastUpdate = now

	wipe(A.ActiveLumos)

	for unit in next, A.WatchedUnits do
		for i = 1, 40 do
			local name, _, count, _, duration, expire, caster, _, _, spellID, _, _, _, _, _, value = UnitAura(GetAuraValues(unit, i))
			if not name then break end
			local lumosIndex = A.WatchedAuras[spellID]
			if lumosIndex and caster == "player" then
				UpdateLumosAura(lumosIndex, name, count, duration, expire, spellID, value)
				A.ActiveLumos[lumosIndex] = true
			end
		end
	end
end

function A:UpdateCooldown(button, spellID, texture)
	B.HideOverlayGlow(button.glowFrame)

	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
	local start, duration = GetSpellCooldown(spellID)
	if charges and maxCharges > 1 then
		button.Count:SetText(charges)
	else
		button.Count:SetText("")
	end
	if charges and charges > 0 and charges < maxCharges then
		button.CD:SetCooldown(chargeStart, chargeDuration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
		button.Count:SetTextColor(0, 1, 0)
	elseif start and duration > 1.5 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(true)
		button.Count:SetTextColor(1, 1, 1)
	else
		button.CD:Hide()
		button.Icon:SetDesaturated(false)
		if charges == maxCharges then button.Count:SetTextColor(1, 0, 0) end
	end

	if texture then
		button.Icon:SetTexture(GetSpellTexture(spellID))
	end
end

local function UpdateLumosCooldown(index)
	local button = A.Lumos[index]
	local data = A.LumosMap[A.LumosSpec][index]
	if data.Type == "Cooldown" then
		A:UpdateCooldown(button, data.SpellID)
	elseif data.InactiveSpellID then
		A:UpdateCooldown(button, data.InactiveSpellID, true)
	else
		if button.Count then button.Count:SetText("") end
		button.CD:Hide()
		button.Icon:SetDesaturated(true)
		button:SetScript("OnUpdate", nil)
		B.HideOverlayGlow(button.glowFrame)
	end
end

local function UpdateCooldowns()
	for i = 1, 5 do
		if not A.ActiveLumos[i] then
			UpdateLumosCooldown(i)
		end
	end
end

local function ResetLumos()
	if InCombatLockdown() or C.db["Nameplate"]["PPOnFire"] then return end

	for i = 1, 5 do
		local bu = A.Lumos[i]
		bu.Count:SetTextColor(1, 1, 1)
		bu.Count:SetText("")
		bu.CD:Hide()
		bu:SetScript("OnUpdate", nil)
		bu.Icon:SetDesaturated(true)
		B.HideOverlayGlow(bu.glowFrame)
	end

	--if A.PostUpdateVisibility then A:PostUpdateVisibility() end
end

local function TurnOffLumos()
	ResetLumos()
	B:UnregisterEvent("UNIT_AURA", UpdateAuras)
	B:UnregisterEvent("PLAYER_TARGET_CHANGED", UpdateAuras)
	B:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UpdateCooldowns)
	B:UnregisterEvent("SPELL_UPDATE_CHARGES", UpdateCooldowns)
end

local function TurnOnLumos()
	B:RegisterEvent("UNIT_AURA", UpdateAuras)
	B:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateAuras)
	B:RegisterEvent("SPELL_UPDATE_COOLDOWN", UpdateCooldowns)
	B:RegisterEvent("SPELL_UPDATE_CHARGES", UpdateCooldowns)
end

local function ToggleOnFireMode()
	if C.db["Nameplate"]["PPOnFire"] then
		TurnOnLumos()
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", TurnOffLumos)
		B:UnregisterEvent("PLAYER_REGEN_DISABLED", TurnOnLumos)
	else
		B:RegisterEvent("PLAYER_REGEN_ENABLED", TurnOffLumos)
		B:RegisterEvent("PLAYER_REGEN_DISABLED", TurnOnLumos)
	end
end

function A:CreateLumos(self)
	if not A.ChantLumos then return end

	self.lumos = {}

	local iconSize = (C.db["Nameplate"]["PPWidth"]+2*C.mult - C.margin*4)/5
	for i = 1, 5 do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetSize(iconSize, iconSize)
		B.AuraIcon(bu)
		bu.glowFrame = B.CreateGlowFrame(bu, iconSize)

		local fontParent = CreateFrame("Frame", nil, bu)
		fontParent:SetAllPoints()
		fontParent:SetFrameLevel(bu:GetFrameLevel() + 6)
		bu.Count = B.CreateFS(fontParent, 16, "", false, "BOTTOM", 0, -10)
		if i == 1 then
			bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", -C.mult, -C.margin)
		else
			bu:SetPoint("LEFT", self.lumos[i-1], "RIGHT", C.margin, 0)
		end

		self.lumos[i] = bu
	end

	--if A.PostCreateLumos then A:PostCreateLumos(self) end

	A.Lumos = self.lumos

	CheckCurrentSpec()
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", CheckCurrentSpec)

	ToggleOnFireMode()
end