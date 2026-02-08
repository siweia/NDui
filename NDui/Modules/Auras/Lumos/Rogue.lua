local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "ROGUE" then return end

local diceSpells = {
	[1] = {id = 193356, text = L["Combo"]},
	[2] = {id = 193357, text = L["Crit"]},
	[3] = {id = 193358, text = L["AttackSpeed"]},
	[4] = {id = 193359, text = L["CD"]},
	[5] = {id = 199603, text = L["Strike"]},
	[6] = {id = 199600, text = L["Power"]},
}

function A:PostCreateLumos(self)
	local iconSize = (self:GetWidth() - 10)/6
	local buttons = {}
	local parent = C.db["Nameplate"]["TargetPower"] and self.Health or self.ClassPowerBar
	for i = 1, 6 do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetSize(iconSize, iconSize)
		bu.Text = B.CreateFS(bu, 12, diceSpells[i].text, false, "TOP", 1, 12)
		B.AuraIcon(bu)
		if i == 1 then
			bu:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, C.margin)
		else
			bu:SetPoint("LEFT", buttons[i-1], "RIGHT", 2, 0)
		end
		buttons[i] = bu
	end

	self.dices = buttons
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

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function A:ChantLumos(self)
	if GetSpecialization() == 1 then
		for i = 1, 6 do self.dices[i]:Hide() end

		UpdateDebuff(self.bu[1], 703, 703, true, "END")
		UpdateDebuff(self.bu[2], 1943, 1943, false, "END")

		do
			local button = self.bu[3]
			if IsPlayerSpell(111240) then
				UpdateSpellStatus(button, 111240)
			elseif IsPlayerSpell(193640) then
				UpdateBuff(button, 193640, 193641, false, true)
			else
				UpdateSpellStatus(button, 1329)
			end
		end

		do
			local button = self.bu[4]
			if IsPlayerSpell(200806) then
				UpdateCooldown(button, 200806, true)
			elseif IsPlayerSpell(245388) then
				UpdateDebuff(button, 245388, 245389, true, true)
			else
				UpdateDebuff(button, 2818, 2818)
			end
		end

		UpdateDebuff(self.bu[5], 79140, 79140, true, true)
	elseif GetSpecialization() == 2 then
		UpdateBuff(self.bu[1], 195627, 195627)
		UpdateCooldown(self.bu[2], 199804, true)

		do
			local button = self.bu[3]
			if IsPlayerSpell(5171) then
				UpdateBuff(button, 5171, 5171)
			elseif IsPlayerSpell(193539) then
				UpdateBuff(button, 193539, 193538)
			else
				UpdateBuff(button, 31224, 31224, true, true)
			end
		end

		UpdateBuff(self.bu[4], 13750, 13750, true, true)
		UpdateBuff(self.bu[5], 13877, 13877, true, true)

		-- Dices
		for i = 1, 6 do
			local bu = self.dices[i]
			local diceSpell = diceSpells[i].id
			bu:Show()
			UpdateBuff(bu, diceSpell, diceSpell)
		end
	elseif GetSpecialization() == 3 then
		for i = 1, 6 do self.dices[i]:Hide() end

		UpdateDebuff(self.bu[1], 195452, 195452, true, "END")

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

		UpdateBuff(self.bu[3], 185313, 185422, true, true)
		UpdateBuff(self.bu[4], 212283, 212283, true)
		UpdateBuff(self.bu[5], 121471, 121471, true, true)
	end
end