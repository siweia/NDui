local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "DEATHKNIGHT" then return end

-- BloodyHell, not really handy
local IconSize = C.Auras.IconSize + 3
local bar, cur, maxPower
local function BloodyHell()
	if bar then bar:Show() return end

	bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetSize(IconSize*5+20, 8)
	bar:SetPoint("CENTER")
	bar:SetFrameStrata("HIGH")
	B.CreateSB(bar, true)
	bar:SetMinMaxValues(0, 10)
	bar:SetValue(0)

	bar.Power = B.CreateFS(bar, 16, "", false, "CENTER", 0, -6)

	bar.Shield = B.CreateFS(bar, 16, "")
	bar.Shield:ClearAllPoints()
	bar.Shield:SetPoint("RIGHT", bar, "LEFT", -5, 8)
	bar.Shield:SetTextColor(1, .8, 0)

	bar.Count = B.CreateFS(bar, 16, "")
	bar.Count:ClearAllPoints()
	bar.Count:SetPoint("LEFT", bar, "RIGHT", 5, 8)
	bar.Count:SetTextColor(.14, .5, 1)

	local runes = {}
	for i = 1, 6 do
		runes[i] = CreateFrame("StatusBar", nil, bar)
		runes[i]:SetSize((bar:GetWidth()-15)/6, 6)
		B.CreateSB(runes[i])
		runes[i]:SetStatusBarColor(.14, .5, 1)
		if i == 1 then
			runes[i]:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 5)
		else
			runes[i]:SetPoint("LEFT", runes[i-1], "RIGHT", 3, 0)
		end
	end
	bar.runes = runes

	local spells = {49998, 195181, 205223, 48707, 55233}
	local icons = {}
	for i = 1, 5 do
		icons[i] = CreateFrame("Frame", nil, bar)
		icons[i]:SetSize(IconSize, IconSize)
		B.CreateIF(icons[i])
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

-- localized spell name
local spellBone = GetSpellInfo(195181)
local spellShield = GetSpellInfo(77535)
local spellShell = GetSpellInfo(48707)
local spellVampiric = GetSpellInfo(55233)

local f = NDui:EventFrame{"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"}
f:SetScript("OnEvent", function(self, event, ...)
	if not NDuiDB["Auras"]["BloodyHell"] then return end

	if event == "PLAYER_LOGIN" or event == "PLAYER_TALENT_UPDATE" then
		if GetSpecializationInfo(GetSpecialization()) == 250 then
			BloodyHell()
			bar:SetAlpha(.1)
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			self:RegisterEvent("RUNE_POWER_UPDATE")
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			self:RegisterUnitEvent("UNIT_AURA", "player")
		else
			if bar then bar:Hide() end
			self:UnregisterEvent("UNIT_POWER_FREQUENT")
			self:UnregisterEvent("RUNE_POWER_UPDATE")
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
			self:UnregisterEvent("UNIT_AURA")
		end
	elseif event == "UNIT_POWER_FREQUENT" then
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
	elseif event == "RUNE_POWER_UPDATE" then
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
	else
		bar:SetAlpha(1)
		local icons, boneCount = bar.icons, 0
		if not cur then cur = UnitPower("player") end
		local hasBone, _, _, boneStack, _, boneDur, boneExp = UnitBuff("player", spellBone)
		local hasShield, _, _, _, _, shieldDur, shieldExp, _, _, _, _, _, _, _, _, _, value = UnitBuff("player", spellShield)

		if hasBone and boneStack >= 5 and IsPlayerSpell(219786) then
			boneCount = floor(cur/40)
		else
			boneCount = floor(cur/45)
		end
		icons[1].Count:SetText(boneCount)

		if hasShield then
			bar.Shield:SetText(B.Numb(value))
			icons[1].CD:SetCooldown(shieldExp-shieldDur, shieldDur)
		else
			bar.Shield:SetText("")
			icons[1].CD:SetCooldown(0, 0)
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
			if boneStack > 7 or boneStack < 5 then
				icons[2].Count:SetTextColor(1, 0, 0)
			else
				icons[2].Count:SetTextColor(1, 1, 0)
			end
		else
			icons[2].Count:SetText("0")
			icons[2]:SetAlpha(.5)
			icons[2].CD:SetCooldown(0, 0)
		end

		if IsPlayerSpell(205223) then
			local start, duration = GetSpellCooldown(205223)
			if start and duration > 1.5 then
				icons[3]:SetAlpha(.5)
				icons[3].CD:SetCooldown(start, duration)
			else
				icons[3]:SetAlpha(1)
				icons[3].CD:SetCooldown(0, 0)
			end
		else
			icons[3]:SetAlpha(.5)
			icons[3].CD:SetCooldown(0, 0)
		end

		do
			local name, _, _, _, _, dur, expire, _, _, _, _, _, _, _, _, _, value = UnitBuff("player", spellShell)
			local start, duration = GetSpellCooldown(48707)
			icons[4].Count:SetText("")
			if name then
				icons[4]:SetAlpha(1)
				icons[4].CD:SetCooldown(expire-dur, dur)
				icons[4].Count:SetText(B.Numb(value))
			elseif start and duration > 1.5 then
				icons[4]:SetAlpha(.5)
				icons[4].CD:SetCooldown(start, duration)
			else
				icons[4]:SetAlpha(1)
				icons[4].CD:SetCooldown(0, 0)
			end
		end

		do
			local name, _, _, _, _, dur, expire = UnitBuff("player", spellVampiric)
			local start, duration = GetSpellCooldown(55233)
			if name then
				icons[5]:SetAlpha(1)
				icons[5].CD:SetCooldown(expire-dur, dur)
			elseif start and duration > 1.5 then
				icons[5]:SetAlpha(.5)
				icons[5].CD:SetCooldown(start, duration)
			else
				icons[5]:SetAlpha(1)
				icons[5].CD:SetCooldown(0, 0)
			end
		end
	end

	if not InCombatLockdown() then
		if bar then bar:SetAlpha(.1) end
	end
end)