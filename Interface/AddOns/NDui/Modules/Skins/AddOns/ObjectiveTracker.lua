local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local _G = getfenv(0)
local pairs, tinsert, select = pairs, tinsert, select
local GetNumQuestLogEntries, GetQuestLogTitle, GetNumQuestWatches = GetNumQuestLogEntries, GetQuestLogTitle, GetNumQuestWatches
local IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool = IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool
local GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard = GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

local cr, cg, cb = DB.r, DB.g, DB.b
local MAX_QUESTLOG_QUESTS = MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = MAX_WATCHABLE_QUESTS or 5
local headerString = QUESTS_LABEL.." %s/%s"

local frame

function S:ExtQuestLogFrame()
	local QuestLogFrame = _G.QuestLogFrame
	if QuestLogFrame:GetWidth() > 700 then return end

	B.StripTextures(QuestLogFrame, 2)
	QuestLogFrame.TitleText = _G.QuestLogTitleText
	QuestLogFrame.scrollFrame = _G.QuestLogDetailScrollFrame
	QuestLogFrame.listScrollFrame = _G.QuestLogListScrollFrame
	S:EnlargeDefaultUIPanel("QuestLogFrame", 0)

	B.StripTextures(_G.EmptyQuestLogFrame)
	_G.QuestLogNoQuestsText:ClearAllPoints()
	_G.QuestLogNoQuestsText:SetPoint("CENTER", QuestLogFrame.listScrollFrame)
	_G.QuestFramePushQuestButton:ClearAllPoints()
	_G.QuestFramePushQuestButton:SetPoint("LEFT", _G.QuestLogFrameAbandonButton, "RIGHT", 1, 0)

	_G.QUESTS_DISPLAYED = 22
	for i = 7, _G.QUESTS_DISPLAYED do
		local button = _G["QuestLogTitle"..i]
		if not button then
			button = CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
			button:SetPoint("TOPLEFT", _G["QuestLogTitle"..(i-1)], "BOTTOMLEFT", 0, 1)
			button:SetID(i)
			button:Hide()
		end
	end

	local toggleMap = CreateFrame("Button", nil, QuestLogFrame)
	toggleMap:SetPoint("TOP", 10, -35)
	toggleMap:SetSize(48, 32)
	local text = B.CreateFS(toggleMap, 14, SHOW_MAP)
	text:ClearAllPoints()
	text:SetPoint("LEFT", toggleMap, "RIGHT")
	local tex = toggleMap:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture(316593)
	tex:SetTexCoord(.125, .875, 0, .5)
	toggleMap:SetScript("OnClick", ToggleWorldMap)
	toggleMap:SetScript("OnMouseUp", function() tex:SetTexCoord(.125, .875, 0, .5) end)
	toggleMap:SetScript("OnMouseDown", function() tex:SetTexCoord(.125, .875, .5, 1) end)

	if C.db["Skins"]["BlizzardSkins"] then
		B.CreateBDFrame(QuestLogFrame.scrollFrame, .25)
	end

	-- Move ClassicCodex
	if CodexQuest then
		local buttonShow = CodexQuest.buttonShow
		buttonShow:SetWidth(55)
		buttonShow:SetText(DB.InfoColor..SHOW)

		local buttonHide = CodexQuest.buttonHide
		buttonHide:ClearAllPoints()
		buttonHide:SetPoint("LEFT", buttonShow, "RIGHT", 5, 0)
		buttonHide:SetWidth(55)
		buttonHide:SetText(DB.InfoColor..HIDE)

		local buttonReset = CodexQuest.buttonReset
		buttonReset:ClearAllPoints()
		buttonReset:SetPoint("LEFT", buttonHide, "RIGHT", 5, 0)
		buttonReset:SetWidth(55)
		buttonReset:SetText(DB.InfoColor..RESET)
	end
end

function S:QuestLogLevel()
	local numEntries = GetNumQuestLogEntries()

	for i = 1, QUESTS_DISPLAYED, 1 do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
		if questIndex <= numEntries then
			local questLogTitle = _G["QuestLogTitle"..i]
			local questTitleTag = _G["QuestLogTitle"..i.."Tag"]
			local questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("["..level.."] "..questLogTitleText)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = .5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, .5, 1)
				end
			end

			local questText = _G["QuestLogTitle"..i.."NormalText"]
			local questCheck = _G["QuestLogTitle"..i.."Check"]
			if questText then
				local width = questText:GetStringWidth()
				if width then
					if width <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", width+22, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end

			local questNumGroupMates = _G["QuestLogTitle"..i.."GroupMates"]
			if not questNumGroupMates.anchored then
				questNumGroupMates:SetPoint("LEFT")
				questNumGroupMates.anchored = true
			end
		end
	end
end

function S:EnhancedQuestTracker()
	local header = CreateFrame("Frame", nil, frame)
	header:SetAllPoints()
	header:SetParent(QuestWatchFrame)
	header.Text = B.CreateFS(header, 16, "", true, "TOPLEFT", 0, 15)

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(cr, cg, cb, .8)
	bg:SetPoint("TOPLEFT", 0, 20)
	bg:SetSize(250, 30)

	local bu = CreateFrame("Button", nil, frame)
	bu:SetSize(20, 20)
	bu:SetPoint("TOPRIGHT", 0, 18)
	bu.collapse = false
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	if C.db["Skins"]["BlizzardSkins"] then
		bu:SetPoint("TOPRIGHT", 0, 14)
		B.ReskinCollapse(bu)
		bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	end
	bu:SetShown(GetNumQuestWatches() > 0)

	bu.Text = B.CreateFS(bu, 16, TRACKER_HEADER_OBJECTIVE, "system", "RIGHT", -24, C.db["Skins"]["BlizzardSkins"] and 3 or 0)
	bu.Text:Hide()

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		if self.collapse then
			self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			self.Text:Show()
			QuestWatchFrame:Hide()
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
			self.Text:Hide()
			if GetNumQuestWatches() > 0 then
				QuestWatchFrame:Show()
			end
		end
	end)

	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if IsShiftKeyDown() then -- untrack quest
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					tremove(QUEST_WATCH_LIST, index)
				end
			end
			RemoveQuestWatch(self.questIndex)
			QuestWatch_Update()
		else -- open to quest log
			if QuestLogEx then -- https://www.wowinterface.com/downloads/info24980-QuestLogEx.html
				ShowUIPanel(QuestLogExFrame)
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then -- https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html
				ShowUIPanel(ClassicQuestLog)
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then -- https://www.curseforge.com/wow/addons/questguru_classic
				ShowUIPanel(QuestGuru)
				QuestLog_SetSelection(self.questIndex)
			else
				ShowUIPanel(QuestLogFrame)
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue(self.questIndex*valueStep/2)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		if self.completed then
			-- use normal colors instead as highlight
			self.headerText:SetTextColor(.75, .61, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(.8, .8, .8)
			end
		else
			self.headerText:SetTextColor(1, .8, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local ClickFrames = {}
	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		if not ClickFrames[watchIndex] then
			ClickFrames[watchIndex] = CreateFrame("Frame")
			ClickFrames[watchIndex]:SetScript("OnMouseUp", onMouseUp)
			ClickFrames[watchIndex]:SetScript("OnEnter", onEnter)
			ClickFrames[watchIndex]:SetScript("OnLeave", QuestWatch_Update)
		end

		local f = ClickFrames[watchIndex]
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
	end

	hooksecurefunc("QuestWatch_Update", function()
		local numQuests = select(2, GetNumQuestLogEntries())
		header.Text:SetFormattedText(headerString, numQuests, MAX_QUESTLOG_QUESTS)

		local watchTextIndex = 1
		local numWatches = GetNumQuestWatches()
		for i = 1, numWatches do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local numObjectives = GetNumQuestLeaderBoards(questIndex)
				if numObjectives > 0 then
					local headerText = _G["QuestWatchLine"..watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						_G["QuestWatchLine"..watchTextIndex]:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						tinsert(objectivesGroup, _G["QuestWatchLine"..watchTextIndex])
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end
		-- hide/show frames so it doesnt eat clicks, since we cant parent to a FontString
		for _, frame in pairs(ClickFrames) do
			frame[GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide"](frame)
		end

		bu:SetShown(numWatches > 0)
		if bu.collapse then QuestWatchFrame:Hide() end
	end)

	local function autoQuestWatch(_, questIndex)
		-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
		-- calling AddQuestWatch() while on the max watch limit silently fails
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
		end
	end
	B:RegisterEvent("QUEST_ACCEPTED", autoQuestWatch)
end

function S:QuestTracker()
	-- Mover for quest tracker
	frame = CreateFrame("Frame", "NDuiQuestMover", UIParent)
	frame:SetSize(240, 50)
	B.Mover(frame, L["QuestTracker"], "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -70, -55})

	--QuestWatchFrame:SetHeight(GetScreenHeight()*.65)
	QuestWatchFrame:SetClampedToScreen(false)
	QuestWatchFrame:SetMovable(true)
	QuestWatchFrame:SetUserPlaced(true)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame, 5, -5)
		end
	end)

	local timerMover = CreateFrame("Frame", "NDuiQuestTimerMover", UIParent)
	timerMover:SetSize(150, 30)
	B.Mover(timerMover, QUEST_TIMERS, "QuestTimer", {"TOPRIGHT", frame, "TOPLEFT", -10, 0})

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(self, _, parent)
		if parent ~= timerMover then
			self:ClearAllPoints()
			self:SetPoint("TOP", timerMover)
		end
	end)

	if not C.db["Skins"]["QuestTracker"] then return end

	S:EnhancedQuestTracker()
	S:ExtQuestLogFrame()
	hooksecurefunc("QuestLog_Update", S.QuestLogLevel)
end