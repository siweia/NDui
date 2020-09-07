local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local format, gsub, strsplit = string.format, string.gsub, string.split
local pairs, tonumber, wipe, select = pairs, tonumber, wipe, select
local GetInstanceInfo, GetAtlasInfo, PlaySound = GetInstanceInfo, GetAtlasInfo, PlaySound
local IsPartyLFG, IsInRaid, IsInGroup, IsInInstance, IsInGuild = IsPartyLFG, IsInRaid, IsInGroup, IsInInstance, IsInGuild
local UnitInRaid, UnitInParty, SendChatMessage = UnitInRaid, UnitInParty, SendChatMessage
local UnitName, Ambiguate, GetTime = UnitName, Ambiguate, GetTime
local GetSpellLink, GetSpellInfo = GetSpellLink, GetSpellInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_MythicPlus_GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes

--[[
	SoloInfo是一个告知你当前副本难度的小工具，防止我有时候单刷时进错难度了。
	instList左侧是副本ID，你可以使用"/getid"命令来获取当前副本的ID；右侧的是副本难度，常用的一般是：2为5H，4为25普通，6为25H。
]]
local soloInfo
local instList = {
	[556] = 2,		-- H塞塔克大厅，乌鸦
	[575] = 2,		-- H乌特加德之巅，蓝龙
	[585] = 2,		-- H魔导师平台，白鸡
	[631] = 6,		-- 25H冰冠堡垒，无敌
	[1205] = 16,	-- M黑石，裂蹄牛
	[1448] = 16,	-- M地狱火，魔钢
	[1651] = 23,	-- M卡拉赞，新午夜
}

function M:SoloInfo_Create()
	if soloInfo then soloInfo:Show() return end

	soloInfo = CreateFrame("Frame", nil, UIParent)
	soloInfo:SetPoint("CENTER", 0, 120)
	soloInfo:SetSize(150, 70)
	B.SetBD(soloInfo)

	soloInfo.Text = B.CreateFS(soloInfo, 14, "")
	soloInfo.Text:SetWordWrap(true)
	soloInfo:SetScript("OnMouseUp", function() soloInfo:Hide() end)
end

function M:SoloInfo_Update()
	local name, instType, diffID, diffName, _, _, _, instID = GetInstanceInfo()

	if instType ~= "none" and diffID ~= 24 and instList[instID] and instList[instID] ~= diffID then
		M:SoloInfo_Create()
		soloInfo.Text:SetText(DB.InfoColor..name..DB.MyColor.."\n( "..diffName.." )\n\n"..DB.InfoColor..L["Wrong Difficulty"])
	else
		if soloInfo then soloInfo:Hide() end
	end
end

function M:SoloInfo()
	if NDuiDB["Misc"]["SoloInfo"] then
		self:SoloInfo_Update()
		B:RegisterEvent("UPDATE_INSTANCE_INFO", self.SoloInfo_Update)
		B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", self.SoloInfo_Update)
	else
		if soloInfo then soloInfo:Hide() end
		B:UnregisterEvent("UPDATE_INSTANCE_INFO", self.SoloInfo_Update)
		B:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED", self.SoloInfo_Update)
	end
end

--[[
	发现稀有/事件时的通报插件
]]
local cache = {}
local isIgnored = {
	[1153] = true,	-- 部落要塞
	[1159] = true,	-- 联盟要塞
	[1803] = true,	-- 涌泉海滩
	[1876] = true,	-- 部落激流堡
	[1943] = true,	-- 联盟激流堡
	[2111] = true,	-- 黑海岸前线
}

function M:RareAlert_Update(id)
	if id and not cache[id] then
		local instType = select(2, GetInstanceInfo())
		local info = C_VignetteInfo_GetVignetteInfo(id)
		if not info then return end
		local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(info.atlasName)
		if not filename then return end

		local atlasWidth = width/(txRight-txLeft)
		local atlasHeight = height/(txBottom-txTop)
		local tex = format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, 0, 0, atlasWidth, atlasHeight, atlasWidth*txLeft, atlasWidth*txRight, atlasHeight*txTop, atlasHeight*txBottom)

		UIErrorsFrame:AddMessage(DB.InfoColor..L["Rare Found"]..tex..(info.name or ""))
		if NDuiDB["Misc"]["AlertinChat"] then
			local currrentTime = NDuiADB["TimestampFormat"] == 1 and "|cff00ff00["..date("%H:%M:%S").."]|r" or ""
			print(currrentTime.." -> "..DB.InfoColor..L["Rare Found"]..tex..(info.name or ""))
		end
		if not NDuiDB["Misc"]["RareAlertInWild"] or instType == "none" then
			PlaySound(23404, "master")
		end

		cache[id] = true
	end

	if #cache > 666 then wipe(cache) end
end

function M:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnored[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		B:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", M.RareAlert_Update)
	else
		B:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", M.RareAlert_Update)
	end
end

function M:RareAlert()
	if NDuiDB["Misc"]["RareAlerter"] then
		self:RareAlert_CheckInstance()
		B:RegisterEvent("UPDATE_INSTANCE_INFO", self.RareAlert_CheckInstance)
	else
		wipe(cache)
		B:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", self.RareAlert_Update)
		B:UnregisterEvent("UPDATE_INSTANCE_INFO", self.RareAlert_CheckInstance)
	end
end

--[[
	闭上你的嘴！
	打断、偷取及驱散法术时的警报
]]
local function msgChannel()
	return IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
end

local infoType = {
	["SPELL_INTERRUPT"] = L["Interrupt"],
	["SPELL_STOLEN"] = L["Steal"],
	["SPELL_DISPEL"] = L["Dispel"],
	["SPELL_AURA_BROKEN_SPELL"] = L["BrokenSpell"],
}

local blackList = {
	[99] = true,		-- 夺魂咆哮
	[122] = true,		-- 冰霜新星
	[1776] = true,		-- 凿击
	[1784] = true,		-- 潜行
	[5246] = true,		-- 破胆怒吼
	[8122] = true,		-- 心灵尖啸
	[31661] = true,		-- 龙息术
	[33395] = true,		-- 冰冻术
	[64695] = true,		-- 陷地
	[82691] = true,		-- 冰霜之环
	[91807] = true,		-- 蹒跚冲锋
	[102359] = true,	-- 群体缠绕
	[105421] = true,	-- 盲目之光
	[115191] = true,	-- 潜行
	[157997] = true,	-- 寒冰新星
	[197214] = true,	-- 裂地术
	[198121] = true,	-- 冰霜撕咬
	[207167] = true,	-- 致盲冰雨
	[207685] = true,	-- 悲苦咒符
	[226943] = true,	-- 心灵炸弹
	[228600] = true,	-- 冰川尖刺
}

function M:IsAllyPet(sourceFlags)
	if DB:IsMyPet(sourceFlags) or (not NDuiDB["Misc"]["OwnInterrupt"] and (sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags)) then
		return true
	end
end

function M:InterruptAlert_Update(...)
	if NDuiDB["Misc"]["AlertInInstance"] and (not IsInInstance() or IsPartyLFG()) then return end

	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then return end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or M:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			if infoText == L["BrokenSpell"] then
				if not NDuiDB["Misc"]["BrokenSpell"] then return end
				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellID] then return end
				SendChatMessage(format(infoText, sourceName..GetSpellLink(extraskillID), destName..GetSpellLink(spellID)), msgChannel())
			else
				if NDuiDB["Misc"]["OwnInterrupt"] and sourceName ~= DB.MyName and not M:IsAllyPet(sourceFlags) then return end
				SendChatMessage(format(infoText, sourceName..GetSpellLink(spellID), destName..GetSpellLink(extraskillID)), msgChannel())
			end
		end
	end
end

function M:InterruptAlert_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	else
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

function M:InterruptAlert()
	if NDuiDB["Misc"]["Interrupt"] then
		self:InterruptAlert_CheckGroup()
		B:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
	else
		B:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

--[[
	NDui版本过期提示
]]
local lastVCTime, isVCInit = 0
function M:VersionCheck_Compare(new, old)
	local new1, new2 = strsplit(".", new)
	new1, new2 = tonumber(new1), tonumber(new2)

	local old1, old2 = strsplit(".", old)
	old1, old2 = tonumber(old1), tonumber(old2)

	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

function M:VersionCheck_Create(text)
	if not NDuiADB["VersionCheck"] then return end

	local frame = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
	frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 20, 70)
	frame.Text:SetText(text)
	frame:Show()
end

function M:VersionCheck_Init()
	if not isVCInit then
		local status = M:VersionCheck_Compare(NDuiADB["DetectVersion"], DB.Version)
		if status == "IsNew" then
			local release = gsub(NDuiADB["DetectVersion"], "(%d+)$", "0")
			M:VersionCheck_Create(format(L["Outdated NDui"], release))
		elseif status == "IsOld" then
			NDuiADB["DetectVersion"] = DB.Version
		end

		isVCInit = true
	end
end

function M:VersionCheck_Send(channel)
	if GetTime() - lastVCTime >= 10 then
		C_ChatInfo_SendAddonMessage("NDuiVersionCheck", NDuiADB["DetectVersion"], channel)
		lastVCTime = GetTime()
	end
end

function M:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "NDuiVersionCheck" then return end
	if Ambiguate(author, "none") == DB.MyName then return end

	local status = M:VersionCheck_Compare(msg, NDuiADB["DetectVersion"])
	if status == "IsNew" then
		NDuiADB["DetectVersion"] = msg
	elseif status == "IsOld" then
		M:VersionCheck_Send(distType)
	end

	M:VersionCheck_Init()
end

function M:VersionCheck_UpdateGroup()
	if not IsInGroup() then return end
	M:VersionCheck_Send(msgChannel())
end

function M:VersionCheck()
	M:VersionCheck_Init()
	C_ChatInfo_RegisterAddonMessagePrefix("NDuiVersionCheck")
	B:RegisterEvent("CHAT_MSG_ADDON", M.VersionCheck_Update)

	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("NDuiVersionCheck", DB.Version, "GUILD")
		lastVCTime = GetTime()
	end
	M:VersionCheck_UpdateGroup()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", M.VersionCheck_UpdateGroup)
end

--[[
	大米完成时，通报打球统计
]]
local eventList = {
	["SWING_DAMAGE"] = 13,
	["RANGE_DAMAGE"] = 16,
	["SPELL_DAMAGE"] = 16,
	["SPELL_PERIODIC_DAMAGE"] = 16,
	["SPELL_BUILDING_DAMAGE"] = 16,
}

function M:Explosive_Update(...)
	local _, eventType, _, _, sourceName, _, _, destGUID = ...
	local index = eventList[eventType]
	if index and B.GetNPCID(destGUID) == 120651 then
		local overkill = select(index, ...)
		if overkill and overkill > 0 then
			local name = strsplit("-", sourceName or UNKNOWN)
			local cache = NDuiDB["Misc"]["ExplosiveCache"]
			if not cache[name] then cache[name] = 0 end
			cache[name] = cache[name] + 1
		end
	end
end

local function startCount()
	wipe(NDuiDB["Misc"]["ExplosiveCache"])
	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.Explosive_Update)
end

local function endCount()
	local text
	for name, count in pairs(NDuiDB["Misc"]["ExplosiveCache"]) do
		text = (text or L["ExplosiveCount"])..name.."("..count..") "
	end
	if text then SendChatMessage(text, "PARTY") end
	B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.Explosive_Update)
end

local function pauseCount()
	local name, _, instID = GetInstanceInfo()
	if name and instID == 8 then
		B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.Explosive_Update)
	else
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.Explosive_Update)
	end
end

function M.Explosive_CheckAffixes(event)
	local affixes = C_MythicPlus_GetCurrentAffixes()
	if not affixes then return end

	if affixes[3] and affixes[3].id == 13 then
		B:RegisterEvent("CHALLENGE_MODE_START", startCount)
		B:RegisterEvent("CHALLENGE_MODE_COMPLETED", endCount)
		B:RegisterEvent("UPDATE_INSTANCE_INFO", pauseCount)
	end
	B:UnregisterEvent("PLAYER_ENTERING_WORLD", M.Explosive_CheckAffixes)
end

function M:ExplosiveAlert()
	if NDuiDB["Misc"]["ExplosiveCount"] then
		self:Explosive_CheckAffixes()
		B:RegisterEvent("PLAYER_ENTERING_WORLD", self.Explosive_CheckAffixes)
	else
		B:UnregisterEvent("CHALLENGE_MODE_START", startCount)
		B:UnregisterEvent("CHALLENGE_MODE_COMPLETED", endCount)
		B:UnregisterEvent("UPDATE_INSTANCE_INFO", pauseCount)
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", self.Explosive_CheckAffixes)
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Explosive_Update)
	end
end

--[[
	放大餐时叫一叫
]]
local lastTime = 0
local itemList = {
	[226241] = true,	-- 宁神圣典
	[256230] = true,	-- 静心圣典
	[185709] = true,	-- 焦糖鱼宴
	[259409] = true,	-- 海帆盛宴
	[259410] = true,	-- 船长盛宴
	[276972] = true,	-- 秘法药锅
	[286050] = true,	-- 鲜血大餐
	[265116] = true,	-- 工程战复
}

function M:ItemAlert_Update(unit, _, spellID)
	if not NDuiDB["Misc"]["PlacedItemAlert"] then return end

	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(format(L["Place item"], who, link or name), msgChannel())

		lastTime = GetTime()
	end
end

function M:ItemAlert_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.ItemAlert_Update)
	else
		B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.ItemAlert_Update)
	end
end

function M:PlacedItemAlert()
	self:ItemAlert_CheckGroup()
	B:RegisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
	B:RegisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
end

-- 大幻象水晶及箱子计数
function M:NVision_Create()
	if M.VisionFrame then M.VisionFrame:Show() return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(24, 24)
	frame.bars = {}

	local mover = B.Mover(frame, L["NzothVision"], "NzothVision", {"TOP", PlayerPowerBarAlt, "BOTTOM"}, 216, 24)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)

	local barData = {
		[1] = {
			anchorF = "RIGHT", anchorT = "LEFT", offset = -3,
			texture = 134110,
			color = {1, .8, 0}, reverse = false, maxValue = 10,
		},
		[2] = {
			anchorF = "LEFT", anchorT = "RIGHT", offset = 3,
			texture = 2000861,
			color = {.8, 0, 1}, reverse = true, maxValue = 12,
		}
	}

	for i, v in ipairs(barData) do
		local bar = CreateFrame("StatusBar", nil, frame)
		bar:SetSize(80, 20)
		bar:SetPoint(v.anchorF, frame, "CENTER", v.offset, 0)
		bar:SetMinMaxValues(0, v.maxValue)
		bar:SetValue(0)
		bar:SetReverseFill(v.reverse)
		B:SmoothBar(bar)
		B.CreateSB(bar, nil, unpack(v.color))
		bar.text = B.CreateFS(bar, 16, "0/"..v.maxValue, nil, "CENTER", 0, 0)

		local icon = CreateFrame("Frame", nil, bar)
		icon:SetSize(22, 22)
		icon:SetPoint(v.anchorF, bar, v.anchorT, v.offset, 0)
		B.PixelIcon(icon, v.texture)
		B.CreateSD(icon)

		bar.count = 0
		bar.__max = v.maxValue
		frame.bars[i] = bar
	end

	M.VisionFrame = frame
end

function M:NVision_Update(index, reset)
	local frame = M.VisionFrame
	local bar = frame.bars[index]
	if reset then bar.count = 0 end
	bar:SetValue(bar.count)
	bar.text:SetText(bar.count.."/"..bar.__max)
end

local castSpellIndex = {[143394] = 1, [306608] = 2}
function M:NVision_OnEvent(unit, _, spellID)
	local index = castSpellIndex[spellID]
	if index and (index == 1 or unit == "player") then
		local frame = M.VisionFrame
		local bar = frame.bars[index]
		bar.count = bar.count + 1
		M:NVision_Update(index)
	end
end

function M:NVision_Check()
	local diffID = select(3, GetInstanceInfo())
	if diffID == 152 then
		M:NVision_Create()
		B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.NVision_OnEvent, "player")

		if not RaidBossEmoteFrame.__isOff then
			RaidBossEmoteFrame:UnregisterAllEvents()
			RaidBossEmoteFrame.__isOff = true
		end
	else
		if M.VisionFrame then
			M:NVision_Update(1, true)
			M:NVision_Update(2, true)
			M.VisionFrame:Hide()
			B:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", M.NVision_OnEvent)
		end

		if RaidBossEmoteFrame.__isOff then
			if not NDuiDB["Misc"]["HideBossEmote"] then
				RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
				RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
				RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
			end
			RaidBossEmoteFrame.__isOff = nil
		end
	end
end

function M:NVision_Init()
	if not NDuiDB["Misc"]["NzothVision"] then return end
	M:NVision_Check()
	B:RegisterEvent("UPDATE_INSTANCE_INFO", M.NVision_Check)
end

-- Init
function M:AddAlerts()
	M:SoloInfo()
	M:RareAlert()
	M:InterruptAlert()
	M:VersionCheck()
	M:ExplosiveAlert()
	M:PlacedItemAlert()
	M:NVision_Init()
end
M:RegisterMisc("Notifications", M.AddAlerts)