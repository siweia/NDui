local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "DEATHKNIGHT" then return end
local floor = math.floor
local GetSpellTexture = C_Spell.GetSpellTexture

function A:PostCreateLumos(self)
	local shield = B.CreateFS(self.Health, 18, "", "system")
	shield:ClearAllPoints()
	shield:SetPoint("RIGHT", self.Health, "LEFT", -5, 0)

	self.shield = shield
end

function A:PostUpdateVisibility(self)
	if self.shield then self.shield:SetText("") end
end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet, glow)
	return A:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown)
end

local function UpdateBuffValue(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	local name, _, duration, expire, _, _, value = GetUnitAura("player", spellID, "HELPFUL")
	if name then
		button.Count:SetText(B.Numb(value))
		button.CD:SetCooldown(expire-duration, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
	else
		button.Count:SetText("")
		UpdateCooldown(button, spellID)
	end
	button.Count:SetTextColor(1, 1, 1)
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		do
			local button = self.lumos[1]
			local price = 45
			local hasBuff = GetUnitAura("player", 219788, "HELPFUL")
			if hasBuff then price = 40 end
			local boneCount = floor(UnitPower("player")/price)
			button.Icon:SetTexture(GetSpellTexture(49998))
			button.Count:SetText(boneCount)
			local name, _, dur, exp, _, _, value = GetUnitAura("player", 77535, "HELPFUL")
			if name then
				self.shield:SetText(B.Numb(value))
				button.CD:SetCooldown(exp-dur, dur)
				button.CD:Show()
			else
				self.shield:SetText("")
				button.CD:Hide()
			end
		end

		UpdateBuff(self.lumos[2], 195181, 195181, false, false, "END")
		UpdateBuff(self.lumos[3], 49028, 81256, true, false, true)
		UpdateBuffValue(self.lumos[4], 48707)
		UpdateBuff(self.lumos[5], 55233, 55233, true, false, true)
	elseif spec == 2 then
		do
			local button = self.lumos[1]
			if IsPlayerSpell(253593) then
				UpdateBuff(button, 253593, 253595)
			elseif IsPlayerSpell(281208) then
				UpdateBuff(button, 281208, 281209)
			else
				UpdateBuff(button, 194878, 194879)
			end
		end

		do
			local button = self.lumos[2]
			if IsPlayerSpell(321995) then
				UpdateBuff(button, 321995, 321995, true)
			elseif IsPlayerSpell(194913) then
				UpdateCooldown(button, 194913, true)
			else
				UpdateBuff(button, 196770, 196770, true)
			end
		end

		UpdateBuffValue(self.lumos[3], 51271)
		UpdateBuff(self.lumos[4], 47568, 47568, true, false, true)
		UpdateCooldown(self.lumos[5], 279302, true)
	elseif spec == 3 then
		do
			local button = self.lumos[1]
			local name, _, duration, expire = GetUnitAura("player", 51460, "HELPFUL")
			if name then
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button.Icon:SetDesaturated(false)
				button.Count:SetText("")
				button.Icon:SetTexture(GetSpellTexture(51460))
			else
				local count = floor(UnitPower("player")/40)
				if count == 0 then
					button.Icon:SetDesaturated(true)
				else
					button.Icon:SetDesaturated(false)
				end
				button.CD:Hide()
				button.Count:SetText(count)
				button.Icon:SetTexture(GetSpellTexture(47541))
			end
		end

		UpdateBuff(self.lumos[2], 63560, 63560, true, true, true)
		UpdateDebuff(self.lumos[3], 194310, 194310)
		UpdateCooldown(self.lumos[4], 275699, true)

		do
			local button = self.lumos[5]
			if IsPlayerSpell(207289) then
				UpdateBuff(button, 207289, 207289, true, false, true)
			elseif IsPlayerSpell(49206) then
				UpdateCooldown(button, 49206, true)
			else
				UpdateCooldown(button, 42650, true)
			end
		end
	end
end