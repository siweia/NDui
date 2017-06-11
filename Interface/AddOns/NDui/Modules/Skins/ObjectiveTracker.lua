local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")
local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b

local tracker = ObjectiveTrackerFrame
local minimize = tracker.HeaderMenu.MinimizeButton

do
	-- Move Tracker Frame
	local Mover = CreateFrame("Frame", "NDuiQuestMover", tracker)
	Mover:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -30, -25)
	Mover:SetSize(50, 50)
	B.CreateMF(minimize, Mover)
	minimize:SetFrameStrata("HIGH")
	minimize:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Toggle"], 1, .8, 0)
		GameTooltip:Show()
	end)
	minimize:HookScript("OnLeave", GameTooltip_Hide)

	hooksecurefunc(tracker, "SetPoint", function(_, _, parent)
		if parent ~= Mover then
			tracker:ClearAllPoints()
			tracker:SetPoint("TOPRIGHT", Mover, "CENTER", 15, 15)
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
	hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(self, block) QuestHook(block.id) end)
	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) QuestHook(self.questID) end)

	-- Show quest color and level
	local function Showlevel()
		if ENABLE_COLORBLIND_MODE == "1" then return end
		local numEntries = GetNumQuestLogEntries()
		local titleIndex = 1
		for i = 1, numEntries do
			local title, level, _, isHeader, _, isComplete, frequency, questID = GetQuestLogTitle(i)
			local titleButton = QuestLogQuests_GetTitleButton(titleIndex)
			if title and (not isHeader) and titleButton.questID == questID then
				titleButton.Check:SetPoint("LEFT", titleButton.Text, titleButton.Text:GetWrappedWidth() + 2, 0)
				titleIndex = titleIndex + 1
				local text = "["..level.."] "..title
				if isComplete then
					text = "|cffff78ff"..text
				elseif frequency == LE_QUEST_FREQUENCY_DAILY then
					text = "|cff3399ff"..text
				end
				titleButton.Text:SetText(text)
				titleButton.Text:SetPoint("TOPLEFT", 24, -5)
				titleButton.Text:SetWidth(216)
				titleButton.Text:SetWordWrap(false)
			end
		end
	end
	hooksecurefunc("QuestLogQuests_Update", Showlevel)

	-- ObjectiveTracker Skin
	if not NDuiDB["Skins"]["TrackerSkin"] then return end

	-- Reskin QuestIcons
	local function reskinQuestIcon(self, block)
		local itemButton = block.itemButton
		if itemButton and not itemButton.styled then
			itemButton:SetNormalTexture("")
			itemButton:SetPushedTexture("")
			itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
			itemButton.icon:SetTexCoord(unpack(DB.TexCoord))
			B.CreateSD(itemButton, 3, 3)

			itemButton.styled = true
		end

		local rightButton = block.rightButton
		if rightButton and not rightButton.styled then
			rightButton:SetNormalTexture("")
			rightButton:SetPushedTexture("")
			rightButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
			local bg = B.CreateBG(rightButton, 3)
			B.CreateBD(bg)
			rightButton:SetSize(22, 22)
			rightButton.Icon:SetParent(bg)
			rightButton.Icon:SetSize(18, 18)

			rightButton.styled = true
		end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", reskinQuestIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcon)

	-- Reskin Headers
	local function reskinHeader(header)
		header.Text:SetTextColor(r, g, b)
		header.Background:Hide()
		local bg = header:CreateTexture(nil, "ARTWORK")
		bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
		bg:SetTexCoord(0, .66, 0, .31)
		bg:SetVertexColor(r, g, b, .8)
		bg:SetPoint("BOTTOMLEFT", -30, -4)
		bg:SetSize(250, 30)
	end

	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
	}
	for _, header in pairs(headers) do reskinHeader(header) end

	-- Reskin Progressbars
	local function reskinProgressbar(self, block, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar
		local icon = bar.Icon

		if not bar.styled then
			bar.BarFrame:Hide()
			bar.BarFrame2:Hide()
			bar.BarFrame3:Hide()
			bar.BarBG:Hide()
			bar.BarGlow:Hide()
			bar.IconBG:SetTexture("")

			bar:SetPoint("LEFT", 22, 0)
			bar:SetStatusBarTexture(DB.normTex)
			bar:SetStatusBarColor(r*.8, g*.8, b*.8)
			local bg = B.CreateBG(bar, 3)
			B.CreateBD(bg)
			B.CreateTex(bg)
			if bar.AnimIn then	-- Fix bg opacity
				bar.AnimIn:HookScript("OnFinished", function() bg:SetBackdropColor(0, 0, 0, .5) end)
			end

			icon:SetMask(nil)
			icon:SetTexCoord(unpack(DB.TexCoord))
			B.CreateSD(icon, 3, 3)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 1)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, -1)

			bar.styled = true
		end

		icon.Shadow:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
	end
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", function(self, block, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar

		if not bar.styled then
			bar:ClearAllPoints()
			bar:SetPoint("LEFT")
			for i = 1, 6 do
				select(i, bar:GetRegions()):Hide()
			end
			bar:SetStatusBarTexture(DB.normTex)
			bar.Label:Show()
			local oldBg = select(5, bar:GetRegions())
			local bg = B.CreateBG(oldBg, 3)
			B.CreateBD(bg)
			B.CreateTex(bg)

			bar.styled = true
		end
	end)

	-- Reskin Blocks
	hooksecurefunc("ScenarioStage_CustomizeBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.CreateBG(block.GlowTexture)
			B.CreateBD(block.bg)
			B.CreateTex(block.bg)
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_ShowBlock", function()
		local block = ScenarioChallengeModeBlock
		if not block.bg then
			block.TimerBG:Hide()
			block.TimerBGBack:Hide()
			block.timerbg = B.CreateBG(block.TimerBGBack)
			block.timerbg:SetPoint("TOPLEFT", block.TimerBGBack, 5, -1)
			block.timerbg:SetPoint("BOTTOMRIGHT", block.TimerBGBack, -5, -6)
			B.CreateBD(block.timerbg, .3)

			block.StatusBar:SetStatusBarTexture(DB.normTex)
			block.StatusBar:SetStatusBarColor(r*.8, g*.8, b*.8)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = B.CreateBG(block)
			block.bg:SetPoint("TOPLEFT", 2, 0)
			B.CreateBD(block.bg)
			B.CreateTex(block.bg)
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_SetUpAffixes", function(block)
		for i, frame in ipairs(block.Affixes) do
			frame.Border:Hide()
			frame.Portrait:SetTexture(nil)
			frame.Portrait:SetTexCoord(unpack(DB.TexCoord))
			B.CreateSD(frame.Portrait, 3, 3)

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
		end
	end)

	-- Minimize Button
	if IsAddOnLoaded("Aurora") then
		local F = unpack(Aurora)
		F.ReskinExpandOrCollapse(minimize)
		minimize:SetSize(18, 18)
		minimize.plus:Hide()
		hooksecurefunc("ObjectiveTracker_Collapse", function() minimize.plus:Show() end)
		hooksecurefunc("ObjectiveTracker_Expand", function() minimize.plus:Hide() end)
	end
end