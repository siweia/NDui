local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:UpdateCastbarGlow(unit)
	if self.barGlow then
		local isImportant = C.db["Nameplate"]["CastbarGlow"] and C_Spell.IsSpellImportant(self.spellID)
		self.barGlow:SetAlphaFromBoolean(isImportant, 1, 0)
	end
end

function UF:UpdateSpellTarget(unit)
	if not C.db["Nameplate"]["CastTarget"] then return end
	if self.spellTarget then
		local isTargetingYou = UnitIsSpellTarget(unit, "player")
		if self.isYou then
			self.isYou:SetAlphaFromBoolean(isTargetingYou, 1, 0)
		end
		self.spellTarget:SetAlphaFromBoolean(isTargetingYou, 0, 1)

		local name = UnitSpellTargetName(unit)
		local class = UnitSpellTargetClass(unit)
		self.spellTarget:SetText(name or "")
		if class then
			self.spellTarget:SetTextColor(C_ClassColor.GetClassColor(class):GetRGB())
		else
			self.spellTarget:SetTextColor(1, 1, 1)
		end
	end
end

function UF:UpdateCastBarColors()
	local castingColor = C.db["UFs"]["CastingColor"]
	local ownCastColor = C.db["UFs"]["OwnCastColor"]
	local notInterruptColor = C.db["UFs"]["NotInterruptColor"]

	UF.CastingColor = UF.CastingColor or CreateColor(0, 0, 0)
	UF.OwnCastColor = UF.OwnCastColor or CreateColor(0, 0, 0)
	UF.NotInterruptColor = UF.NotInterruptColor or CreateColor(0, 0, 0)

	UF.CastingColor:SetRGB(castingColor.r, castingColor.g, castingColor.b)
	UF.OwnCastColor:SetRGB(ownCastColor.r, ownCastColor.g, ownCastColor.b)
	UF.NotInterruptColor:SetRGB(notInterruptColor.r, notInterruptColor.g, notInterruptColor.b)
end

function UF:UpdateCastBarColor(unit)
	if unit == "player" then
		self:SetStatusBarColor(UF.OwnCastColor:GetRGB())
	elseif not UnitIsUnit(unit, "player") then
		self:GetStatusBarTexture():SetVertexColorFromBoolean(self.notInterruptible, UF.NotInterruptColor, UF.CastingColor)
	else
		self:SetStatusBarColor(UF.CastingColor:GetRGB())
	end
	UF.UpdateSpellTarget(self, unit)
	UF.UpdateCastbarGlow(self, unit)
end

function UF:Castbar_FailedColor(unit, interruptedBy)
	self:SetStatusBarColor(1, .1, 0)

	if C.db["Nameplate"]["Interruptor"] and self.spellTarget and interruptedBy ~= nil then
		local sourceName = UnitNameFromGUID(interruptedBy)
		local _, class = GetPlayerInfoByGUID(interruptedBy)
		class = class or "PRIEST"
		self.Text:SetText(INTERRUPTED.." > "..sourceName)
		self.Text:SetTextColor(C_ClassColor.GetClassColor(class):GetRGB())
		self.Time:SetText("")
	else
		self.Text:SetTextColor(1, 1, 1)
	end
end

-- Empower Pips
UF.PipColors = {
	[1] = {.08, 1, 0, .5},
	[2] = {1, .1, .1, .5},
	[3] = {1, .5, 0, .5},
	[4] = {.1, .7, .7, .5},
	[5] = {0, 1, 1, .5},
}

function UF:CreatePip(stage)
	local _, height = self:GetSize()

	local pip = CreateFrame("Frame", nil, self, "CastingBarFrameStagePipTemplate")
	pip.BasePip:SetTexture(DB.bdTex)
	pip.BasePip:SetVertexColor(0, 0, 0)
	pip.BasePip:SetWidth(C.mult)
	pip.BasePip:SetHeight(height)
	pip.tex = pip:CreateTexture(nil, "ARTWORK", nil, 2)
	pip.tex:SetTexture(DB.normTex)
	pip.tex:SetVertexColor(unpack(UF.PipColors[stage]))

	return pip
end

function UF:PostUpdatePips(numStages)
	local pips = self.Pips
	local num = #numStages

	for stage = 1, num do
		local pip = pips[stage]
		if stage == num then
			local firstPip = pips[1]
			local anchor = pips[num]
			firstPip.tex:SetPoint("BOTTOMRIGHT", self)
			firstPip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end

		if stage ~= 1 then
			local anchor = pips[stage-1]
			pip.tex:SetPoint("BOTTOMRIGHT", pip.BasePip, "BOTTOMLEFT")
			pip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end
	end
end