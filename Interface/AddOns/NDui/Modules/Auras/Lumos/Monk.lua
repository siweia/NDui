local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "MONK" then return end

function module:PostCreateLumos(self)
	local stagger = B.CreateFS(self.Health, 18, "", "system")
	stagger:ClearAllPoints()
	stagger:SetPoint("LEFT", self.Health, "RIGHT", 5, 0)

	self.stagger = stagger
end

function module:PostUpdateVisibility(self)
	if self.stagger then self.stagger:SetText("") end
end

local function GetUnitAura(unit, spell, filter)
	return module:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet)
	return module:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown)
end

local function UpdateTargetBuff(button, spellID, auraID, cooldown)
	return module:UpdateAura(button, "target", auraID, "HELPFUL", spellID, cooldown)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button:SetAlpha(1)
	else
		button:SetAlpha(.5)
	end
end

function module:ChantLumos(self)
	if GetSpecialization() == 1 then
		do
			local button = self.bu[1]
			local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage("player")
			local amount = staggerAgainstTarget or stagger
			if amount > 0 then
				button.Count:SetText(floor(amount))
				button:SetAlpha(1)
			else
				button.Count:SetText("")
				button:SetAlpha(.5)
			end
			button.Icon:SetTexture(GetSpellTexture(115069))
		end

		do
			local button = self.bu[2]
			local count = GetSpellCount(115072)
			button.Count:SetText(count)
			if count > 0 then
				button:SetAlpha(1)
			else
				button:SetAlpha(.5)
			end
			button.Icon:SetTexture(GetSpellTexture(115072))
		end

		UpdateBuff(self.bu[3], 115308, 215479, true)
		UpdateBuff(self.bu[4], 195630, 195630)

		do
			local button = self.bu[5]
			local cur = UnitStagger("player") or 0
			local max = UnitHealthMax("player")
			local perc = cur / max
			local name, _, duration, expire, _, spellID = GetUnitAura("player", 124275, "HARMFUL")
			if not name then name, _, duration, expire, _, spellID = GetUnitAura("player", 124274, "HARMFUL") end
			if not name then name, _, duration, expire, _, spellID = GetUnitAura("player", 124273, "HARMFUL") end

			if name and cur > 0 and duration > 0 then
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button:SetAlpha(1)
			else
				button.CD:Hide()
				button:SetAlpha(.5)
			end
			local texture = spellID and GetSpellTexture(spellID) or 463281
			button.Icon:SetTexture(texture)
			self.stagger:SetText(DB.InfoColor..B.Numb(cur).." "..DB.MyColor..B.Numb(perc * 100).."%")

			if button.Icon:GetTexture() == GetSpellTexture(124273) then
				ActionButton_ShowOverlayGlow(button)
			else
				ActionButton_HideOverlayGlow(button)
			end
		end
	elseif GetSpecialization() == 2 then
		UpdateCooldown(self.bu[1], 115151, true)
		UpdateCooldown(self.bu[2], 191837, true)
		UpdateBuff(self.bu[3], 116680, 116680, true)
		UpdateTargetBuff(self.bu[4], 116849, 116849, true)
		UpdateCooldown(self.bu[5], 115310, true)
	elseif GetSpecialization() == 3 then
		UpdateCooldown(self.bu[1], 113656, true)
		UpdateCooldown(self.bu[2], 107428, true)

		do
			local button = self.bu[3]
			button.Count:SetText(GetSpellCount(101546))
			UpdateSpellStatus(button, 101546)
		end

		UpdateBuff(self.bu[4], 137639, 137639, true)

		do
			local button = self.bu[5]
			if IsPlayerSpell(123904) then
				module:UpdateTotemAura(button, 620832, 123904)
			elseif IsPlayerSpell(261715) then
				UpdateBuff(button, 261715, 261715)
			else
				UpdateBuff(button, 196741, 196741)
			end
		end
	end
end