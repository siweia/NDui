local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

local IconSize = C.Auras.IconSize + 2
local bu, bar, boom = {}

local function CreateElements()
	if bar then bar:Show() return end

	bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetSize(IconSize*5+20, 6)
	B.CreateSB(bar, true)
	bar:SetAlpha(.5)
	bar.Count = B.CreateFS(bar, 18, "", false, "CENTER", 0, -5)

	local spells = {259491, 131894, 259495, 259387, 266779}

	for i = 1, 5 do
		bu[i] = CreateFrame("Frame", nil, UIParent)
		bu[i]:SetSize(IconSize, IconSize)
		B.CreateIF(bu[i], false, true)
		bu[i]:SetAlpha(.5)
		bu[i].Icon:SetTexture(GetSpellTexture(spells[i]))
		bu[i].Count = B.CreateFS(bu[i], 16, "")
		bu[i].Count:SetPoint("TOP", 0, 15)
		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 5)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 5, 0)
		end
	end

	boom = CreateFrame("Frame", nil, UIParent)
	boom:SetSize(IconSize, IconSize)
	boom:SetPoint("BOTTOM", bu[3], "TOP", 0, 5)
	B.CreateIF(boom, false, true)
	boom:Hide()

	B.Mover(bar, L["HunterTool"], "HunterTool", C.Auras.HunterToolPos, bar:GetWidth(), 30)
end

local function UpdateVisibility()
	if InCombatLockdown() then return end
	if not bar then return end
	for i = 1, 5 do bu[i]:SetAlpha(.1) end
	if boom:IsShown() then boom:SetAlpha(.1) end
	bar:SetAlpha(.1)
	bar.Count:SetText("")
end

local function UpdatePowerBar()
	local cur, max = UnitPower("player"), UnitPowerMax("player")
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)
	bar.Count:SetText(cur)
	bar:SetAlpha(1)
	if cur > 80 then
		bar.Count:SetTextColor(1, 0, 0)
	elseif cur > 30 then
		bar.Count:SetTextColor(1, 1, 0)
	else
		bar.Count:SetTextColor(1, 1, 1)
	end

	UpdateVisibility()
end

local function GetUnitAura(unit, spell, filter)
	for index = 1, 32 do
		local name, _, count, _, dur, exp, caster, _, _, spellID = UnitAura(unit, index, filter)
		if name and spellID == spell then
			return name, count, dur, exp, caster, spellID
		end
	end
end

local function UpdateCooldown(button, spellID)
	local start, duration = GetSpellCooldown(spellID)
	if start and duration > 1.5 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button:SetAlpha(.5)
	else
		button.CD:Hide()
		button:SetAlpha(1)
	end
end

local function UpdateBuff(button, spellID, auraID, cooldown)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	local name, count, duration, expire = GetUnitAura("player", auraID, "HELPFUL")
	if name then
		if count == 0 then count = "" end
		button.Count:SetText(count)
		button.CD:SetCooldown(expire-duration, duration)
		button.CD:Show()
		button:SetAlpha(1)
	else
		if cooldown then
			UpdateCooldown(button, spellID)
		else
			button.Count:SetText("")
			button.CD:Hide()
			button:SetAlpha(.5)
		end
	end
end

local function UpdateDebuff(button, spellID, auraID, cooldown)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	local name, _, duration, expire, caster = GetUnitAura("target", auraID, "HARMFUL")
	if name and caster == "player" then
		button:SetAlpha(1)
		button.CD:SetCooldown(expire-duration, duration)
		button.CD:Show()
	else
		if cooldown then
			UpdateCooldown(button, spellID)
		else
			button:SetAlpha(.5)
			button.CD:Hide()
		end
	end
end

local boomGroups = {
	[270339] = 186270,
	[270332] = 259489,
	[271049] = 259491,
}
local function UpdateIcons()
	UpdateDebuff(bu[1], 259491, 259491)

	do
		local button = bu[2]
		if IsPlayerSpell(260248) then
			UpdateBuff(button, 260248, 260249)
		elseif IsPlayerSpell(162488) then
			UpdateDebuff(button, 162488, 162487, true)
		else
			UpdateDebuff(button, 131894, 131894, true)
		end
	end

	do
		local button = bu[4]
		if IsPlayerSpell(260285) then
			UpdateBuff(button, 260285, 260286)
		elseif IsPlayerSpell(269751) then
			button.Icon:SetTexture(GetSpellTexture(269751))
			UpdateCooldown(button, 269751)
		else
			UpdateBuff(button, 259387, 259388)
		end
	end

	do
		local button = bu[3]
		if IsPlayerSpell(271014) then
			boom:Show()

			local name, _, duration, expire, caster, spellID = GetUnitAura("target", 270339, "HARMFUL")
			if not name then name, _, duration, expire, caster, spellID = GetUnitAura("target", 270332, "HARMFUL") end
			if not name then name, _, duration, expire, caster, spellID = GetUnitAura("target", 271049, "HARMFUL") end
			if name and caster == "player" then
				boom.Icon:SetTexture(GetSpellTexture(boomGroups[spellID]))
				boom.CD:SetCooldown(expire-duration, duration)
				boom.CD:Show()
				boom:SetAlpha(1)
			else
				local texture = GetSpellTexture(259495)
				if texture == GetSpellTexture(270323) then
					boom.Icon:SetTexture(GetSpellTexture(259489))
					boom:SetAlpha(.5)
				elseif texture == GetSpellTexture(270335) then
					boom.Icon:SetTexture(GetSpellTexture(186270))
					boom:SetAlpha(.5)
				elseif texture == GetSpellTexture(271045) then
					boom.Icon:SetTexture(GetSpellTexture(259491))
					boom:SetAlpha(.5)
				end
				boom:SetAlpha(.5)
			end

			button.Icon:SetTexture(GetSpellTexture(259495))
			UpdateCooldown(button, 259495)
		else
			boom:Hide()
			UpdateDebuff(button, 259495, 269747, true)
		end
	end

	UpdateBuff(bu[5], 266779, 266779, true)

	UpdateVisibility()
end

local function CheckSpec(event)
	if GetSpecializationInfo(GetSpecialization()) == 255 and UnitLevel("player") > 99 then
		CreateElements()
		for i = 1, 5 do bu[i]:Show() end

		B:RegisterEvent("UNIT_POWER_FREQUENT", UpdatePowerBar, "player")
		B:RegisterEvent("UNIT_AURA", UpdateIcons, "player", "target")
		B:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons)
		B:RegisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons)
	else
		for i = 1, 5 do
			if bu[i] then bu[i]:Hide() end
		end
		if boom then boom:Hide() end
		if bar then bar:Hide() end

		B:UnregisterEvent("UNIT_POWER_FREQUENT", UpdatePowerBar)
		B:UnregisterEvent("UNIT_AURA", UpdateIcons)
		B:UnregisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons)
		B:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		B:UnregisterEvent(event, CheckSpec)
	end

	UpdateVisibility()
end

function module:HunterTool()
	if not NDuiDB["Auras"]["HunterTool"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", CheckSpec)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
end