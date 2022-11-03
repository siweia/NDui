local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, strfind = pairs, strfind
local UnitGUID, GetItemCount = UnitGUID, GetItemCount
local GetActionInfo, GetSpellInfo, GetOverrideBarSkin = GetActionInfo, GetSpellInfo, GetOverrideBarSkin
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_GossipInfo_SelectOption, C_GossipInfo_GetNumOptions = C_GossipInfo.SelectOption, C_GossipInfo.GetNumOptions

local watchQuests = {
	-- check npc
	[60739] = true, -- https://www.wowhead.com/quest=60739/tough-crowd
	[62453] = true, -- https://www.wowhead.com/quest=62453/into-the-unknown
	-- glow
	[59585] = true, -- https://www.wowhead.com/quest=59585/well-make-an-aspirant-out-of-you
	[64271] = true, -- https://www.wowhead.com/quest=64271/a-more-civilized-way
}
local activeQuests = {}

local questNPCs = {
	[170080] = true, -- Boggart
	[174498] = true, -- Shimmersod
}

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

	-- Override button quests
	if C.db["Actionbar"]["Enable"] then
		B:RegisterEvent("CHAT_MSG_MONSTER_SAY", M.QuestTool_SetGlow)
		B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", M.QuestTool_ClearGlow)
	end

	-- Check npc in quests
	if DB.isBeta then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, M.QuestTool_SetQuestUnit)
	else
		GameTooltip:HookScript("OnTooltipSetUnit", M.QuestTool_SetQuestUnit)
	end

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