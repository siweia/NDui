local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

local questList = {}
local function getQuestList()
	questList = {}

	for i = 1, GetNumQuestLogEntries() do
		local title, level, _, isHeader, _, isComplete, frequency, questID = GetQuestLogTitle(i)
		if not title then break end
		if not isHeader then
			questList[questID] = {
				title = title,
				level = level,
				isComplete = isComplete,
				frequency = frequency,
				link = GetQuestLink(questID),
				object = {},
			}

			for j = 1, GetNumQuestLeaderBoards(i) do
				local text = GetQuestLogLeaderBoard(j, i)
				if text then
					local needs, object = strsplit(" ", text)
					local cur, max = strsplit("/", needs)
					if cur and max then
						questList[questID].object[j] = {
							object = object,
							cur = tonumber(cur),
							max = tonumber(max)
						}
					end
				end
			end
		end
	end

	return questList
end

local previous, current
local debugMode = false

local function acceptText(data, daily)
	if daily then
		return format("%s: [%s][%s]%s", L["AcceptQuest"], data.level, data.frequency, data.link)
	else
		return format("%s: [%s]%s", L["AcceptQuest"], data.level, data.link)
	end
end

local function progressText(data, object)
	return format("%s%s: %s %s/%s", data.link, L["Progress"], object.object, object.cur, object.max)
end

local function completeText(data)
	return format("[%s]%s %s", data.level, data.link, QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if not NDuiDB["Misc"]["QuestNotifier"] then return end

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

local function questLogUpdate()
	current = getQuestList()

	for questID, currentdata in pairs(current) do
		if previous[questID] then
			local previousData = previous[questID]
			if not previousData.isComplete then
				if currentdata.title and previousData.title then
					if currentdata.isComplete == 1 then
						sendQuestMsg(completeText(currentdata))
						PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "Master")
					elseif NDuiDB["Misc"]["QuestProgress"] then
						for i = 1, #currentdata.object do
							local previousObj = previousData.object[i]
							local currentObj = currentdata.object[i]
							if previousObj and currentObj and currentObj.cur > previousObj.cur then
								sendQuestMsg(progressText(currentdata, currentObj))
							end
						end
					end
				end
			end
		else
			sendQuestMsg(acceptText(currentdata, currentdata.frequency == LE_QUEST_FREQUENCY_DAILY))
		end
	end

	previous = current
end

function module:QuestNotifier()
	if IsAddOnLoaded("QuestNotifier") then return end

	previous = getQuestList()
	B:RegisterEvent("QUEST_LOG_UPDATE", questLogUpdate)
end