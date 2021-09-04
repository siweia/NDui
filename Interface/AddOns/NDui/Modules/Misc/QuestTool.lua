local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, strfind = pairs, strfind
local UnitGUID, InCombatLockdown, IsResting = UnitGUID, InCombatLockdown, IsResting
local GetActionInfo, GetSpellInfo, GetOverrideBarSkin = GetActionInfo, GetSpellInfo, GetOverrideBarSkin
local ClearOverrideBindings, SetOverrideBindingClick, SetBinding = ClearOverrideBindings, SetOverrideBindingClick, SetBinding
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetDistanceSqToQuest = C_QuestLog.GetDistanceSqToQuest
local C_GossipInfo_SelectOption, C_GossipInfo_GetNumOptions = C_GossipInfo.SelectOption, C_GossipInfo.GetNumOptions

local watchQuests = {
	-- check npc
	[60739] = true, -- https://www.wowhead.com/quest=60739/tough-crowd
	[62453] = true, -- https://www.wowhead.com/quest=62453/into-the-unknown
	-- glow
	[59585] = true, -- https://www.wowhead.com/quest=59585/well-make-an-aspirant-out-of-you
	[64271] = true, -- https://www.wowhead.com/quest=64271/a-more-civilized-way
	-- mousewheel
	[60657] = 333960, -- https://www.wowhead.com/quest=60657/aid-from-above
	[64018] = 356464, -- https://www.wowhead.com/quest=64018/the-weight-of-stone
	-- others
	[62459] = true, -- https://www.wowhead.com/quest=62459/go-beyond -- questItem = 183725
}
local activeQuests = {}

local questNPCs = {
	[170080] = true, -- Boggart
	[174498] = true, -- Shimmersod
}

function M:GetOverrideIndex(spellID)
	if spellID == 356464 then
		return 1, 2
	elseif spellID == 356151 or spellID == 333960 then
		return 1
	end
end

local function GetActionSpell(index)
	local button = _G["ActionButton"..index]
	local _, spellID = GetActionInfo(button.action)
	return spellID
end

local function GetOverrideButton(index)
	return "OverrideActionBarButton"..index
end

function M:QuestTool_Init()
	for questID, value in pairs(watchQuests) do
		if C_QuestLog_GetLogIndexForQuestID(questID) then
			activeQuests[questID] = value
		end
	end
end

function M:QuestTool_Accept(questID)
	if watchQuests[questID] then
		activeQuests[questID] = watchQuests[questID]
	end
end

function M:QuestTool_Remove(questID)
	if watchQuests[questID] then
		activeQuests[questID] = nil
	end
end

function M:QuestTool_IsMatch(questID, spellID)
	return activeQuests[questID] == spellID
end

function M:QuestTool_SetAction()
	local spellID = GetActionSpell(1)
	if M:QuestTool_IsMatch(60657, spellID) or M:QuestTool_IsMatch(64018, spellID) or spellID == 356151 then
		if InCombatLockdown() then
			B:RegisterEvent("PLAYER_REGEN_ENABLED", M.QuestTool_SetAction)
			M.isDelay = true
		else
			local index1, index2 = M:GetOverrideIndex(spellID)
			if index1 then
				ClearOverrideBindings(M.QuestHandler)
				SetOverrideBindingClick(M.QuestHandler, true, "MOUSEWHEELUP", GetOverrideButton(index1))
				if index2 then
					SetOverrideBindingClick(M.QuestHandler, true, "MOUSEWHEELDOWN", GetOverrideButton(index2))
				end

				M.QuestTip:SetText(DB.NDuiString.." "..L["SpellTip"..spellID])
				M.QuestTip:Show()
				M.isHandling = true

				if M.isDelay then
					B:UnregisterEvent("PLAYER_REGEN_ENABLED", M.QuestTool_SetAction)
					M.isDelay = nil
				end
			end
		end
	end
end

function M:QuestTool_ClearAction()
	if M.isHandling then
		M.isHandling = nil
		ClearOverrideBindings(M.QuestHandler)
		M.QuestTip:Hide()
	end
end

local fixedStrings = {
	["横扫"] = "低扫",
	["突刺"] = "突袭",
}
local function isActionMatch(msg, text)
	return text and strfind(msg, text)
end

function M:QuestTool_SetGlow(msg)
	if GetOverrideBarSkin() and (activeQuests[59585] or activeQuests[64271]) then
		for i = 1, 3 do
			local button = _G["ActionButton"..i]
			local _, spellID = GetActionInfo(button.action)
			local name = spellID and GetSpellInfo(spellID)
			if fixedStrings[name] and isActionMatch(msg, fixedStrings[name]) or isActionMatch(msg, name) then
				B.ShowOverlayGlow(button)
			else
				B.HideOverlayGlow(button)
			end
		end
		M.isGlowing = true
	else
		M:QuestTool_ClearGlow()
	end
end

function M:QuestTool_ClearGlow()
	if M.isGlowing then
		M.isGlowing = nil
		for i = 1, 3 do
			B.HideOverlayGlow(_G["ActionButton"..i])
		end
	end
end

function M:QuestTool_SetQuestUnit()
	if not activeQuests[60739] and not activeQuests[62453] then return end

	local guid = UnitGUID("mouseover")
	local npcID = guid and B.GetNPCID(guid)
	if questNPCs[npcID] then
		self:AddLine(L["NPCisTrue"])
	end
end

function M:QuestTool_UpdateBinding()
	if activeQuests[62459] and not IsResting() and C_QuestLog_GetDistanceSqToQuest(62459) < 35000 then
		SetBinding("MOUSEWHEELUP", "EXTRAACTIONBUTTON1")
		M.isBinding = true
		M.QuestTip:SetText(DB.NDuiString.." "..L["CatchButterfly"])
		M.QuestTip:Show()
	elseif M.isBinding then
		SetBinding("MOUSEWHEELUP", M.SavedKey)
		M.isBinding = nil
		M.QuestTip:Hide()
	end
end

function M:QuestTool()
	if not C.db["Misc"]["QuestTool"] then return end

	local handler = CreateFrame("Frame", nil, UIParent)
	M.QuestHandler = handler

	local text = B.CreateFS(handler, 20)
	text:ClearAllPoints()
	text:SetPoint("TOP", UIParent, 0, -200)
	text:SetWidth(800)
	text:SetWordWrap(true)
	text:Hide()
	M.QuestTip = text

	-- Check existing quests
	M:QuestTool_Init()
	B:RegisterEvent("QUEST_ACCEPTED", M.QuestTool_Accept)
	B:RegisterEvent("QUEST_REMOVED", M.QuestTool_Remove)

	-- Vehicle button quests
	C_Timer.After(10, M.QuestTool_SetAction) -- may need this for ui reload
	B:RegisterEvent("UNIT_ENTERED_VEHICLE", M.QuestTool_SetAction)
	B:RegisterEvent("UNIT_EXITED_VEHICLE", M.QuestTool_ClearAction)

	-- Override button quests
	if C.db["Actionbar"]["Enable"] then
		B:RegisterEvent("CHAT_MSG_MONSTER_SAY", M.QuestTool_SetGlow)
		B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", M.QuestTool_ClearGlow)
	end

	-- Check npc in quests
	GameTooltip:HookScript("OnTooltipSetUnit", M.QuestTool_SetQuestUnit)

	-- Quest items
	M.SavedKey = GetBindingFromClick("MOUSEWHEELUP")
	M:QuestTool_UpdateBinding()
	B:RegisterEvent("ZONE_CHANGED", M.QuestTool_UpdateBinding)
	B:RegisterEvent("ZONE_CHANGED_INDOORS", M.QuestTool_UpdateBinding)

	-- Auto gossip
	local firstStep
	B:RegisterEvent("GOSSIP_SHOW", function()
		local guid = UnitGUID("npc")
		local npcID = guid and B.GetNPCID(guid)
		if npcID == 174498 then
			C_GossipInfo_SelectOption(3)
		elseif npcID == 174371 then
			if GetItemCount(183961) == 0 then return end
			if C_GossipInfo_GetNumOptions() ~= 5 then return end
			if firstStep then
				C_GossipInfo_SelectOption(5)
			else
				C_GossipInfo_SelectOption(2)
				firstStep = true
			end
		end
	end)
end

M:RegisterMisc("QuestTool", M.QuestTool)