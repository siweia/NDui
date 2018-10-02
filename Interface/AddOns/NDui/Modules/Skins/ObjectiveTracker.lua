local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")
local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b

local tracker = ObjectiveTrackerFrame
local minimize = tracker.HeaderMenu.MinimizeButton

do
	-- Move Tracker Frame
	local mover = CreateFrame("Frame", "NDuiQuestMover", tracker)
	mover:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -60, -25)
	mover:SetSize(50, 50)
	B.CreateMF(minimize, mover)
	minimize:SetFrameStrata("HIGH")
	minimize:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Toggle"], 1, .8, 0)
		GameTooltip:Show()
	end)
	minimize:HookScript("OnLeave", GameTooltip_Hide)

	hooksecurefunc(tracker, "SetPoint", function(_, _, parent)
		if parent ~= mover then
			tracker:ClearAllPoints()
			tracker:SetPoint("TOPRIGHT", mover, "CENTER", 15, 15)
			tracker:SetHeight(GetScreenHeight() - 400)
		end
	end)
end

function module:QuestTracker()
	-- Questblock click enhant
	local function QuestHook(id)
		local questLogIndex = GetQuestLogIndexByID(id)
		if IsControlKeyDown() and CanAbandonQuest(id) then
			QuestMapQuestOptions_AbandonQuest(id)
		elseif IsAltKeyDown() and GetQuestLogPushable(questLogIndex) then
			QuestMapQuestOptions_ShareQuest(id)
		end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(_, block) QuestHook(block.id) end)
	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) QuestHook(self.questID) end)

	-- Show quest color and level
	local function Showlevel(_, _, _, title, level, _, isHeader, _, isComplete, frequency, questID)
		if ENABLE_COLORBLIND_MODE == "1" then return end

		for button in pairs(QuestScrollFrame.titleFramePool.activeObjects) do
			if title and not isHeader and button.questID == questID then
				local title = "["..level.."] "..title
				if isComplete then
					title = "|cffff78ff"..title
				elseif frequency == LE_QUEST_FREQUENCY_DAILY then
					title = "|cff3399ff"..title
				end
				button.Text:SetText(title)
				button.Text:SetPoint("TOPLEFT", 24, -5)
				button.Text:SetWidth(205)
				button.Text:SetWordWrap(false)
				button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth(), 0)
			end
		end
	end
	hooksecurefunc("QuestLogQuests_AddQuestButton", Showlevel)
end