local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF or oUF
local cast = ns.cast
local UF = B:RegisterModule("UnitFrames")

-- Custom colors
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.power.MANA = {0, .4, 1}
oUF.colors.power.SOUL_SHARDS = {.58, .51, .79}
oUF.colors.power.HOLY_POWER = {.88, .88, .06}
oUF.colors.power.CHI = {0, 1, .59}
oUF.colors.power.ARCANE_CHARGES = {.41, .8, .94}

-- Various values
local function retVal(self, val1, val2, val3, val4)
	if self.mystyle == "player" or self.mystyle == "target" then
		return val1
	elseif self.mystyle == "focus" then
		return val2
	else
		if self.mystyle == "nameplate" and val4 then
			return val4
		else
			return val3
		end
	end
end

-- Elements
function UF:CreateHeader(self)
	local hl = self:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(.6, .6, .6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function()
		UnitFrame_OnEnter(self)
		self.Highlight:Show()
	end)
	self:SetScript("OnLeave", function()
		UnitFrame_OnLeave(self)
		self.Highlight:Hide()
	end)
end

function UF:CreateHealthBar(self)
	local health = CreateFrame("StatusBar", nil, self)
	health:SetAllPoints()
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(self:GetFrameLevel() - 2)
	B.CreateSD(health, 3, 3)
	B.SmoothBar(health)

	local bg = health:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)
	bg.multiplier = .25

	if self.mystyle == "PlayerPlate" then
		health.colorHealth = true
	elseif (self.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (self.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) then
		health.colorClass = true
		health.colorTapping = true
		health.colorReaction = true
		health.colorDisconnected = true
	elseif self.mystyle ~= "raid" and NDuiDB["UFs"]["SmoothColor"] then
		health.colorSmooth = true
	end
	health.frequentUpdates = true

	self.Health = health
	self.Health.bg = bg
end

function UF:CreateHealthText(self)
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints()

	local name = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 11), "", false, "LEFT", 3, -1)
	name:SetJustifyH("LEFT")
	if self.mystyle == "raid" then
		name:SetWidth(self:GetWidth()*.95)
		name:ClearAllPoints()
		name:SetPoint("TOPLEFT", 2, -2)
	elseif self.mystyle == "nameplate" then
		name:SetWidth(self:GetWidth()*.85)
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	else
		name:SetWidth(self:GetWidth()*.55)
	end

	if self.mystyle == "player" then
		self:Tag(name, " [color][name]")
	elseif self.mystyle == "target" then
		self:Tag(name, "[fulllevel] [color][name][afkdnd]")
	elseif self.mystyle == "focus" then
		self:Tag(name, "[color][name][afkdnd]")
	elseif self.mystyle == "nameplate" then
		self:Tag(name, "[nplevel][name]")
	else
		self:Tag(name, "[color][name]")
	end

	local hpval = B.CreateFS(textFrame, retVal(self, 14, 13, 13, 14), "", false, "RIGHT", -3, -1)
	if self.mystyle == "raid" then
		hpval:SetPoint("RIGHT", -3, -7)
		if NDuiDB["UFs"]["HealthPerc"] then
			self:Tag(hpval, "[raidhp]")
		else
			self:Tag(hpval, "[DDG]")
		end
	elseif self.mystyle == "nameplate" then
		hpval:SetPoint("RIGHT", self, "TOPRIGHT", 0, 3)
		self:Tag(hpval, "[nphp]")
	else
		self:Tag(hpval, "[hp]")
	end

	self.nameFrame = textFrame
end

function UF:CreatePowerBar(self)
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	if self.mystyle == "PlayerPlate" then
		power:SetHeight(self:GetHeight())
	else
		power:SetHeight(retVal(self, 4, 3, 2, 4))
	end
	power:SetWidth(self:GetWidth())
	power:SetPoint("TOP", self, "BOTTOM", 0, -3)
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	B.CreateSD(power, 3, 3)
	B.SmoothBar(power)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	if (self.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (self.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) or self.mystyle == "PlayerPlate" then
		power.colorPower = true
	else
		power.colorClass = true
		power.colorTapping = true
		power.colorDisconnected = true
		power.colorReaction = true
	end
	power.frequentUpdates = true

	self.Power = power
	self.Power.bg = bg
end

function UF:CreatePowerText(self)
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Power)

	local ppval = B.CreateFS(textFrame, retVal(self, 13, 12, 12), "", false, "RIGHT", -3, 2)
	self:Tag(ppval, "[color][power]")
end

function UF:CreatePortrait(self)
	if not NDuiDB["UFs"]["Portrait"] then return end

	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetAllPoints()
	portrait:SetAlpha(.2)
	self.Portrait = portrait

	self.Health.bg:ClearAllPoints()
	self.Health.bg:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	self.Health.bg:SetPoint("TOPRIGHT", self.Health)
	self.Health.bg:SetParent(self)
end

local roleTexCoord = {
	["TANK"] = {.5, .75, 0, 1},
	["HEALER"] = {.75, 1, 0, 1},
	["DAMAGER"] = {.25, .5, 0, 1},
}
local function postUpdateRole(element, role)
	if element:IsShown() then
		element:SetTexCoord(unpack(roleTexCoord[role]))
	end
end

function UF:CreateIcons(self)
	if self.mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(20, 20)
		combat:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
		combat:SetTexCoord(0, .5, 0, .5)
		combat:SetVertexColor(.8, 0, 0)
		self.CombatIndicator = combat

		local rest = self:CreateTexture(nil, "OVERLAY")
		rest:SetPoint("CENTER", self, "LEFT", -2, 4)
		rest:SetSize(18, 18)
		rest:SetTexture("Interface\\PLAYERFRAME\\DruidEclipse")
		rest:SetTexCoord(.445, .55, .648, .905)
		rest:SetVertexColor(.6, .8, 1)
		self.RestingIndicator = rest
	elseif self.mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = self:CreateTexture(nil, "OVERLAY")
	phase:SetPoint("TOP", self, 0, 12)
	phase:SetSize(22, 22)
	self.PhaseIndicator = phase

	local ri = self:CreateTexture(nil, "OVERLAY")
	if self.mystyle == "raid" then
		ri:SetPoint("TOPRIGHT", self, 5, 5)
	else
		ri:SetPoint("TOPRIGHT", self, 0, 8)
	end
	ri:SetSize(12, 12)
	ri:SetTexture("Interface\\LFGFrame\\LFGROLE")
	ri.PostUpdate = postUpdateRole
	self.GroupRoleIndicator = ri

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, 0, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, 0, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai
end

function UF:CreateRaidMark(self)
	local ri = self:CreateTexture(nil, "OVERLAY")
	if self.mystyle == "raid" then
		ri:SetPoint("TOP", self, 0, 10)
	elseif self.mystyle == "nameplate" then
		ri:SetPoint("RIGHT", self, "LEFT", -3, 3)
	else
		ri:SetPoint("TOPRIGHT", self, "TOPRIGHT", -30, 10)
	end
	local size = retVal(self, 14, 13, 12, 20)
	ri:SetSize(size, size)
	self.RaidTargetIndicator = ri
end

function UF:CreateCastBar(self)
	if self.mystyle ~= "nameplate" and not NDuiDB["UFs"]["Castbars"] then return end

	local cb = CreateFrame("StatusBar", "oUF_Castbar"..self.mystyle, self)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - 22)
	cb:SetStatusBarTexture(DB.normTex)
	cb:SetFrameLevel(1)
	B.CreateBD(cb, .5, .1)
	B.CreateSD(cb, 3, 3)
	B.CreateTex(cb)

	if self.mystyle == "player" then
		cb:SetSize(unpack(C.UFs.PlayercbSize))
		cb.Mover = B.Mover(cb, L["Player Castbar"], "PlayerCB", C.UFs.Playercb, cb:GetWidth(), 32)
	elseif self.mystyle == "target" then
		cb:SetSize(unpack(C.UFs.TargetcbSize))
		cb.Mover = B.Mover(cb, L["Target Castbar"], "TargetCB", C.UFs.Targetcb, cb:GetWidth(), 32)
	elseif self.mystyle == "focus" then
		cb:SetSize(unpack(C.UFs.FocuscbSize))
		cb.Mover = B.Mover(cb, L["Focus Castbar"], "FocusCB", C.UFs.Focuscb, cb:GetWidth(), 32)
	elseif self.mystyle == "boss" or self.mystyle == "arena" then
		cb:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -8)
		cb:SetSize(self:GetWidth(), 10)
	elseif self.mystyle == "nameplate" then
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		cb:SetSize(self:GetWidth(), 5)
	end

	cb.CastingColor = {.3, .7, 1}
	cb.ChannelingColor = {.3, .7, 1}
	cb.notInterruptibleColor = {1, .5, .5}
	cb.CompleteColor = {.1, .8, 0}
	cb.FailColor = {1, .1, 0}

	local spark = cb:CreateTexture(nil, "OVERLAY")
	spark:SetBlendMode("ADD")
	spark:SetAlpha(0.5)
	spark:SetHeight(cb:GetHeight()*2.5)
	cb.Spark = spark

	local timer = B.CreateFS(cb, retVal(self, 12, 12, 12, 10), "", false, "RIGHT", -2, 0)
	cb.Time = timer

	local name = B.CreateFS(cb, retVal(self, 12, 12, 12, 10), "", false, "LEFT", 2, 0)
	name:SetJustifyH("LEFT")
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
	cb.Text = name

	if self.mystyle ~= "boss" and self.mystyle ~= "arena" then
		cb.Icon = cb:CreateTexture(nil, "ARTWORK")
		cb.Icon:SetSize(cb:GetHeight(), cb:GetHeight())
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -5, 0)
		cb.Icon:SetTexCoord(unpack(DB.TexCoord))
		B.CreateSD(cb.Icon, 3, 3)
	end

	if self.mystyle == "player" then
		local safe = cb:CreateTexture(nil,"OVERLAY")
		safe:SetTexture(DB.normTex)
		safe:SetVertexColor(1, 0.1, 0, .6)
		safe:SetPoint("TOPRIGHT")
		safe:SetPoint("BOTTOMRIGHT")
		cb:SetFrameLevel(10)
		cb.SafeZone = safe

		local lag = B.CreateFS(cb, 10, "", false, "CENTER", -2, 17)
		lag:SetJustifyH("RIGHT")
		lag:Hide()
		cb.Lag = lag
		self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", cast.OnCastSent)
	elseif self.mystyle == "nameplate" then
		name:SetPoint("LEFT", cb, "BOTTOMLEFT", 0, -3)
		timer:SetPoint("RIGHT", cb, "BOTTOMRIGHT", 0, -3)

		local shield = cb:CreateTexture(nil, "OVERLAY")
		shield:SetAtlas("nameplates-InterruptShield")
		shield:SetSize(15, 15)
		shield:SetPoint("CENTER", 0, -5)
		cb.Shield = shield

		local iconSize = self.Health:GetHeight() + cb:GetHeight() + 5
		cb.Icon:SetSize(iconSize, iconSize)
	end

	cb.OnUpdate = cast.OnCastbarUpdate
	cb.PostCastStart = cast.PostCastStart
	cb.PostChannelStart = cast.PostCastStart
	cb.PostCastStop = cast.PostCastStop
	cb.PostChannelStop = cast.PostChannelStop
	cb.PostCastFailed = cast.PostCastFailed
	cb.PostCastInterrupted = cast.PostCastFailed
	cb.PostCastInterruptible = cast.PostUpdateInterruptible
	cb.PostCastNotInterruptible = cast.PostUpdateInterruptible

	self.Castbar = cb
end

function UF:ReskinMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer"..i]
		B.StripTextures(bar, true)
		bar:SetSize(280, 15)

		local bg = B.CreateBG(bar, 3)
		B.CreateBD(bg)
		B.CreateTex(bg)

		local statusbar = _G["MirrorTimer"..i.."StatusBar"]
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(DB.normTex)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
		end
		previous = bar
	end
end

-- Auras Relevant
local function postCreateIcon(element, button)
	local fontSize = element.fontSize or element.size*.6
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = B.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.cd:SetReverse(true)

	button.icon:SetTexCoord(unpack(DB.TexCoord))
	button.icon:SetDrawLayer("ARTWORK")
	B.CreateSD(button, 2, 2)
	button.overlay:SetTexture(nil)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()
end

local function postUpdateIcon(element, _, button, _, _, duration, _, debuffType)
	if duration then button.Shadow:Show() end

	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size - 4)
	else
		button:SetSize(element.size, element.size)
	end

	if button.isDebuff and (style == "target" or style == "nameplate") and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.Shadow:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button.Shadow:SetBackdropBorderColor(0, 0, 0)
	end
end

local function bolsterPreUpdate(element)
	element.bolster = 0
	element.bolsterIndex = nil
end

local function bolsterPostUpdate(element)
	if not element.bolsterIndex then return end
	for _, button in pairs(element) do
		if button == element.bolsterIndex then
			button.count:SetText(element.bolster)
			return
		end
	end
end

local function postUpdateGapIcon(_, _, icon)
	if icon.Shadow and icon.Shadow:IsShown() then
		icon.Shadow:Hide()
	end
end

local function customFilter(element, unit, button, name, _, _, _, _, _, caster, _, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle
	if name and spellID == 209859 then
		element.bolster = element.bolster + 1
		if not element.bolsterIndex then
			element.bolsterIndex = button
			return true
		end
	elseif style == "raid" then
		if C.RaidBuffs[DB.MyClass] and C.RaidBuffs[DB.MyClass][spellID] and button.isPlayer then
			return true
		elseif C.RaidBuffs["ALL"][spellID] then
			return true
		end
	elseif style == "nameplate" then
		if UnitIsUnit("player", unit) then
			return false
		elseif C.WhiteList and C.WhiteList[spellID] then
			return true
		elseif C.BlackList and C.BlackList[spellID] then
			return false
		else
			return (NDuiDB["Nameplate"]["AllAuras"] and nameplateShowAll) or (caster == "player" or caster == "pet" or caster == "vehicle")
		end
	elseif (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name) then
		return true
	end
end

local function auraIconSize(w, n, s)
	return (w-(n-1)*s)/n
end

function UF:CreateAuras(self)
	local bu = CreateFrame("Frame", nil, self)
	bu.gap = true
	bu.initialAnchor = "TOPLEFT"
	bu["growth-y"] = "DOWN"
	bu.spacing = 5
	if self.mystyle == "target" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.numBuffs = 20
		bu.numDebuffs = 15
		bu.iconsPerRow = 9
	elseif self.mystyle == "tot" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -5)
		bu.numBuffs = 0
		bu.numDebuffs = 10
		bu.iconsPerRow = 5
	elseif self.mystyle == "focus" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.numBuffs = 0
		bu.numDebuffs = 14
		bu.iconsPerRow = 7
	elseif self.mystyle == "raid" then
		bu:SetPoint("BOTTOMLEFT", self, 2, 0)
		bu.numTotal = 6
		bu.spacing = 2
		bu.iconsPerRow = 6
		bu.gap = false
		bu.disableMouse = NDuiDB["UFs"]["AurasClickThrough"]
	elseif self.mystyle == "nameplate" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-y"] = "UP"
		bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 20)
		bu.numTotal = NDuiDB["Nameplate"]["maxAuras"]
		bu.spacing = 3
		bu.size = NDuiDB["Nameplate"]["AuraSize"]
		bu.showDebuffType = NDuiDB["Nameplate"]["ColorBorder"]
		bu.gap = false
		bu.disableMouse = true
	end

	local width = self:GetWidth()
	local maxAuras = bu.numTotal or bu.numBuffs + bu.numDebuffs
	local maxLines = bu.iconsPerRow and floor(maxAuras/bu.iconsPerRow + .5) or 2
	bu.size = bu.iconsPerRow and auraIconSize(width, bu.iconsPerRow, bu.spacing) or bu.size
	bu:SetWidth(width)
	bu:SetHeight((bu.size + bu.spacing) * maxLines)

	bu.showStealableBuffs = NDuiDB["UFs"]["StealableBuff"]
	bu.CustomFilter = customFilter
	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon
	bu.PostUpdateGapIcon = postUpdateGapIcon
	bu.PreUpdate = bolsterPreUpdate
	bu.PostUpdate = bolsterPostUpdate

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	bu.initialAnchor = "BOTTOMLEFT"
	bu["growth-x"] = "RIGHT"
	bu["growth-y"] = "UP"
	bu.num = 6
	bu.spacing = 5
	bu.iconsPerRow = 6
	bu.onlyShowPlayer = false

	local width = self:GetWidth()
	bu.size = auraIconSize(width, bu.iconsPerRow, bu.spacing)
	bu:SetWidth(self:GetWidth())
	bu:SetHeight((bu.size + bu.spacing) * floor(bu.num/bu.iconsPerRow + .5))

	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu.spacing = 5
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "DOWN"
	if self.mystyle == "player" then
		bu:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -10)
		bu.onlyShowPlayer = false
		bu.num = 14
		bu.iconsPerRow = 7
		bu.showDebuffType = true
	elseif self.mystyle == "boss" or self.mystyle == "arena" then
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
		bu.onlyShowPlayer = true
		bu.num = 10
		bu.iconsPerRow = 5
	end

	local width = self:GetWidth()
	bu.size = auraIconSize(width, bu.iconsPerRow, bu.spacing)
	bu:SetWidth(self:GetWidth())
	bu:SetHeight((bu.size + bu.spacing) * floor(bu.num/bu.iconsPerRow + .5))

	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon

	self.Debuffs = bu
end

-- Class Powers
local margin = C.UFs.BarMargin
local width, height = unpack(C.UFs.BarSize)

local function postUpdateClassPower(element, cur, max, diff, powerType, event)
	if diff or event == "ClassPowerEnable" then
		for i = 1, 6 do
			element[i]:SetWidth((width - (max-1)*margin)/max)
		end
	end

	if NDuiDB["Nameplate"]["ShowPlayerPlate"] then
		if (powerType == "COMBO_POINTS" or powerType == "HOLY_POWER") and element.__owner.unit ~= "vehicle" and cur == max then
			for i = 1, 6 do
				if element[i]:IsShown() then
					ActionButton_ShowOverlayGlow(element[i].glow)
				end
			end
		else
			for i = 1, 6 do
				ActionButton_HideOverlayGlow(element[i].glow)
			end
		end
	end
end

function UF:CreateClassPower(self)
	if self.mystyle == "PlayerPlate" then
		width, height = self:GetWidth(), self:GetHeight()*2 + 3
		C.UFs.BarPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, 3}
	end

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, self.Health)
		bars[i]:SetHeight(height)
		bars[i]:SetWidth((width - 5*margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 2)
		B.CreateSD(bars[i], 3, 3)
		if i == 1 then
			bars[i]:SetPoint(unpack(C.UFs.BarPoint))
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", margin, 0)
		end

		if DB.MyClass == "DEATHKNIGHT" then
			bars[i].bg = bars[i]:CreateTexture(nil, "BACKGROUND")
			bars[i].bg:SetAllPoints()
			bars[i].bg:SetTexture(DB.normTex)
			bars[i].bg.multiplier = .2
		end

		if NDuiDB["Nameplate"]["ShowPlayerPlate"] then
			bars[i].glow = CreateFrame("Frame", nil, bars[i])
			bars[i].glow:SetPoint("TOPLEFT", -3, 2)
			bars[i].glow:SetPoint("BOTTOMRIGHT", 3, -2)
		end
	end

	if DB.MyClass == "DEATHKNIGHT" then
		bars.colorSpec = true
		if NDuiDB["UFs"]["SortRunes"] then bars.sortOrder = "asc" end
		self.Runes = bars
	else
		bars.PostUpdate = postUpdateClassPower
		self.ClassPower = bars
	end
end

local function postUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		local perc = math.floor((cur/max)*100)
		if perc < 35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOP", self.Power, "BOTTOM", 0, -3)
	bar:SetSize(self:GetWidth(), 2)
	B.CreateBD(bar, .5, .1)
	B.CreateSD(bar, 3, 3)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar		
	self.AlternativePower.PostUpdate = postUpdateAltPower
end

function UF:CreateExpRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 10, 0)
	bar:SetOrientation("VERTICAL")
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints(bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	local module = B:GetModule("Misc")
	module:SetupScript(bar)
end

function UF:CreatePrediction(self)
	local mhpb = self:CreateTexture(nil, "BORDER", nil, 5)
	mhpb:SetWidth(1)
	mhpb:SetTexture(DB.normTex)
	mhpb:SetVertexColor(0, 1, .5, .5)

	local ohpb = self:CreateTexture(nil, "BORDER", nil, 5)
	ohpb:SetWidth(1)
	ohpb:SetTexture(DB.normTex)
	ohpb:SetVertexColor(0, 1, 0, .5)

	local abb = self:CreateTexture(nil, "BORDER", nil, 5)
	abb:SetWidth(1)
	abb:SetTexture(DB.normTex)
	abb:SetVertexColor(.66, 1, 1, .7)

	local abbo = self:CreateTexture(nil, "ARTWORK", nil, 1)
	abbo:SetAllPoints(abb)
	abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	abbo.tileSize = 32

	local oag = self:CreateTexture(nil, "ARTWORK", nil, 1)
	oag:SetWidth(15)
	oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	oag:SetBlendMode("ADD")
	oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

	local hab = CreateFrame("StatusBar", nil, self)
	hab:SetPoint("TOP")
	hab:SetPoint("BOTTOM")
	hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
	hab:SetWidth(self.Health:GetWidth())
	hab:SetReverseFill(true)
	hab:SetStatusBarTexture(DB.normTex)
	hab:SetStatusBarColor(0, .5, .8, .5)

	local ohg = self:CreateTexture(nil, "ARTWORK", nil, 1)
	ohg:SetWidth(15)
	ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	ohg:SetBlendMode("ADD")
	ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		healAbsorbBar = hab,
		overHealAbsorbGlow = ohg,
		maxOverflow = 1,
	}
end

local function postUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur/max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function UF:CreateAddPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetSize(150, 4)
	bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -10)
	bar:SetStatusBarTexture(DB.normTex)
	B.CreateSD(bar, 3, 3)
	bar.colorPower = true

	local b = bar:CreateTexture(nil, "BACKGROUND")
	b:SetAllPoints()
	b:SetTexture(DB.normTex)
	b.multiplier = .3
	local t = B.CreateFS(bar, 12, "", false, "CENTER", 1, -3)

	self.AdditionalPower = bar
	self.AdditionalPower.bg = b
	self.AdditionalPower.Text = t
	self.AdditionalPower.PostUpdate = postUpdateAddPower
end

function UF:CreateSwing(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetSize(250, 3)
	bar:SetPoint("TOP", self.Castbar, "BOTTOM", -16, -5)

	local two = CreateFrame("StatusBar", nil, bar)
	two:Hide()
	two:SetAllPoints()
	B.CreateSB(two, true, .8, .8, .8)

	local main = CreateFrame("StatusBar", nil, bar)
	main:Hide()
	main:SetAllPoints()
	B.CreateSB(main, true, .8, .8, .8)

	local off = CreateFrame("StatusBar", nil, bar)
	off:Hide()
	off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
	off:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, -6)
	B.CreateSB(off, true, .8, .8, .8)

	if NDuiDB["UFs"]["SwingTimer"] then
		bar.Text = B.CreateFS(bar, 12, "")
		bar.TextMH = B.CreateFS(main, 12, "")
		bar.TextOH = B.CreateFS(off, 12, "", false, "CENTER", 1, -3)
	end

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

function UF:CreateFCT(self)
	if not NDuiDB["UFs"]["CombatText"] then return end

	local parentFrame = CreateFrame("Frame", nil, UIParent)
	local fcf = CreateFrame("Frame", "oUF_CombatTextFrame", parentFrame)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 36 do
		fcf[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
	end

	fcf.xOffset = 60
	fcf.fontHeight = 18
	fcf.showPets = NDuiDB["UFs"]["PetCombatText"]
	fcf.showHots = NDuiDB["UFs"]["HotsDots"]
	fcf.showAutoAttack = NDuiDB["UFs"]["AutoAttack"]
	fcf.showOverHealing = NDuiDB["UFs"]["FCTOverHealing"]
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
	B.HideOption(InterfaceOptionsCombatPanelEnableFloatingCombatText)
end

local function postUpdateFaction(self)
	local _, instanceType = IsInInstance()
	local faction = UnitFactionGroup(self.unit)
	if faction and faction ~= "Neutral" and instanceType ~= "arena" then
		self.factionIndicator.Icon:SetTexture("Interface\\FriendsFrame\\PlusManz-"..faction)
		self.factionIndicator:Show()
	else
		self.factionIndicator:Hide()
	end
end

function UF:CreateFactionIcon(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetSize(30, 30)
	bu:SetPoint("LEFT", self, "RIGHT", 5, -2)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()

	self.factionIndicator = bu
	self:RegisterEvent("UNIT_AURA", postUpdateFaction)	-- need reviewed
	self:RegisterEvent("ARENA_OPPONENT_UPDATE", postUpdateFaction)
	self:RegisterEvent("UNIT_NAME_UPDATE", postUpdateFaction)
end