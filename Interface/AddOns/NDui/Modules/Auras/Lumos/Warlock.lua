local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

if DB.MyClass ~= "WARLOCK" then return end

function module:PostCreateLumos(self)
	local frame = CreateFrame("Frame")
	frame:SetScript("OnUpdate", function()
		if not self.dotExp then return end
		local elapsed = self.dotExp - GetTime()
		if elapsed >= 7 then
			self.bu[3]:SetAlpha(1)
		else
			self.bu[3]:SetAlpha(.5)
		end
	end)
	frame:Hide()

	self.dotUpdater = frame
end

function module:PostUpdateVisibility(self)
	if self.dotUpdater then self.dotUpdater:Hide() end
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

local function UpdateTotemAura(button, texture, spellID)
	return module:UpdateTotemAura(button, texture, spellID)
end

function module:ChantLumos(self)
	if GetSpecialization() == 1 then
		UpdateDebuff(self.bu[1], 172, 146739)
		UpdateDebuff(self.bu[2], 980, 980)

		local shown
		do
			local button = self.bu[3]
			if IsPlayerSpell(108558) then
				UpdateBuff(button, 108558, 264571)
			elseif IsPlayerSpell(264106) then
				UpdateCooldown(button, 264106, true)
			else
				if IsPlayerSpell(63106) and not shown then
					UpdateDebuff(button, 63106, 63106)
					shown = true
				else
					UpdateDebuff(button, 198590, 198590)
				end
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(32388) then
				UpdateDebuff(button, 32388, 32390)
			elseif IsPlayerSpell(48181) then
				UpdateDebuff(button, 48181, 48181, true)
			else
				if IsPlayerSpell(63106) and not shown then
					UpdateDebuff(button, 63106, 63106)
					shown = true
				else
					UpdateBuff(button, 108503, 196099)
				end
			end
		end

		do
			local button = self.bu[5]
			if IsPlayerSpell(63106) and not shown then
				button.Count:SetText("")
				local found
				for slot = 1, 4 do
					local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
					if haveTotem and icon == 1416161 then
						button.CD:SetCooldown(start, dur)
						button.CD:Show()
						button:SetAlpha(1)
						button.Icon:SetTexture(icon)
						found = true
						break
					end
				end
				if not found then
					local name, _, duration, expire, caster = GetUnitAura("target", 63106, "HARMFUL")
					if name and caster == "player" then
						button.CD:SetCooldown(expire-duration, duration)
						button.CD:Show()
						button:SetAlpha(1)
						button.Icon:SetTexture(GetSpellTexture(63106))
					else
						UpdateCooldown(button, 205180)
						button.Icon:SetTexture(1416161)
					end
				end
			else
				UpdateTotemAura(button, 1416161, 205180)
			end
		end
	elseif GetSpecialization() == 2 then
		UpdateBuff(self.bu[1], 264178, 264173)

		do
			local button = self.bu[2]
			if IsPlayerSpell(265412) then
				UpdateDebuff(button, 265412, 265412)
			elseif IsPlayerSpell(205145) then
				UpdateBuff(button, 205145, 205146)
			else
				UpdateCooldown(button, 264130, true)
			end
		end

		UpdateCooldown(self.bu[3], 104316, true)

		do
			local button = self.bu[4]
			if IsPlayerSpell(267170) then
				UpdateDebuff(button, 267170, 270569)
			elseif IsPlayerSpell(264057) then
				UpdateCooldown(button, 264057, true)
			else
				UpdateCooldown(button, 264119, true)
			end
		end

		UpdateCooldown(self.bu[5], 265187, true)
	elseif GetSpecialization() == 3 then
		UpdateDebuff(self.bu[1], 348, 157736)

		do
			local button = self.bu[2]
			if IsPlayerSpell(6353) then
				UpdateCooldown(button, 6353, true)
			elseif IsPlayerSpell(196412) then
				UpdateDebuff(button, 196412, 196414)
			else
				UpdateCooldown(button, 17962, true)
			end
		end

		do
			local button = self.bu[3]
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

		UpdateCooldown(self.bu[4], 80240, true)
		UpdateTotemAura(self.bu[5], 136219, 1122)
	end
end