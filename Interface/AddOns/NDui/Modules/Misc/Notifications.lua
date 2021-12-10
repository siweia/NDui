local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local format, gsub, strsplit, strfind = string.format, string.gsub, string.split, string.find
local pairs, tonumber, wipe, select = pairs, tonumber, wipe, select
local GetInstanceInfo, PlaySound, print = GetInstanceInfo, PlaySound, print
local IsPartyLFG, IsInRaid, IsInGroup, IsInInstance, IsInGuild = IsPartyLFG, IsInRaid, IsInGroup, IsInInstance, IsInGuild
local UnitInRaid, UnitInParty, SendChatMessage = UnitInRaid, UnitInParty, SendChatMessage
local UnitName, Ambiguate, GetTime = UnitName, Ambiguate, GetTime
local GetSpellLink, GetSpellInfo, GetSpellCooldown = GetSpellLink, GetSpellInfo, GetSpellCooldown
local GetActionInfo, GetMacroSpell, GetMacroItem = GetActionInfo, GetMacroSpell, GetMacroItem
local GetItemInfo, GetItemInfoFromHyperlink = GetItemInfo, GetItemInfoFromHyperlink
local C_Timer_After = C_Timer.After
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
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

	if (diffName and diffName ~= "") and instType ~= "none" and diffID ~= 24 and instList[instID] and instList[instID] ~= diffID then
		M:SoloInfo_Create()
		soloInfo.Text:SetText(DB.InfoColor..name..DB.MyColor.."\n( "..diffName.." )\n\n"..DB.InfoColor..L["Wrong Difficulty"])
	else
		if soloInfo then soloInfo:Hide() end
	end
end

function M:SoloInfo_DelayCheck()
	C_Timer_After(3, M.SoloInfo_Update)
end

function M:SoloInfo()
	if C.db["Misc"]["SoloInfo"] then
		self:SoloInfo_Update()
		B:RegisterEvent("PLAYER_ENTERING_WORLD", self.SoloInfo_DelayCheck)
		B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", self.SoloInfo_DelayCheck)
	else
		if soloInfo then soloInfo:Hide() end
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", self.SoloInfo_DelayCheck)
		B:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED", self.SoloInfo_DelayCheck)
	end
end

--[[
	发现稀有/事件时的通报插件
]]
local cache = {}
local isIgnoredZone = {
	[1153] = true,	-- 部落要塞
	[1159] = true,	-- 联盟要塞
	[1803] = true,	-- 涌泉海滩
	[1876] = true,	-- 部落激流堡
	[1943] = true,	-- 联盟激流堡
	[2111] = true,	-- 黑海岸前线
}

local function isUsefulAtlas(info)
	local atlas = info.atlasName
	if atlas then
		return strfind(atlas, "[Vv]ignette") or (atlas == "nazjatar-nagaevent")
	end
end

function M:RareAlert_Update(id)
	if id and not cache[id] then
		local info = C_VignetteInfo_GetVignetteInfo(id)
		if not info or not isUsefulAtlas(info) then return end

		local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
		if not atlasInfo then return end
		local tex = B:GetTextureStrByAtlas(atlasInfo)
		if not tex then return end

		UIErrorsFrame:AddMessage(DB.InfoColor..L["Rare Found"]..tex..(info.name or ""))

		if C.db["Misc"]["RarePrint"] then
			local currrentTime = NDuiADB["TimestampFormat"] == 1 and "|cff00ff00["..date("%H:%M:%S").."]|r" or ""
			local nameString
			local mapID = C_Map_GetBestMapForUnit("player")
			local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
			if position then
				local x, y = position:GetXY()
				nameString = format(M.RareString, mapID, x*10000, y*10000, info.name, x*100, y*100, "")
			end
			print(currrentTime.." -> "..tex..DB.InfoColor..(nameString or info.name or ""))
		end

		if not C.db["Misc"]["RareAlertInWild"] or M.RareInstType == "none" then
			PlaySound(23404, "master")
		end

		cache[id] = true
	end

	if #cache > 666 then wipe(cache) end
end

function M:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		B:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", M.RareAlert_Update)
	else
		B:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", M.RareAlert_Update)
	end
	M.RareInstType = instanceType
end

function M:RareAlert()
	M.RareString = "|Hworldmap:%d+:%d+:%d+|h[%s (%.1f, %.1f)%s]|h|r"

	if C.db["Misc"]["RareAlerter"] then
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

local infoType = {}

function M:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C.db["Misc"]["DispellAlert"] and L["Steal"]
	infoType["SPELL_DISPEL"] = C.db["Misc"]["DispellAlert"] and L["Dispel"]
	infoType["SPELL_INTERRUPT"] = C.db["Misc"]["InterruptAlert"] and L["Interrupt"]
	infoType["SPELL_AURA_BROKEN_SPELL"] = C.db["Misc"]["BrokenAlert"] and L["BrokenSpell"]
end

function M:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
end

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
	[331866] = true,	-- 混沌代理人
}

function M:IsAllyPet(sourceFlags)
	if DB:IsMyPet(sourceFlags) or sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags then
		return true
	end
end

function M:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then return end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or M:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			local sourceSpellID, destSpellID
			if infoText == L["BrokenSpell"] then
				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellID] then return end
				sourceSpellID, destSpellID = extraskillID, spellID
			elseif infoText == L["Interrupt"] then
				if C.db["Misc"]["OwnInterrupt"] and sourceName ~= DB.MyName and not DB:IsMyPet(sourceFlags) then return end
				sourceSpellID, destSpellID = spellID, extraskillID
			else
				if C.db["Misc"]["OwnDispell"] and sourceName ~= DB.MyName and not DB:IsMyPet(sourceFlags) then return end
				sourceSpellID, destSpellID = spellID, extraskillID
			end

			if sourceSpellID and destSpellID then
				SendChatMessage(format(infoText, sourceName..GetSpellLink(sourceSpellID), destName..GetSpellLink(destSpellID)), msgChannel())
			end
		end
	end
end

function M:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C.db["Misc"]["InstAlertOnly"] or (IsInInstance() and not IsPartyLFG())) then
		B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	else
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

function M:InterruptAlert()
	M:InterruptAlert_Toggle()

	if M:InterruptAlert_IsEnabled() then
		self:InterruptAlert_CheckGroup()
		B:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		B:RegisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
	else
		B:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
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

	HelpTip:Show(ChatFrame1, {
		text = text,
		buttonStyle = HelpTip.ButtonStyle.Okay,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		offsetY = 10,
	})
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
			local cache = C.db["Misc"]["ExplosiveCache"]
			if not cache[name] then cache[name] = 0 end
			cache[name] = cache[name] + 1
		end
	end
end

local function startCount()
	wipe(C.db["Misc"]["ExplosiveCache"])
	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.Explosive_Update)
end

local function endCount()
	local text
	for name, count in pairs(C.db["Misc"]["ExplosiveCache"]) do
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
	if C.db["Misc"]["ExplosiveCount"] then
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
	[54710] = true,		-- 随身邮箱
	[67826] = true,		-- 基维斯
	[226241] = true,	-- 宁神圣典
	[256230] = true,	-- 静心圣典
	[185709] = true,	-- 焦糖鱼宴
	[259409] = true,	-- 海帆盛宴
	[259410] = true,	-- 船长盛宴
	[276972] = true,	-- 秘法药锅
	[286050] = true,	-- 鲜血大餐
	[265116] = true,	-- 8.0工程战复

	[308458] = true,	-- 惊异怡人大餐
	[308462] = true,	-- 纵情饕餮盛宴
	[345130] = true,	-- 9.0工程战复
	[307157] = true,	-- 永恒药锅
	[324029] = true,	-- 宁心圣典
}

function M:ItemAlert_Update(unit, _, spellID)
	if not C.db["Misc"]["PlacedItemAlert"] then return end

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
			if not C.db["Misc"]["HideBossEmote"] then
				RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
				RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
				RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
			end
			RaidBossEmoteFrame.__isOff = nil
		end
	end
end

function M:NVision_Init()
	if not C.db["Misc"]["NzothVision"] then return end
	M:NVision_Check()
	B:RegisterEvent("UPDATE_INSTANCE_INFO", M.NVision_Check)
end

-- Incompatible check
local IncompatibleAddOns = {
	["BigFoot"] = true,
	["_ShiGuang"] = true,
	["!!!163UI!!!"] = true,
	["Aurora"] = true,
	["AuroraClassic"] = true, -- my own addon
	["DomiRank"] = true, -- my own addon
	["MDGuildBest"] = true, -- my own addon
	["SexyMap"] = true,
}
local AddonDependency = {
	["BigFoot"] = "!!!Libs",
}
function M:CheckIncompatible()
	local IncompatibleList = {}
	for addon in pairs(IncompatibleAddOns) do
		if IsAddOnLoaded(addon) then
			tinsert(IncompatibleList, addon)
		end
	end

	if #IncompatibleList > 0 then
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetPoint("TOP", 0, -200)
		frame:SetFrameStrata("HIGH")
		B.CreateMF(frame)
		B.SetBD(frame)
		B.CreateFS(frame, 18, L["FoundIncompatibleAddon"], true, "TOPLEFT", 10, -10)
		B.CreateWatermark(frame)

		local offset = 0
		for _, addon in pairs(IncompatibleList) do
			B.CreateFS(frame, 14, addon, false, "TOPLEFT", 10, -(50 + offset))
			offset = offset + 24
		end
		frame:SetSize(300, 100 + offset)

		local close = B.CreateButton(frame, 16, 16, true, DB.closeTex)
		close:SetPoint("TOPRIGHT", -10, -10)
		close:SetScript("OnClick", function() frame:Hide() end)

		local disable = B.CreateButton(frame, 150, 25, L["DisableIncompatibleAddon"])
		disable:SetPoint("BOTTOM", 0, 10)
		disable.text:SetTextColor(1, .8, 0)
		disable:SetScript("OnClick", function()
			for _, addon in pairs(IncompatibleList) do
				DisableAddOn(addon, true)
				if AddonDependency[addon] then
					DisableAddOn(AddonDependency[addon], true)
				end
			end
			ReloadUI()
		end)
	end
end

-- Send cooldown status
local function GetRemainTime(second)
	if second > 60 then
		return format("%d:%.2d", second/60, second%60)
	else
		return format("%ds", second)
	end
end

local lastCDSend = 0
function M:SendCurrentSpell(thisTime, spellID)
	local start, duration = GetSpellCooldown(spellID)
	local spellLink = GetSpellLink(spellID)
	if start and duration > 0 then
		local remain = start + duration - thisTime
		SendChatMessage(format(L["CooldownRemaining"], spellLink, GetRemainTime(remain)), msgChannel())
	else
		SendChatMessage(format(L["CooldownCompleted"], spellLink), msgChannel())
	end
end

function M:SendCurrentItem(thisTime, itemID, itemLink)
	local start, duration = GetItemCooldown(itemID)
	if start and duration > 0 then
		local remain = start + duration - thisTime
		SendChatMessage(format(L["CooldownRemaining"], itemLink, GetRemainTime(remain)), msgChannel())
	else
		SendChatMessage(format(L["CooldownCompleted"], itemLink), msgChannel())
	end
end

function M:AnalyzeButtonCooldown()
	if not C.db["Misc"]["SendActionCD"] then return end
	if not IsInGroup() then return end

	local thisTime = GetTime()
	if thisTime - lastCDSend < 1.5 then return end
	lastCDSend = thisTime

	local spellType, id = GetActionInfo(self.action)
	if spellType == "spell" then
		M:SendCurrentSpell(thisTime, id)
	elseif spellType == "item" then
		local itemName, itemLink = GetItemInfo(id)
		M:SendCurrentItem(thisTime, id, itemLink or itemName)
	elseif spellType == "macro" then
		local spellID = GetMacroSpell(id)
		local _, itemLink = GetMacroItem(id)
		local itemID = itemLink and GetItemInfoFromHyperlink(itemLink)
		if spellID then
			M:SendCurrentSpell(thisTime, spellID)
		elseif itemID then
			M:SendCurrentItem(thisTime, itemID, itemLink)
		end
	end
end

function M:SendCDStatus()
	if not C.db["Actionbar"]["Enable"] then return end

	local Bar = B:GetModule("Actionbar")
	for _, button in pairs(Bar.buttons) do
		button:HookScript("OnMouseWheel", M.AnalyzeButtonCooldown)
	end
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
	M:CheckIncompatible()
	M:SendCDStatus()
end
M:RegisterMisc("Notifications", M.AddAlerts)