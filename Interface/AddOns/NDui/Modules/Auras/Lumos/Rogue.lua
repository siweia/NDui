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
	local left, right, top, bottom = unpack(DB.TexCoord)
	top = top + 1/4
	bottom = bottom - 1/4

	local iconSize = (self:GetWidth() - 10)/6
	local buttons = {}
	local parent = C.db["Nameplate"]["TargetPower"] and self.Health or self.ClassPowerBar
	for i = 1, 6 do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetSize(iconSize, iconSize/2)
		bu.Text = B.CreateFS(bu, 12, diceSpells[i].text, false, "TOP", 1, 12)
		B.AuraIcon(bu)
		bu.Icon:SetTexCoord(left, right, top, bottom)
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

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		for i = 1, 6 do self.dices[i]:Hide() end

		UpdateDebuff(self.lumos[1], 703, 703, true)
		UpdateDebuff(self.lumos[2], 1943, 1943)
		UpdateBuff(self.lumos[3], 315496, 315496)

		do
			local button = self.lumos[4]
			if IsPlayerSpell(193539) then
				UpdateBuff(button, 193539, 193538)
			else
				UpdateDebuff(button, 5938, 5938)
			end
		end

		UpdateCooldown(self.lumos[5], 381623, true)
	elseif spec == 2 then
		UpdateBuff(self.lumos[1], 315496, 315496)
		UpdateCooldown(self.lumos[2], 315341, true)
		UpdateCooldown(self.lumos[3], 315508, true)
		UpdateBuff(self.lumos[4], 13750, 13750, true, true)
		UpdateBuff(self.lumos[5], 13877, 13877, true)

		-- Dices
		for i = 1, 6 do
			local bu = self.dices[i]
			local diceSpell = diceSpells[i].id
			bu:Show()
			UpdateBuff(bu, diceSpell, diceSpell)
		end
	elseif spec == 3 then
		for i = 1, 6 do self.dices[i]:Hide() end

		UpdateBuff(self.lumos[1], 315496, 315496)
		UpdateDebuff(self.lumos[2], 1943, 1943)
		UpdateBuff(self.lumos[3], 185313, 185422, true, true)
		UpdateBuff(self.lumos[4], 212283, 212283, true)
		UpdateBuff(self.lumos[5], 121471, 121471, true, true)
	end
end