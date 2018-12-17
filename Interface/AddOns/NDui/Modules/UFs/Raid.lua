local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

local strmatch, format, wipe, tinsert = string.match, string.format, table.wipe, table.insert
local pairs, ipairs, next, tonumber = pairs, ipairs, next, tonumber
local floor, ceil = math.floor, math.ceil

-- RaidFrame Elements
function UF:CreateRaidIcons(self)
	local parent = CreateFrame("Frame", nil, self)
	parent:SetAllPoints()
	parent:SetFrameLevel(self:GetFrameLevel() + 2)

	local check = parent:CreateTexture(nil, "OVERLAY")
	check:SetSize(16, 16)
	check:SetPoint("CENTER")
	self.ReadyCheckIndicator = check

	local resurrect = parent:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", self, 1, 0)
	self.ResurrectIndicator = resurrect

	local role = parent:CreateTexture(nil, "OVERLAY")
	role:SetSize(12, 12)
	role:SetPoint("TOPLEFT", 12, 8)
	self.RaidRoleIndicator = role
end

local function UpdateTargetBorder(self)
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
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetBorder)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetBorder)
end

local function UpdateThreatBorder(self, _, unit)
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
	self.ThreatIndicator.Override = UpdateThreatBorder
end

local debuffList = {}
function B:UpdateRaidDebuffs()
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
	bu.time = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)
	bu.glowFrame = B.CreateBG(bu, 4)
	bu.glowFrame:SetSize(size+8, size+8)

	if not NDuiDB["UFs"]["AurasClickThrough"] then
		bu:SetScript("OnEnter", function(self)
			if not self.index then return end
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:ClearLines()
			GameTooltip:SetUnitAura(self.__owner.unit, self.index, self.filter)
			GameTooltip:Show()
		end)
		bu:SetScript("OnLeave", GameTooltip_Hide)
	end

	bu.ShowDispellableDebuff = true
	bu.ShowDebuffBorder = true
	bu.FilterDispellableDebuff = true
	if NDuiDB["UFs"]["InstanceAuras"] then
		if not next(debuffList) then B.UpdateRaidDebuffs() end
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
	[24] = {L["WheelUp"], "SHIFT", "%s9"},		-- SHIFT+滚轮上

	[25] = {L["WheelDown"], "", "%s10"},			-- 滚轮下
	[26] = {L["WheelDown"], "ALT", "%s11"},		-- ALT+滚轮下
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
		[6] = 34477,		-- 误导
	},
	["ROGUE"] = {
		[6] = 57934,		-- 嫁祸
	},
	["WARRIOR"] = {
		[6] = 3411,			-- 援护
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

local function onMouseWheelCast(self)
	local found
	for _, data in pairs(NDuiDB["RaidClickSets"]) do
		local key = unpack(data)
		if strmatch(key, L["Wheel"]) then
			found = true
			break
		end
	end

	if found then
		self:SetAttribute("_onenter", [[
			self:ClearBindings()
			self:SetBindingClick(1, "MOUSEWHEELUP", self, "Button6")
			self:SetBindingClick(1, "ALT-MOUSEWHEELUP", self, "Button7")
			self:SetBindingClick(1, "CTRL-MOUSEWHEELUP", self, "Button8")
			self:SetBindingClick(1, "SHIFT-MOUSEWHEELUP", self, "Button9")
			self:SetBindingClick(1, "MOUSEWHEELDOWN", self, "Button10")
			self:SetBindingClick(1, "ALT-MOUSEWHEELDOWN", self, "Button11")
			self:SetBindingClick(1, "CTRL-MOUSEWHEELDOWN", self, "Button12")
			self:SetBindingClick(1, "SHIFT-MOUSEWHEELDOWN", self, "Button13")
		]])
		self:SetAttribute("_onleave", [[
			self:ClearBindings()
		]])
	end
end

local function setupClickSets(self)
	if self.mystyle ~= "raid" then return end	-- just in case
	if InCombatLockdown() then return end

	onMouseWheelCast(self)

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

	self:RegisterForClicks("AnyDown")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupClickSets)
end

function UF:CreateClickSets(self)
	if not NDuiDB["UFs"]["RaidClickSets"] then return end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupClickSets)
	else
		setupClickSets(self)
	end
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

local function onUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= .1 then
		local timeLeft = self.expiration - GetTime()
		if timeLeft > 0 then
			local text = B.FormatTimeRaw(timeLeft)
			self.timer:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.timer:SetText(nil)
		end
		self.elapsed = 0
	end
end

local found = {}
local function updateBuffIndicator(self, event, unit)
	if self.unit ~= unit then return end
	local spellList = C.CornerBuffs[DB.MyClass]
	local icons = self.BuffIndicator

	wipe(found)
	for i = 1, 40 do
		local name, _, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, "HELPFUL")
		if not name then break end
		local value = spellList[spellID]
		if value and (value[3] or caster == "player") then
			for _, icon in pairs(icons) do
				if icon.anchor == value[1] then
					if icon.timer then
						if duration and duration > 0 then
							icon.expiration = expiration
							icon:SetScript("OnUpdate", onUpdate)
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
						icon.icon:SetVertexColor(unpack(value[2]))
					end
					if count > 1 then icon.count:SetText(count) end
					icon:Show()
					found[icon.anchor] = true
					break
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

	local spellList = C.CornerBuffs[DB.MyClass]
	if not next(spellList) then return end

	local cache, icons = {}, {}
	for spell, value in pairs(spellList) do
		local anchor, color = unpack(value)
		if not cache[anchor] then
			local icon = CreateFrame("Frame", nil, self)
			icon:SetFrameLevel(self:GetFrameLevel()+10)
			icon:SetSize(10, 10)
			icon:SetPoint(anchor)
			icon:Hide()

			icon.count = B.CreateFS(icon, 12, "")
			icon.count:ClearAllPoints()
			if NDuiDB["UFs"]["BuffTimerIndicator"] then
				icon.timer = B.CreateFS(icon, 12, "")
				local point, anchorPoint, x, y = unpack(counterOffsets[anchor][2])
				icon.count:SetPoint(point, icon.timer, anchorPoint, x, y)
			else
				icon.bg = icon:CreateTexture(nil, "BACKGROUND")
				icon.bg:SetPoint("TOPLEFT", -C.mult, C.mult)
				icon.bg:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
				icon.bg:SetTexture(DB.bdTex)
				icon.bg:SetVertexColor(0, 0, 0)

				icon.icon = icon:CreateTexture(nil, "BORDER")
				icon.icon:SetAllPoints()
				icon.icon:SetTexture(DB.bdTex)

				icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
				icon.cd:SetAllPoints()
				icon.cd:SetReverse(true)
				icon.cd:SetHideCountdownNumbers(true)

				icon.count:SetPoint("CENTER", unpack(counterOffsets[anchor][1]))
			end

			icon.anchor = anchor
			tinsert(icons, icon)
			cache[anchor] = true
		end
	end

	self.BuffIndicator = icons
	self:RegisterEvent("UNIT_AURA", updateBuffIndicator)
end