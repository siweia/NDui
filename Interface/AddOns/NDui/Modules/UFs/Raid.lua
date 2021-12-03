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
	local border = B.CreateSD(self, 4, true)
	border:SetOutside(self.Health.backdrop, C.mult+4, C.mult+4, self.Power.backdrop)
	border:SetBackdropBorderColor(1, 1, 1)
	border:Hide()
	self.__shadow = nil

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
	local threatIndicator = B.CreateSD(self, 3, true)
	threatIndicator:SetOutside(self.Health.backdrop, C.mult+3, C.mult+3, self.Power.backdrop)
	threatIndicator:SetBackdropBorderColor(.7, .7, .7)
	threatIndicator:SetFrameLevel(0)
	self.__shadow = nil

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
	if not NDuiADB["RaidClickSets"][DB.MyClass] then NDuiADB["RaidClickSets"][DB.MyClass] = {} end

	if not next(NDuiADB["RaidClickSets"][DB.MyClass]) then
		for k, v in pairs(defaultSpellList[DB.MyClass]) do
			local clickSet = keyList[k][2]..keyList[k][1]
			NDuiADB["RaidClickSets"][DB.MyClass][clickSet] = {keyList[k][1], keyList[k][2], v}
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
	for _, data in pairs(NDuiADB["RaidClickSets"][DB.MyClass]) do
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

	for _, data in pairs(NDuiADB["RaidClickSets"][DB.MyClass]) do
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
					value = gsub(value, "~", "\n")
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
			local value = spellList[spellID]
			if value and (value[3] or caster == "player" or caster == "pet") then
				local bu = buttons[value[1]]
				if bu then
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

					bu.count:SetText(count > 1 and count)
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
	if self.isSimpleMode then return end

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

function UF:InterruptIndicator(self)
	if not C.db["UFs"]["PartyWatcher"] then return end

	local horizon = C.db["UFs"]["HorizonParty"]
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
		yOffset = horizon and -(self.Power:GetHeight()+8) or 0
		margin = 2
	end
	local rel1 = not horizon and not otherSide and "RIGHT" or "LEFT"
	local rel2 = not horizon and not otherSide and "LEFT" or "RIGHT"
	local buttons = {}
	local maxIcons = 6
	local iconSize = horizon and (self:GetWidth()-2*abs(margin))/3 or (self:GetHeight()+self.Power:GetHeight()+3)
	if iconSize > 34 then iconSize = 34 end

	for i = 1, maxIcons do
		local bu = CreateFrame("Frame", nil, self)
		bu:SetSize(iconSize, iconSize)
		B.AuraIcon(bu)
		bu.CD:SetReverse(false)
		if i == 1 then
			bu:SetPoint(relF, self, relT, xOffset, yOffset)
		elseif i == 4 and horizon then
			bu:SetPoint(relF, buttons[i-3], relT, 0, margin)
		else
			bu:SetPoint(rel1, buttons[i-1], rel2, margin, 0)
		end
		bu:Hide()

		buttons[i] = bu
	end

	buttons.__max = maxIcons
	buttons.PartySpells = UF.PartyWatcherSpells
	buttons.TalentCDFix = C.TalentCDFix
	self.PartyWatcher = buttons
	if C.db["UFs"]["PartyWatcherSync"] then
		self.PartyWatcher.PostUpdate = UF.PartyWatcherPostUpdate
	end
end

function UF:CreatePartyAltPower(self)
	if not C.db["UFs"]["PartyAltPower"] then return end

	local horizon = C.db["UFs"]["HorizonParty"]
	local relF = horizon and "TOP" or "LEFT"
	local relT = horizon and "BOTTOM" or "RIGHT"
	local xOffset = horizon and 0 or 5
	local yOffset = horizon and -5 or 0
	local otherSide = C.db["UFs"]["PWOnRight"]
	if otherSide then
		xOffset = horizon and 0 or -5
		yOffset = horizon and 5 or 0
	end

	local altPower = B.CreateFS(self, 16, "")
	altPower:ClearAllPoints()
	if otherSide then
		altPower:SetPoint(relT, self, relF, xOffset, yOffset)
	else
		local parent = horizon and self.Power or self
		altPower:SetPoint(relF, parent, relT, xOffset, yOffset)
	end
	self:Tag(altPower, "[altpower]")
end