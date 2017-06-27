local B, C, L, DB = unpack(select(2, ...))
local cast = NDui.cast
local oUF = NDui.oUF or oUF
local UF = NDui:GetModule("UnitFrames")

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
	health:SetPoint("TOP", 0, 0)
	health:SetHeight(self:GetHeight())
	health:SetWidth(self:GetWidth())
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

	if (self.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (self.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) then
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

	local name = B.CreateFS(textFrame, retVal(self, 12, 12, 12, 11), "", false, "LEFT", 3, -1)
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
		self:Tag(name, "  [color][name]")
	elseif self.mystyle == "target" then
		self:Tag(name, "[fulllevel] [color][name][afkdnd]")
	elseif self.mystyle == "focus" then
		self:Tag(name, "[color][name][afkdnd]")
	elseif self.mystyle == "nameplate" then
		self:Tag(name, "[nplevel][name]")
	else
		self:Tag(name, "[color][name]")
	end

	local hpval = B.CreateFS(textFrame, retVal(self, 14, 13, 13, 12), "", false, "RIGHT", -3, -1)
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
	power:SetHeight(retVal(self, 4, 3, 2, 4))
	power:SetWidth(self:GetWidth())
	power:SetPoint("TOP", self, "BOTTOM", 0, -3)
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	B.CreateSD(power, 3, 3)
	B.SmoothBar(power)

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	if (self.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (self.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) or self.mystyle == "nameplate" then
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

	local ppval = B.CreateFS(textFrame, retVal(self, 14, 12, 12), "", false, "RIGHT", -3, 2)
	self:Tag(ppval, "[color][power]")
end

function UF:CreatePortrait(self)
	if not NDuiDB["UFs"]["Portrait"] then return end

	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetAllPoints()
	portrait:SetAlpha(.1)
	self.Portrait = portrait

	self.Health.bg:ClearAllPoints()
	self.Health.bg:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	self.Health.bg:SetPoint("TOPRIGHT", self.Health)
	self.Health.bg:SetParent(self)
end

function UF:CreateIcons(self)
	if self.mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetSize(20, 20)
		combat:SetPoint("BOTTOMLEFT", -10, -3)
		combat:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
		combat:SetTexCoord(0, .5, 0, .5)
		combat:SetVertexColor(.8, 0, 0)
		self.CombatIndicator = combat

		local rest = self:CreateTexture(nil, "OVERLAY")
		rest:SetPoint("TOPLEFT", -12, 2)
		rest:SetSize(18, 18)
		rest:SetTexture("Interface\\PLAYERFRAME\\DruidEclipse")
		rest:SetTexCoord(.445, .55, .648, .905)
		rest:SetVertexColor(.6, .8, 1)
		self.RestingIndicator = rest

	elseif self.mystyle == "target" then
		local phase = self:CreateTexture(nil, "OVERLAY")
		phase:SetPoint("TOP", self, 0, 12)
		phase:SetSize(22, 22)
		self.PhaseIndicator = phase

		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local ri = self:CreateTexture(nil, "OVERLAY")
	if self.mystyle == "raid" then
		ri:SetPoint("TOPRIGHT", self, 5, 5)
	else
		ri:SetPoint("TOPRIGHT", self, 0, 8)
	end
	ri:SetSize(12, 12)
	self.GroupRoleIndicator = ri

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, 0, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, 0, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai

	local ml = self:CreateTexture(nil, "OVERLAY")
	ml:SetPoint("LEFT", li, "RIGHT")
	ml:SetSize(12, 12)
	self.MasterLooterIndicator = ml
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

	local cbColor = {95/255, 182/255, 255/255}
	local cb = CreateFrame("StatusBar", "oUF_Castbar"..self.mystyle, self)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - 22)
	cb:SetStatusBarTexture(DB.normTex)
	cb:SetStatusBarColor(95/255, 182/255, 255/255, 1)
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
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -10)
		cb:SetSize(134, 10)
	elseif self.mystyle == "nameplate" then
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		cb:SetSize(self:GetWidth(), 5)
	end

	cb.CastingColor = cbColor
	cb.ChannelingColor = cbColor
	cb.CompleteColor = {20/255, 208/255, 0/255}
	cb.FailColor = {255/255, 12/255, 0/255}

	local spark = cb:CreateTexture(nil, "OVERLAY")
	spark:SetBlendMode("ADD")
	spark:SetAlpha(0.5)
	spark:SetHeight(cb:GetHeight()*2.5)

	local timer = B.CreateFS(cb, retVal(self, 12, 12, 12, 10), "", false, "RIGHT", -2, 0)
	local name = B.CreateFS(cb, retVal(self, 12, 12, 12, 10), "", false, "LEFT", 2, 0)
	name:SetJustifyH("LEFT")
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)

	local icon = cb:CreateTexture(nil, "ARTWORK")
	icon:SetSize(cb:GetHeight(), cb:GetHeight())
	icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -5, 0)
	icon:SetTexCoord(unpack(DB.TexCoord))
	B.CreateSD(icon, 3, 3)

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
		local iconSize = self.Health:GetHeight() + cb:GetHeight() + 5
		icon:SetSize(iconSize, iconSize)
		name:SetPoint("LEFT", cb, "BOTTOMLEFT", 0, -3)
		timer:SetPoint("RIGHT", cb, "BOTTOMRIGHT", 0, -3)

		local shield = cb:CreateTexture(nil, "OVERLAY")
		shield:SetAtlas("nameplates-InterruptShield")
		shield:SetSize(15, 15)
		shield:SetPoint("CENTER", 0, -5)
		cb.Shield = shield
	end

	cb.OnUpdate = cast.OnCastbarUpdate
	cb.PostCastStart = cast.PostCastStart
	cb.PostChannelStart = cast.PostCastStart
	cb.PostCastStop = cast.PostCastStop
	cb.PostChannelStop = cast.PostChannelStop
	cb.PostCastFailed = cast.PostCastFailed
	cb.PostCastInterrupted = cast.PostCastFailed

	self.Castbar = cb
	self.Castbar.Text = name
	self.Castbar.Time = timer
	self.Castbar.Icon = icon
	self.Castbar.Spark = spark
end

function UF:CreateMirrorBar(self)
	for _, bar in pairs({"MirrorTimer1", "MirrorTimer2", "MirrorTimer3"}) do   
		_G[bar]:GetRegions():Hide()
		_G[bar.."Border"]:Hide()
		_G[bar]:SetParent(UIParent)
		_G[bar]:SetScale(1)
		_G[bar]:SetHeight(15)
		_G[bar]:SetWidth(280)
		_G[bar.."Background"] = _G[bar]:CreateTexture(bar.."Background", "BACKGROUND", _G[bar])
		_G[bar.."Background"]:SetTexture(DB.normTex)
		_G[bar.."Background"]:SetAllPoints(bar)
		_G[bar.."Background"]:SetVertexColor(0, 0, 0, .5)
		_G[bar.."Text"]:SetFont(unpack(DB.Font))
		_G[bar.."Text"]:ClearAllPoints()
		_G[bar.."Text"]:SetPoint("CENTER")
		_G[bar.."StatusBar"]:SetAllPoints(_G[bar])
		B.CreateSD(_G[bar], 3, 3)
	end
end

-- Auras Relevant
local function postCreateIcon(element, button)
	local fontSize = element.fontSize or element.size*.6
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = B.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)

	button.icon:SetTexCoord(unpack(DB.TexCoord))
	button.icon:SetDrawLayer("ARTWORK")
	B.CreateSD(button, 2, 2)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .3)
	button.HL:SetAllPoints()
	button.cd:SetReverse(true)
end

local function postUpdateIcon(element, unit, button, index)
	local _, _, _, _, _, duration = UnitAura(unit, index, button.filter)
	if duration then button.Shadow:Show() end

	local style = element:GetParent().mystyle
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
end

local function postUpdateGapIcon(element, unit, icon)
	if icon.Shadow and icon.Shadow:IsShown() then
		icon.Shadow:Hide()
	end
end

local function customFilter(element, unit, button, name, _, _, _, _, _, _, caster, _, nameplateShowSelf, spellID, _, _, _, nameplateShowAll)
	local style = element:GetParent().mystyle
	if style == "raid" then
		local auraList = C.RaidAuraWatch[DB.MyClass]
		if auraList and auraList[spellID] and button.isPlayer then
			return true
		elseif C.RaidAuraWatch["ALL"][spellID] then
			return true
		end
	elseif style == "nameplate" then
		if UnitIsUnit("player", unit) and not NDuiDB["Nameplate"]["PlayerAura"] then return end
		if C.WhiteList and C.WhiteList[spellID] then
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

function UF:CreateAuras(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetHeight(41)
	bu:SetWidth(self:GetWidth())
	bu.gap = true
	bu["growth-y"] = "DOWN"
	if self.mystyle == "target" then
		bu:SetPoint("BOTTOMLEFT", self, 0, -48)
		bu.numBuffs = 20
		bu.numDebuffs = 15
		bu.spacing = 6
		bu.size = 22
	elseif self.mystyle == "tot" then
		bu:SetPoint("LEFT", self, "LEFT", 0, -12)
		bu.numBuffs = 0
		bu.numDebuffs = 10
		bu.spacing = 5
		bu.size = 19
	elseif self.mystyle == "focus" then
		bu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 3)
		bu.numBuffs = 0
		bu.numDebuffs = 8
		bu.spacing = 7
		bu.size = 26
	elseif self.mystyle == "raid" then
		bu:SetPoint("BOTTOMLEFT", self, 2, 0)
		bu.numTotal = 6
		bu.spacing = 2
		bu.size = 14*NDuiDB["UFs"]["RaidScale"]
		bu.gap = false
	elseif self.mystyle == "nameplate" then
		bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 20)
		bu.numTotal = NDuiDB["Nameplate"]["maxAuras"]
		bu.spacing = 3
		bu["growth-y"] = "UP"
		bu.size = NDuiDB["Nameplate"]["AuraSize"]
		bu.showDebuffType = NDuiDB["Nameplate"]["ColorBorder"]
		bu.gap = false
		bu.disableMouse = true
	end
	bu.showStealableBuffs = NDuiDB["UFs"]["StealableBuff"]
	bu.CustomFilter = customFilter
	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon
	bu.PostUpdateGapIcon = postUpdateGapIcon

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu.size = 20
	bu.spacing = 5
	bu.onlyShowPlayer = false
	bu:SetHeight((bu.size + bu.spacing) * 4)
	bu:SetWidth(self:GetWidth())
	if self.mystyle == "target" then
		bu:SetPoint("TOP", self, "TOP", 0, 51)
		bu.initialAnchor = "TOPLEFT"
		bu["growth-x"] = "RIGHT"
		bu["growth-y"] = "UP"
		bu.num = 10
	elseif self.mystyle == "player" then
		bu.size = 28
		bu:SetPoint("TOPRIGHT", UIParent,  -180, -10)
		bu.initialAnchor = "TOPRIGHT"
		bu["growth-x"] = "LEFT"
		bu["growth-y"] = "DOWN"
		bu.num = 40
	elseif self.mystyle == "boss" or self.mystyle == "arena" then
		bu.size = 22
		bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-x"] = "RIGHT"
		bu["growth-y"] = "UP"
		bu.num = 10
	else
		bu.num = 0
	end
	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu.size = 20
	bu.num = 18
	bu.onlyShowPlayer = false
	bu.spacing = 5
	bu:SetHeight((bu.size + bu.spacing) * 4)
	bu:SetWidth(self:GetWidth())
	if self.mystyle == "target" then
		bu:SetPoint("TOP", self, "TOP", 0, 25)
		bu.initialAnchor = "TOPLEFT"
		bu["growth-x"] = "RIGHT"
		bu["growth-y"] = "UP"
	elseif self.mystyle == "player" then
		bu:SetPoint("BOTTOMRIGHT", self, 0, -48)
		bu.initialAnchor = "BOTTOMRIGHT"
		bu["growth-x"] = "LEFT"
		bu["growth-y"] = "DOWN"
		bu.size = 22
		bu.spacing = 6
	elseif self.mystyle == "boss" or self.mystyle == "arena" then
		bu.size = 26
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, -1)
		bu.initialAnchor = "TOPRIGHT"
		bu.onlyShowPlayer = true
		bu["growth-x"] = "LEFT"
		bu["growth-y"] = "DOWN"
		bu.num = 10
	else
		bu.num = 0
	end
	bu.PostCreateIcon = postCreateIcon
	bu.PostUpdateIcon = postUpdateIcon

	self.Debuffs = bu
end

-- Class Powers
local margin = C.UFs.BarMargin
local width, height = unpack(C.UFs.BarSize)

local function postUpdateClassPower(element, cur, max, diff, event)
	if(diff or event == "ClassPowerEnable") then
		if max <= 6 then
			for i = 1, 6 do
				element[i]:SetWidth((width - (max-1)*margin)/max)
			end
		else
			for i = 1, 5 do
				element[i]:SetWidth((width - (5-1)*margin)/5)
			end
			element[6]:Hide()
		end
	end
end

function UF:CreateClassPower(self)
	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, self)
		bars[i]:SetHeight(height)
		bars[i]:SetWidth((width - 5*margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
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
	end

	if DB.MyClass == "DEATHKNIGHT" then
		bars.colorSpec = true
		self.Runes = bars
	else
		bars.PostUpdate = postUpdateClassPower
		self.ClassPower = bars
	end
end

local function postUpdateAltPower(element, unit, cur, min, max)
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
	bar:SetHeight(4)
	bar:SetStatusBarTexture(DB.normTex)
	if self.unit == "boss" then
		bar:SetPoint("BOTTOM", self, "TOP", 0, -2)
		bar:SetWidth(self:GetWidth() - 30)
	else
		bar:SetPoint("TOP", self.Power, "BOTTOM", 0, -2)
		bar:SetWidth(self:GetWidth())
	end
	B.CreateBD(bar, .5, .1)
	B.CreateSD(bar, 3, 3)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar		
	self.AlternativePower.PostUpdate = postUpdateAltPower
end

function UF:CreateExpBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(0, 0.7, 1)
	bar:SetPoint("TOPRIGHT", "oUF_Player", "TOPRIGHT", 9, 0)
	bar:SetHeight(30)
	bar:SetWidth(5)
	bar:SetFrameLevel(2)
	bar:SetOrientation("VERTICAL")
	B.CreateBD(bar, .5, .1)
	B.CreateSD(bar, 3, 3)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, 0.4, 1, 0.6)
	rest:SetFrameLevel(2)
	rest:SetOrientation("VERTICAL")
	rest:SetAllPoints(bar)

	bar.Tooltip = true
	bar.Rested = rest
	self.Experience = bar
end

local function postUpdateRepColor(element, event, unit, bar)
	local name, id, _, _, _, factionID = GetWatchedFactionInfo()
	local friendID = GetFriendshipReputation(factionID)
	if friendID then id = 5 end		
	bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
end

function UF:CreateRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", "oUF_Player", "TOPLEFT", -9, 0)
	bar:SetWidth(5)
	bar:SetHeight(30)
	bar:SetFrameLevel(2)
	bar:SetOrientation("VERTICAL")
	B.CreateBD(bar, .5, .1)
	B.CreateSD(bar, 3, 3)

	bar.Tooltip = true
	bar.PostUpdate = postUpdateRepColor
	self.Reputation = bar
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
	hab:Hide()

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		healAbsorbBar = hab,
		maxOverflow = 1,
	}
end

local function postUpdateAddPower(element, unit, cur, max)
	if element.Text then
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
	bar:SetSize(100, 4)
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

	local fcf = CreateFrame("Frame", "oUF_CombatTextFrame", self)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 20 do
		fcf[i] = self:CreateFontString("$parentText", "OVERLAY")
	end

	fcf.xOffset = 60
	fcf.fontHeight = 18
	fcf.showPets = NDuiDB["UFs"]["PetCombatText"]
	fcf.showHots = NDuiDB["UFs"]["HotsDots"]
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
	InterfaceOptionsCombatPanelEnableFloatingCombatText:Hide()
end