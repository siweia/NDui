local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

-- Marksman Master
local IconSize = C.Auras.IconSize + 3
local bu, bar = {}
local function MarksmanGo()
	if bar then bar:Show() return end

	bar = CreateFrame("StatusBar", "NDui_Marksman", UIParent)
	bar:SetSize(IconSize*5+20, 6)
	bar:SetFrameStrata("HIGH")
	B.CreateSB(bar, true)
	bar.Count = B.CreateFS(bar, 18, "", false, "CENTER", 0, -5)

	local spells = {187131, 194594, 204147, 185901, 214579}
	for i = 1, 5 do
		bu[i] = CreateFrame("Frame", nil, UIParent)
		bu[i]:SetSize(IconSize, IconSize)
		bu[i]:SetFrameStrata("HIGH")
		B.CreateIF(bu[i], false, true)
		bu[i].Icon:SetTexture(GetSpellTexture(spells[i]))
		bu[i].Count = B.CreateFS(bu[i], 16, "")
		bu[i].Count:SetPoint("TOP", 0, 15)
		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 5)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 5, 0)
		end
	end

	B.Mover(bar, L["Marksman"], "Marksman", C.Auras.MarksmanPos, bar:GetWidth(), 30)
end

-- localized
local blackArrowTex = GetSpellTexture(194599)
local vulnurable = GetSpellInfo(187131)
local trueAim = GetSpellInfo(199803)
local trueAimTex = GetSpellTexture(199803)
local locknload = GetSpellInfo(194594)
local locknloadTex = GetSpellTexture(194594)
local hunterMark = GetSpellInfo(185365)
local markingTarget = GetSpellInfo(223138)
local markingTargetTex = GetSpellTexture(223138)
local trueShot = GetSpellInfo(193526)
local sidewindersTex = GetSpellTexture(214579)
local piercingShotTex = GetSpellTexture(198670)

local function updateVisibility()
	if InCombatLockdown() then return end
	if not bar then return end
	for i = 1, 5 do bu[i]:SetAlpha(.1) end
	bar:SetAlpha(.1)
	bar.Count:SetText("")
	bu[5].Count:SetText("")
end

local function updatePower()
	local cur, max = UnitPower("player"), UnitPowerMax("player")
	bar:SetMinMaxValues(0, max)
	bar:SetValue(cur)
	bar.Count:SetText(cur)
	bar:SetAlpha(1)
	if cur > 94 then
		bar.Count:SetTextColor(1, 0, 0)
	elseif cur > 64 then
		bar.Count:SetTextColor(1, 1, 0)
	else
		bar.Count:SetTextColor(1, 1, 1)
		if cur < 50 then bar:SetAlpha(.5) end
	end

	updateVisibility()
end

local function updateSpells()
	-- Vulnerable
	do
		local name, _, _, _, duration, expire, caster = UnitDebuff("target", vulnurable)
		if name and caster == "player" then
			bu[1]:SetAlpha(1)
			bu[1].CD:SetCooldown(expire-duration, duration)
			bu[1].CD:Show()
		else
			bu[1]:SetAlpha(.5)
			bu[1].CD:Hide()
		end
	end

	-- Tier 30: Black Arrow, True Aim, Lock & Load
	do
		if IsPlayerSpell(194599) then
			local start, duration = GetSpellCooldown(194599)
			if start and duration > 1.5 then
				bu[2]:SetAlpha(.5)
				bu[2].CD:SetCooldown(start, duration)
				bu[2].CD:Show()
			else
				bu[2]:SetAlpha(1)
				bu[2].CD:Hide()
			end
			bu[2].Count:SetText("")
			bu[2].Icon:SetTexture(blackArrowTex)
		elseif IsPlayerSpell(199527) then
			local name, _, count, _, duration, expire = UnitDebuff("target", trueAim)
			if name then
				bu[2]:SetAlpha(1)
				bu[2].CD:SetCooldown(expire-duration, duration)
				bu[2].CD:Show()
				bu[2].Count:SetText(count)
			else
				bu[2]:SetAlpha(.5)
				bu[2].CD:Hide()
				bu[2].Count:SetText("")
			end
			bu[2].Icon:SetTexture(trueAimTex)
		else
			local name, _, count, _, duration, expire = UnitBuff("player", locknload)
			if name then
				bu[2]:SetAlpha(1)
				bu[2].CD:SetCooldown(expire-duration, duration)
				bu[2].CD:Show()
				bu[2].Count:SetText(count)
			else
				bu[2]:SetAlpha(.5)
				bu[2].CD:Hide()
				bu[2].Count:SetText("")
			end
			bu[2].Icon:SetTexture(locknloadTex)
		end
	end

	-- Windburst, MM's Artifact
	do
		if IsPlayerSpell(204147) then
			local start, duration = GetSpellCooldown(204147)
			if start and duration > 1.5 then
				bu[3]:SetAlpha(.5)
				bu[3].CD:SetCooldown(start, duration)
				bu[3].CD:Show()
			else
				bu[3]:SetAlpha(1)
				bu[3].CD:Hide()
			end
		else
			bu[3]:SetAlpha(.5)
			bu[3].CD:Hide()
		end
	end

	-- Marked Shot
	do
		local name, _, _, _, duration, expire, caster = UnitDebuff("target", hunterMark)
		if name and caster == "player" then
			bu[4]:SetAlpha(1)
			bu[4].CD:SetCooldown(expire-duration, duration)
			bu[4].CD:Show()
		else
			bu[4]:SetAlpha(.5)
			bu[4].CD:Hide()
		end
	end

	-- Sidewinders, spec at tier 100
	do
		if IsPlayerSpell(214579) then
			local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(214579)
			local start, duration = GetSpellCooldown(214579)
			bu[5].Count:SetText(charges)
			if charges < maxCharges and charges > 0 then
				StartChargeCooldown(bu[5], chargeStart, chargeDuration)
				bu[5].CD:Hide()
			elseif start and duration > 1.5 then
				ClearChargeCooldown(bu[5])
				bu[5].CD:SetCooldown(start, duration)
				bu[5].CD:Show()
			elseif charges == maxCharges then
				ClearChargeCooldown(bu[5])
				bu[5].CD:Hide()
			end

			local hasBuff1 = UnitBuff("player", markingTarget)	-- Marking Targets
			local hasBuff2 = UnitBuff("player", trueShot)		-- Trueshot
			if charges == maxCharges or hasBuff1 or hasBuff2 then
				bu[5].Count:SetTextColor(1, 0, 0)
				bu[5]:SetAlpha(1)
			else
				bu[5].Count:SetTextColor(1, 1, 1)
				bu[5]:SetAlpha(.5)
			end
			bu[5].Icon:SetTexture(sidewindersTex)
		elseif IsPlayerSpell(198670) then
			local start, duration = GetSpellCooldown(198670)
			if start and duration > 1.5 then
				bu[5]:SetAlpha(.5)
				bu[5].CD:SetCooldown(start, duration)
				bu[5].CD:Show()
			else
				bu[5]:SetAlpha(1)
				bu[5].CD:Hide()
			end
			bu[5].Count:SetText("")
			bu[5].Icon:SetTexture(piercingShotTex)
		else
			local name, _, _, _, duration, expire = UnitBuff("player", markingTarget)
			if name then
				bu[5]:SetAlpha(1)
				bu[5].CD:SetCooldown(expire-duration, duration)
				bu[5].CD:Show()
			else
				bu[5]:SetAlpha(.5)
				bu[5].CD:Hide()
			end
			bu[5].Count:SetText("")
			bu[5].Icon:SetTexture(markingTargetTex)
		end
	end

	updateVisibility()
end

local function checkSpec(event)
	if GetSpecializationInfo(GetSpecialization()) == 254 and UnitLevel("player") > 99 then
		MarksmanGo()
		for i = 1, 5 do bu[i]:Show() end

		B:RegisterEvent("UNIT_AURA", updateSpells, "player", "target")
		B:RegisterEvent("PLAYER_TARGET_CHANGED", updateSpells)
		B:RegisterEvent("SPELL_UPDATE_COOLDOWN", updateSpells)
		B:RegisterEvent("UNIT_POWER_FREQUENT", updatePower)
	else
		for i = 1, 5 do
			if bu[i] then bu[i]:Hide() end
		end
		if bar then bar:Hide() end

		B:UnregisterEvent("UNIT_AURA", updateSpells)
		B:UnregisterEvent("PLAYER_TARGET_CHANGED", updateSpells)
		B:UnregisterEvent("SPELL_UPDATE_COOLDOWN", updateSpells)
		B:UnregisterEvent("UNIT_POWER_FREQUENT", updatePower)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		B:UnregisterEvent(event, checkSpec)
	end

	updateVisibility()
end

function module:Marksman()
	if not hehelele then return end
	if not NDuiDB["Auras"]["Marksman"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkSpec)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpec)
end