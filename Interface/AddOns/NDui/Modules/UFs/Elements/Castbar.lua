local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local castTimeFormatter = C_StringUtil.CreateSecondsFormatter()
castTimeFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
-- Minutes interval keeps the "elapsed | total" pair compact and symmetric on long
-- casts: "5m | 10m" instead of the long/asymmetric "5m 35s | 10m". Sub-minute casts
-- still show seconds (e.g. "3.2s | 8.5s").
castTimeFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Minutes)
castTimeFormatter:SetMillisecondsThreshold(60)

function UF.CreateCastbarTimeBinding()
	local binding = C_DurationUtil.CreateDurationTextBinding()
	binding:SetTextFormat("{} | {}", {
		{
			property = Enum.DurationTextBindingProperty.ElapsedDuration,
			formatter = castTimeFormatter,
		},
		{
			property = Enum.DurationTextBindingProperty.TotalDuration,
			formatter = castTimeFormatter,
		},
	})
	return binding
end

-- Freeze the cast time countdown: the DurationTextBinding keeps ticking on its own,
-- so while the castbar is held after an interrupted/failed cast we disable it and
-- blank the text, otherwise the "elapsed | total" timer would keep counting through
-- the whole timeToHold. Resumed by UF:ResumeCastbarTime on the next cast start.
function UF:StopCastbarTime()
	if self.Time and self.Time.binding then
		self.Time.binding:SetEnabled(false)
	end
	if self.Time then self.Time:SetText("") end
end

function UF:ResumeCastbarTime()
	if self.Time and self.Time.binding then
		self.Time.binding:SetEnabled(true)
	end
end

function UF:UpdateCastbarGlow(spellID)
	if self.barGlow then
		local isImportant = C.db["Nameplate"]["CastbarGlow"] and C_Spell.IsSpellImportant(spellID)
		self.barGlow:SetAlphaFromBoolean(isImportant, .7, 0)
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

		if UnitShouldDisplaySpellTargetName(unit) then
			self.spellTarget:SetText(UnitSpellTargetName(unit))
			local targetClass = UnitSpellTargetClass(unit)
			local classColor = type(targetClass) ~= "nil" and C_ClassColor.GetClassColor(targetClass)
			if classColor then
				self.spellTarget:SetTextColor(classColor:GetRGB())
			else
				self.spellTarget:SetTextColor(1, 1, 1)
			end
		else
			self.spellTarget:SetText("")
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

function UF:UpdateCastBarColor(unit, spellID, notInterruptible)
	-- A new cast is starting: re-enable the countdown binding that StopCastbarTime
	-- disabled while the previous cast's bar was held.
	UF.ResumeCastbarTime(self)
	if unit == "player" then
		self:SetStatusBarColor(UF.OwnCastColor:GetRGB())
	elseif not UnitIsUnit(unit, "player") then
		self:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, UF.NotInterruptColor, UF.CastingColor)
	else
		self:SetStatusBarColor(UF.CastingColor:GetRGB())
	end
	UF.UpdateSpellTarget(self, unit)
	UF.UpdateCastbarGlow(self, spellID)
end

function UF:Castbar_FailedColor(unit)
	self:SetStatusBarColor(1, .1, 0)
	-- Cast ended (failed, interrupted or finished): stop the countdown so the held
	-- bar shows a frozen/blank timer instead of keeping on counting through timeToHold.
	UF.StopCastbarTime(self)
end

function UF:Castbar_UpdateInterrupted(unit, spellID, interruptedBy)
	self:SetStatusBarColor(1, .1, 0)
	UF.StopCastbarTime(self)

	if not C.db["Nameplate"]["Interruptor"] or not self.spellTarget or not B:NotSecretValue(interruptedBy) then return end
	if not interruptedBy then return end

	local sourceName = UnitNameFromGUID(interruptedBy)
	if not B:NotSecretValue(sourceName) or not sourceName then return end

	local _, class = GetPlayerInfoByGUID(interruptedBy)
	class = class or "PRIEST"
	local classColor = C_ClassColor.GetClassColor(class)
	self.Text:SetText(INTERRUPTED.." > "..classColor:WrapTextInColorCode(sourceName))
	self.Time:SetText("")
end

-- Empower Pips
UF.PipColors = {
	[1] = {.08, 1, 0, .5},
	[2] = {1, .1, .1, .5},
	[3] = {1, .5, 0, .5},
	[4] = {.1, .7, .7, .5},
	[5] = {0, 1, 1, .5},
	[6] = {0,.5, 1, .5},
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
	if not numStages then return end

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

