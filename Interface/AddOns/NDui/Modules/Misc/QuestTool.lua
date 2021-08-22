local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, strfind = pairs, strfind
local GetActionInfo, GetSpellInfo, GetOverrideBarSkin = GetActionInfo, GetSpellInfo, GetOverrideBarSkin
local ClearOverrideBindings, SetOverrideBindingClick, InCombatLockdown = ClearOverrideBindings, SetOverrideBindingClick, InCombatLockdown
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID

local watchQuests = {
	-- glow
	[59585] = true, -- https://www.wowhead.com/quest=59585/well-make-an-aspirant-out-of-you
	[64271] = true, -- https://www.wowhead.com/quest=64271/a-more-civilized-way
	-- mousewheel
	[64018] = true, -- https://www.wowhead.com/quest=64018/the-weight-of-stone
}
local activeQuests = {}

local function GetActionSpell(index)
	local button = _G["ActionButton"..index]
	local _, spellID = GetActionInfo(button.action)
	return spellID
end

local function GetOverrideButton(index)
	return "OverrideActionBarButton"..index
end

function M:QuestTool_Init()
	for questID in pairs(watchQuests) do
		if C_QuestLog_GetLogIndexForQuestID(questID) then
			activeQuests[questID] = true
		end
	end
end

function M:QuestTool_Accept(questID)
	if watchQuests[questID] then
		activeQuests[questID] = true
	end
end

function M:QuestTool_Remove(questID)
	if watchQuests[questID] then
		activeQuests[questID] = nil
	end
end

function M:QuestTool_Set()
	if activeQuests[64018] and GetActionSpell(1) == 356464 then
		if InCombatLockdown() then
			B:RegisterEvent("PLAYER_REGEN_ENABLED", M.QuestTool_Set)
			M.isDelay = true
		else
			M.isHandling = true

			ClearOverrideBindings(M.QuestHandler)
			SetOverrideBindingClick(M.QuestHandler, true, "MOUSEWHEELUP", GetOverrideButton(1))
			SetOverrideBindingClick(M.QuestHandler, true, "MOUSEWHEELDOWN", GetOverrideButton(2))
			M.QuestTip:SetText("靠近蓝圈时滚轮上，滚近红圈时滚轮下。用力滚！")
			M.QuestTip:Show()

			if M.isDelay then
				B:UnrgisterEvent("PLAYER_REGEN_ENABLED", M.QuestTool_Set)
				M.isDelay = nil
			end
		end
	end
end

function M:QuestTool_Clear()
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

function M:QuestTool()
	if not C.db["Actionbar"]["Enable"] then return end

	local handler = CreateFrame("Frame", nil, UIParent)
	M.QuestHandler = handler

	local text = B.CreateFS(handler, 20)
	text:ClearAllPoints()
	text:SetPoint("TOP", UIParent, 0, -250)
	text:Hide()
	M.QuestTip = text

	-- Check existing quests
	M:QuestTool_Init()
	B:RegisterEvent("QUEST_ACCEPTED", M.QuestTool_Accept)
	B:RegisterEvent("QUEST_REMOVED", M.QuestTool_Remove)

	-- Vehicle button quests
	M.QuestTool_Set() -- may need this for ui reload
	B:RegisterEvent("UNIT_ENTERED_VEHICLE", M.QuestTool_Set)
	B:RegisterEvent("UNIT_EXITED_VEHICLE", M.QuestTool_Clear)

	-- Override button quests
	B:RegisterEvent("CHAT_MSG_MONSTER_SAY", M.QuestTool_SetGlow)
	B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", M.QuestTool_ClearGlow)
end

M:RegisterMisc("QuestTool", M.QuestTool)