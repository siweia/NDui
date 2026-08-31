local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:RegisterModule("UnitFrames")
local Cooldown = B:GetModule("Cooldown")

local pairs, next, unpack = pairs, next, unpack
local max, min = math.max, math.min
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local x1, x2, y1, y2 = unpack(DB.TexCoord)

-- Custom colors
oUF.colors.health:SetCurve({
	[ 0] = CreateColor(1, 0, 0),
	[.5] = CreateColor(.85, .8, .45),
	[ 1] = CreateColor(.1, .1, .1),
})
oUF.colors.dispel.None = oUF:CreateColor(0, 0, 0)

local UNITFRAME_AURA_DISPEL_COLORS = {}
for dispelName, color in pairs(oUF.colors.dispel) do
	UNITFRAME_AURA_DISPEL_COLORS[dispelName] = color
end
UNITFRAME_AURA_DISPEL_COLORS.None = oUF:CreateColor(.2, 0, 0)
UNITFRAME_AURA_DISPEL_COLORS.Bleed = oUF:CreateColor(.95, .05, .05)
UNITFRAME_AURA_DISPEL_COLORS.Disease = oUF:CreateColor(1, .7, 0)

local function ReplacePowerColor(name, index, r, g, b)
	oUF.colors.power[name] = oUF:CreateColor(r, g, b)
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, 0, .4, 1)
ReplacePowerColor("SOUL_SHARDS", 7, .58, .51, .79)
ReplacePowerColor("HOLY_POWER", 9, .88, .88, .06)
ReplacePowerColor("CHI", 12, 0, 1, .59)
ReplacePowerColor("ARCANE_CHARGES", 16, .41, .8, .94)

-- Various values
local function retVal(self, val1, val2, val3, val4, val5)
	local mystyle = self.mystyle
	if mystyle == "player" or mystyle == "target" then
		return val1
	elseif mystyle == "focus" then
		return val2
	elseif mystyle == "boss" or mystyle == "arena" then
		return val3
	else
		if mystyle == "nameplate" and val5 then
			return val5
		else
			return val4
		end
	end
end

-- Elements
UF.smoothbars = {}
function UF:SmoothBar(bar)
	bar.smoothing = NDuiADB["SmoothBars"] and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate
	UF.smoothbars[bar] = true
end

local function UF_OnEnter(self)
	if not self.disableTooltip then
		local unit = self.__unit
		if unit then
			-- Blizzard's unit tooltip helpers still read the public unit field.
			self.unit = unit
			UnitFrame_OnEnter(self)
		end
	end
	self.Highlight:Show()
end

local function UF_OnLeave(self)
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
	self.Highlight:Hide()
end

function UF:UpdateClickState()
	self:RegisterForClicks(self.onKeyDown and "AnyDown" or "AnyUp")
	self.onKeyDown = nil
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", UF.UpdateClickState, true)
end

function UF:CreateHeader(self, onKeyDown)
	local hl = self:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(.6, .6, .6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	if InCombatLockdown() then
		self.onKeyDown = onKeyDown
		self:RegisterEvent("PLAYER_REGEN_ENABLED", UF.UpdateClickState, true)
	else
		self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	end
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

local function UpdateHealthColorByIndex(health, index)
	local useClassGradient = index == 5
	health.colorClass = (index == 2) or useClassGradient
	health.colorReaction = (index == 2) or useClassGradient
	health:SetStatusBarTexture(useClassGradient and DB.classGradientTex or DB.normTex)
	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	health.colorSmooth = (index == 3)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	elseif index == 2 or index == 3 then
		health.bg:SetVertexColor(0, 0, 0, .7)
	elseif index == 4 then
		health:SetStatusBarColor(0, 0, 0, 0)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local health = self.Health
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		health.colorHealth = true
	elseif mystyle == "raid" then
		UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	else
		UpdateHealthColorByIndex(health, C.db["UFs"]["HealthColor"])
	end

	if force then
		health:ForceUpdate()
	end
end

local bgCurve = C_CurveUtil.CreateColorCurve()
bgCurve:SetType(Enum.LuaCurveType.Linear)
bgCurve:AddPoint(0.0, CreateColor(1, 0, 0))
bgCurve:AddPoint(0.5, CreateColor(1, .7, 0))
bgCurve:AddPoint(1, CreateColor(.7, 1, 0))

function UF.HealthPostUpdate(element, unit)
	local self = element.__owner
	local mystyle = self.mystyle
	local useGradient
	if mystyle == "PlayerPlate" then
		-- do nothing
	elseif mystyle == "raid" then
		useGradient = C.db["UFs"]["RaidHealthColor"] > 3
	else
		useGradient = C.db["UFs"]["HealthColor"] > 3
	end
	if useGradient then
		local color = UnitHealthPercent(unit, true, bgCurve)
		element.bg:SetVertexColor(color:GetRGB())
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	UF:SmoothBar(health)
	local healthHeight
	if mystyle == "PlayerPlate" then
		healthHeight = C.db["Nameplate"]["PPHealthHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			healthHeight = C.db["UFs"]["PartyHeight"]
		elseif self.raidType == "pet" then
			healthHeight = C.db["UFs"]["PartyPetHeight"]
		elseif self.raidType == "simple" then
			local scale = C.db["UFs"]["SMRScale"]/10
			healthHeight = 20*scale - 2*scale - C.mult
		else
			healthHeight = C.db["UFs"]["RaidHeight"]
		end
	else
		healthHeight = retVal(self, C.db["UFs"]["PlayerHeight"], C.db["UFs"]["FocusHeight"], C.db["UFs"]["BossHeight"], C.db["UFs"]["PetHeight"])
	end
	health:SetHeight(healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(max(self:GetFrameLevel() - 2, 0))

	self.backdrop = B.SetBD(health, 0)
	if self.backdrop.__shadow then
		self.backdrop.__shadow:SetOutside(self, 4+C.mult, 4+C.mult)
		self.backdrop.__shadow:SetFrameLevel(0)
		self.backdrop.__shadow = nil
	end

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", health)
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)

	self.Health = health
	self.Health.bg = bg
	self.Health.PostUpdate = UF.HealthPostUpdate

	UF:UpdateHealthBarColor(self)
end

UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmax",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	--[7] = "losspercent",
}

function UF:UpdateFrameHealthTag()
	local mystyle = self.mystyle
	local valueType, showValue
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerHPTag"]]
		showValue = C.db["UFs"]["PlayerAbsorb"] and "[curAbsorb] "
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusHPTag"]]
	elseif mystyle == "boss" or mystyle == "arena" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossHPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["PetHPTag"]]
	end

	self:Tag(self.healthValue, (showValue or "").."[VariousHP("..valueType..")]")
	self.healthValue:UpdateTag()
end

function UF:UpdateFrameNameTag()
	local name = self.nameText
	if not name then return end

	local mystyle = self.mystyle
	if mystyle == "nameplate" then return end

	local value = mystyle == "raid" and "RCCName" or "CCName"
	local colorTag = C.db["UFs"][value] and "[color]" or ""

	if mystyle == "player" then
		self:Tag(name, " "..colorTag.."[name]")
	elseif mystyle == "target" then
		self:Tag(name, " [fulllevel] "..colorTag.."[name][afkdnd]")
	elseif mystyle == "focus" then
		self:Tag(name, " "..colorTag.."[name][afkdnd]")
	elseif mystyle == "arena" then
		self:Tag(name, "[arenaspec] "..colorTag.."[name]")
	elseif self.raidType == "simple" and C.db["UFs"]["TeamIndex"] then
		self:Tag(name, "[group] "..colorTag.."[name]")
	else
		self:Tag(name, colorTag.."[name]")
	end
	name:UpdateTag()
end

function UF:UpdateRaidNameAnchor(name)
	if self.raidType == "pet" then
		name:ClearAllPoints()
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
			name:SetJustifyH("CENTER")
			name:SetPoint("CENTER")
		else
			name:SetWidth(self:GetWidth()*.65)
			name:SetJustifyH("LEFT")
			name:SetPoint("LEFT", 3, -1)
		end
	elseif self.raidType == "simple" then
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
		else
			name:SetWidth(self:GetWidth()*.65)
		end
	else
		name:ClearAllPoints()
		name:SetWidth(self:GetWidth()*.95)
		name:SetJustifyH("CENTER")
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetPoint("CENTER")
		else
			name:SetPoint("TOP", 0, -3)
		end
	end
end

function UF:CreateHealthText(self)
	local mystyle = self.mystyle
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Health)

	local name = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["NameTextSize"]), "", false, "LEFT", 3, 0)
	self.nameText = name
	name:SetJustifyH("LEFT")
	if mystyle == "raid" then
		UF.UpdateRaidNameAnchor(self, name)
		name:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 5)
		self:Tag(name, "[nplevel][name]")
	elseif mystyle == "player" or mystyle == "target" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["PlayerNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["PlayerNameOffset"] == 0 and .55 or 1))
	elseif mystyle == "focus" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["FocusNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["FocusNameOffset"] == 0 and .55 or 1))
	elseif mystyle == "boss" or mystyle == "arena" then
		name:SetPoint("LEFT", 3, C.db["UFs"]["BossNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["BossNameOffset"] == 0 and .55 or 1))
	else
		name:SetPoint("LEFT", 3, C.db["UFs"]["PetNameOffset"])
		name:SetWidth(self:GetWidth()*(C.db["UFs"]["PetNameOffset"] == 0 and .55 or 1))
	end

	UF.UpdateFrameNameTag(self)

	local hpval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["HealthTextSize"]), "", false, "RIGHT", -3, 0)
	self.healthValue = hpval
	if mystyle == "raid" then
		self:Tag(hpval, "[raidhp]")
		if self.raidType == "pet" then
			hpval:SetPoint("RIGHT", -3, -1)
		elseif self.raidType == "simple" then
			hpval:SetPoint("RIGHT", -4, 0)
		else
			hpval:ClearAllPoints()
			hpval:SetPoint("BOTTOM", 0, 1)
			hpval:SetJustifyH("CENTER")
		end
		hpval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		hpval:SetPoint("RIGHT", self, 0, 5)
		self:Tag(hpval, "[VariousHP(currentpercent)]")
	else
		UF.UpdateFrameHealthTag(self)
	end
end

local function UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2) or (index == 5)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)
	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
end

function UF:UpdatePowerBarColor(self, force)
	local power = self.Power
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		power.colorPower = true
	elseif mystyle == "raid" then
		UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	else
		UpdatePowerColorByIndex(power, C.db["UFs"]["HealthColor"])
	end

	if force then
		power:ForceUpdate()
	end
end

local frequentUpdateCheck = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["PlayerPlate"] = true,
}
function UF:CreatePowerBar(self)
	local mystyle = self.mystyle
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	UF:SmoothBar(power)
	local powerHeight
	if mystyle == "PlayerPlate" then
		powerHeight = C.db["Nameplate"]["PPPowerHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			powerHeight = C.db["UFs"]["PartyPowerHeight"]
		elseif self.raidType == "pet" then
			powerHeight = C.db["UFs"]["PartyPetPowerHeight"]
		elseif self.raidType == "simple" then
			powerHeight = 2*C.db["UFs"]["SMRScale"]/10
		else
			powerHeight = C.db["UFs"]["RaidPowerHeight"]
		end
	else
		powerHeight = retVal(self, C.db["UFs"]["PlayerPowerHeight"], C.db["UFs"]["FocusPowerHeight"], C.db["UFs"]["BossPowerHeight"], C.db["UFs"]["PetPowerHeight"])
	end
	power:SetHeight(powerHeight)
	power.wasHidden = powerHeight == 0
	power:SetFrameLevel(max(self:GetFrameLevel() - 2, 0))
	power.backdrop = B.CreateBDFrame(power, 0)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg:SetVertexColor(0, 0, 0, .7)

	self.Power = power
	self.Power.bg = bg

	power.frequentUpdates = frequentUpdateCheck[mystyle]
	UF:UpdatePowerBarColor(self)
end

function UF:CheckPowerBars()
	for _, frame in pairs(oUF.objects) do
		if frame.Power and frame.Power.wasHidden then
			frame:DisableElement("Power")
			if frame.powerText then frame.powerText:Hide() end
		end
	end
end

function UF:UpdateFramePowerTag()
	local mystyle = self.mystyle
	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerMPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusMPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossMPTag"]]
	end

	self:Tag(self.powerText, "[color][VariousMP("..valueType..")]")
	self.powerText:UpdateTag()
end

function UF:CreatePowerText(self)
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Power)

	local ppval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12), "", false, "RIGHT", -3, 2)
	local mystyle = self.mystyle
	if mystyle == "raid" then
		ppval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "player" or mystyle == "target" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["PlayerPowerOffset"])
	elseif mystyle == "focus" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["FocusPowerOffset"])
	elseif mystyle == "boss" or mystyle == "arena" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["BossPowerOffset"])
	end
	self.powerText = ppval
	UF.UpdateFramePowerTag(self)
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["tot"] = true,
	["focustarget"] = true,
	["boss"] = true,
	["arena"] = true,
}
function UF:UpdateTextScale()
	local scale = C.db["UFs"]["UFTextScale"]
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			if frame.powerText then frame.powerText:SetScale(scale) end
			local castbar = frame.Castbar
			if castbar then
				if castbar.Text then castbar.Text:SetScale(scale) end
				if castbar.Time then castbar.Time:SetScale(scale) end
				if castbar.Lag then castbar.Lag:SetScale(scale) end
			end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end

function UF:UpdateRaidTextScale()
	local scale = C.db["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			UF.UpdateRaidNameAnchor(frame, frame.nameText)
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = C.db["UFs"]["HideTip"]
		end
	end
end

function UF:CreatePortrait(self)
	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetAllPoints()
	portrait:SetAlpha(.2)
	self.Portrait = portrait
end

function UF:TogglePortraits()
	for _, frame in pairs(oUF.objects) do
		if frame.Portrait then
			if C.db["UFs"]["Portrait"] and not frame:IsElementEnabled("Portrait") then
				frame:EnableElement("Portrait")
				frame.Portrait:ForceUpdate()
			elseif not C.db["UFs"]["Portrait"] and frame:IsElementEnabled("Portrait") then
				frame:DisableElement("Portrait")
			end
		end
	end
end

local function postUpdateRole(element, role)
	if element:IsShown() then
		if role == Enum.LFGRole.Damage and C.db["UFs"]["ShowRoleMode"] == 3 then
			element:Hide()
			return
		end
	end
end

function UF:CreateRestingIndicator(self)
	local frame = CreateFrame("Frame", "NDuiRestingFrame", self)
	frame:SetSize(5, 5)
	frame:SetPoint("CENTER", self, "LEFT", -2, 4)
	frame:Hide()
	frame.str = {}

	local step, stepSpeed = 0, .33

	local stepMaps = {
		[1] = {true, false, false},
		[2] = {true, true, false},
		[3] = {true, true, true},
		[4] = {false, true, true},
		[5] = {false, false, true},
		[6] = {false, false, false},
	}

	local offsets = {
		[1] = {4, -4},
		[2] = {0, 0},
		[3] = {-5, 5},
	}

	for i = 1, 3 do
		local textFrame = CreateFrame("Frame", nil, frame)
		textFrame:SetAllPoints()
		textFrame:SetFrameLevel(i+5)
		local text = B.CreateFS(textFrame, (7+i*3), "z", nil, "CENTER", offsets[i][1], offsets[i][2])
		text:SetTextColor(.6, .8, 1)
		frame.str[i] = text
	end

	frame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > stepSpeed then
			step = step + 1
			if step == 7 then step = 1 end

			for i = 1, 3 do
				frame.str[i]:SetShown(stepMaps[step][i])
			end

			self.elapsed = 0
		end
	end)

	frame:SetScript("OnHide", function()
		step = 6
	end)

	self.RestingIndicator = frame
end

function UF:CreateIcons(self)
	local mystyle = self.mystyle
	if mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(28, 28)
		combat:SetAtlas(DB.objectTex)
		self.CombatIndicator = combat
	elseif mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, self)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	if C.db["UFs"]["ShowRoleMode"] ~= 2 then
		local ri = self:CreateTexture(nil, "OVERLAY")
		if mystyle == "raid" then
			ri:SetPoint("TOPRIGHT", self, 5, 5)
		else
			ri:SetPoint("TOPRIGHT", self, 0, 8)
		end
		ri:SetSize(15, 15)
		ri.PostUpdate = postUpdateRole
		self.GroupRoleIndicator = ri
	end

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, -1, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, -1, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai
end

function UF:CreateRaidMark(self)
	local mystyle = self.mystyle
	local ri = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		ri:SetPoint("TOP", self, 0, 10)
	elseif mystyle == "nameplate" then
		ri:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 3)
	else
		ri:SetPoint("CENTER", self, "TOP")
	end
	local size = retVal(self, 18, 13, 12, 12, 32)
	ri:SetSize(size, size)
	self.RaidTargetIndicator = ri
end

local function createBarMover(bar, text, value, anchor)
	local mover = B.Mover(bar, text, value, anchor, bar:GetHeight()+bar:GetWidth()+3, bar:GetHeight()+3)
	bar:ClearAllPoints()
	bar:SetPoint("RIGHT", mover)
	bar.mover = mover
end

function UF:CreateCastBar(self)
	local mystyle = self.mystyle
	if mystyle ~= "nameplate" and not C.db["UFs"]["Castbars"] then return end

	local cb = CreateFrame("StatusBar", "oUF_Castbar"..mystyle, self)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - 22)
	B.CreateSB(cb, true, .3, .7, 1)
	cb.castTicks = {}

	if mystyle == "player" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
		createBarMover(cb, L["Player Castbar"], "PlayerCB", C.UFs.Playercb)
	elseif mystyle == "target" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"])
		createBarMover(cb, L["Target Castbar"], "TargetCB", C.UFs.Targetcb)
	elseif mystyle == "focus" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"])
		createBarMover(cb, L["Focus Castbar"], "FocusCB", C.UFs.Focuscb)
	elseif mystyle == "boss" or mystyle == "arena" then
		cb:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -8)
		cb:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -8)
		cb:SetHeight(10)
	elseif mystyle == "nameplate" then
		cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		cb:SetHeight(self:GetHeight())
	end

	local timer = B.CreateFS(cb, 12, "", false, "RIGHT", -2, 0)
	timer.binding = UF.CreateCastbarTimeBinding()
	local name = B.CreateFS(cb, 12, "", false, "LEFT", 2, 0)
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
	name:SetJustifyH("LEFT")

	if mystyle ~= "boss" and mystyle ~= "arena" then
		cb.Icon = cb:CreateTexture(nil, "ARTWORK")
		cb.Icon:SetSize(cb:GetHeight(), cb:GetHeight())
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -3, 0)
		cb.Icon:SetTexCoord(x1, x2, y1, y2)
		B.SetBD(cb.Icon)
	end

	if mystyle == "player" then
		local safeZone = cb:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(DB.normTex)
		safeZone:SetVertexColor(1, 0, 0, .6)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		cb:SetFrameLevel(10)
		cb.SafeZone = safeZone
	elseif mystyle == "nameplate" then
		name:SetPoint("TOPLEFT", cb, "LEFT", 0, -1)
		timer:SetPoint("TOPRIGHT", cb, "RIGHT", 0, -1)

		local shield = cb:CreateTexture(nil, "OVERLAY")
		shield:SetAtlas("nameplates-InterruptShield")
		shield:SetSize(18, 18)
		shield:SetPoint("TOP", cb, "CENTER", 0, -1)
		cb.Shield = shield

		local iconSize = self:GetHeight()*2 + 5
		cb.Icon:SetSize(iconSize, iconSize)
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -5, 0)

		local spellTarget = B.CreateFS(cb, C.db["Nameplate"]["NameTextSize"]+3)
		spellTarget:ClearAllPoints()
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		cb.spellTarget = spellTarget

		local isYou = B.CreateFS(cb, C.db["Nameplate"]["NameTextSize"]+3)
		isYou:ClearAllPoints()
		isYou:SetJustifyH("LEFT")
		isYou:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		isYou:SetTextColor(1, 0, 0)
		isYou:SetText(">>"..YOU.."<<")
		isYou:SetAlpha(0)
		cb.isYou = isYou

		local barGlow = cb:CreateTexture(nil, "ARTWORK", nil, 2)
		barGlow:SetAllPoints()
		barGlow:SetTexture(DB.barArrow)
		barGlow:SetAlpha(0)
		cb.barGlow = barGlow
	end

	cb.Time = timer
	cb.Text = name
	cb.timeToHold = .5
	cb.PostCastStart = UF.UpdateCastBarColor
	cb.PostCastInterruptible = UF.UpdateCastBarColor
	cb.PostCastStop = UF.Castbar_FailedColor
	cb.PostCastFail = UF.Castbar_FailedColor
	cb.PostCastInterrupted = UF.Castbar_UpdateInterrupted
	cb.PostCastGlobal = UF.ResumeCastbarTime -- GCD right after an interrupted cast must show its countdown again
	cb.CreatePip = UF.CreatePip
	cb.PostUpdatePips = UF.PostUpdatePips

	self.Castbar = cb
end

function UF:CreateSparkleCastBar(self)
	if not C.db["UFs"]["PetCB"] then return end

	local bar = CreateFrame("StatusBar", "oUF_SparkleCastbar"..self.mystyle, self)
	bar:SetAllPoints(self.Power)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(1, 1, 1, .25)

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(DB.sparkTex)
	spark:SetBlendMode("ADD")
	spark:SetAlpha(.8)
	spark:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
	spark:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
	bar.Spark = spark

	self.Castbar = bar
end

function UF:ToggleCastBar(unit)
	if not self or not unit then return end

	if C.db["UFs"][unit.."CB"] and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
	elseif not C.db["UFs"][unit.."CB"] and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
	end
end

local function reskinTimerBar(bar)
	bar:SetSize(280, 15)
	B.StripTextures(bar)

	local statusbar = bar.StatusBar or _G[bar:GetName().."StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
	elseif bar.SetStatusBarTexture then
		bar:SetStatusBarTexture(DB.normTex)
	end

	B.SetBD(bar)
end

function UF:ReskinMirrorBars()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", function(self, timer)
		local bar = self:GetAvailableTimer(timer)
		if not bar.styled then
			reskinTimerBar(bar)
			bar.styled = true
		end
	end)
end

function UF:ReskinTimerTrakcer(self)
	local function updateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				reskinTimerBar(timer.bar)

				timer.bar.styled = true
			end
		end
	end
	self:RegisterEvent("START_TIMER", updateTimerTracker, true)
end

-- Auras Relevant
local AURA_DURATION_BREAKPOINTS = {
	{
		threshold = 0,
		step = 1,
		rounding = Enum.NumericRuleFormatRounding.Down,
		format = "%d",
	},
	{
		threshold = SECONDS_PER_MIN,
		format = "%d:%02d",
		components = {
			{div = SECONDS_PER_MIN, step = 1, rounding = Enum.NumericRuleFormatRounding.Down},
			{mod = SECONDS_PER_MIN, step = 1, rounding = Enum.NumericRuleFormatRounding.Down},
		},
	},
	{
		threshold = 5 * SECONDS_PER_MIN,
		format = "%dm",
		components = {{div = SECONDS_PER_MIN, step = 1, rounding = Enum.NumericRuleFormatRounding.Down}},
	},
	{
		threshold = SECONDS_PER_HOUR,
		format = "%dh",
		components = {{div = SECONDS_PER_HOUR, step = 1, rounding = Enum.NumericRuleFormatRounding.Down}},
	},
	{
		threshold = SECONDS_PER_DAY,
		format = "%dd",
		components = {{div = SECONDS_PER_DAY, step = 1, rounding = Enum.NumericRuleFormatRounding.Down}},
	},
}
local HIDDEN_AURA_DURATION_BREAKPOINTS = {{threshold = 0, format = ""}}

local function UpdateAuraDurationFormatter(element, hidden)
	local formatter = element.__nduiDurationFormatter
	if not formatter then
		formatter = C_StringUtil.CreateNumericRuleFormatter()
		element.__nduiDurationFormatter = formatter
	end

	hidden = hidden and true or false
	if element.__nduiDurationHidden ~= hidden then
		formatter:SetBreakpoints(hidden and HIDDEN_AURA_DURATION_BREAKPOINTS or AURA_DURATION_BREAKPOINTS)
		element.__nduiDurationHidden = hidden
	end

	return formatter
end

function UF:UpdateIconTexCoord(width, height)
	local ratio = height / width
	local mult = (1 - ratio) / 2
	self.Icon:SetTexCoord(x1, x2, y1 + mult, y2 - mult)
end

local function CreateAuraDispelBorder(button)
	local thickness = C.mult
	local border = CreateFrame("Frame", nil, button)
	border:SetAllPoints()
	border:SetFrameLevel(button.Cooldown:GetFrameLevel())
	local textures = {}

	local top = border:CreateTexture(nil, "OVERLAY", nil, 7)
	top:SetColorTexture(1, 1, 1)
	top:SetPoint("TOPLEFT", button)
	top:SetPoint("TOPRIGHT", button)
	top:SetHeight(thickness)
	textures[1] = top

	local bottom = border:CreateTexture(nil, "OVERLAY", nil, 7)
	bottom:SetColorTexture(1, 1, 1)
	bottom:SetPoint("BOTTOMLEFT", button)
	bottom:SetPoint("BOTTOMRIGHT", button)
	bottom:SetHeight(thickness)
	textures[2] = bottom

	local left = border:CreateTexture(nil, "OVERLAY", nil, 7)
	left:SetColorTexture(1, 1, 1)
	left:SetPoint("TOPLEFT", button)
	left:SetPoint("BOTTOMLEFT", button)
	left:SetWidth(thickness)
	textures[3] = left

	local right = border:CreateTexture(nil, "OVERLAY", nil, 7)
	right:SetColorTexture(1, 1, 1)
	right:SetPoint("TOPRIGHT", button)
	right:SetPoint("BOTTOMRIGHT", button)
	right:SetWidth(thickness)
	textures[4] = right

	local options = {
		showWhenHarmful = true,
		showWhenHelpful = true,
		showWithoutDispelType = true,
		style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
		customDispelColorMap = UNITFRAME_AURA_DISPEL_COLORS,
	}
	for _, texture in ipairs(textures) do
		button:AddDispelTypeTexture(texture, options)
	end
end

function UF.PostCreateButton(element, button, options)
	local size = options.size or element.size
	local fontSize = options.fontSize or element.fontSize or size*.4
	if button.Count then
		button.Count:SetFont(DB.Font[1], fontSize, DB.Font[3])
		button.Count:SetPoint("BOTTOMRIGHT", 2, 0)
	end
	if button.Cooldown then
		button.Cooldown:SetReverse(true)
		button.CooldownText = button.Cooldown:GetRegions()
		if button.CooldownText then
			button.CooldownText:SetFont(DB.Font[1], fontSize, DB.Font[3])
		end
		Cooldown:IgnoreCooldown(button.Cooldown)
		button.Cooldown:SetCountdownFormatter(UpdateAuraDurationFormatter(element, element.hideDuration))
	end
	if options.desaturated then
		button.Icon:SetDesaturated(true)
	end
	button.iconbg = B.ReskinIcon(button.Icon)
	button.iconbg:SetBackdropBorderColor(0, 0, 0)
	B.CreateSD(button)

	if options.showDebuffTypeBorder then
		CreateAuraDispelBorder(button)
	end

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()

	if button.Overlay then
		button.Overlay:Hide()
		button.Overlay = nil
	end
	if button.Stealable then
		button.Stealable:SetAtlas("bags-newitem")
	end

	if element.__owner.mystyle == "nameplate" then
		local sizeRatio = options.sizeRatio or element.sizeRatio
		UF.UpdateIconTexCoord(button, size, size * sizeRatio)
		if button.Count then
			button.Count:ClearAllPoints()
			button.Count:SetPoint("RIGHT", button, "BOTTOMRIGHT", 5, 0)
		end
	end
end

-- 友方减益的法术ID过滤仅对NeverSecret光环生效 / Friendly harmful spell-ID filters only apply to NeverSecret auras.
local RAID_DEBUFF_BLACKLIST = {
	[57723] = true,	-- 筋疲力尽 / Exhaustion
	[57724] = true,	-- 心满意足 / Sated
	[80354] = true,	-- 时空错位 / Temporal Displacement
	[95809] = true,	-- 疯狂 / Insanity
	[160455] = true,	-- 疲倦 / Fatigued
	[264689] = true,	-- 疲倦 / Fatigued
	[390435] = true,	-- 筋疲力尽 / Exhaustion
	[26013] = true,	-- 逃亡者 / Deserter
	[71041] = true,	-- 地下城逃亡者 / Dungeon Deserter
	[1313593] = true,	-- 逃亡者 / Deserter
	[206151] = true,	-- 挑战者的负担 / Challenger's Burden
	[308312] = true,	-- 限时试炼练习 / Time Trial Practice
	[1254550] = true,	-- 奥术强化 / Arcane Empowerment
}

local function UpdateAuraGroup(element, name, filter, count)
	local groupKey = filter and element.__groups[name]
	if not groupKey then return end

	element:SetAuraGroupFilterString(groupKey, filter)
	element:SetAuraGroupMaxFrameCount(groupKey, count or 0)
end

local NAMEPLATE_AURA_GROUP_NAME = "NameplateAuras"
local NAMEPLATE_AURA_SETTINGS = {
	buffs = {
		enabled = "PlateBuffs",
		count = "maxBuffs",
		size = "BuffSize",
		fontSize = "BuffFontSize",
		sizeRatio = "BuffSizeRatio",
		typeBorder = "BuffColor",
	},
	debuffs = {
		enabled = "PlateAuras",
		count = "maxAuras",
		size = "AuraSize",
		fontSize = "FontSize",
		sizeRatio = "SizeRatio",
		typeBorder = "DebuffColor",
	},
}

-- Aura filter rules
local PRIORITY_BUFF_RULES = {
	bossOrRole = { -- Boss and role buffs
		auraType = "buffs",
		filter = "HELPFUL",
		candidateFilters = {
			isBossOrRoleAura = true,
		},
	},
	stealable = { -- Other stealable buffs
		auraType = "buffs",
		filter = "HELPFUL|!IMPORTANT",
		candidateFilters = {
			isStealable = true,
			isBossOrRoleAura = false,
		},
	},
	dispellable = { -- Other dispellable buffs
		auraType = "buffs",
		filter = "HELPFUL|DISPELLABLE|!IMPORTANT",
		candidateFilters = {
			isBossOrRoleAura = false,
		},
	},
	important = { -- Other important buffs
		auraType = "buffs",
		filter = "HELPFUL|IMPORTANT",
		candidateFilters = {
			isBossOrRoleAura = false,
		},
	},
}

local NAMEPLATE_DEBUFF_GROUPS = {
	{ -- Personal nameplate debuffs, excluding crowd control
		auraType = "debuffs",
		filter = "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL",
		candidateFilters = {
			nameplateShowPersonal = true,
		},
	},
	{ -- Other nameplate debuffs visible to everyone, excluding crowd control
		auraType = "debuffs",
		filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL",
		candidateFilters = {
			nameplateShowAll = true,
			nameplateShowPersonal = false,
		},
	},
}

local NAMEPLATE_BUFF_GROUPS = {
	PRIORITY_BUFF_RULES.bossOrRole,
	PRIORITY_BUFF_RULES.stealable,
	PRIORITY_BUFF_RULES.important,
}
local NAMEPLATE_AURA_GROUPS = {
	NAMEPLATE_BUFF_GROUPS[1],
	NAMEPLATE_BUFF_GROUPS[2],
	NAMEPLATE_BUFF_GROUPS[3],
	NAMEPLATE_DEBUFF_GROUPS[1],
	NAMEPLATE_DEBUFF_GROUPS[2],
}
local NAMEPLATE_NPC_BUFF_GROUP = PRIORITY_BUFF_RULES.dispellable
local NAMEPLATE_CC_RULE = {
	filter = "HARMFUL|CROWD_CONTROL|INCLUDE_NAME_PLATE_ONLY",
}
local NAMEPLATE_AURA_CONTAINERS = {
	{auraType = "debuffs", element = "Auras", anchor = "BOTTOMLEFT", relativeAnchor = "TOPLEFT", growthX = "RIGHT"},
	{auraType = "buffs", element = "Buffs", anchor = "BOTTOMRIGHT", relativeAnchor = "TOPRIGHT", growthX = "LEFT"},
}

local BOSS_BUFF_GROUP_NAME = "BossBuffs"
local BOSS_BUFF_GROUPS = {
	PRIORITY_BUFF_RULES.bossOrRole,
	PRIORITY_BUFF_RULES.stealable,
	PRIORITY_BUFF_RULES.important,
}

local DEFENSIVE_BUFF_RULES = {
	big = {
		filter = "HELPFUL|BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE",
	},
	external = {
		filter = "HELPFUL|EXTERNAL_DEFENSIVE",
	},
	dispellable = {
		filter = "HELPFUL|DISPELLABLE|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE",
	},
}

local ARENA_BUFF_GROUP_NAME = "ArenaBuffs"
local ARENA_BUFF_GROUPS = {
	[3] = {
		DEFENSIVE_BUFF_RULES.big,
		DEFENSIVE_BUFF_RULES.external,
	},
	[5] = {
		DEFENSIVE_BUFF_RULES.big,
		DEFENSIVE_BUFF_RULES.external,
		DEFENSIVE_BUFF_RULES.dispellable,
	},
}

local ARENA_DEBUFF_GROUP_NAME = "ArenaDebuffs"
local ARENA_DEBUFF_GROUPS = {
	{
		filter = "HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY",
		candidateFilters = {
			nameplateShowPersonal = true,
		},
	},
	{
		filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY",
		candidateFilters = {
			nameplateShowAll = true,
			nameplateShowPersonal = false,
		},
	},
}

local RAID_BUFF_GROUP = {
	filter = "HELPFUL|RAID_IN_COMBAT|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE",
	candidateFilters = {
		isFromPlayerOrPlayerPet = true,
	},
}

local RAID_BIG_DEFENSIVE_SPACING = 2
local RAID_BIG_DEFENSIVE_RIGHT_INSET = 17
local RAID_BIG_DEFENSIVE_PADDING = 3
local RAID_BIG_DEFENSIVE_GROUPS = {
	DEFENSIVE_BUFF_RULES.big,
	DEFENSIVE_BUFF_RULES.external,
}

local function PostCreateRaidBigDefensiveButton(element, button, options)
	UF.PostCreateButton(element, button, options)
	button:ClearAllPoints()
	local xOffset = -RAID_BIG_DEFENSIVE_RIGHT_INSET - (options.slotIndex - 1) * (options.size + RAID_BIG_DEFENSIVE_SPACING)
	button:SetPoint("BOTTOMRIGHT", element.__owner.Health, "BOTTOMRIGHT", xOffset, C.db["UFs"]["RaidDebuffSize"] + 4)
end

local RAID_DEBUFF_GROUP_NAME = "RaidDebuffs"
local RAID_DEBUFF_GROUPS = {
	{ -- Boss and role auras
		filter = "HARMFUL",
		candidateFilters = {
			isBossOrRoleAura = true,
			isFromPlayerOrPlayerPet = false,
		},
	},
	{ -- Other priority auras
		filter = "HARMFUL",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = true,
			isFromPlayerOrPlayerPet = false,
		},
	},
	{ -- Dispellable auras
		filter = "HARMFUL|DISPELLABLE",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = false,
		},
	},
	{ -- Other regular auras
		filter = "HARMFUL|!DISPELLABLE",
		candidateFilters = {
			isBossOrRoleAura = false,
			isPriorityAura = false,
			isFromPlayerOrPlayerPet = false,
			excludeSpellIDs = RAID_DEBUFF_BLACKLIST,
		},
	},
}

local UNITFRAME_DESATURATED_DEBUFF_TYPE = 2
local UNITFRAME_DESATURATED_DEBUFF_GROUP_NAME = "UnitFrameDesaturatedDebuffs"
local UNITFRAME_DESATURATED_DEBUFF_GROUPS = {
	{filter = "HARMFUL|PLAYER"},
	{filter = "HARMFUL|!PLAYER"},
}
local UNITFRAME_PERSONAL_DEBUFF_LIMIT = 8
local UNITFRAME_DESATURATED_DEBUFF_VALUES = {
	Player = true,
	Target = true,
	Focus = true,
}

-- Filter strings mapped to each GUI dropdown value
local UNITFRAME_AURA_FILTERS = {
	Buff = {
		[1] = "HELPFUL",
		[2] = "HELPFUL",
		[3] = "HELPFUL|DISPELLABLE",
		[4] = "HELPFUL|CANCELABLE",
	},
	Debuff = {
		[1] = "HARMFUL",
		[2] = "HARMFUL",
		[3] = "HARMFUL|PLAYER",
		[4] = "HARMFUL|DISPELLABLE",
	},
}

local AURA_FILTER_OPTIONS = {
	Raid = {
		Buff = {
			[1] = "HELPFUL",
			[2] = RAID_BUFF_GROUP.filter,
		},
		Debuff = {
			[1] = "HARMFUL",
			[2] = "HARMFUL|RAID_IN_COMBAT",
			[3] = "HARMFUL|DISPELLABLE",
			[4] = "HARMFUL",
		},
	},
	Boss = {
		Buff = {
			[1] = "HELPFUL",
			[2] = "HELPFUL",
			[3] = BOSS_BUFF_GROUPS[1].filter,
		},
		Debuff = UNITFRAME_AURA_FILTERS.Debuff,
	},
	Arena = {
		Buff = {
			[1] = "HELPFUL",
			[2] = "HELPFUL",
			[3] = ARENA_BUFF_GROUPS[3][1].filter,
			[4] = "HELPFUL|DISPELLABLE",
			[5] = ARENA_BUFF_GROUPS[5][1].filter,
		},
		Debuff = {
			[1] = "HARMFUL",
			[2] = "HARMFUL",
			[3] = ARENA_DEBUFF_GROUPS[1].filter,
		},
	},
}

local function GetUnitFrameDesaturatedDebuffCount(total, index)
	if index == 1 then
		return min(total, UNITFRAME_PERSONAL_DEBUFF_LIMIT)
	end

	return max(total - UNITFRAME_PERSONAL_DEBUFF_LIMIT, 0)
end

local function GetNameplateAuraGroupCount(group)
	local settings = NAMEPLATE_AURA_SETTINGS[group.auraType]
	local db = C.db["Nameplate"]
	return db[settings.enabled] and db[settings.count] or 0
end

local function UpdateNameplateAuraGroups(parent, element)
	local useNPCBuffFilter = element.__nameplateAuraType == "buffs" and parent.isPlayer == false and parent.isFriendly == false
	local buffFilterChanged = element.__useNPCBuffFilter ~= nil and element.__useNPCBuffFilter ~= useNPCBuffFilter
	element.__useNPCBuffFilter = useNPCBuffFilter

	for index, group in ipairs(NAMEPLATE_AURA_GROUPS) do
		if group.auraType == element.__nameplateAuraType then
			local name = NAMEPLATE_AURA_GROUP_NAME..index
			local activeGroup = useNPCBuffFilter and index == 2 and NAMEPLATE_NPC_BUFF_GROUP or group

			UpdateAuraGroup(element, name, activeGroup.filter, GetNameplateAuraGroupCount(group))
			if buffFilterChanged and index == 2 then
				element:SetAuraGroupCandidateFilters(element.__groups[name], activeGroup.candidateFilters)
			end
		end
	end
end

local function UpdateAuraGroups(element, groupName, groups, count)
	for index, group in ipairs(groups) do
		UpdateAuraGroup(element, groupName..index, group.filter, count)
	end
end

function UF:UpdateAuraContainer(parent, element)
	UpdateAuraGroup(element, "Buffs", element.buffFilter, element.numBuffs)
	if element.__groups[UNITFRAME_DESATURATED_DEBUFF_GROUP_NAME..1] then
		for index, group in ipairs(UNITFRAME_DESATURATED_DEBUFF_GROUPS) do
			local count = element.__desaturateOthers and GetUnitFrameDesaturatedDebuffCount(element.numDebuffs, index) or 0
			UpdateAuraGroup(element, UNITFRAME_DESATURATED_DEBUFF_GROUP_NAME..index, group.filter, count)
		end
	else
		local count = element.__desaturateOthers and 0 or element.numDebuffs
		UpdateAuraGroup(element, "Debuffs", element.debuffFilter, count)
	end

	local auraType = element.__auraType
	if auraType then
		if auraType == "nameplate" then
			UpdateNameplateAuraGroups(parent, element)
		else
			local isRaidDebuffs = auraType == "debuffs" and element.__value == "Raid"
			local isBossBuffs = auraType == "buffs" and element.__value == "Boss"
			local isArenaBuffs = auraType == "buffs" and element.__value == "Arena"
			local isArenaDebuffs = auraType == "debuffs" and element.__value == "Arena"
			if isRaidDebuffs and element.__groups[RAID_DEBUFF_GROUP_NAME..1] then
				local count = element.__filterType == 2 and element.num or 0
				UpdateAuraGroups(element, RAID_DEBUFF_GROUP_NAME, RAID_DEBUFF_GROUPS, count)
			elseif isBossBuffs and element.__groups[BOSS_BUFF_GROUP_NAME..1] then
				local count = element.__filterType == 3 and element.num or 0
				UpdateAuraGroups(element, BOSS_BUFF_GROUP_NAME, BOSS_BUFF_GROUPS, count)
			elseif isArenaBuffs and element.__groups[ARENA_BUFF_GROUP_NAME..1] then
				local groupType = element.__groups[ARENA_BUFF_GROUP_NAME..3] and 5 or 3
				local count = element.__filterType == groupType and element.num or 0
				UpdateAuraGroups(element, ARENA_BUFF_GROUP_NAME, ARENA_BUFF_GROUPS[groupType], count)
			elseif isArenaDebuffs and element.__groups[ARENA_DEBUFF_GROUP_NAME..1] then
				local count = element.__filterType == 3 and element.num or 0
				UpdateAuraGroups(element, ARENA_DEBUFF_GROUP_NAME, ARENA_DEBUFF_GROUPS, count)
			else
				local groupName = auraType == "buffs" and "Buffs" or "Debuffs"
				local needsReload = isRaidDebuffs and element.__filterType == 2
					or isBossBuffs and element.__filterType == 3
					or isArenaBuffs and ARENA_BUFF_GROUPS[element.__filterType]
					or isArenaDebuffs and element.__filterType == 3
				local count = needsReload and 0 or element.num or element.numTotal
				UpdateAuraGroup(element, groupName, element.filter, count)
			end
		end
	end

	if parent.mystyle == "nameplate" then return end

	-- AuraButton regions are forbidden after the provider initializer returns.
	UpdateAuraDurationFormatter(element, element.hideDuration)
end

function UF:ConfigureAuras(element)
	local value = element.__value
	local buffType = C.db["UFs"][value.."BuffType"]
	local debuffType = C.db["UFs"][value.."DebuffType"]
	element.numBuffs = buffType ~= 1 and C.db["UFs"][value.."NumBuff"] or 0
	element.numDebuffs = debuffType ~= 1 and C.db["UFs"][value.."NumDebuff"] or 0
	element.buffFilter = UNITFRAME_AURA_FILTERS.Buff[buffType]
	element.debuffFilter = UNITFRAME_AURA_FILTERS.Debuff[debuffType]
	element.__desaturateOthers = UNITFRAME_DESATURATED_DEBUFF_VALUES[value] and debuffType == UNITFRAME_DESATURATED_DEBUFF_TYPE
	element.size = C.db["UFs"][value.."AuraSize"]
	-- Keep oUF's native Border uncreated; Blizzard can show it again after a layout-side Hide.
	element.showDebuffTypeBorder = C.db["UFs"]["DebuffColor"]
	element.fontSize = C.db["UFs"][value.."CDSize"]
end

function UF:RefreshUFAuras(frame)
	if not frame then return end
	local element = frame.Auras
	if not element then return end

	UF:ConfigureAuras(element)
	UF:UpdateAuraContainer(frame, element)
	UF:UpdateAuraDirection(frame, element)
	element:ForceUpdate()
end

function UF:ConfigureBuffAndDebuff(element, isDebuff)
	local value = element.__value
	local vType = isDebuff and "Debuff" or "Buff"
	local isRaid = value == "Raid"
	local filterType = C.db["UFs"][value..vType.."Type"]
	element.__filterType = filterType
	element.num = filterType ~= 1 and C.db["UFs"][value.."Num"..vType] or 0
	local filterOptions = AURA_FILTER_OPTIONS[value] or UNITFRAME_AURA_FILTERS
	element.filter = filterOptions[vType][filterType]
	element.size = C.db["UFs"][value..vType.."Size"]
	element.showDebuffTypeBorder = isDebuff and (isRaid or C.db["UFs"]["DebuffColor"])
	if isRaid then
		local setting = isDebuff and "RaidDebuff" or "RaidBuff"
		element.fontSize = C.db["UFs"][setting.."CDSize"]
		element.hideDuration = not C.db["UFs"][setting.."CDText"]
	else
		element.fontSize = C.db["UFs"][value.."CDSize"]
		element.hideDuration = false
	end
end

function UF:RefreshBuffAndDebuff(frame)
	if not frame then return end

	local element = frame.Buffs
	if element then
		UF:ConfigureBuffAndDebuff(element)
		UF:UpdateAuraContainer(frame, element)
		element:ForceUpdate()
	end

	local element = frame.Debuffs
	if element then
		UF:ConfigureBuffAndDebuff(element, true)
		UF:UpdateAuraContainer(frame, element)
		element:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 10 do
		UF:RefreshBuffAndDebuff(_G["oUF_Boss"..i])
	end

	for i = 1, 5 do
		UF:RefreshBuffAndDebuff(_G["oUF_Arena"..i])
	end

	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			UF:RefreshBuffAndDebuff(frame)
		end
	end
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
		end
	end
end

function UF:ToggleAllAuras()
	local enable = C.db["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
	UF:ToggleUFAuras(_G.oUF_Pet, enable)
end

UF.AuraDirections = {
	[1] = {name = L["RIGHT_DOWN"], initialAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -1, growthX = "RIGHT", growthY = "DOWN"},
	[2] = {name = L["RIGHT_UP"], initialAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 1, growthX = "RIGHT", growthY = "UP"},
	[3] = {name = L["LEFT_DOWN"], initialAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -1, growthX = "LEFT", growthY = "DOWN"},
	[4] = {name = L["LEFT_UP"], initialAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 1, growthX = "LEFT", growthY = "UP"},
}

function UF:UpdateAuraDirection(self, element)
	local direc = C.db["UFs"][element.__value.."AuraDirec"]
	local yOffset = C.db["UFs"][element.__value.."AuraOffset"]
	local value = UF.AuraDirections[direc]
	element.initialAnchor = value.initialAnchor
	element["growthX"] = value.growthX
	element["growthY"] = value.growthY
	element:SetFlowLayoutAnchorPoint(value.initialAnchor)
	element:SetFlowLayoutGrowthDirection(
		value.growthX == "LEFT" and -1 or 1,
		value.growthY == "DOWN" and -1 or 1
	)
	element:ClearAllPoints()
	element:SetPoint(value.initialAnchor, self, value.relAnchor, value.x, value.y * yOffset)
end

local function AuraGroupLayout(element, index, groupSpacing)
	if groupSpacing == nil then groupSpacing = element.groupSpacing end
	if groupSpacing == nil then groupSpacing = element.spacing end
	return {
		elementSpacing = element.spacing,
		lineSpacing = element.spacing,
		groupSpacing = groupSpacing,
		groupLineSpacing = groupSpacing,
		forceNewLine = false,
		layoutIndex = index,
	}
end

local function AddAuraGroup(element, name, filter, count, index, candidateFilters, sortMethod, buttonOptions)
	buttonOptions = buttonOptions or {}
	local size = buttonOptions.size or element.size
	local sizeRatio = buttonOptions.sizeRatio or element.sizeRatio
	local showTypeBorder = buttonOptions.showDebuffTypeBorder
	if showTypeBorder == nil then
		local useTypeBorder = name == "Debuffs" or element.__auraType == "debuffs"
		showTypeBorder = useTypeBorder and element.showDebuffTypeBorder
	end

	element.__groups[name] = element:AddGroup(filter, {
		candidateFilters = candidateFilters,
		maxFrameCount = count,
		sortMethod = sortMethod,
		size = size,
		height = element.__owner.mystyle == "nameplate" and size * sizeRatio or nil,
		fontSize = buttonOptions.fontSize,
		sizeRatio = sizeRatio,
		desaturated = buttonOptions.desaturated,
		showDebuffTypeBorder = showTypeBorder,
		layout = AuraGroupLayout(element, index, buttonOptions.groupSpacing),
	})
end

local function CreateAuraElement(self, options)
	local element = self:CreateAuras({
		initialAnchor = options.initialAnchor,
		growthX = options.growthX,
		growthY = options.growthY,
		layout = AnchorUtil.FlowLayoutAxis.Horizontal,
		layoutLimit = self:GetWidth(),
	})

	element.__groups = {}
	element.__value = options.value
	element.spacing = options.spacing or 0
	element.groupSpacing = options.groupSpacing
	element.fontSize = options.fontSize
	element.hideDuration = options.hideDuration
	element.sizeRatio = options.sizeRatio or 1
	element.disableMouse = options.disableMouse
	element.showDebuffBorder = options.showDebuffBorder
	element.showCount = true
	element.showDuration = false
	element.showStealableBorder = true
	element.PostCreateButton = UF.PostCreateButton
	return element
end

function UF:UpdateAuraLayoutLimit(frame)
	local width = frame:GetWidth()
	local element = frame.Auras
	if element then
		element:SetFlowLayoutMaximumLineSize(width)
	end

	element = frame.Buffs
	if element then
		local buffWidth = width
		if frame.BigDefensives then
			local defensiveSize = frame.BigDefensives.iconSize
			local reservedWidth = RAID_BIG_DEFENSIVE_RIGHT_INSET + defensiveSize * 2 + RAID_BIG_DEFENSIVE_SPACING + RAID_BIG_DEFENSIVE_PADDING
			buffWidth = max(width - reservedWidth, element.size)
		end
		element:SetFlowLayoutMaximumLineSize(buffWidth)
	end

	element = frame.Debuffs
	if element then
		element:SetFlowLayoutMaximumLineSize(width)
	end
end

local auraUFs = {
	["player"] = "Player",
	["target"] = "Target",
	["tot"] = "ToT",
	["pet"] = "Pet",
	["focus"] = "Focus",
}

function UF:CreateAuras(self)
	local mystyle = self.mystyle
	if mystyle == "nameplate" then
		local db = C.db["Nameplate"]
		local yOffset = db["TargetPower"] and 10 + db["PPBarHeight"] or 5
		for _, container in ipairs(NAMEPLATE_AURA_CONTAINERS) do
			local bu = CreateAuraElement(self, {
				initialAnchor = container.anchor,
				growthX = container.growthX,
				growthY = "UP",
				spacing = 3,
				groupSpacing = 0,
				disableMouse = true,
			})
			bu.__auraType = "nameplate"
			bu.__nameplateAuraType = container.auraType
			bu:SetPoint(container.anchor, self.nameText, container.relativeAnchor, 0, yOffset)

			local layoutIndex = 0
			for index, group in ipairs(NAMEPLATE_AURA_GROUPS) do
				if group.auraType == container.auraType then
					layoutIndex = layoutIndex + 1
					local settings = NAMEPLATE_AURA_SETTINGS[group.auraType]
					AddAuraGroup(bu, NAMEPLATE_AURA_GROUP_NAME..index, group.filter, GetNameplateAuraGroupCount(group), layoutIndex, group.candidateFilters, nil, {
						size = db[settings.size],
						fontSize = db[settings.fontSize],
						sizeRatio = db[settings.sizeRatio],
						showDebuffTypeBorder = db[settings.typeBorder],
					})
				end
			end

			UF:UpdateAuraContainer(self, bu)
			self[container.element] = bu
		end
		return
	end

	local bu = CreateAuraElement(self, {
		initialAnchor = "TOPLEFT",
		growthX = "RIGHT",
		growthY = "DOWN",
		spacing = 3,
	})
	if auraUFs[mystyle] then
		bu.__value = auraUFs[mystyle]
		UF:ConfigureAuras(bu)
		UF:UpdateAuraDirection(self, bu)
		AddAuraGroup(bu, "Buffs", bu.buffFilter, bu.numBuffs, 1)
		if bu.__desaturateOthers then
			for index, group in ipairs(UNITFRAME_DESATURATED_DEBUFF_GROUPS) do
				AddAuraGroup(bu, UNITFRAME_DESATURATED_DEBUFF_GROUP_NAME..index, group.filter, GetUnitFrameDesaturatedDebuffCount(bu.numDebuffs, index), index + 1, group.candidateFilters, nil, {
					desaturated = index == 2,
					groupSpacing = index == 2 and 0 or (bu.size + 3),
					showDebuffTypeBorder = bu.showDebuffTypeBorder,
				})
			end
		else
			AddAuraGroup(bu, "Debuffs", bu.debuffFilter, bu.numDebuffs, 2)
		end
	end

	UF:UpdateAuraContainer(self, bu)

	self.Auras = bu
end

local function ConfigureNameplateDebuffs(element)
	element.num = C.db["Nameplate"]["PlateCC"] and min(C.db["Nameplate"]["NumCC"], 2) or 0
	element.size = C.db["Nameplate"]["CCSize"]
	element.fontSize = C.db["Nameplate"]["CCFontSize"]
	element.showDebuffTypeBorder = false
	element.sizeRatio = C.db["Nameplate"]["CCSizeRatio"]
	element.filter = NAMEPLATE_CC_RULE.filter
end

function UF:UpdateNameplateDebuffs()
	local element = self.Debuffs
	if not element then return end

	ConfigureNameplateDebuffs(element)
	UF:UpdateAuraContainer(self, element)
	element:ForceUpdate()
end

function UF:CreatePlateDebuffs(self)
	local bu = CreateAuraElement(self, {
		initialAnchor = "LEFT",
		growthX = "RIGHT",
		growthY = "DOWN",
		spacing = 3,
		disableMouse = true,
	})
	bu.__auraType = "debuffs"
	bu:SetPoint("LEFT", self.Health, "RIGHT", 5, 0)

	ConfigureNameplateDebuffs(bu)
	AddAuraGroup(bu, "Debuffs", bu.filter, bu.num, 1)

	self.Debuffs = bu
end

function UF:CreateBuffs(self)
	local mystyle = self.mystyle
	local value = mystyle == "raid" and "Raid" or mystyle == "arena" and "Arena" or "Boss"
	local bu = CreateAuraElement(self, {
		initialAnchor = mystyle == "raid" and "TOPLEFT" or "BOTTOMLEFT",
		growthX = "RIGHT",
		growthY = mystyle == "raid" and "DOWN" or "UP",
		spacing = mystyle == "raid" and 2 or 3,
		value = value,
		disableMouse = mystyle == "raid",
	})
	bu.__auraType = "buffs"
	if mystyle == "raid" then
		bu:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	else
		bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	end

	UF:ConfigureBuffAndDebuff(bu)
	local filterGroups = mystyle == "arena" and ARENA_BUFF_GROUPS[bu.__filterType]
	if filterGroups then
		for index, group in ipairs(filterGroups) do
			AddAuraGroup(bu, ARENA_BUFF_GROUP_NAME..index, group.filter, bu.num, index, group.candidateFilters)
		end
	elseif mystyle == "boss" and bu.__filterType == 3 then
		for index, group in ipairs(BOSS_BUFF_GROUPS) do
			AddAuraGroup(bu, BOSS_BUFF_GROUP_NAME..index, group.filter, bu.num, index, group.candidateFilters)
		end
	else
		local candidateFilters = mystyle == "raid" and RAID_BUFF_GROUP.candidateFilters or {}
		AddAuraGroup(bu, "Buffs", bu.filter, bu.num, 1, candidateFilters)
	end
	UF:UpdateAuraContainer(self, bu)

	self.Buffs = bu
end

function UF:CreateRaidBigDefensives(self)
	local size = C.db["UFs"]["RaidBigDefensiveSize"]
	local bu = CreateAuraElement(self, {
		initialAnchor = "TOPRIGHT",
		growthX = "LEFT",
		growthY = "DOWN",
		fontSize = C.db["UFs"]["RaidBigDefensiveCDSize"],
		hideDuration = not C.db["UFs"]["RaidBigDefensiveCDText"],
		disableMouse = true,
	})
	bu:SetPoint("TOPLEFT", self)
	bu.iconSize = size
	bu.showStealableBorder = false
	bu.PostCreateButton = PostCreateRaidBigDefensiveButton

	for index, group in ipairs(RAID_BIG_DEFENSIVE_GROUPS) do
		bu:AddSlot(group.filter, {
			size = size,
			sortMethod = AuraContainerSortMethod.BigDefensive,
			slotIndex = index,
		})
	end

	self.BigDefensives = bu
	UF:UpdateAuraLayoutLimit(self)
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local value = mystyle == "raid" and "Raid" or mystyle == "arena" and "Arena" or "Boss"
	local bu = CreateAuraElement(self, {
		initialAnchor = mystyle == "raid" and "BOTTOMRIGHT" or "TOPRIGHT",
		growthX = "LEFT",
		growthY = mystyle == "raid" and "UP" or "DOWN",
		spacing = mystyle == "raid" and 2 or 3,
		value = value,
		disableMouse = mystyle == "raid",
	})
	bu.__auraType = "debuffs"
	if mystyle == "raid" then
		bu:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -2, 2)
	else
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
	end

	UF:ConfigureBuffAndDebuff(bu, true)
	if mystyle == "raid" and bu.__filterType == 2 then
		for index, group in ipairs(RAID_DEBUFF_GROUPS) do
			AddAuraGroup(bu, RAID_DEBUFF_GROUP_NAME..index, group.filter, bu.num, index, group.candidateFilters, AuraContainerSortMethod.Default)
		end
	elseif mystyle == "arena" and bu.__filterType == 3 then
		for index, group in ipairs(ARENA_DEBUFF_GROUPS) do
			AddAuraGroup(bu, ARENA_DEBUFF_GROUP_NAME..index, group.filter, bu.num, index, group.candidateFilters)
		end
	else
		AddAuraGroup(bu, "Debuffs", bu.filter, bu.num, 1)
	end
	UF:UpdateAuraContainer(self, bu)

	self.Debuffs = bu
end

-- Class Powers
function UF.PostUpdateClassPower(element, cur, max, _, diff, _, chargedPowerPoints)
	element.__max = max
	if not cur or cur == 0 then
		for i = 1, 10 do
			element[i].bg:Hide()
		end
	else
		for i = 1, max do
			element[i].bg:Show()
		end
	end

	local isMax = cur == max
	for i = 1, #element do
		element[i].cover:SetShown(isMax)
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar.width - (max-1)*C.margin)/max)
		end
		for i = max + 1, 10 do
			element[i].bg:Hide()
		end
	end

	for i = 1, 10 do
		local bar = element[i]
		if not bar.chargeStar then break end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function UF.PostVisibilityClassPower(element, shouldEnable)
	if not shouldEnable then
		for i = 1, 10 do
			element[i].bg:Hide()
		end
	end

	if element.fragmentsText then
		element.fragmentsText:SetShown(shouldEnable)
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText("")
	if C.db["UFs"]["RuneTimer"] then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(B.FormatTime(remain))
		end
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				rune.timer:SetText("")
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", UF.OnUpdateRunes)
			end
		end
	end
end

function UF:CreateClassPower(self)
	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"CENTER", self}
	end

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local isDH = DB.MyClass == "DEMONHUNTER"
	local maxBar = isDK and 6 or 10
	local bar = CreateFrame("Frame", "$parentClassPowerBar", self)
	bar:SetSize(barWidth, barHeight)
	bar.width = barWidth
	bar:SetPoint(unpack(barPoint))

	-- show bg while size changed
	if not isDK then
		bar.bg = B.SetBD(bar)
		bar.bg:SetFrameLevel(5)
		bar.bg:SetBackdropBorderColor(1, .8, 0)
		bar.bg:Hide()
	end

	local bars = {}
	for i = 1, maxBar do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - (maxBar-1)*C.margin) / maxBar)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", C.margin, 0)
		end

		bars[i].bg = CreateFrame("Frame", nil, (isDK and bars[i] or bar))
		bars[i].bg:SetAllPoints(bars[i])
		B.SetBD(bars[i].bg, .7)
		bars[i].bg:SetShown(isDK)

		if not isDK then
			bars[i].cover = bars[i]:CreateTexture(nil, "ARTWORK", nil, 5)
			bars[i].cover:SetAllPoints(bars[i])
			bars[i].cover:SetTexture(DB.normTex)
			bars[i].cover:SetVertexColor(1, 0, 0)
			bars[i].cover:Hide()
		end

		if isDK then
			bars[i].timer = B.CreateFS(bars[i], 13, "")
		else
			if not bar.chargeParent then
				bar.chargeParent = CreateFrame("Frame", nil, bar)
				bar.chargeParent:SetAllPoints()
				bar.chargeParent:SetFrameLevel(8)
			end
			local chargeStar = bar.chargeParent:CreateTexture()
			chargeStar:SetTexture(DB.starTex)
			chargeStar:SetSize(12, 12)
			chargeStar:SetPoint("CENTER", bars[i])
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if isDH then
		local text = B.CreateFS(bars[1], 13)
		text:SetPoint("CENTER", bars[1], "TOP")
		self:Tag(text, "[SoulFragments]")
		bars.fragmentsText = text
	end

	if isDK then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		bars.PostVisibility = UF.PostVisibilityClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

function UF:StaggerBar(self)
	if DB.MyClass ~= "MONK" then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	end

	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetSize(barWidth, barHeight)
	stagger:SetPoint(unpack(barPoint))
	stagger:SetStatusBarTexture(DB.normTex)
	stagger:SetFrameLevel(self:GetFrameLevel() + 5)
	B.SetBD(stagger, 0)
	UF:SmoothBar(stagger)

	local bg = stagger:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg:SetVertexColor(0, 0, 0, .7)

	local text = B.CreateFS(stagger, 13)
	text:SetPoint("CENTER", stagger, "TOP")
	self:Tag(text, "[monkstagger]")

	self.Stagger = stagger
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	if C.db["UFs"]["ClassPower"] then
		if playerFrame.ClassPower then
			if not playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:EnableElement("ClassPower")
				playerFrame.ClassPower:ForceUpdate()
			end
		end
		if playerFrame.Runes then
			if not playerFrame:IsElementEnabled("Runes") then
				playerFrame:EnableElement("Runes")
				playerFrame.Runes:ForceUpdate()
			end
		end
		if playerFrame.Stagger then
			if not playerFrame:IsElementEnabled("Stagger") then
				playerFrame:EnableElement("Stagger")
				playerFrame.Stagger:ForceUpdate()
			end
		end
	else
		if playerFrame.ClassPower then
			if playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:DisableElement("ClassPower")
			end
		end
		if playerFrame.Runes then
			if playerFrame:IsElementEnabled("Runes") then
				playerFrame:DisableElement("Runes")
			end
		end
		if playerFrame.Stagger then
			if playerFrame:IsElementEnabled("Stagger") then
				playerFrame:DisableElement("Stagger")
			end
		end
	end
end

function UF:UpdateUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local xOffset, yOffset = C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]
	local bars = playerFrame.ClassPower or playerFrame.Runes
	if bars then
		local bar = playerFrame.ClassPowerBar
		bar:SetSize(barWidth, barHeight)
		bar.width = barWidth
		bar:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
		if bar.bg then bar.bg:Show() end
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end

	if playerFrame.Stagger then
		playerFrame.Stagger:SetSize(barWidth, barHeight)
		playerFrame.Stagger:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(2)
	B.SetBD(bar, 0)
	UF:SmoothBar(bar)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar
	self.AlternativePower.colorPowerSmooth = true
end

function UF:CreateExpRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 10, 0)
	bar:SetOrientation("VERTICAL")
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints(bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	B:GetModule("Misc"):SetupScript(bar)
end

function UF:CreatePrediction(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints(self.Health)
	frame:SetClipsChildren(true)
	local frameLevel = frame:GetFrameLevel()-1

	-- Position and size
	local myBar = CreateFrame("StatusBar", nil, frame)
	myBar:SetPoint("TOP")
	myBar:SetPoint("BOTTOM")
	myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
	myBar:SetStatusBarTexture(DB.normTex)
	myBar:SetStatusBarColor(0, 1, .5, .5)

	local absorbBar = CreateFrame("StatusBar", nil, frame)
	absorbBar:SetPoint("TOP")
	absorbBar:SetPoint("BOTTOM")
	absorbBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
	absorbBar:SetStatusBarTexture(DB.bdTex)
	absorbBar:SetStatusBarColor(.66, 1, 1)
	absorbBar:SetFrameLevel(frameLevel)
	absorbBar:SetAlpha(.5)
	local tex = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(absorbBar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	tex:SetHorizTile(true)
	tex:SetVertTile(true)

	local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
	healAbsorbBar:SetPoint("TOP")
	healAbsorbBar:SetPoint("BOTTOM")
	healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(DB.bdTex)
	healAbsorbBar:SetStatusBarColor(1, 0, .5)
	healAbsorbBar:SetFrameLevel(frameLevel)
	healAbsorbBar:SetAlpha(.35)
	local tex = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	tex:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
	tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	tex:SetHorizTile(true)
	tex:SetVertTile(true)

	local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetWidth(15)
	overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	overAbsorb:SetBlendMode("ADD")
	overAbsorb:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	overAbsorb:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

	local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetWidth(15)
	overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	overHealAbsorb:SetBlendMode("ADD")
	overHealAbsorb:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	overHealAbsorb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

	-- Register with oUF
	self.predicFrame = frame
	self.Health.HealingAll = myBar
	self.Health.DamageAbsorb = absorbBar
	self.Health.HealAbsorb = healAbsorbBar
	self.Health.OverDamageAbsorbIndicator = overAbsorb
	self.Health.OverHealAbsorbIndicator = overHealAbsorb
end

function UF.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		--[[local perc = cur/max * 100
		if perc > 95 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end]]
		element.Text:SetText(B.Numb(cur))
	end
end

function UF:CreateAddPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(4)
	bar:SetStatusBarTexture(DB.normTex)
	B.SetBD(bar, 0)
	bar.colorPower = true
	UF:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg:SetVertexColor(0, 0, 0, .7)
	local text = B.CreateFS(bar, 12, "", false, "CENTER", 1, -3)

	self.AdditionalPower = bar
	self.AdditionalPower.bg = bg
	self.AdditionalPower.Text = text
	self.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	self.AdditionalPower.displayPairs = {
		["DRUID"] = {
			[1] = true,
			[3] = true,
			[8] = true,
		},
		["SHAMAN"] = {
			[11] = true,
		},
		["PRIEST"] = {
			[13] = true,
		}
	}
end

function UF:ToggleAddPower()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["AddPower"] then
		if not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
			frame.AdditionalPower:ForceUpdate()
		end
	elseif frame:IsElementEnabled("AdditionalPower") then
		frame:DisableElement("AdditionalPower")
	end
end

function UF:CreatePVPClassify(self)
	local bu = self:CreateTexture(nil, "ARTWORK")
	bu:SetSize(30, 30)
	bu:SetPoint("LEFT", self, "RIGHT", 5, -2)

	self.PvPClassificationIndicator = bu
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if(hasJoined) then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function UF:CreateQuestSync(self)
	local sync = self:CreateTexture(nil, "OVERLAY")
	sync:SetPoint("CENTER", self, "BOTTOMLEFT", 16, 0)
	sync:SetSize(28, 28)
	sync:SetAtlas("QuestSharing-DialogIcon")
	sync:Hide()

	self.QuestSyncIndicator = sync
	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)
end
