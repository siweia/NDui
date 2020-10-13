local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "MONK" then return end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateTargetBuff(button, spellID, auraID, cooldown)
	return A:UpdateAura(button, "target", auraID, "HELPFUL", spellID, cooldown, true)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 121253, true)
		UpdateBuff(self.lumos[2], 215479, 215479, false, "END")
		UpdateBuff(self.lumos[3], 322507, 322507, true)
		A:UpdateTotemAura(self.lumos[4], 608951, 132578, true)

		do
			local button = self.lumos[5]
			local name, _, duration, expire, _, spellID = GetUnitAura("player", 124275, "HARMFUL")
			if not name then name, _, duration, expire, _, spellID = GetUnitAura("player", 124274, "HARMFUL") end
			if not name then name, _, duration, expire, _, spellID = GetUnitAura("player", 124273, "HARMFUL") end

			if name and duration > 0 then
				button.CD:SetCooldown(expire-10, 10)
				button.CD:Show()
				button.Icon:SetDesaturated(false)
			else
				button.CD:Hide()
				button.Icon:SetDesaturated(true)
			end
			local texture = spellID and GetSpellTexture(spellID) or 463281
			button.Icon:SetTexture(texture)

			if button.Icon:GetTexture() == GetSpellTexture(124273) then
				B.ShowOverlayGlow(button)
			else
				B.HideOverlayGlow(button)
			end
		end
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 115151, true)
		UpdateCooldown(self.lumos[2], 191837, true)
		UpdateBuff(self.lumos[3], 116680, 116680, true, true)
		UpdateTargetBuff(self.lumos[4], 116849, 116849, true)
		UpdateCooldown(self.lumos[5], 115310, true)
	elseif spec == 3 then
		UpdateCooldown(self.lumos[1], 113656, true)
		UpdateCooldown(self.lumos[2], 107428, true)

		do
			local button = self.lumos[3]
			button.Count:SetText(GetSpellCount(101546))
			UpdateSpellStatus(button, 101546)
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(152175) then
				UpdateCooldown(button, 152175, true)
			elseif IsPlayerSpell(152173) then
				UpdateBuff(button, 152173, 152173, true, true)
			else
				UpdateBuff(button, 137639, 137639, true)
			end
		end

		A:UpdateTotemAura(self.lumos[5], 620832, 123904, true)
	end
end