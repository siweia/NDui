local B, C, L, DB = unpack(select(2, ...))
local cast = NDui.cast
local oUF = NDui.oUF or oUF
local lib = CreateFrame("Frame")

-- Config
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.power["MANA"] = {0, .4, 1}

local retVal = function(f, val1, val2, val3)
	if f.mystyle == "player" or f.mystyle == "target" then
		return val1
	elseif f.mystyle == "focus" then
		return val2
	else
		return val3
	end
end

-- Elements
lib.menu = function(self)
    local unit = self.unit:sub(1, -2)
    local cunit = self.unit:gsub("(.)", string.upper, 1)
    if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
    elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
    end
end

lib.init = function(f)
    f.menu = lib.menu
    f:RegisterForClicks("AnyUp")
    f:SetScript("OnEnter", UnitFrame_OnEnter)
    f:SetScript("OnLeave", UnitFrame_OnLeave)
end

lib.gen_hpbar = function(f)
    local s = CreateFrame("StatusBar", nil, f)
    s:SetPoint("TOP", 0, 0)
	s:SetHeight(f:GetHeight())
    s:SetWidth(f:GetWidth())
    s:SetStatusBarTexture(DB.normTex)
	s:SetStatusBarColor(.1, .1, .1)
	s:SetFrameStrata("LOW")
	s:SetFrameLevel(10)
	B.CreateSD(s, 3, 3)
	B.SmoothBar(s)
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetAllPoints(s)
    b:SetTexture(DB.bdTex)
	b:SetVertexColor(.6, .6, .6)
	b.multiplier = .25

	if (f.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (f.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) then
		s.colorClass = true
		s.colorTapping = true
		s.colorReaction = true
		s.colorDisconnected = true
	elseif f.mystyle ~= "raid" and NDuiDB["UFs"]["SmoothColor"] then
		s.colorSmooth = true
	end
	s.frequentUpdates = true
	f.Health = s
    f.Health.bg = b
end

lib.gen_hpstrings = function(f)
	local nameframe = CreateFrame("Frame", nil, f)
	nameframe:SetAllPoints(f.Health)
	nameframe:SetFrameLevel(f.Health:GetFrameLevel() + 1)
	nameframe:SetFrameStrata("LOW")

    local name = B.CreateFS(nameframe, 12, "", false, "LEFT", 3, -1)
	name:SetJustifyH("LEFT")
	if f.mystyle == "raid" then
		name:SetWidth(f:GetWidth()*.95)
		name:ClearAllPoints()
		name:SetPoint("TOPLEFT", 2, -2)
	else
		name:SetWidth(f:GetWidth()*.55)
	end

	if f.mystyle == "player" then
		f:Tag(name, "  [color][name]")
	elseif f.mystyle == "target" then
		f:Tag(name, "[level] [color][name][afkdnd]")
	elseif f.mystyle == "focus" then
		f:Tag(name, "[color][name][afkdnd]")
	else
		f:Tag(name, "[color][name]")
	end

    local hpval = B.CreateFS(nameframe, retVal(f, 14, 13, 13), "", false, "RIGHT", -3, -1)
	if f.mystyle == "raid" then
		hpval:SetPoint("RIGHT", -3, -7)
		if NDuiDB["UFs"]["HealthPerc"] then
			f:Tag(hpval, "[raidhp]")
		else
			f:Tag(hpval, "[DDG]")
		end
	else
		f:Tag(hpval, "[hp]")
	end
end

lib.gen_ppstrings = function(f)
	local powerframe = CreateFrame("Frame", nil, f)
	powerframe:SetAllPoints(f.Power)
	powerframe:SetFrameLevel(f.Power:GetFrameLevel() + 1)
	powerframe:SetFrameStrata("LOW")

    local ppval = B.CreateFS(powerframe, retVal(f, 14, 12, 12), "", false, "RIGHT", -3, 2)
	f:Tag(ppval, "[color][power]")
end

lib.gen_ppbar = function(f)
	local s = CreateFrame("StatusBar", nil, f)
	s:SetStatusBarTexture(DB.normTex)
	s:SetHeight(retVal(f, 4, 3, 2))
	s:SetWidth(f:GetWidth())
	s:SetPoint("TOP", f, "BOTTOM", 0, -3)
	s:SetFrameStrata("LOW")
	s:SetFrameLevel(11)
	B.CreateSD(s, 3, 3)
	B.SmoothBar(s)
	s.frequentUpdates = true

    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetAllPoints(s)
    b:SetTexture(DB.normTex)
	b.multiplier = .25

	if (f.mystyle == "raid" and NDuiDB["UFs"]["RaidClassColor"]) or (f.mystyle ~= "raid" and NDuiDB["UFs"]["ClassColor"]) then
		s.colorPower = true
	else
		s.colorClass = true
		s.colorTapping = true
		s.colorDisconnected = true
		s.colorReaction = true
	end
    f.Power = s
    f.Power.bg = b
end

local PortraitUpdate = function(self, unit) 
	self:SetAlpha(0)
	self:SetAlpha(.1)
end

local HidePortrait = function(self, unit)
	if self.unit == "target" then
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.Portrait:SetAlpha(0)
		else
			self.Portrait:SetAlpha(.1)
		end
	end
end

lib.gen_portrait = function(f)
	if not NDuiDB["UFs"]["Portrait"] then return end

    local portrait = CreateFrame("PlayerModel", nil, f)
    portrait:SetFrameStrata("LOW")
    portrait:SetFrameLevel(f.Health:GetFrameLevel())
	portrait:SetAllPoints(f.Health)
	table.insert(f.__elements, HidePortrait)
	portrait.PostUpdate = PortraitUpdate
	f.Portrait = portrait

    local overlay = CreateFrame("Frame", nil, f)
	overlay:SetFrameLevel(f.Health:GetFrameLevel() + 1)
	overlay:SetFrameStrata("LOW")

	f.Health.bg:ClearAllPoints()
	f.Health.bg:SetPoint("BOTTOMLEFT", f.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	f.Health.bg:SetPoint("TOPRIGHT", f.Health)
	f.Health.bg:SetParent(overlay)
end

-- UFs' Infoicons
lib.gen_InfoIcons = function(f)
    if f.mystyle == "player" then
		f.Combat = f:CreateTexture(nil, "OVERLAY")
		f.Combat:SetSize(20, 20)
		f.Combat:SetPoint("BOTTOMLEFT", -10, -3)
		f.Combat:SetTexture("Interface\\WORLDSTATEFRAME\\CombatSwords")
		f.Combat:SetTexCoord(0, .5, 0, .5)
		f.Combat:SetVertexColor(.8, 0, 0)
    end
	local ri = f:CreateTexture(nil, "OVERLAY")
	if f.mystyle == "raid" then
		ri:SetPoint("TOPRIGHT", f, 5, 5)
	else
		ri:SetPoint("TOPRIGHT", f, 0, 8)
	end
	ri:SetSize(12, 12)
	f.LFDRole = ri
    local li = f:CreateTexture(nil, "OVERLAY")
    li:SetPoint("TOPLEFT", f, 0, 8)
    li:SetSize(12, 12)
    f.Leader = li
    local ai = f:CreateTexture(nil, "OVERLAY")
    ai:SetPoint("TOPLEFT", f, 0, 8)
    ai:SetSize(12, 12)
    f.Assistant = ai
    local ml = f:CreateTexture(nil, "OVERLAY")
    ml:SetPoint("LEFT", f.Leader, "RIGHT")
    ml:SetSize(10, 10)
    f.MasterLooter = ml
end

lib.addPhaseIcon = function(f)
	local picon = f:CreateTexture(nil, "OVERLAY")
	picon:SetPoint("TOP", f, 0, 12)
	picon:SetSize(22, 22)
	f.PhaseIcon = picon
end

lib.addQuestIcon = function(f)
	local qicon = f:CreateTexture(nil, "OVERLAY")
	qicon:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 8)
	qicon:SetSize(16, 16)
	f.QuestIcon = qicon
end

lib.gen_Resting = function(f)
	local ricon = f:CreateTexture(nil, "OVERLAY")
	ricon:SetPoint("TOPLEFT", -12, 2)
	ricon:SetSize(18, 18)
	ricon:SetTexture("Interface\\PLAYERFRAME\\DruidEclipse")
	ricon:SetTexCoord(.445, .55, .648, .905)
	ricon:SetVertexColor(.6, .8, 1)
	f.Resting = ricon
end

lib.gen_RaidMark = function(f)
    local ri = f:CreateTexture(nil, "OVERLAY")
	if f.mystyle == "raid" then
		ri:SetPoint("TOP", f, 0, 10)
	else
		ri:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, 10)
	end
	local size = retVal(f, 14, 13, 12)
    ri:SetSize(size, size)
    f.RaidIcon = ri
end

lib.gen_highlight = function(f)
    local OnEnter = function(f)
		UnitFrame_OnEnter(f)
		f.Highlight:Show()
    end
    local OnLeave = function(f)
		UnitFrame_OnLeave(f)
		f.Highlight:Hide()
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
    hl:SetVertexColor(.6, .6, .6)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end

lib.gen_castbar = function(f)
	if not NDuiDB["UFs"]["Castbars"] then return end

	local cbColor = {95/255, 182/255, 255/255}
    local s = CreateFrame("StatusBar", "oUF_Castbar"..f.mystyle, f)
    s:SetHeight(20)
    s:SetWidth(f:GetWidth() - 22)
    if f.mystyle == "player" then
		s:SetSize(unpack(C.UFs.PlayercbSize))
		s.Mover = B.Mover(s, L["Player Castbar"], "PlayerCB", C.UFs.Playercb, s:GetWidth(), 32)
    elseif f.mystyle == "target" then
		s:SetSize(unpack(C.UFs.TargetcbSize))
		s.Mover = B.Mover(s, L["Target Castbar"], "TargetCB", C.UFs.Targetcb, s:GetWidth(), 32)
	elseif f.mystyle == "focus" then
		s:SetSize(unpack(C.UFs.FocuscbSize))
		s.Mover = B.Mover(s, L["Focus Castbar"], "FocusCB", C.UFs.Focuscb, s:GetWidth(), 32)
    elseif f.mystyle == "boss" or f.mystyle == "oUF_Arena" then
	    s:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, -10)
		s:SetSize(134, 10)
	end

    s:SetStatusBarTexture(DB.normTex)
    s:SetStatusBarColor(95/255, 182/255, 255/255, 1)
    s:SetFrameLevel(1)
	B.CreateBD(s, .5, .1)
	B.CreateSD(s, 3, 3)
	B.CreateTex(s)

    s.CastingColor = cbColor
    s.CompleteColor = {20/255, 208/255, 0/255}
    s.FailColor = {255/255, 12/255, 0/255}
    s.ChannelingColor = cbColor

    local sp = s:CreateTexture(nil, "OVERLAY")							-- castbar spark
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)

    local txt = B.CreateFS(s, 12, "", false, "LEFT", 2, 0)				-- spell name
    txt:SetJustifyH("LEFT")

    local t = B.CreateFS(s, 12, "", false, "RIGHT", -2, 0)				-- spell time
    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)

    local i = s:CreateTexture(nil, "ARTWORK")							-- castbar icon
    i:SetSize(s:GetHeight() + 1, s:GetHeight() + 1)
    i:SetPoint("RIGHT", s, "LEFT", -5, 0)
    i:SetTexCoord(unpack(DB.TexCoord))

    local ibg = CreateFrame("Frame", nil, s)							-- castbar icon shadow
    ibg:SetFrameLevel(0)
    ibg:SetPoint("TOPLEFT", i, "TOPLEFT", -1, 1)
    ibg:SetPoint("BOTTOMRIGHT", i, "BOTTOMRIGHT", 1, -1)
	B.CreateSD(ibg, 2, 3)

    if f.mystyle == "player" then
		local z = s:CreateTexture(nil,"OVERLAY")
		z:SetTexture(DB.normTex)
		z:SetVertexColor(1, 0.1, 0, .6)
		z:SetPoint("TOPRIGHT")
		z:SetPoint("BOTTOMRIGHT")
		s:SetFrameLevel(10)
		s.SafeZone = z
		local l = B.CreateFS(s, 10, "", false, "CENTER", -2, 17)
		l:SetJustifyH("RIGHT")
		l:Hide()
		s.Lag = l
		f:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", cast.OnCastSent)
    end
    s.OnUpdate = cast.OnCastbarUpdate
    s.PostCastStart = cast.PostCastStart
    s.PostChannelStart = cast.PostCastStart
    s.PostCastStop = cast.PostCastStop
    s.PostChannelStop = cast.PostChannelStop
    s.PostCastFailed = cast.PostCastFailed
    s.PostCastInterrupted = cast.PostCastFailed

    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
end

lib.gen_mirrorcb = function(f)
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
local setTimer = function(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = B.FormatTime(self.timeLeft)
				self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, .5, .5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local postCreateIcon = function(element, button)
	local self = element:GetParent()
	element.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	local fontSize = element.fontSize or element.size*.6
	local time = B.CreateFS(button, fontSize, "", false, "CENTER", 1, 0)
	button.time = time
	local count = B.CreateFS(button, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.count = count

	button.icon:SetTexCoord(unpack(DB.TexCoord))
	button.icon:SetDrawLayer("ARTWORK")
	B.CreateSD(button, 3, 3)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .3)
	button.HL:SetAllPoints()
end

local postUpdateIcon = function(self, unit, button, index)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, button.filter)

	if duration and duration > 0 then
		button.time:Show()
		button.timeLeft = expirationTime	
		button:SetScript("OnUpdate", setTimer)			
	else
		button.time:Hide()
		button.timeLeft = math.huge
		button:SetScript("OnUpdate", nil)
	end
	if duration then button.Shadow:Show() end

	-- Desaturate non-Player Debuffs
	if button.isDebuff and unit == "target" then	
		if button.isPlayer then
			button.icon:SetDesaturated(false)
		elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don't desaturate debuffs
			button.icon:SetDesaturated(true)
		end
	end

	button.first = true
end

local postUpdateGapIcon = function(self, unit, icon)
	icon.Shadow:Hide()
	icon.time:Hide()
end

-- RaidFrame AuraFilter
local customFilter = function(icons, _, icon, name, _, _, _, _, _, _, _, _, _, spellID)
	if icons:GetParent().mystyle == "raid" then
		local auraList = C.RaidAuraWatch[DB.MyClass]
		if auraList and auraList[spellID] and icon.isPlayer then
			return true
		elseif C.RaidAuraWatch["ALL"][spellID] then
			return true
		end
	elseif (icons.onlyShowPlayer and icon.isPlayer) or (not icons.onlyShowPlayer and name) then
		return true
	end
end

lib.createAuras = function(f)
	local Auras = CreateFrame("Frame", nil, f)
	Auras.size = 20
	Auras:SetHeight(41)
	Auras:SetWidth(f:GetWidth())
	Auras.spacing = 8
	Auras.gap = true
	if f.mystyle == "target" then
		Auras:SetPoint("BOTTOMLEFT", f, 0, -48)
		Auras.numBuffs = 20
		Auras.numDebuffs = 15
		Auras.spacing = 6
		Auras.size = 22
	elseif f.mystyle == "tot" then
		Auras:SetPoint("LEFT", f, "LEFT", 0, -12)
		Auras.numBuffs = 0
		Auras.numDebuffs = 10
		Auras.spacing = 5
		Auras.size = 19
	elseif f.mystyle == "focus" then
		Auras:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 3)
		Auras.numBuffs = 0
		Auras.numDebuffs = 8
		Auras.spacing = 7
		Auras.size = 26
	elseif f.mystyle == "raid" then
		Auras:SetPoint("BOTTOMLEFT", f, 2, 0)
		Auras.numBuffs = 5
		Auras.numDebuffs = 5
		Auras.spacing = 2
		Auras.size = 14*NDuiDB["UFs"]["RaidScale"]
		Auras.gap = false
	end
	Auras.initialAnchor = "BOTTOMLEFT"
	Auras["growth-x"] = "RIGHT"
	Auras["growth-y"] = "DOWN"
	Auras.showStealableBuffs = NDuiDB["UFs"]["StealableBuff"]
	Auras.CustomFilter = customFilter
	Auras.PostCreateIcon = postCreateIcon
	Auras.PostUpdateIcon = postUpdateIcon
	Auras.PostUpdateGapIcon = postUpdateGapIcon

	f.Auras = Auras
end

lib.createBuffs = function(f)
    local b = CreateFrame("Frame", nil, f)
	b.size = 20
    b.spacing = 5
    b.onlyShowPlayer = false
    b:SetHeight((b.size+b.spacing)*4)
    b:SetWidth(f:GetWidth())
    if f.mystyle == "target" then
		b:SetPoint("TOP", f, "TOP", 0, 51)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "UP"
	    b.num = 10
    elseif f.mystyle == "player" then
	    b.size = 28
		b:SetPoint("TOPRIGHT", UIParent,  -180, -10)
		b.initialAnchor = "TOPRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
		b.num = 40
    elseif f.mystyle == "boss" or f.mystyle == "oUF_Arena" then
	    b.size = 22
		b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 5)
		b.initialAnchor = "BOTTOMLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "UP"
		b.num = 10
	else
		b.num = 0
    end
    b.PostCreateIcon = postCreateIcon
    b.PostUpdateIcon = postUpdateIcon

    f.Buffs = b
end

lib.createDebuffs = function(f)
    local b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 18
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight((b.size+b.spacing)*4)
    b:SetWidth(f:GetWidth())
	if f.mystyle == "target" then
		b:SetPoint("TOP", f, "TOP", 0, 25)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "UP"
	elseif f.mystyle == "player" then
		b:SetPoint("BOTTOMRIGHT", f, 0, -48)
		b.initialAnchor = "BOTTOMRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
	    b.size = 22
		b.spacing = 6
	elseif f.mystyle == "boss" or f.mystyle == "oUF_Arena" then
	    b.size = 26
		b:SetPoint("TOPRIGHT", f, "TOPLEFT", -5, -1)
		b.initialAnchor = "TOPRIGHT"
		b.onlyShowPlayer = true
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
		b.num = 10
	else
		b.num = 0
	end
    b.PostCreateIcon = postCreateIcon
    b.PostUpdateIcon = postUpdateIcon

    f.Debuffs = b
end

-- Class Resources
local margin = C.UFs.BarMargin
local width, height = unpack(C.UFs.BarSize)

local function PostUpdateClassIcon(element, cur, max, diff, event)
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

lib.genResourcebar = function(self)
	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, self)
		bars[i]:SetHeight(height)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 2)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetStatusBarColor(228/255, 225/255, 16/255)
		B.CreateSD(bars[i], 3, 3)
		if i == 1 then
			bars[i]:SetPoint(unpack(C.UFs.BarPoint))
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", margin, 0)
		end
	end

	bars.PostUpdate = PostUpdateClassIcon
	self.ClassIcons = bars
end

lib.genRunes = function(self)
	if DB.MyClass ~= "DEATHKNIGHT" then return end
	local runes, bars = CreateFrame("Frame", nil, self), {}
	runes:SetPoint(unpack(C.UFs.BarPoint))
	runes:SetFrameLevel(self:GetFrameLevel() + 2)
	runes:SetSize(unpack(C.UFs.BarSize))
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, runes)
		bars[i]:SetHeight(runes:GetHeight())
		bars[i]:SetWidth((runes:GetWidth() - 5*margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
		B.CreateSD(bars[i], 3, 3)
		if (i == 1) then
			bars[i]:SetPoint("LEFT", runes)
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", margin, 0)
		end
		bars[i].bg = bars[i]:CreateTexture(nil, "BACKGROUND")
		bars[i].bg:SetAllPoints()
		bars[i].bg:SetTexture(DB.normTex)
		bars[i].bg.multiplier = 0.2
	end

	self.Runes = bars
end

lib.TotemBars = function(self)
	if DB.MyClass ~= "SHAMAN" then return end
	local TotemBar, Totems = CreateFrame("Frame", nil, self), {}
	TotemBar:SetPoint(unpack(C.UFs.BarPoint))
	TotemBar:SetFrameLevel(self:GetFrameLevel() + 2)
	TotemBar:SetSize(unpack(C.UFs.BarSize))
	for i = 1, 4 do
		Totems[i] = CreateFrame("StatusBar", nil, TotemBar)
		Totems[i]:SetHeight(TotemBar:GetHeight())
		Totems[i]:SetWidth((TotemBar:GetWidth() - 3*margin)/4)
		Totems[i]:SetStatusBarTexture(DB.normTex)
		B.CreateSD(Totems[i], 3, 3)
		if (i == 1) then
			Totems[i]:SetPoint("LEFT", TotemBar, "LEFT", 0, 0)
		else
			Totems[i]:SetPoint("TOPLEFT", Totems[i-1], "TOPRIGHT", margin, 0)
		end

		Totems[i].Time = B.CreateFS(Totems[i], 14, "", false, "CENTER", 1, 1)
	end

	Totems.colors = {{233/255, 46/255, 16/255};{173/255, 217/255, 25/255};{35/255, 127/255, 255/255};{178/255, 53/255, 240/255};}
	self.TotemBar = Totems
end

local function AltPowerBarOnToggle(self)
	local unit = self:GetParent().unit or self:GetParent():GetParent().unit
end
local function AltPowerBarPostUpdate(self, min, cur, max)
	local perc = math.floor((cur/max)*100)
	if perc < 35 then
		self:SetStatusBarColor(0, 1, 0)
	elseif perc < 70 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end
	local unit = self:GetParent().unit or self:GetParent():GetParent().unit
	local type = select(10, UnitAlternatePowerInfo(unit))
end
lib.AltPowerBar = function(self)
	local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
	AltPowerBar:SetHeight(4)
	AltPowerBar:SetStatusBarTexture(DB.normTex)
	if self.unit == "boss" then
		AltPowerBar:SetPoint("BOTTOM", self, "TOP", 0, -2)
		AltPowerBar:SetWidth(self:GetWidth() - 30)
	else
		AltPowerBar:SetPoint("TOP", self.Power, "BOTTOM", 0, -2)
		AltPowerBar:SetWidth(self:GetWidth())
	end
	B.CreateBD(AltPowerBar, .5, .1)
	B.CreateSD(AltPowerBar, 3, 3)

	local text = B.CreateFS(AltPowerBar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	AltPowerBar:HookScript("OnShow", AltPowerBarOnToggle)
	AltPowerBar:HookScript("OnHide", AltPowerBarOnToggle)
	self.AltPowerBar = AltPowerBar		
	self.AltPowerBar.PostUpdate = AltPowerBarPostUpdate
end

lib.Experience = function(self)
	local Experience = CreateFrame("StatusBar", nil, self)
	Experience:SetStatusBarTexture(DB.normTex)
	Experience:SetStatusBarColor(0, 0.7, 1)
	Experience:SetPoint("TOPRIGHT", oUF_Player, "TOPRIGHT", 9, 0)
	Experience:SetHeight(30)
	Experience:SetWidth(5)
	Experience:SetFrameLevel(2)
	Experience:SetOrientation("VERTICAL")
	B.CreateBD(Experience, .5, .1)
	B.CreateSD(Experience, 3, 3)

	local Rested = CreateFrame("StatusBar", nil, Experience)
	Rested:SetStatusBarTexture(DB.normTex)
	Rested:SetStatusBarColor(0, 0.4, 1, 0.6)
	Rested:SetFrameLevel(2)
	Rested:SetOrientation("VERTICAL")
	Rested:SetAllPoints(Experience)

	Experience.Tooltip = true
	self.Experience = Experience
	self.Experience.Rested = Rested
end

local UpdateReputationColor = function(self, event, unit, bar)
	local name, id, _, _, _, factionID = GetWatchedFactionInfo()
	local friendID = GetFriendshipReputation(factionID)
	if friendID then id = 5 end		
	bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
end
lib.Reputation = function(self)
	local Reputation = CreateFrame("StatusBar", nil, self)
	Reputation:SetStatusBarTexture(DB.normTex)
	Reputation:SetPoint("TOPLEFT", oUF_Player, "TOPLEFT", -9, 0)
	Reputation:SetWidth(5)
	Reputation:SetHeight(30)
	Reputation:SetFrameLevel(2)
	Reputation:SetOrientation("VERTICAL")
	B.CreateBD(Reputation, .5, .1)
	B.CreateSD(Reputation, 3, 3)

	Reputation.Tooltip = true
	Reputation.PostUpdate = UpdateReputationColor
	self.Reputation = Reputation
end

lib.HealPrediction = function(self)
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

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		maxOverflow = 1,
	}
end

lib.genAddPower = function(self)
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
end

lib.genSwing = function(self)
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

lib.FloatingCombatText = function(self)
	if not NDuiDB["UFs"]["CombatText"] then return end

	local fcf = CreateFrame("Frame", "oUF_CombatTextFrame", self)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 10 do
		fcf[i] = self:CreateFontString(nil, "OVERLAY")
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

NDui.lib = lib