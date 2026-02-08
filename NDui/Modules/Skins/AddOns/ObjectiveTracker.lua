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
local QUESTS_DISPLAYED = QUESTS_DISPLAYED or 22
local MAX_QUESTLOG_QUESTS = MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = MAX_WATCHABLE_QUESTS or 5
local headerString = QUESTS_LABEL.." %s/%s"

local frame

function S:ExtQuestLogFrame()
	-- Move ClassicCodex
	if CodexQuest then
		local buttonShow = CodexQuest.buttonShow
		if not buttonShow then return end
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
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogListScrollFrame)
	local buttons = QuestLogListScrollFrame.buttons

	local questIndex, questLogTitle, questTitleTag, questNumGroupMates, questNormalText, questCheck
	local questLogTitleText, level, isHeader, isComplete

	for i = 1, QUESTS_DISPLAYED, 1 do
		questLogTitle = buttons[i]
		if not questLogTitle then break end -- precaution for other addons

		questIndex = i + scrollOffset
		questTitleTag = questLogTitle.tag
		questNumGroupMates = questLogTitle.groupMates
		questNormalText = questLogTitle.normalText
		questCheck = questLogTitle.check

		if questIndex <= numEntries then
			questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("["..level.."] "..questLogTitleText)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = .5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, .5, 1)
				end
			end

			if questNormalText then
				questNormalText:SetWidth(questNormalText:GetWidth() + 30)
				local width = questNormalText:GetStringWidth()
				if width then
					if width <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", width+22, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end

			if not questNumGroupMates.anchored then
				questNumGroupMates:SetPoint("LEFT")
				questNumGroupMates.anchored = true
			end
		end
	end
end

local function updateMinimizeButton(self)
	WatchFrameCollapseExpandButton.__texture:DoCollapse(self.collapsed)
	WatchFrame.header:SetShown(not self.collapsed)
end

local function reskinMinimizeButton(button)
	B.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
end

local function reskinQuestIcon(button)
	if not button then return end
	if not button.SetNormalTexture then return end

	if not button.styled then
		button:SetSize(24, 24)
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		local icon = _G[button:GetName().."IconTexture"]
		if icon then
			button.bg = B.ReskinIcon(icon, true)
			icon:SetInside()
		end

		button.styled = true
	end

	if button.bg then
		button.bg:SetFrameLevel(0)
	end
end

function S:QuestTracker()
	-- Mover for quest tracker
	frame = CreateFrame("Frame", "NDuiQuestMover", UIParent)
	frame:SetSize(240, 50)
	B.Mover(frame, L["QuestTracker"], "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -70, -55})

	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", frame)
	WatchFrame:SetClampedToScreen(false)
	WatchFrame:SetHeight(GetScreenHeight()*.65)

	hooksecurefunc(WatchFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)

	hooksecurefunc("WatchFrameItem_UpdateCooldown", function(button)
		reskinQuestIcon(button)
	end)

	reskinMinimizeButton(WatchFrameCollapseExpandButton)
	hooksecurefunc("WatchFrame_Collapse", updateMinimizeButton)
	hooksecurefunc("WatchFrame_Expand", updateMinimizeButton)

	local header = CreateFrame("Frame", nil, WatchFrameHeader)
	header:SetSize(1, 1)
	header:SetPoint("TOPLEFT")
	WatchFrame.header = header

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(cr, cg, cb, .8)
	bg:SetPoint("TOPLEFT", -25, 5)
	bg:SetSize(250, 30)

	if not C.db["Skins"]["QuestTracker"] then return end

	S:ExtQuestLogFrame()
	hooksecurefunc("QuestLog_Update", S.QuestLogLevel)
	hooksecurefunc(QuestLogListScrollFrame, "update", S.QuestLogLevel)

	-- Extend the wrap text on WatchFrame, needs review
	hooksecurefunc("WatchFrame_SetLine", function(line)
		if not line.text then return end

		local height = line:GetHeight()
		if height > 28 and height < 34 then
			line:SetHeight(34)
			line.text:SetHeight(34)
		end
	end)

	-- Allow to send quest name
	hooksecurefunc("WatchFrameLinkButtonTemplate_OnClick", function(self)
		if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
			if self.type == "QUEST" then
				local name, level = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
				if name then
					ChatEdit_InsertLink("["..name.."]")
				end
			end
		end
	end)
end