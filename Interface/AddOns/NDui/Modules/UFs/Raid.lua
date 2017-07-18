local B, C, L, DB = unpack(select(2, ...))
local UF = NDui:GetModule("UnitFrames")

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
	self.TargetBorder = B.CreateBG(self, 2)
	self.TargetBorder:SetBackdrop({edgeFile = DB.bdTex, edgeSize = 1.2})
	self.TargetBorder:SetBackdropBorderColor(.7, .7, .7)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self.Power, 2, -2)
	self.TargetBorder:Hide()
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetBorder)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetBorder)
end

function UF:CreateRaidDebuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	local size = 18*NDuiDB["UFs"]["RaidScale"]
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
	bu.EnableTooltip = not NDuiDB["UFs"]["NoTooltip"]
	bu.ShowDebuffBorder = NDuiDB["UFs"]["DebuffBorder"]
	bu.FilterDispellableDebuff = NDuiDB["UFs"]["Dispellable"]
	if NDuiDB["UFs"]["InstanceAuras"] then bu.Debuffs = C.RaidDebuffs end
	self.RaidDebuffs = bu
end

local keyList = {
	[1] = {KEY_BUTTON1, "ALT", "ALT-%s1"},			-- ALT+左键
	[2] = {KEY_BUTTON1, "CTRL", "CTRL-%s1"},		-- CTRL+左键

	[3] = {KEY_BUTTON2, "", "%s2"},					-- 右键
	[4] = {KEY_BUTTON2, "ALT", "ALT-%s2"},			-- ALT+右键
	[5] = {KEY_BUTTON2, "CTRL", "CTRL-%s2"},		-- CTRL+右键
	[6] = {KEY_BUTTON2, "SHIFT", "SHIFT-%s2"},		-- SHIFT+右键

	[7] = {KEY_BUTTON4, "", "%s4"},					-- 鼠标键4
	[8] = {KEY_BUTTON4, "ALT", "ALT-%s4"},			-- ALT+鼠标键4
	[9] = {KEY_BUTTON4, "CTRL", "CTRL-%s4"},		-- CTRL+鼠标键4
	[10] = {KEY_BUTTON4, "SHIFT", "SHIFT-%s4"},		-- SHIFT+鼠标键4

	[11] = {KEY_BUTTON5, "", "%s5"},				-- 鼠标键5
	[12] = {KEY_BUTTON5, "ALT", "ALT-%s5"},			-- ALT+鼠标键5
	[13] = {KEY_BUTTON5, "CTRL", "CTRL-%s5"},		-- CTRL+鼠标键5
	[14] = {KEY_BUTTON5, "SHIFT", "SHIFT-%s5"},		-- SHIFT+鼠标键5
}

local defaultSpellList = {
	["DRUID"] = {
		[1] = 88423,		-- 驱散
		[2] = 50769,		-- 复活
		[3] = 774,			-- 回春术
		[4] = 33763,		-- 生命绽放
	},
	["HUNTER"] = {
		[4] = 34477,		-- 误导
	},
	["ROGUE"] = {
		[4] = 57934,		-- 嫁祸
	},
	["WARRIOR"] = {
		[4] = 3411,			-- 援护
	},
	["SHAMAN"] = {
		[1] = 77130,		-- 驱散
		[2] = 2008,			-- 复活
		[3] = 61295,		-- 激流
		[4] = 546,			-- 水上行走
	},
	["PALADIN"] = {
		[1] = 4987,			-- 驱散
		[2] = 7328,			-- 复活
		[3] = 20476,		-- 神圣震击
		[4] = 1022,			-- 保护祝福
	},
	["PRIEST"] = {
		[1] = 527,			-- 驱散
		[2] = 2006,			-- 复活
		[3] = 17,			-- 真言术盾
		[4] = 1706,			-- 漂浮术
	},
	["MONK"] = {
		[1] = 115450,		-- 驱散
		[2] = 115178,		-- 复活
		[3] = 119611,		-- 复苏之雾
	},
	["MAGE"] = {
		[4] = 130,			-- 缓落
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

local function setupClickSets(self, ...)
	if not self.clickSets then self.clickSets = {} end

	for _, data in pairs(NDuiDB["RaidClickSets"]) do
		local key, modKey, spellID = unpack(data)
		if self.clickSets[modKey..key] then return end

		for _, v in pairs(keyList) do
			if v[1] == key and v[2] == modKey then
				local name = GetSpellInfo(spellID)
				self:SetAttribute(format(v[3], "type"), "spell")
				self:SetAttribute(format(v[3], "spell"), name)
				self.clickSets[modKey..key] = true
			end
		end
	end	
end

function UF:CreateClickSets(self)
	if not NDuiDB["UFs"]["RaidClickSets"] then return end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupClickSets)
	else
		setupClickSets(self)
	end
end