local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local strmatch, format, wipe = strmatch, format, wipe
local pairs, ipairs, next, tonumber, unpack, gsub = pairs, ipairs, next, tonumber, unpack, gsub
local UnitAura, GetSpellInfo = UnitAura, GetSpellInfo
local InCombatLockdown = InCombatLockdown
local GetTime, GetSpellCooldown, IsInRaid, IsInGroup = GetTime, GetSpellCooldown, IsInRaid, IsInGroup
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

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
	role:SetPoint("TOPLEFT", 12, 8)
	self.RaidRoleIndicator = role

	local summon = parent:CreateTexture(nil, "OVERLAY")
	summon:SetSize(32, 32)
	summon:SetPoint("CENTER", parent)
	self.SummonIndicator = summon
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
		local r, g, b = unpack(oUF.colors.threat[status])
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
		self:SetAttribute("clickcast_onenter", onEnterString)
		self:SetAttribute("clickcast_onleave", onLeaveString)
		self:SetAttribute("_onshow", onLeaveString)
		self:SetAttribute("_onhide", onLeaveString)
		self:SetAttribute("_onmousedown", onMouseString)
	end
end

local fixedSpells = {
	[360823] = 365585, -- incorrect spellID for Evoker
}

local function setupClickSets(self)
	if self.clickCastRegistered then return end

	for fullkey, value in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		if fullkey == "SHIFT-LMB" then self.focuser = true end

		local keyIndex = keyList[fullkey]
		if keyIndex then
			if tonumber(value) then
				value = fixedSpells[value] or value
				--self:SetAttribute(format(keyIndex, "type"), "spell")
				--self:SetAttribute(format(keyIndex, "spell"), value)
				local spellName = GetSpellInfo(value)
				self:SetAttribute(format(keyIndex, "type"), "macro")
				self:SetAttribute(format(keyIndex, "macrotext"), "/cast [@mouseover]"..spellName)
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

-- Partywatcher
UF.PartyWatcherSpells = {}
function UF:UpdatePartyWatcherSpells()
	wipe(UF.PartyWatcherSpells)

	for spellID, duration in pairs(C.PartySpells) do
		local name = GetSpellInfo(spellID)
		if name then
			local modDuration = NDuiADB["PartySpells"][spellID]
			if not modDuration or modDuration > 0 then
				UF.PartyWatcherSpells[spellID] = duration
			end
		end
	end

	for spellID, duration in pairs(NDuiADB["PartySpells"]) do
		if duration > 0 then
			UF.PartyWatcherSpells[spellID] = duration
		end
	end
end

local watchingList = {}
function UF:PartyWatcherPostUpdate(button, unit, spellID)
	local guid = UnitGUID(unit)
	if not watchingList[guid] then watchingList[guid] = {} end
	watchingList[guid][spellID] = button
end

function UF:HandleCDMessage(...)
	local prefix, msg = ...
	if prefix ~= "ZenTracker" then return end

	local _, msgType, guid, spellID, duration, remaining = strsplit(":", msg)
	if msgType == "U" then
		spellID = tonumber(spellID)
		duration = tonumber(duration)
		remaining = tonumber(remaining)
		local button = watchingList[guid] and watchingList[guid][spellID]
		if button then
			local start = GetTime() + remaining - duration
			if start > 0 and duration > 1.5 then
				button.CD:SetCooldown(start, duration)
			end
		end
	end
end

local function SendPartySyncMsg(text)
	if IsInRaid() or not IsInGroup() then return end
	if not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		C_ChatInfo_SendAddonMessage("ZenTracker", text, "INSTANCE_CHAT")
	else
		C_ChatInfo_SendAddonMessage("ZenTracker", text, "PARTY")
	end
end

local lastUpdate = 0
function UF:SendCDMessage()
	local thisTime = GetTime()
	if thisTime - lastUpdate >= 5 then
		local value = watchingList[UF.myGUID]
		if value then
			for spellID in pairs(value) do
				local start, duration, enabled = GetSpellCooldown(spellID)
				if enabled ~= 0 and start ~= 0 then
					local remaining = start + duration - thisTime
					if remaining < 0 then remaining = 0 end
					SendPartySyncMsg(format("3:U:%s:%d:%.2f:%.2f:%s", UF.myGUID, spellID, duration, remaining, "-")) -- sync to others
				end
			end
		end
		lastUpdate = thisTime
	end
end

local lastSyncTime = 0
function UF:UpdateSyncStatus()
	if IsInGroup() and not IsInRaid() and C.db["UFs"]["PartyFrame"] then
		local thisTime = GetTime()
		if thisTime - lastSyncTime > 5 then
			SendPartySyncMsg(format("3:H:%s:0::0:1", UF.myGUID)) -- handshake to ZenTracker
			lastSyncTime = thisTime
		end
		B:RegisterEvent("SPELL_UPDATE_COOLDOWN", UF.SendCDMessage)
	else
		B:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UF.SendCDMessage)
	end
end

function UF:SyncWithZenTracker()
	if not C.db["UFs"]["PartyWatcherSync"] then return end

	UF.myGUID = UnitGUID("player")
	C_ChatInfo.RegisterAddonMessagePrefix("ZenTracker")
	B:RegisterEvent("CHAT_MSG_ADDON", UF.HandleCDMessage)

	UF:UpdateSyncStatus()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateSyncStatus)
end

local function UpdateWatcherAnchor(element)
	local self = element.__owner
	local horizon = C.db["UFs"]["PartyDirec"] > 2
	local otherSide = C.db["UFs"]["PWOnRight"]
	local relF = horizon and "BOTTOMLEFT" or "TOPRIGHT"
	local relT = "TOPLEFT"
	local xOffset = horizon and 0 or -5
	local yOffset = horizon and 5 or 0
	local margin = horizon and 2 or -2
	if otherSide then
		relF = "TOPLEFT"
		relT = horizon and "BOTTOMLEFT" or "TOPRIGHT"
		xOffset = horizon and 0 or 5
		yOffset = horizon and -5 or 0
		margin = 2
	end
	local rel1 = not horizon and not otherSide and "RIGHT" or "LEFT"
	local rel2 = not horizon and not otherSide and "LEFT" or "RIGHT"
	local iconSize = horizon and (self:GetWidth()-2*abs(margin))/3 or self:GetHeight()
	if iconSize > 40 then iconSize = 40 end

	for i = 1, element.__max do
		local bu = element[i]
		bu:SetSize(iconSize, iconSize)
		bu:ClearAllPoints()
		if i == 1 then
			bu:SetPoint(relF, self, relT, xOffset, yOffset)
		elseif i == 4 and horizon then
			bu:SetPoint(relF, element[i-3], relT, 0, margin)
		else
			bu:SetPoint(rel1, element[i-1], rel2, margin, 0)
		end
	end
end

function UF:InterruptIndicator(self)
	if not C.db["UFs"]["PartyWatcher"] then return end

	local buttons = {}
	local maxIcons = 6
	for i = 1, maxIcons do
		local bu = CreateFrame("Frame", nil, self)
		B.AuraIcon(bu)
		bu.CD:SetReverse(false)
		bu:Hide()

		buttons[i] = bu
	end

	buttons.__owner = self
	buttons.__max = maxIcons
	UpdateWatcherAnchor(buttons)
	buttons.UpdateAnchor = UpdateWatcherAnchor
	buttons.PartySpells = UF.PartyWatcherSpells
	buttons.TalentCDFix = C.TalentCDFix
	self.PartyWatcher = buttons
	if C.db["UFs"]["PartyWatcherSync"] then
		self.PartyWatcher.PostUpdate = UF.PartyWatcherPostUpdate
	end
end

local function UpdateAltPowerAnchor(element)
	if C.db["UFs"]["PartyAltPower"] then
		local self = element.__owner
		local horizon = C.db["UFs"]["PartyDirec"] > 2
		local relF = horizon and "TOP" or "LEFT"
		local relT = horizon and "BOTTOM" or "RIGHT"
		local xOffset = horizon and 0 or 5
		local yOffset = horizon and -5 or 0
		local otherSide = C.db["UFs"]["PWOnRight"]
		if otherSide then
			xOffset = horizon and 0 or -5
			yOffset = horizon and 5 or 0
		end

		element:Show()
		element:ClearAllPoints()
		if otherSide then
			element:SetPoint(relT, self, relF, xOffset, yOffset)
		else
			local parent = horizon and self.Power or self
			element:SetPoint(relF, parent, relT, xOffset, yOffset)
		end
	else
		element:Hide()
	end
end

function UF:CreatePartyAltPower(self)
	local altPower = B.CreateFS(self, 16, "")
	self:Tag(altPower, "[altpower]")
	altPower.__owner = self
	UpdateAltPowerAnchor(altPower)

	self.altPower = altPower
	self.altPower.UpdateAnchor = UpdateAltPowerAnchor
end

function UF:UpdatePartyElements()
	for _, frame in pairs(oUF.objects) do
		if frame.raidType == "party" then
			if frame.altPower then
				frame.altPower:UpdateAnchor()
			end
			if frame.PartyWatcher then
				frame.PartyWatcher:UpdateAnchor()
			end
		end
	end
end