local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

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
	if self.GroupRoleIndicator then
		role:SetPoint("RIGHT", self.GroupRoleIndicator, "LEFT")
	else
		role:SetPoint("TOPRIGHT", self, 5, 5)
	end
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