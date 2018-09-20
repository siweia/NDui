local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

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

function UF:CreateRaidDebuffs(self)
	local size = 18*NDuiDB["UFs"]["RaidScale"]

	local bu = CreateFrame("Frame", nil, self)
	bu:SetSize(size, size)
	bu:SetPoint("TOPRIGHT", -10, -2)
	bu:SetFrameLevel(self:GetFrameLevel() + 3)
	B.CreateSD(bu, 2, 2)

	bu.icon = bu:CreateTexture(nil, "ARTWORK")
	bu.icon:SetAllPoints()
	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.count = B.CreateFS(bu, 12, "", false, "BOTTOMRIGHT", 6, -3)
	bu.time = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)

	bu.ShowDispellableDebuff = true
	bu.EnableTooltip = not NDuiDB["UFs"]["AurasClickThrough"]
	bu.ShowDebuffBorder = NDuiDB["UFs"]["DebuffBorder"]
	bu.FilterDispellableDebuff = NDuiDB["UFs"]["Dispellable"]
	if NDuiDB["UFs"]["InstanceAuras"] then bu.Debuffs = C.RaidDebuffs end
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
	["DEMONHUNTER"] = {
	},
	["WARLOCK"] = {
	},
	["DEATHKNIGHT"] = {
	},
}

function UF:DefaultClickSets()
	if not NDuiDB["RaidClickSets"] then
		NDuiDB["RaidClickSets"] = {}
		for k, v in pairs(defaultSpellList[DB.MyClass]) do
			local clickSet = keyList[k][2]..keyList[k][1]
			NDuiDB["RaidClickSets"][clickSet] = {keyList[k][1], keyList[k][2], v}
		end
	end
end

local function onMouseWheelCast(self)
	local found
	for _, data in pairs(NDuiDB["RaidClickSets"]) do
		local key, modKey, value = unpack(data)
		if key:match(L["Wheel"]) then
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
				elseif value:match("/") then
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