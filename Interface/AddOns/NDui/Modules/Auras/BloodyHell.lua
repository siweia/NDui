local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

local cr, cg, cb = DB.cc.r, DB.cc.g, DB.cc.b
local IconSize = C.Auras.IconSize + 3
local bar, cur, maxPower
local function BloodyHell()
	if bar then bar:Show() return end

	bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetSize(IconSize*5+20, 7)
	bar:SetPoint("CENTER")
	bar:SetFrameStrata("HIGH")
	B.CreateSB(bar, true, .14, .5, 1)
	B.SmoothBar(bar)
	bar:SetMinMaxValues(0, 10)
	bar:SetValue(0)

	bar.Power = B.CreateFS(bar, 18, "", false, "CENTER", 0, -6)

	bar.Shield = B.CreateFS(bar, 18, "")
	bar.Shield:ClearAllPoints()
	bar.Shield:SetPoint("RIGHT", bar, "LEFT", -5, 8)
	bar.Shield:SetTextColor(1, .8, 0)

	bar.Count = B.CreateFS(bar, 18, "")
	bar.Count:ClearAllPoints()
	bar.Count:SetPoint("LEFT", bar, "RIGHT", 5, 8)
	bar.Count:SetTextColor(cr, cg, cb)

	local runes = {}
	for i = 1, 6 do
		runes[i] = CreateFrame("StatusBar", nil, bar)
		runes[i]:SetSize((bar:GetWidth()-15)/6, 7)
		B.CreateSB(runes[i])
		if i == 1 then
			runes[i]:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 5)
		else
			runes[i]:SetPoint("LEFT", runes[i-1], "RIGHT", 3, 0)
		end
	end
	bar.runes = runes

	local spells = {49998, 195181, 49028, 48707, 55233}
	local icons = {}
	for i = 1, 5 do
		icons[i] = CreateFrame("Frame", nil, bar)
		icons[i]:SetSize(IconSize, IconSize)
		B.CreateIF(icons[i], false, true)
		icons[i].Icon:SetTexture(GetSpellTexture(spells[i]))
		icons[i].Count = B.CreateFS(icons[i], 16, "")
		icons[i].Count:SetPoint("TOP", 0, 18)
		if i == 1 then
			icons[i]:SetPoint("BOTTOMLEFT", runes[1], "TOPLEFT", 0, 5)
		else
			icons[i]:SetPoint("LEFT", icons[i-1], "RIGHT", 5, 0)
		end
	end
	bar.icons = icons

	B.Mover(bar, L["BloodyHell"], "BloodyHell", C.Auras.BHPos, bar:GetWidth(), 30)
end

local function lookingForBuff(spell)
	for i = 1, 32 do
		local name, _, count, _, dur, exp, _, _, _, spellID, _, _, _, _, _, value = UnitBuff("player", i)
		if name and spellID == spell then
			return name, count, dur, exp, value
		end
	end
end

local function updateVisibility()
	if InCombatLockdown() then return end
	if bar then bar:SetAlpha(.1) end
end

local function updatePower()
	cur, maxPower = UnitPower("player"), UnitPowerMax("player")
	bar:SetMinMaxValues(0, maxPower)
	bar:SetValue(cur)
	bar.Power:SetText(cur)
	bar:SetAlpha(1)
	if cur > 90 then
		bar.Power:SetTextColor(1, 0, 0)
	elseif cur > 50 then
		bar.Power:SetTextColor(1, 1, 0)
	else
		bar.Power:SetTextColor(1, 1, 1)
	end

	updateVisibility()
end

local function updateRune(_, ...)
	local rid = ...
	local rune = bar.runes
	local start, duration, runeReady = GetRuneCooldown(rid)
	if start then
		bar:SetAlpha(1)
		if runeReady then
			rune[rid]:SetMinMaxValues(0, 1)
			rune[rid]:SetValue(1)
			rune[rid]:SetScript("OnUpdate", nil)
			rune[rid]:SetAlpha(1)
		else
			rune[rid].duration = GetTime() - start
			rune[rid].max = duration
			rune[rid]:SetMinMaxValues(1, duration)
			rune[rid]:SetAlpha(.7)
			rune[rid]:SetScript("OnUpdate", function(self, elapsed)
				local duration = self.duration + elapsed
				if(duration >= self.max) then
					return self:SetScript("OnUpdate", nil)
				else
					self.duration = duration
					return self:SetValue(duration)
				end
			end)
		end
	end

	local runeCount = 0
	for i = 1, 6 do
		if rune[i]:GetAlpha() == 1 then
			runeCount = runeCount + 1
		end
	end
	bar.Count:SetText(runeCount)

	updateVisibility()
end

local function AddSpellGroup(i, buff, cd, showValue)
	local icons = bar.icons
	local name, _, dur, expire, value = lookingForBuff(buff)
	local start, duration = GetSpellCooldown(cd)
	if name then
		icons[i]:SetAlpha(1)
		icons[i].CD:SetCooldown(expire-dur, dur)
		icons[i].CD:Show()
	elseif start and duration > 1.5 then
		icons[i]:SetAlpha(.5)
		icons[i].CD:SetCooldown(start, duration)
		icons[i].CD:Show()
	else
		icons[i]:SetAlpha(1)
		icons[i].CD:Hide()
	end
	if showValue then
		if name then
			icons[4].Count:SetText(B.Numb(value))
		else
			icons[4].Count:SetText("")
		end
	end
end

local function updateSpells()
	bar:SetAlpha(1)
	local icons, boneCount = bar.icons, 0
	if not cur then cur = UnitPower("player") end
	local hasBone, boneStack, boneDur, boneExp = lookingForBuff(195181)
	local hasShield, _, shieldDur, shieldExp, value = lookingForBuff(77535)

	boneCount = floor(cur/45)
	icons[1].Count:SetText(boneCount)

	if hasShield then
		bar.Shield:SetText(B.Numb(value))
		icons[1].CD:SetCooldown(shieldExp-shieldDur, shieldDur)
		icons[1].CD:Show()
	else
		bar.Shield:SetText("")
		icons[1].CD:Hide()
		if boneCount == 0 then
			icons[1]:SetAlpha(.5)
		else
			icons[1]:SetAlpha(1)
		end
	end

	if hasBone then
		icons[2].Count:SetText(boneStack)
		icons[2]:SetAlpha(1)
		icons[2].CD:SetCooldown(boneExp-boneDur, boneDur)
		icons[2].CD:Show()
		if boneStack > 7 or boneStack < 5 then
			icons[2].Count:SetTextColor(1, 0, 0)
		else
			icons[2].Count:SetTextColor(1, 1, 0)
		end
	else
		icons[2].Count:SetText("0")
		icons[2]:SetAlpha(.5)
		icons[2].CD:Hide()
	end

	AddSpellGroup(3, 81256, 49028)
	AddSpellGroup(4, 48707, 48707, true)
	AddSpellGroup(5, 55233, 55233)

	updateVisibility()
end

local function checkSpec(event)
	if GetSpecializationInfo(GetSpecialization()) == 250 then
		BloodyHell()
		bar:SetAlpha(.1)
		B:RegisterEvent("UNIT_POWER_FREQUENT", updatePower)
		B:RegisterEvent("RUNE_POWER_UPDATE", updateRune)
		B:RegisterEvent("SPELL_UPDATE_COOLDOWN", updateSpells)
		B:RegisterEvent("UNIT_AURA", updateSpells, "player")
	else
		if bar then bar:Hide() end
		B:UnregisterEvent("UNIT_POWER_FREQUENT", updatePower)
		B:UnregisterEvent("RUNE_POWER_UPDATE", updateRune)
		B:UnregisterEvent("SPELL_UPDATE_COOLDOWN", updateSpells)
		B:UnregisterEvent("UNIT_AURA", updateSpells)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		B:UnregisterEvent(event, checkSpec)
	end

	updateVisibility()
end

function module:BloodyHell()
	if not NDuiDB["Auras"]["BloodyHell"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkSpec)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpec)
end