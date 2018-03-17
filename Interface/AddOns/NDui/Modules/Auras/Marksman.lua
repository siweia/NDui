local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "HUNTER" then return end

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
		B.CreateIF(bu[i])
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

local f = NDui:EventFrame{"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"}
f:SetScript("OnEvent", function(self, event)
	if not NDuiDB["Auras"]["Marksman"] then
		self:UnregisterAllEvents()
		return
	end

	if event == "PLAYER_LOGIN" or event == "PLAYER_TALENT_UPDATE" then
		if GetSpecializationInfo(GetSpecialization()) == 254 and UnitLevel("player") > 99 then
			MarksmanGo()
			for i = 1, 5 do bu[i]:Show() end

			self:RegisterEvent("UNIT_AURA")
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		else
			for i = 1, 5 do
				if bu[i] then bu[i]:Hide() end
			end
			if bar then bar:Hide() end

			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("UNIT_POWER_FREQUENT")
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
		end
	elseif event == "UNIT_POWER_FREQUENT" then
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
	else
		-- Vulnerable
		do
			local name, _, _, _, _, duration, expire, caster = UnitDebuff("target", GetSpellInfo(187131))
			if name and caster == "player" then
				bu[1]:SetAlpha(1)
				bu[1].CD:SetCooldown(expire-duration, duration)
			else
				bu[1]:SetAlpha(.5)
				bu[1].CD:SetCooldown(0, 0)
			end
		end

		-- Tier 30: Black Arrow, True Aim, Lock & Load
		do
			if IsPlayerSpell(194599) then
				local start, duration = GetSpellCooldown(194599)
				if start and duration > 1.5 then
					bu[2]:SetAlpha(.5)
					bu[2].CD:SetCooldown(start, duration)
				else
					bu[2]:SetAlpha(1)
					bu[2].CD:SetCooldown(0, 0)
				end
				bu[2].Count:SetText("")
				bu[2].Icon:SetTexture(GetSpellTexture(194599))
			elseif IsPlayerSpell(199527) then
				local name, _, _, count, _, duration, expire = UnitDebuff("target", GetSpellInfo(199803))
				if name then
					bu[2]:SetAlpha(1)
					bu[2].CD:SetCooldown(expire-duration, duration)
					bu[2].Count:SetText(count)
				else
					bu[2]:SetAlpha(.5)
					bu[2].CD:SetCooldown(0, 0)
					bu[2].Count:SetText("")
				end
				bu[2].Icon:SetTexture(GetSpellTexture(199803))
			else
				local name, _, _, count, _, duration, expire = UnitBuff("player", GetSpellInfo(194594))
				if name then
					bu[2]:SetAlpha(1)
					bu[2].CD:SetCooldown(expire-duration, duration)
					bu[2].Count:SetText(count)
				else
					bu[2]:SetAlpha(.5)
					bu[2].CD:SetCooldown(0, 0)
					bu[2].Count:SetText("")
				end
				bu[2].Icon:SetTexture(GetSpellTexture(194594))
			end
		end

		-- Windburst, MM's Artifact
		do
			if IsPlayerSpell(204147) then
				local start, duration = GetSpellCooldown(204147)
				if start and duration > 1.5 then
					bu[3]:SetAlpha(.5)
					bu[3].CD:SetCooldown(start, duration)
				else
					bu[3]:SetAlpha(1)
					bu[3].CD:SetCooldown(0, 0)
				end
			else
				bu[3]:SetAlpha(.5)
				bu[3].CD:SetCooldown(0, 0)
			end
		end

		-- Marked Shot
		do
			local name, _, _, _, _, duration, expire, caster = UnitDebuff("target", GetSpellInfo(185365))
			if name and caster == "player" then
				bu[4]:SetAlpha(1)
				bu[4].CD:SetCooldown(expire-duration, duration)
			else
				bu[4]:SetAlpha(.5)
				bu[4].CD:SetCooldown(0, 0)
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
					bu[5].CD:SetCooldown(0, 0)
				elseif start and duration > 1.5 then
					ClearChargeCooldown(bu[5])
					bu[5].CD:SetCooldown(start, duration)
				elseif charges == maxCharges then
					ClearChargeCooldown(bu[5])
					bu[5].CD:SetCooldown(0, 0)
				end

				local hasBuff1 = UnitBuff("player", GetSpellInfo(223138))	-- Marking Targets
				local hasBuff2 = UnitBuff("player", GetSpellInfo(193526))	-- Trueshot
				if charges == maxCharges or hasBuff1 or hasBuff2 then
					bu[5].Count:SetTextColor(1, 0, 0)
					bu[5]:SetAlpha(1)
				else
					bu[5].Count:SetTextColor(1, 1, 1)
					bu[5]:SetAlpha(.5)
				end
				bu[5].Icon:SetTexture(GetSpellTexture(214579))
			elseif IsPlayerSpell(198670) then
				local start, duration = GetSpellCooldown(198670)
				if start and duration > 1.5 then
					bu[5]:SetAlpha(.5)
					bu[5].CD:SetCooldown(start, duration)
				else
					bu[5]:SetAlpha(1)
					bu[5].CD:SetCooldown(0, 0)
				end
				bu[5].Count:SetText("")
				bu[5].Icon:SetTexture(GetSpellTexture(198670))
			else
				local name, _, _, _, _, duration, expire = UnitBuff("player", GetSpellInfo(223138))
				if name then
					bu[5]:SetAlpha(1)
					bu[5].CD:SetCooldown(expire-duration, duration)
				else
					bu[5]:SetAlpha(.5)
					bu[5].CD:SetCooldown(0, 0)
				end
				bu[5].Count:SetText("")
				bu[5].Icon:SetTexture(GetSpellTexture(223138))
			end
		end
	end

	if not InCombatLockdown() then
		if not bar then return end
		for i = 1, 5 do
			bu[i]:SetAlpha(.1)
		end
		bar:SetAlpha(.1)
		bar.Count:SetText("")
		bu[5].Count:SetText("")
	end
end)