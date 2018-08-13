local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "ROGUE" then return end

local function UpdateCooldown(button, spellID, texture)
	return module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet)
	return module:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown)
end

local function UpdateDebuff(button, spellID, auraID, cooldown)
	return module:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown)
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
		UpdateDebuff(self.bu[1], 1943, 1943)

		do
			local button = self.bu[2]
			if IsPlayerSpell(111240) then
				UpdateSpellStatus(button, 111240)
			elseif IsPlayerSpell(193640) then
				UpdateBuff(button, 193640, 193641)
			else
				UpdateSpellStatus(button, 1329)
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(200806) then
				UpdateCooldown(button, 200806, true)
			elseif IsPlayerSpell(245388) then
				UpdateDebuff(button, 245388, 245389, true)
			else
				UpdateDebuff(button, 2818, 2818)
			end
		end

		UpdateDebuff(self.bu[4], 79140, 79140, true)
		UpdateBuff(self.bu[5], 31224, 31224, true)
	elseif GetSpecialization() == 2 then
		UpdateBuff(self.bu[1], 195627, 195627)

		do
			local button = self.bu[2]
			if IsPlayerSpell(5171) then
				UpdateBuff(button, 5171, 5171)
			elseif IsPlayerSpell(193539) then
				UpdateBuff(button, 193539, 193538)
			else
				UpdateCooldown(button, 199804, true)
			end
		end

		do
			local button = self.bu[3]
			if IsPlayerSpell(51690) then
				UpdateBuff(button, 51690, 51690, true)
			elseif IsPlayerSpell(271877) then
				UpdateCooldown(button, 271877, true)
			else
				UpdateBuff(button, 13877, 13877, true)
			end
		end
		UpdateBuff(self.bu[4], 13750, 13750, true)
		UpdateBuff(self.bu[5], 31224, 31224, true)
	elseif GetSpecialization() == 3 then
		UpdateDebuff(self.bu[1], 195452, 195452)

		do
			local button = self.bu[2]
			if IsPlayerSpell(277925) then
				UpdateBuff(button, 277925, 277925, true)
			elseif IsPlayerSpell(280719) then
				UpdateCooldown(button, 280719, true)
			else
				UpdateBuff(button, 196980, 196980)
			end
		end

		UpdateBuff(self.bu[3], 185313, 185422, true)
		UpdateBuff(self.bu[4], 212283, 212283, true)
		UpdateBuff(self.bu[5], 121471, 121471, true)
	end
end