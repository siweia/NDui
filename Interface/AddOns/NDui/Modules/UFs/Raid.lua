local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local LCD = DB.LibClassicDurations

local strmatch, format, wipe = string.match, string.format, table.wipe
local pairs, ipairs, next, tonumber, unpack, gsub = pairs, ipairs, next, tonumber, unpack, gsub
local UnitAura, GetSpellInfo = UnitAura, GetSpellInfo
local InCombatLockdown = InCombatLockdown

-- RaidFrame Elements
function UF:CreateRaidIcons(self)
	local parent = CreateFrame("Frame", nil, self)
	parent:SetAllPoints()
	parent:SetFrameLevel(self:GetFrameLevel() + 2)

	local check = parent:CreateTexture(nil, "OVERLAY")
	check:SetSize(16, 16)
	check:SetPoint("BOTTOM", 0, 1)
	self.ReadyCheckIndicator = check

	local resurrect = parent:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", self, 1, 0)
	self.ResurrectIndicator = resurrect

	local role = parent:CreateTexture(nil, "OVERLAY")
	role:SetSize(12, 12)
	role:SetPoint("TOPRIGHT", self, 5, 5)
	self.RaidRoleIndicator = role
end

function UF:UpdateTargetBorder()
	if UnitIsUnit("target", self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

function UF:CreateTargetBorder(self)
	local border = B.CreateBDFrame(self, 0)
	border:SetBackdropBorderColor(.9, .9, .9)
	border:Hide()

	self.TargetBorder = border
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetBorder, true)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetBorder, true)
end

function UF:UpdateThreatBorder(_, unit)
	if unit ~= self.unit then return end

	local element = self.ThreatIndicator
	local status = UnitThreatSituation(unit)

	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		element:SetBackdropBorderColor(r, g, b)
		element:Show()
	else
		element:Hide()
	end
end

function UF:CreateThreatBorder(self)
	local threatIndicator = B.CreateSD(self.backdrop, 4, true)
	threatIndicator:SetOutside(self, 4+C.mult, 4+C.mult)
	self.backdrop.__shadow = nil

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatBorder
end

local debuffList = {}
function UF:UpdateRaidDebuffs()
	wipe(debuffList)
	for instID, value in pairs(C.RaidDebuffs) do
		for spellID, priority in pairs(value) do
			if not (NDuiADB["RaidDebuffs"][instID] and NDuiADB["RaidDebuffs"][instID][spellID]) then
				if not debuffList[instID] then debuffList[instID] = {} end
				debuffList[instID][spellID] = priority
			end
		end
	end
	for instID, value in pairs(NDuiADB["RaidDebuffs"]) do
		for spellID, priority in pairs(value) do
			if priority > 0 then
				if not debuffList[instID] then debuffList[instID] = {} end
				debuffList[instID][spellID] = priority
			end
		end
	end
end

local function buttonOnEnter(self)
	if not self.index then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	GameTooltip:SetUnitAura(self.__owner.unit, self.index, self.filter)
	GameTooltip:Show()
end

function UF:CreateRaidDebuffs(self)
	local scale = C.db["UFs"]["RaidDebuffScale"]
	local size = 18

	local bu = CreateFrame("Frame", nil, self)
	bu:SetSize(size, size)
	bu:SetPoint("RIGHT", -15, 0)
	bu:SetFrameLevel(self:GetFrameLevel() + 3)
	B.CreateSD(bu, 3, true)
	bu.__shadow:SetFrameLevel(self:GetFrameLevel() + 2)
	bu:SetScale(scale)
	bu:Hide()

	bu.icon = bu:CreateTexture(nil, "ARTWORK")
	bu.icon:SetAllPoints()
	bu.icon:SetTexCoord(unpack(DB.TexCoord))

	local parentFrame = CreateFrame("Frame", nil, bu)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(bu:GetFrameLevel() + 6)
	bu.count = B.CreateFS(parentFrame, 12, "", false, "BOTTOMRIGHT", 6, -3)
	bu.timer = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)
	bu.glowFrame = B.CreateGlowFrame(bu, size)

	if not C.db["UFs"]["AurasClickThrough"] then
		bu:SetScript("OnEnter", buttonOnEnter)
		bu:SetScript("OnLeave", B.HideTooltip)
	end

	bu.ShowDispellableDebuff = true
	bu.ShowDebuffBorder = true
	if C.db["UFs"]["InstanceAuras"] then
		if not next(debuffList) then UF:UpdateRaidDebuffs() end
		bu.Debuffs = debuffList
	end
	self.RaidDebuffs = bu
end

local keyList = {}
local mouseButtonList = {"LMB","RMB","MMB","MB4","MB5"}
local modKeyList = {"","ALT-","CTRL-","SHIFT-","ALT-CTRL-","ALT-SHIFT-","CTRL-SHIFT-","ALT-CTRL-SHIFT-"}
local numModKeys = #modKeyList

for i = 1, #mouseButtonList do
	local button = mouseButtonList[i]
	for j = 1, numModKeys do
		local modKey = modKeyList[j]
		keyList[modKey..button] = modKey.."%s"..i
	end
end

local wheelGroupIndex = {}
for i = 1, numModKeys do
	local modKey = modKeyList[i]
	wheelGroupIndex[5 + i] = modKey.."MOUSEWHEELUP"
	wheelGroupIndex[numModKeys + 5 + i] = modKey.."MOUSEWHEELDOWN"
end
for keyIndex, keyString in pairs(wheelGroupIndex) do
	keyString = gsub(keyString, "MOUSEWHEELUP", "MWU")
	keyString = gsub(keyString, "MOUSEWHEELDOWN", "MWD")
	keyList[keyString] = "%s"..keyIndex
end

function UF:DefaultClickSets()
	if not NDuiADB["ClickSets"][DB.MyClass] then NDuiADB["ClickSets"][DB.MyClass] = {} end
	if not next(NDuiADB["ClickSets"][DB.MyClass]) then
		for fullkey, spellID in pairs(C.ClickCastList[DB.MyClass]) do
			NDuiADB["ClickSets"][DB.MyClass][fullkey] = spellID
		end
	end
end

local onEnterString = "self:ClearBindings();"
local onLeaveString = onEnterString
for keyIndex, keyString in pairs(wheelGroupIndex) do
	onEnterString = format("%sself:SetBindingClick(0, \"%s\", self:GetName(), \"Button%d\");", onEnterString, keyString, keyIndex)
end
local onMouseString = "if not self:IsUnderMouse(false) then self:ClearBindings(); end"

local function setupMouseWheelCast(self)
	local found
	for fullkey in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		if strmatch(fullkey, "MW%w") then
			found = true
			break
		end
	end

	if found then
		self:SetAttribute("_onenter", onEnterString)
		self:SetAttribute("_onleave", onLeaveString)
		self:SetAttribute("_onshow", onLeaveString)
		self:SetAttribute("_onhide", onLeaveString)
		self:SetAttribute("_onmousedown", onMouseString)
	end
end

local function setupClickSets(self)
	if self.clickCastRegistered then return end

	for fullkey, value in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		if fullkey == "SHIFT-LMB" then self.focuser = true end

		local keyIndex = keyList[fullkey]
		if keyIndex then
			if tonumber(value) then
				self:SetAttribute(format(keyIndex, "type"), "spell")
				self:SetAttribute(format(keyIndex, "spell"), value)
			elseif value == "target" then
				self:SetAttribute(format(keyIndex, "type"), "target")
			elseif value == "focus" then
				self:SetAttribute(format(keyIndex, "type"), "focus")
			elseif value == "follow" then
				self:SetAttribute(format(keyIndex, "type"), "macro")
				self:SetAttribute(format(keyIndex, "macrotext"), "/follow mouseover")
			elseif strmatch(value, "/") then
				self:SetAttribute(format(keyIndex, "type"), "macro")
				value = gsub(value, "~", "\n")
				self:SetAttribute(format(keyIndex, "macrotext"), value)
			end
		end
	end

	setupMouseWheelCast(self)

	self.clickCastRegistered = true
end

local pendingFrames = {}
function UF:CreateClickSets(self)
	if not C.db["UFs"]["RaidClickSets"] then return end

	if InCombatLockdown() then
		pendingFrames[self] = true
	else
		setupClickSets(self)
		pendingFrames[self] = nil
	end
end

function UF:DelayClickSets()
	if not next(pendingFrames) then return end

	for frame in next, pendingFrames do
		UF:CreateClickSets(frame)
	end
end

function UF:AddClickSetsListener()
	if not C.db["UFs"]["RaidClickSets"] then return end

	B:RegisterEvent("PLAYER_REGEN_ENABLED", UF.DelayClickSets)
end

local counterOffsets = {
	["TOPLEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["TOPRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOMLEFT"] = {{6, 1},{"LEFT", "RIGHT", -2, 0}},
	["BOTTOMRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["LEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["RIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["TOP"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOM"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
}

function UF:BuffIndicatorOnUpdate(elapsed)
	B.CooldownOnUpdate(self, elapsed, true)
end

UF.CornerSpells = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	for spellID, value in pairs(C.CornerBuffs[DB.MyClass]) do
		local modData = NDuiADB["CornerSpells"][DB.MyClass]
		if not (modData and modData[spellID]) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	for spellID, value in pairs(NDuiADB["CornerSpells"][DB.MyClass]) do
		if next(value) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end
end

UF.CornerSpellsByName = {}
function UF:BuildNameListFromID()
	wipe(UF.CornerSpellsByName)

	for spellID, value in pairs(UF.CornerSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			UF.CornerSpellsByName[name] = value
		end
	end
end

local found = {}
local auraFilter = {"HELPFUL", "HARMFUL"}

function UF:UpdateBuffIndicator(event, unit)
	if event == "UNIT_AURA" and self.unit ~= unit then return end

	local spellList = UF.CornerSpells
	local buttons = self.BuffIndicator
	unit = self.unit

	wipe(found)
	for _, filter in next, auraFilter do
		for i = 1, 32 do
			local name, texture, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, filter)
			if not name then break end
			local value = spellList[spellID] or UF.CornerSpellsByName[name]
			if value and (value[3] or caster == "player" or caster == "pet") then
				local bu = buttons[value[1]]
				if bu then
					if duration == 0 then
						local newduration, newexpires = LCD:GetAuraDurationByUnit(unit, spellID, caster, name)
						if newduration then
							duration, expiration = newduration, newexpires
						end
					end

					if C.db["UFs"]["BuffIndicatorType"] == 3 then
						if duration and duration > 0 then
							bu.expiration = expiration
							bu:SetScript("OnUpdate", UF.BuffIndicatorOnUpdate)
						else
							bu:SetScript("OnUpdate", nil)
						end
						bu.timer:SetTextColor(unpack(value[2]))
					else
						if duration and duration > 0 then
							bu.cd:SetCooldown(expiration - duration, duration)
							bu.cd:Show()
						else
							bu.cd:Hide()
						end
						if C.db["UFs"]["BuffIndicatorType"] == 1 then
							bu.icon:SetVertexColor(unpack(value[2]))
						else
							bu.icon:SetTexture(texture)
						end
					end

					bu.count:SetText(count > 1 and count or "")
					bu:Show()
					found[bu.anchor] = true
				end
			end
		end
	end

	for _, bu in pairs(buttons) do
		if not found[bu.anchor] then
			bu:Hide()
		end
	end
end

function UF:RefreshBuffIndicator(bu)
	if C.db["UFs"]["BuffIndicatorType"] == 3 then
		local point, anchorPoint, x, y = unpack(counterOffsets[bu.anchor][2])
		bu.timer:Show()
		bu.count:ClearAllPoints()
		bu.count:SetPoint(point, bu.timer, anchorPoint, x, y)
		bu.icon:Hide()
		bu.cd:Hide()
		bu.bg:Hide()
	else
		bu:SetScript("OnUpdate", nil)
		bu.timer:Hide()
		bu.count:ClearAllPoints()
		bu.count:SetPoint("CENTER", unpack(counterOffsets[bu.anchor][1]))
		if C.db["UFs"]["BuffIndicatorType"] == 1 then
			bu.icon:SetTexture(DB.bdTex)
		else
			bu.icon:SetVertexColor(1, 1, 1)
		end
		bu.icon:Show()
		bu.cd:Show()
		bu.bg:Show()
	end
end

function UF:CreateBuffIndicator(self)
	if not C.db["UFs"]["RaidBuffIndicator"] then return end
	if self.raidType == "simple" then return end

	local anchors = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
	local buttons = {}
	for _, anchor in pairs(anchors) do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetFrameLevel(self:GetFrameLevel()+10)
		bu:SetSize(10, 10)
		bu:SetScale(C.db["UFs"]["BuffIndicatorScale"])
		bu:SetPoint(anchor)
		bu:Hide()

		bu.bg = B.CreateBDFrame(bu)
		bu.icon = bu:CreateTexture(nil, "BORDER")
		bu.icon:SetInside(bu.bg)
		bu.icon:SetTexCoord(unpack(DB.TexCoord))
		bu.cd = CreateFrame("Cooldown", nil, bu, "CooldownFrameTemplate")
		bu.cd:SetAllPoints(bu.bg)
		bu.cd:SetReverse(true)
		bu.cd:SetHideCountdownNumbers(true)
		bu.timer = B.CreateFS(bu, 12, "", false, "CENTER", -counterOffsets[anchor][2][3], 0)
		bu.count = B.CreateFS(bu, 12, "")

		bu.anchor = anchor
		buttons[anchor] = bu

		UF:RefreshBuffIndicator(bu)
	end

	self.BuffIndicator = buttons
	self:RegisterEvent("UNIT_AURA", UF.UpdateBuffIndicator)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateBuffIndicator, true)
end

function UF:RefreshRaidFrameIcons()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			if frame.RaidDebuffs then
				frame.RaidDebuffs:SetScale(C.db["UFs"]["RaidDebuffScale"])
			end
			if frame.BuffIndicator then
				for _, bu in pairs(frame.BuffIndicator) do
					bu:SetScale(C.db["UFs"]["BuffIndicatorScale"])
					UF:RefreshBuffIndicator(bu)
				end
			end
		end
	end
end