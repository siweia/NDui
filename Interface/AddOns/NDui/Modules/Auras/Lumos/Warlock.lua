local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "WARLOCK" then return end
local GetSpellTexture = C_Spell.GetSpellTexture

function A:PostCreateLumos(self)
	local frame = CreateFrame("Frame")
	frame:SetScript("OnUpdate", function()
		if not self.dotExp then return end
		local elapsed = self.dotExp - GetTime()
		if elapsed >= 7 then
			self.lumos[3].Icon:SetDesaturated(false)
		else
			self.lumos[3].Icon:SetDesaturated(true)
		end
	end)
	frame:Hide()

	self.dotUpdater = frame
end

function A:PostUpdateVisibility(self)
	if self.dotUpdater then self.dotUpdater:Hide() end
end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateTotemAura(button, texture, spellID)
	return A:UpdateTotemAura(button, texture, spellID, true)
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateDebuff(self.lumos[1], 172, 146739, false, "END")
		UpdateDebuff(self.lumos[2], 980, 980, false, "END")

		do
			local button = self.lumos[3]
			local name, _, duration, expire, caster = GetUnitAura("target", 316099, "HARMFUL")
			if not name then
				name, _, duration, expire, caster = GetUnitAura("target", 342938, "HARMFUL")
			end
			if name and caster == "player" then
				button.CD:SetCooldown(expire-duration, duration)
				button.CD:Show()
				button.Icon:SetDesaturated(false)
				button.expire = expire
				button:SetScript("OnUpdate", A.GlowOnEnd)
			else
				button.CD:Hide()
				button.Icon:SetDesaturated(true)
				button:SetScript("OnUpdate", nil)
				B.HideOverlayGlow(button.glowFrame)
			end
			button.Icon:SetTexture(GetSpellTexture(316099))
		end

		UpdateDebuff(self.lumos[4], 32388, 32390, false, "END")
		UpdateTotemAura(self.lumos[5], 1416161, 205180)
	elseif spec == 2 then
		UpdateBuff(self.lumos[1], 264178, 264173, false, true)

		do
			local button = self.lumos[2]
			if IsPlayerSpell(603) then
				UpdateDebuff(button, 603, 603)
			elseif IsPlayerSpell(205145) then
				UpdateBuff(button, 205145, 205146)
			else
				UpdateCooldown(button, 264130, true)
			end
		end

		UpdateCooldown(self.lumos[3], 104316, true)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(267170) then
				UpdateDebuff(button, 267170, 270569)
			elseif IsPlayerSpell(264057) then
				UpdateCooldown(button, 264057, true)
			else
				UpdateCooldown(button, 264119, true)
			end
		end

		UpdateTotemAura(self.lumos[5], 2065628, 265187)
	elseif spec == 3 then
		UpdateDebuff(self.lumos[1], 348, 157736, false, "END")

		do
			local button = self.lumos[2]
			if IsPlayerSpell(6353) then
				UpdateCooldown(button, 6353, true)
			elseif IsPlayerSpell(196412) then
				UpdateDebuff(button, 196412, 196414)
			else
				UpdateCooldown(button, 17962, true)
			end
		end

		do
			local button = self.lumos[3]
			if IsPlayerSpell(205148) then
				UpdateBuff(button, 205148, 266030)
			elseif IsPlayerSpell(17877) then
				UpdateDebuff(button, 17877, 17877)
			else
				button.Icon:SetTexture(GetSpellTexture(116858))
				local name, _, _, expire, caster = GetUnitAura("target", 157736, "HARMFUL")
				if name and caster == "player" then
					self.dotExp = expire
					self.dotUpdater:Show()
				else
					self.dotExp = nil
					self.dotUpdater:Hide()
				end
			end
		end

		UpdateCooldown(self.lumos[4], 80240, true)
		UpdateTotemAura(self.lumos[5], 136219, 1122)
	end
end