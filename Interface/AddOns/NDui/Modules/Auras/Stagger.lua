local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "MONK" then return end

-- Stagger Master
local IconSize = C.Auras.IconSize
local bu, bar = {}
local function StaggerGo()
	if bar then bar:Show() return end

	bar = CreateFrame("StatusBar", "NDui_Stagger", UIParent)
	bar:SetSize(IconSize*4 + 15, 5)
	bar:SetPoint("CENTER", 0, -200)
	bar:SetFrameStrata("HIGH")
	B.CreateSB(bar, true)
	bar:SetMinMaxValues(0, 100)
	bar:SetValue(0)
	bar.Count = B.CreateFS(bar, 16, "", false, "TOPRIGHT", 0, -7)

	local spells = {214326, 115072, 115308, 124275}
	for i = 1, 4 do
		bu[i] = CreateFrame("Frame", nil, UIParent)
		bu[i]:SetSize(IconSize, IconSize)
		bu[i]:SetFrameStrata("HIGH")
		B.CreateIF(bu[i])
		bu[i].Icon:SetTexture(GetSpellTexture(spells[i]))
		bu[i].Count = B.CreateFS(bu[i], 16, "")
		bu[i].Count:SetPoint("BOTTOMRIGHT", 4, -2)
		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 5)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 5, 0)
		end
	end
	B.Mover(bar, L["Stagger"], "Stagger", C.Auras.StaggerPos, bar:GetWidth(), 20)
end

-- localized
local ironskinBrew = GetSpellInfo(215479)
local lightStagger = GetSpellInfo(124275)
local lightStaggerTex = GetSpellTexture(124275)
local moderateStagger = GetSpellInfo(124274)
local heavyStagger = GetSpellInfo(124273)

local f = NDui:EventFrame{"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"}
f:SetScript("OnEvent", function(self, event)
	if not NDuiDB["Auras"]["Stagger"] then
		self:UnregisterAllEvents()
		return
	end

	if event == "PLAYER_LOGIN" or event == "PLAYER_TALENT_UPDATE" then
		if GetSpecializationInfo(GetSpecialization()) == 268 then
			StaggerGo()
			bar:SetAlpha(.5)
			for i = 1, 4 do
				bu[i]:Show()
				bu[i]:SetAlpha(.5)
			end

			self:RegisterUnitEvent("UNIT_AURA", "player")
			self:RegisterEvent("UNIT_MAXHEALTH")
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
		else
			if bar then bar:Hide() end
			for i = 1, 4 do
				if bu[i] then bu[i]:Hide() end
			end

			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("UNIT_MAXHEALTH")
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
			self:UnregisterEvent("SPELL_UPDATE_CHARGES")
		end
	else
		-- Exploding Keg
		if IsPlayerSpell(214326) then
			local start, duration = GetSpellCooldown(214326)
			if start and duration > 1.5 then
				bu[1]:SetAlpha(.5)
				bu[1].CD:SetCooldown(start, duration)
			else
				bu[1]:SetAlpha(1)
				bu[1].CD:SetCooldown(0, 0)
			end
		else
			bu[1]:SetAlpha(.5)
			bu[1].CD:SetCooldown(0, 0)
		end

		-- Expel Harm
		do
			local count = GetSpellCount(115072)
			bu[2].Count:SetText(count)
			if count > 0 then
				bu[2]:SetAlpha(1)
			else
				bu[2]:SetAlpha(.5)
			end
		end

		-- Ironskin Brew
		do
			local name, _, _, _, _, dur, exp = UnitBuff("player", ironskinBrew)
			local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(115308)
			local start, duration = GetSpellCooldown(115308)
			bu[3].Count:SetText(charges)
			if name then
				bu[3].Count:ClearAllPoints()
				bu[3].Count:SetPoint("TOP", 0, 18)
				bu[3]:SetAlpha(1)
				ClearChargeCooldown(bu[3])
				bu[3].CD:SetReverse(true)
				bu[3].CD:SetCooldown(exp - dur, dur)
				ActionButton_ShowOverlayGlow(bu[3])
			else
				bu[3].Count:ClearAllPoints()
				bu[3].Count:SetPoint("BOTTOMRIGHT", 4, -2)
				bu[3].CD:SetReverse(false)
				if charges < maxCharges and charges > 0 then
					StartChargeCooldown(bu[3], chargeStart, chargeDuration)
					bu[3].CD:SetCooldown(0, 0)
				elseif start and duration > 1.5 then
					ClearChargeCooldown(bu[3])
					bu[3].CD:SetCooldown(start, duration)
				elseif charges == maxCharges then
					bu[3]:SetAlpha(.5)
					ClearChargeCooldown(bu[3])
					bu[3].CD:SetCooldown(0, 0)
				end
				ActionButton_HideOverlayGlow(bu[3])
			end
		end

		-- Stagger
		do
			local Per
			local name, _, icon, _, _, duration, expire, _, _, _, _, _, _, _, _, _, value = UnitAura("player", lightStagger, "", "HARMFUL")
			if (not name) then name, _, icon, _, _, duration, expire, _, _, _, _, _, _, _, _, _, value = UnitAura("player", moderateStagger, "", "HARMFUL") end
			if (not name) then name, _, icon, _, _, duration, expire, _, _, _, _, _, _, _, _, _, value = UnitAura("player", heavyStagger, "", "HARMFUL") end
			if name and value > 0 and duration > 0 then
				Per = UnitStagger("player") / UnitHealthMax("player") * 100
				bar:SetAlpha(1)
				bu[4]:SetAlpha(1)
				bu[4].Icon:SetTexture(icon)
				bu[4].CD:SetCooldown(expire - 10, 10)
			else
				value = 0
				Per = 0
				bar:SetAlpha(.5)
				bu[4]:SetAlpha(.5)
				bu[4].Icon:SetTexture(lightStaggerTex)
				bu[4].CD:SetCooldown(0, 0)
			end
			bar:SetValue(Per)
			bar.Count:SetText(DB.InfoColor..B.Numb(value).." "..DB.MyColor..B.Numb(Per).."%")
			if UnitAura("player", heavyStagger, "", "HARMFUL") then
				ActionButton_ShowOverlayGlow(bu[4])
			else
				ActionButton_HideOverlayGlow(bu[4])
			end
		end
	end

	if not InCombatLockdown() then
		if bar then bar:SetAlpha(.1) end
		for i = 1, 4 do
			if bu[i] then bu[i]:SetAlpha(.1) end
		end
	end
end)