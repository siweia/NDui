local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

function module:GetUnitAura(unit, spell, filter)
	for index = 1, 32 do
		local name, _, count, _, duration, expire, caster, _, _, spellID, _, _, _, _, _, value = UnitAura(unit, index, filter)
		if name and spellID == spell then
			return name, count, duration, expire, caster, spellID, value
		end
	end
end

function module:UpdateCooldown(button, spellID, texture)
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
		button:SetAlpha(1)
		button.Count:SetTextColor(0, 1, 0)
	elseif start and duration > 1.5 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button:SetAlpha(.5)
		button.Count:SetTextColor(1, 1, 1)
	else
		button.CD:Hide()
		button:SetAlpha(1)
		if charges == maxCharges then button.Count:SetTextColor(1, 0, 0) end
	end

	if texture then
		button.Icon:SetTexture(GetSpellTexture(spellID))
	end
end

function module:UpdateAura(button, unit, auraID, filter, spellID, cooldown)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	local name, count, duration, expire, caster = self:GetUnitAura(unit, auraID, filter)
	if name and caster == "player" then
		if count == 0 then count = "" end
		button.Count:SetText(count)
		button.CD:SetCooldown(expire-duration, duration)
		button.CD:Show()
		button:SetAlpha(1)
	else
		if cooldown then
			self:UpdateCooldown(button, spellID)
		else
			button.Count:SetText("")
			button.CD:Hide()
			button:SetAlpha(.5)
		end
	end
end

function module:UpdateTotemAura(button, texture, spellID)
	button.Icon:SetTexture(texture)
	local found
	for slot = 1, 4 do
		local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and icon == texture then
			button.CD:SetCooldown(start, dur)
			button.CD:Show()
			button:SetAlpha(1)
			button.Count:SetText("")
			found = true
			break
		end
	end
	if not found then
		if spellID then
			self:UpdateCooldown(button, spellID)
		else
			button.CD:Hide()
			button:SetAlpha(.5)
		end
	end
end

local function UpdateVisibility(self)
	if InCombatLockdown() then return end
	for i = 1, 5 do
		self.bu[i].Count:SetTextColor(1, 1, 1)
		self.bu[i].Count:SetText("")
		self.bu[i].CD:Hide()
		self.bu[i]:SetAlpha(.3)
	end
	if module.PostUpdateVisibility then module:PostUpdateVisibility(self) end
end

local function UpdateIcons(self)
	module:ChantLumos(self)
	UpdateVisibility(self)
end

local function TurnOn(self)
	self:RegisterEvent("UNIT_AURA", UpdateIcons, "player", "target")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons)
	self:RegisterEvent("SPELL_UPDATE_CHARGES", UpdateIcons)
end

local function TurnOff(self)
	self:UnregisterEvent("UNIT_AURA", UpdateIcons)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons)
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons)
	self:UnregisterEvent("SPELL_UPDATE_CHARGES", UpdateIcons)
	UpdateVisibility(self)
end

function module:CreateLumos(self)
	if not module.ChantLumos then return end

	self.bu = {}
	for i = 1, 5 do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetSize(self.iconSize, self.iconSize)
		B.CreateIF(bu, false, true)

		local fontParent = CreateFrame("Frame", nil, bu)
		fontParent:SetAllPoints()
		bu.Count = B.CreateFS(fontParent, 16, "", false, "BOTTOM", 0, -10)
		if i == 1 then
			bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -5)
		else
			bu:SetPoint("LEFT", self.bu[i-1], "RIGHT", 5, 0)
		end

		self.bu[i] = bu
	end

	if module.PostCreateLumos then module:PostCreateLumos(self) end

	UpdateIcons(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", TurnOff)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", TurnOn)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateIcons)
end