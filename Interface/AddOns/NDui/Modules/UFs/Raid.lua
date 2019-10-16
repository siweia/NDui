local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local strmatch, format, wipe, tinsert = string.match, string.format, table.wipe, table.insert
local pairs, ipairs, next, tonumber, unpack = pairs, ipairs, next, tonumber, unpack
local UnitAura = UnitAura
local GetSpellInfo, GetSpellTexture = GetSpellInfo, GetSpellTexture
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
	local border = B.CreateBG(self, 2)
	B.CreateBD(border, 0)
	border:SetBackdropBorderColor(.7, .7, .7)
	border:SetPoint("BOTTOMRIGHT", self.Power, 2, -2)
	border:Hide()

	self.TargetBorder = border
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetBorder, true)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UF.UpdateTargetBorder, true)
end

function UF:UpdateThreatBorder(_, unit)
	if unit ~= self.unit then return end

	local element = self.Health.Shadow
	local status = UnitThreatSituation(unit)

	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		element:SetBackdropBorderColor(r, g, b)
	else
		element:SetBackdropBorderColor(0, 0, 0)
	end
end

function UF:CreateThreatBorder(self)
	local threatIndicator = CreateFrame("Frame", nil, self)
	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatBorder
end

local debuffList = {}
function UF:UpdateRaidDebuffs()
	wipe(debuffList)
	for instName, value in pairs(C.RaidDebuffs) do
		for spell, priority in pairs(value) do
			if not (NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spell]) then
				if not debuffList[instName] then debuffList[instName] = {} end
				debuffList[instName][spell] = priority
			end
		end
	end
	for instName, value in pairs(NDuiADB["RaidDebuffs"]) do
		for spell, priority in pairs(value) do
			if priority > 0 then
				if not debuffList[instName] then debuffList[instName] = {} end
				debuffList[instName][spell] = priority
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
	local size = 18*NDuiDB["UFs"]["RaidScale"]

	local bu = CreateFrame("Frame", nil, self)
	bu:SetSize(size, size)
	bu:SetPoint("RIGHT", -15, 0)
	bu:SetFrameLevel(self:GetFrameLevel() + 3)
	B.CreateSD(bu, 3, 3)
	bu:Hide()

	bu.icon = bu:CreateTexture(nil, "ARTWORK")
	bu.icon:SetAllPoints()
	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.count = B.CreateFS(bu, 12, "", false, "BOTTOMRIGHT", 6, -3)
	bu.timer = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)
	bu.glowFrame = B.CreateBG(bu, 4)
	bu.glowFrame:SetSize(size+8, size+8)

	if not NDuiDB["UFs"]["AurasClickThrough"] then
		bu:SetScript("OnEnter", buttonOnEnter)
		bu:SetScript("OnLeave", B.HideTooltip)
	end

	bu.ShowDispellableDebuff = true
	bu.ShowDebuffBorder = true
	bu.FilterDispellableDebuff = true
	if NDuiDB["UFs"]["InstanceAuras"] then
		if not next(debuffList) then UF:UpdateRaidDebuffs() end
		bu.Debuffs = debuffList
	end
	self.RaidDebuffs = bu
end

local keyList = {
	[1] = {KEY_BUTTON1, "", "%s1"},					-- 左键
	[2] = {KEY_BUTTON1, "ALT", "ALT-%s1"},			-- ALT+左键
	[3] = {KEY_BUTTON1, "CTRL", "CTRL-%s1"},		-- CTRL+左键
	[4] = {KEY_BUTTON1, "SHIFT", "SHIFT-%s1"},		-- SHIFT+左键

	[5] = {KEY_BUTTON2, "", "%s2"},					-- 右键
	[6] = {KEY_BUTTON2, "ALT", "ALT-%s2"},			-- ALT+右键
	[7] = {KEY_BUTTON2, "CTRL", "CTRL-%s2"},		-- CTRL+右键
	[8] = {KEY_BUTTON2, "SHIFT", "SHIFT-%s2"},		-- SHIFT+右键

	[9] = {KEY_BUTTON3, "", "%s3"},					-- 中键
	[10] = {KEY_BUTTON3, "ALT", "ALT-%s3"},			-- ALT+中键
	[11] = {KEY_BUTTON3, "CTRL", "CTRL-%s3"},		-- CTRL+中键
	[12] = {KEY_BUTTON3, "SHIFT", "SHIFT-%s3"},		-- SHIFT+中键

	[13] = {KEY_BUTTON4, "", "%s4"},				-- 鼠标键4
	[14] = {KEY_BUTTON4, "ALT", "ALT-%s4"},			-- ALT+鼠标键4
	[15] = {KEY_BUTTON4, "CTRL", "CTRL-%s4"},		-- CTRL+鼠标键4
	[16] = {KEY_BUTTON4, "SHIFT", "SHIFT-%s4"},		-- SHIFT+鼠标键4

	[17] = {KEY_BUTTON5, "", "%s5"},				-- 鼠标键5
	[18] = {KEY_BUTTON5, "ALT", "ALT-%s5"},			-- ALT+鼠标键5
	[19] = {KEY_BUTTON5, "CTRL", "CTRL-%s5"},		-- CTRL+鼠标键5
	[20] = {KEY_BUTTON5, "SHIFT", "SHIFT-%s5"},		-- SHIFT+鼠标键5

	[21] = {L["WheelUp"], "", "%s6"},				-- 滚轮上
	[22] = {L["WheelUp"], "ALT", "%s7"},			-- ALT+滚轮上
	[23] = {L["WheelUp"], "CTRL", "%s8"},			-- CTRL+滚轮上
	[24] = {L["WheelUp"], "SHIFT", "%s9"},			-- SHIFT+滚轮上

	[25] = {L["WheelDown"], "", "%s10"},			-- 滚轮下
	[26] = {L["WheelDown"], "ALT", "%s11"},			-- ALT+滚轮下
	[27] = {L["WheelDown"], "CTRL", "%s12"},		-- CTRL+滚轮下
	[28] = {L["WheelDown"], "SHIFT", "%s13"},		-- SHIFT+滚轮下
}

local defaultSpellList = {
	["DRUID"] = {
		[2] = 88423,		-- 驱散
		[5] = 774,			-- 回春术
		[6] = 33763,		-- 生命绽放
	},
	["HUNTER"] = {
		[21] = 90361,		-- 灵魂治愈
		[25] = 34477,		-- 误导
	},
	["ROGUE"] = {
		[6] = 57934,		-- 嫁祸
	},
	["WARRIOR"] = {
		[6] = 198304,		-- 拦截
	},
	["SHAMAN"] = {
		[2] = 77130,		-- 驱散
		[5] = 61295,		-- 激流
		[6] = 546,			-- 水上行走
	},
	["PALADIN"] = {
		[2] = 4987,			-- 驱散
		[5] = 20473,		-- 神圣震击
		[6] = 1022,			-- 保护祝福
	},
	["PRIEST"] = {
		[2] = 527,			-- 驱散
		[5] = 17,			-- 真言术盾
		[6] = 1706,			-- 漂浮术
	},
	["MONK"] = {
		[2] = 115450,		-- 驱散
		[5] = 119611,		-- 复苏之雾
	},
	["MAGE"] = {
		[6] = 130,			-- 缓落
	},
	["DEMONHUNTER"] = {},
	["WARLOCK"] = {},
	["DEATHKNIGHT"] = {},
}

function UF:DefaultClickSets()
	if not next(NDuiDB["RaidClickSets"]) then
		for k, v in pairs(defaultSpellList[DB.MyClass]) do
			local clickSet = keyList[k][2]..keyList[k][1]
			NDuiDB["RaidClickSets"][clickSet] = {keyList[k][1], keyList[k][2], v}
		end
	end
end

local wheelBindingIndex = {
	["MOUSEWHEELUP"] = 6,
	["ALT-MOUSEWHEELUP"] = 7,
	["CTRL-MOUSEWHEELUP"] = 8,
	["SHIFT-MOUSEWHEELUP"] = 9,
	["MOUSEWHEELDOWN"] = 10,
	["ALT-MOUSEWHEELDOWN"] = 11,
	["CTRL-MOUSEWHEELDOWN"] = 12,
	["SHIFT-MOUSEWHEELDOWN"] = 13,
}

local onEnterString = "self:ClearBindings();"
local onLeaveString = onEnterString
for keyString, keyIndex in pairs(wheelBindingIndex) do
	onEnterString = format("%sself:SetBindingClick(0, \"%s\", self:GetName(), \"Button%d\");", onEnterString, keyString, keyIndex)
end
local onMouseString = "if not self:IsUnderMouse(false) then self:ClearBindings(); end"

local function setupMouseWheelCast(self)
	local found
	for _, data in pairs(NDuiDB["RaidClickSets"]) do
		if strmatch(data[1], L["Wheel"]) then
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

	for _, data in pairs(NDuiDB["RaidClickSets"]) do
		local key, modKey, value = unpack(data)
		if key == KEY_BUTTON1 and modKey == "SHIFT" then self.focuser = true end

		for _, v in ipairs(keyList) do
			if v[1] == key and v[2] == modKey then
				if tonumber(value) then
					local name = GetSpellInfo(value)
					self:SetAttribute(format(v[3], "type"), "spell")
					self:SetAttribute(format(v[3], "spell"), name)
				elseif value == "target" then
					self:SetAttribute(format(v[3], "type"), "target")
				elseif value == "focus" then
					self:SetAttribute(format(v[3], "type"), "focus")
				elseif value == "follow" then
					self:SetAttribute(format(v[3], "type"), "macro")
					self:SetAttribute(format(v[3], "macrotext"), "/follow mouseover")
				elseif strmatch(value, "/") then
					self:SetAttribute(format(v[3], "type"), "macro")
					self:SetAttribute(format(v[3], "macrotext"), value)
				end
				break
			end
		end
	end

	setupMouseWheelCast(self)
	self:RegisterForClicks("AnyDown")

	self.clickCastRegistered = true
end

local pendingFrames = {}
function UF:CreateClickSets(self)
	if not NDuiDB["UFs"]["RaidClickSets"] then return end

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
	if not NDuiDB["UFs"]["RaidClickSets"] then return end

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

local found = {}
local auraFilter = {"HELPFUL", "HARMFUL"}

function UF:UpdateBuffIndicator(event, unit)
	if self.unit ~= unit then return end
	local spellList = NDuiADB["CornerBuffs"][DB.MyClass]
	local icons = self.BuffIndicator

	wipe(found)
	for _, filter in next, auraFilter do
		for i = 1, 32 do
			local name, _, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, filter)
			if not name then break end
			local value = spellList[spellID]
			if value and (value[3] or caster == "player" or caster == "pet") then
				for _, icon in pairs(icons) do
					if icon.anchor == value[1] then
						if icon.timer then
							if duration and duration > 0 then
								icon.expiration = expiration
								icon:SetScript("OnUpdate", UF.BuffIndicatorOnUpdate)
							else
								icon:SetScript("OnUpdate", nil)
							end
							icon.timer:SetTextColor(unpack(value[2]))
						else
							if duration and duration > 0 then
								icon.cd:SetCooldown(expiration - duration, duration)
								icon.cd:Show()
							else
								icon.cd:Hide()
							end
							if icon.block then
								icon.icon:SetVertexColor(unpack(value[2]))
							else
								icon.icon:SetTexture(GetSpellTexture(spellID))
							end
						end
						if count > 1 then icon.count:SetText(count) end
						icon:Show()
						found[icon.anchor] = true
						break
					end
				end
			end
		end
	end

	for _, icon in pairs(icons) do
		if not found[icon.anchor] then
			icon:Hide()
		end
	end
end

function UF:CreateBuffIndicator(self)
	if not NDuiDB["UFs"]["RaidBuffIndicator"] then return end
	if NDuiDB["UFs"]["SimpleMode"] and not self.isPartyFrame then return end

	local iconSize = NDuiDB["UFs"]["BI_IconSize"]
	local fontScale = iconSize/10
	local anchors = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}
	local icons = {}
	for _, anchor in pairs(anchors) do
		local icon = CreateFrame("Frame", nil, self)
		icon:SetFrameLevel(self:GetFrameLevel()+10)
		icon:SetSize(iconSize, iconSize)
		icon:SetPoint(anchor)
		icon:Hide()

		icon.count = B.CreateFS(icon, 12*fontScale, "")
		icon.count:ClearAllPoints()
		if NDuiDB["UFs"]["BuffIndicatorType"] == 3 then
			local point, anchorPoint, x, y = unpack(counterOffsets[anchor][2])
			icon.timer = B.CreateFS(icon, 12*fontScale, "", false, "CENTER", -x, 0)
			icon.count:SetPoint(point, icon.timer, anchorPoint, x, y)
		else
			icon.bg = B.CreateBG(icon)
			B.CreateBD(icon.bg)

			icon.icon = icon:CreateTexture(nil, "BORDER")
			icon.icon:SetAllPoints()
			if NDuiDB["UFs"]["BuffIndicatorType"] == 1 then
				icon.icon:SetTexture(DB.bdTex)
				icon.block = true
			end

			icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
			icon.cd:SetAllPoints()
			icon.cd:SetReverse(true)
			icon.cd:SetHideCountdownNumbers(true)

			icon.count:SetPoint("CENTER", unpack(counterOffsets[anchor][1]))
		end

		icon.anchor = anchor
		tinsert(icons, icon)
	end

	self.BuffIndicator = icons
	self:RegisterEvent("UNIT_AURA", UF.UpdateBuffIndicator)
end