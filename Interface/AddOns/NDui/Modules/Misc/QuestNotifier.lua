local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

local debugMode = false
local completedQuest, initComplete = {}

local function acceptText(link, daily)
	if daily then
		return format("%s [%s]%s", L["AcceptQuest"], DAILY, link)
	else
		return format("%s %s", L["AcceptQuest"], link)
	end
end

local function completeText(link)
	PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "Master")
	return format("%s %s", link, QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if NDuiDB["Misc"]["OnlyCompleteRing"] then return end

	if debugMode and DB.isDeveloper then
		print(msg)
	elseif IsPartyLFG() then
		SendChatMessage(msg, "INSTANCE_CHAT")
	elseif IsInRaid() then
		SendChatMessage(msg, "RAID")
	elseif IsInGroup() and not IsInRaid() then
		SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = string.gsub(pattern, "%(", "%%%1")
	pattern = string.gsub(pattern, "%)", "%%%1")
	pattern = string.gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
end

local questMatches = {
	["Found"] = getPattern(ERR_QUEST_ADD_FOUND_SII),
	["Item"] = getPattern(ERR_QUEST_ADD_ITEM_SII),
	["Kill"] = getPattern(ERR_QUEST_ADD_KILL_SII),
	["PKill"] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = getPattern(ERR_QUEST_COMPLETE_S),
	["QuestFailed"] = getPattern(ERR_QUEST_FAILED_S),
}

local function FindQuestProgress(_, _, msg)
	for _, pattern in pairs(questMatches) do
		if msg:match(pattern) then
			local _, _, _, cur, max = string.find(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if mod(cur, floor(max/5)) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

local function FindQuestAccept(_, questLogIndex, questID)
	local title, _, _, _, _, _, frequency = GetQuestLogTitle(questLogIndex)
	local link = GetQuestLink(questID)
	if title then
		local tagID, _, worldQuestType = GetQuestTagInfo(questID)
		if tagID == 109 or worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION then return end
		sendQuestMsg(acceptText(link, frequency == LE_QUEST_FREQUENCY_DAILY))
	end
end

local function FindQuestComplete()
	for i = 1, GetNumQuestLogEntries() do
		local title, _, _, _, _, isComplete, _, questID = GetQuestLogTitle(i)
		local link = GetQuestLink(questID)
		local worldQuest = select(3, GetQuestTagInfo(questID))
		if title and isComplete and not completedQuest[questID] and not worldQuest then
			if initComplete then
				sendQuestMsg(completeText(link))
			end
			completedQuest[questID] = true
		end
	end
end

local function FindWorldQuestComplete(_, questID)
	if QuestUtils_IsQuestWorldQuest(questID) then
		local title = C_TaskQuest.GetQuestInfoByQuestID(questID)
		local link = GetQuestLink(questID)
		if title and not completedQuest[questID] then
			sendQuestMsg(completeText(link))
			completedQuest[questID] = true
		end
	end
end

function module:QuestNotifier()
	if not NDuiDB["Misc"]["QuestNotifier"] then return end
	if IsAddOnLoaded("QuestNotifier") then return end

	FindQuestComplete()
	initComplete = true

	B:RegisterEvent("QUEST_ACCEPTED", FindQuestAccept)
	B:RegisterEvent("QUEST_LOG_UPDATE", FindQuestComplete)
	B:RegisterEvent("QUEST_TURNED_IN", FindWorldQuestComplete)
	if NDuiDB["Misc"]["QuestProgress"] and not NDuiDB["Misc"]["OnlyCompleteRing"] then
		B:RegisterEvent("UI_INFO_MESSAGE", FindQuestProgress)
	end
end