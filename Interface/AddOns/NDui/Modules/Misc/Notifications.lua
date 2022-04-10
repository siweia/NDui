local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local format, gsub, strsplit = string.format, string.gsub, string.split
local pairs, tonumber, select = pairs, tonumber, select
local IsInRaid, IsInGroup, IsInInstance, IsInGuild = IsInRaid, IsInGroup, IsInInstance, IsInGuild
local UnitInRaid, UnitInParty, SendChatMessage = UnitInRaid, UnitInParty, SendChatMessage
local UnitName, Ambiguate, GetTime = UnitName, Ambiguate, GetTime
local GetSpellLink, GetSpellInfo, GetSpellCooldown = GetSpellLink, GetSpellInfo, GetSpellCooldown
local GetActionInfo, GetMacroSpell, GetMacroItem = GetActionInfo, GetMacroSpell, GetMacroItem
local GetItemInfo, GetItemInfoFromHyperlink = GetItemInfo, GetItemInfoFromHyperlink
local UnitInBattleground, GetMinimapZoneText = UnitInBattleground, GetMinimapZoneText
local AuraUtil_FindAuraByName = AuraUtil.FindAuraByName
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix

--[[
	闭上你的嘴！
	打断、偷取及驱散法术时的警报
]]
local function msgChannel()
	return UnitInBattleground("player") and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
end

local infoType = {}
local MyGUID = UnitGUID("player")

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
	[(GetSpellInfo(99))] = true,		-- 夺魂咆哮
	[(GetSpellInfo(122))] = true,		-- 冰霜新星
	[(GetSpellInfo(1776))] = true,		-- 凿击
	[(GetSpellInfo(1784))] = true,		-- 潜行
	[(GetSpellInfo(5246))] = true,		-- 破胆怒吼
	[(GetSpellInfo(8122))] = true,		-- 心灵尖啸
	[(GetSpellInfo(31661))] = true,		-- 龙息术
	[(GetSpellInfo(33395))] = true,		-- 冰冻术
}

local LOCspells = {
	[(GetSpellInfo(853))] = true, 		-- 制裁之锤
	[(GetSpellInfo(1776))] = true, 		-- 凿击
	[(GetSpellInfo(2070))] = true,		-- 闷棍
	[(GetSpellInfo(2094))] = true, 		-- 致盲
	[(GetSpellInfo(5246))] = true, 		-- 破胆怒吼
	[(GetSpellInfo(5782))] = true, 		-- 恐惧
	[(GetSpellInfo(8122))] = true, 		-- 心灵尖啸
	[(GetSpellInfo(14308))] = true,		-- 冰冻陷阱
	[(GetSpellInfo(15487))] = true,		-- 沉默
	[(GetSpellInfo(19386))] = true, 	-- 翼龙钉刺
	[(GetSpellInfo(19503))] = true, 	-- 驱散射击
	[(GetSpellInfo(20066))] = true, 	-- 忏悔
	[(GetSpellInfo(34490))] = true, 	-- 沉默射击
}

function M:IsAllyPet(sourceFlags)
	if DB:IsMyPet(sourceFlags) or sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags then
		return true
	end
end

function M:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, spellID, spellName, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then return end

	if C.db["Misc"]["LoCAlert"] and eventType == "SPELL_AURA_APPLIED" and LOCspells[spellName] and destGUID == MyGUID then
		local duration = select(5, AuraUtil_FindAuraByName(spellName, "player", "HARMFUL"))
		if duration > 1.5 then
			SendChatMessage(format(L["LossControl"], sourceName..GetSpellLink(spellID), destName, duration, GetMinimapZoneText()), msgChannel())
		end
	elseif UnitInRaid(sourceName) or UnitInParty(sourceName) or M:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			local sourceSpellID, destSpellID
			if infoText == L["BrokenSpell"] then
				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellName] then return end
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
	if IsInGroup() and (not C.db["Misc"]["InstAlertOnly"] or IsInInstance()) then
		B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	else
		B:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", M.InterruptAlert_Update)
	end
end

function M:InterruptAlert()
	M:InterruptAlert_Toggle()

	if M:InterruptAlert_IsEnabled() or C.db["Misc"]["LoCAlert"] then
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
function M:VersionCheck_Compare(new, old)
	local new1, new2 = strsplit(".", new)
	new1, new2 = tonumber(new1), tonumber(new2)
	if new1 > 2 then new1, new2 = 0, 0 end

	local old1, old2 = strsplit(".", old)
	old1, old2 = tonumber(old1), tonumber(old2)
	if old1 > 2 then old1, old2 = 0, 0 end

	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

local hasChecked
function M:VersionCheck_Initial()
	if not hasChecked then
		if M:VersionCheck_Compare(NDuiADB["DetectVersion"], DB.Version) == "IsNew" then
			local release = gsub(NDuiADB["DetectVersion"], "(%d+)$", "0")
			B:ShowHelpTip(ChatFrame1, format(L["Outdated NDui"], release), "TOP", 0, 70, nil, "Version")
		end

		hasChecked = true
	end
end

local lastTime = 0
function M:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "NDuiVersionCheck" then return end
	if Ambiguate(author, "none") == DB.MyName then return end

	local status = M:VersionCheck_Compare(msg, NDuiADB["DetectVersion"])
	if status == "IsNew" then
		NDuiADB["DetectVersion"] = msg
	elseif status == "IsOld" then
		if GetTime() - lastTime > 10 then
			C_ChatInfo_SendAddonMessage("NDuiVersionCheck", NDuiADB["DetectVersion"], distType)
			lastTime = GetTime()
		end
	end

	M:VersionCheck_Initial()
end

local prevTime = 0
function M:VersionCheck_UpdateGroup()
	if not IsInGroup() or (GetTime()-prevTime < 30) then return end
	prevTime = GetTime()
	C_ChatInfo_SendAddonMessage("NDuiVersionCheck", DB.Version, msgChannel())
end

function M:VersionCheck()
	hasChecked = not NDuiADB["VersionCheck"]

	B:RegisterEvent("CHAT_MSG_ADDON", self.VersionCheck_Update)

	M:VersionCheck_Initial()
	C_ChatInfo_RegisterAddonMessagePrefix("NDuiVersionCheck")
	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("NDuiVersionCheck", DB.Version, "GUILD")
	end

	self:VersionCheck_UpdateGroup()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", self.VersionCheck_UpdateGroup)
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

-- Incompatible check
local IncompatibleAddOns = {
	["!!!163UI!!!"] = true,
	["BigFoot"] = true,
	["_ShiGuang"] = true,
	["Aurora"] = true,
	["AuroraClassic"] = true,
	["ClassicQuestLog"] = true,
	["QuestGuru"] = true,
	["QuestLogEx"] = true,
	["SexyMap"] = true,
	["TrackingEye"] = true,
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
	local spellName = GetSpellInfo(spellID)
	if start and duration > 0 then
		local remain = start + duration - thisTime
		SendChatMessage(format(L["CooldownRemaining"], spellName, GetRemainTime(remain)), msgChannel())
	else
		SendChatMessage(format(L["CooldownCompleted"], spellName), msgChannel())
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
		button:SetScript("OnMouseWheel", M.AnalyzeButtonCooldown)
	end
end

-- Init
function M:AddAlerts()
	M:InterruptAlert()
	M:VersionCheck()
	M:PlacedItemAlert()
	M:CheckIncompatible()
	M:SendCDStatus()
end
M:RegisterMisc("Alerts", M.AddAlerts)