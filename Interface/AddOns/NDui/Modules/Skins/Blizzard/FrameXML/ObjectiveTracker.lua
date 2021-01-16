local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b = DB.r, DB.g, DB.b
local select, pairs = select, pairs

local function reskinQuestIcon(button)
	if not button then return end
	if not button.SetNormalTexture then return end

	if not button.styled then
		button:SetSize(24, 24)
		button:SetNormalTexture("")
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		local icon = button.icon or button.Icon
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

local function reskinQuestIcons(_, block)
	reskinQuestIcon(block.itemButton)
	reskinQuestIcon(block.groupFinderButton)
end

local function reskinHeader(header)
	header.Text:SetTextColor(r, g, b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(r, g, b, .8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

local function reskinBarTemplate(bar)
	if bar.bg then return end

	B.StripTextures(bar)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetStatusBarColor(r, g, b)
	bar.bg = B.SetBD(bar)
	B:SmoothBar(bar)
end

local function reskinProgressbar(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar

	if not bar.bg then
		bar:ClearAllPoints()
		bar:SetPoint("LEFT")
		reskinBarTemplate(bar)
	end
end

local function reskinProgressbarWithIcon(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	local icon = bar.Icon

	if not bar.bg then
		bar:SetPoint("LEFT", 22, 0)
		reskinBarTemplate(bar)

		icon:SetMask(nil)
		icon.bg = B.ReskinIcon(icon, true)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 0)
		icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, 0)
	end

	if icon.bg then
		icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
	end
end

local function reskinTimerBar(_, _, line)
	local timerBar = line.TimerBar
	local bar = timerBar.Bar

	if not bar.bg then
		reskinBarTemplate(bar)
	end
end

local function updateMinimizeButton(button, collapsed)
	button.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(button)
	B.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
	hooksecurefunc(button, "SetCollapsed", updateMinimizeButton)
end

local function GetMawBuffsAnchor(frame)
	local center = frame:GetCenter()
	if center and center < GetScreenWidth()/2 then
		return "LEFT"
	else
		return "RIGHT"
	end
end

tinsert(C.defaultThemes, function()
	if IsAddOnLoaded("!KalielsTracker") then return end

	-- QuestIcons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", reskinQuestIcons)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", reskinQuestIcons)

	-- Reskin Progressbars
	BonusObjectiveTrackerProgressBar_PlayFlareAnim = B.Dummy

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)

	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)

	-- Reskin Blocks
	hooksecurefunc("ScenarioStage_CustomizeBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.SetBD(block.GlowTexture, nil, 4, -2, -4, 2)
		end
	end)

	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", function()
		local widgetContainer = ScenarioStageBlock.WidgetContainer
		if not widgetContainer then return end

		local widgetFrame = widgetContainer:GetChildren()
		if widgetFrame and widgetFrame.Frame then
			widgetFrame.Frame:SetAlpha(0)

			if widgetFrame.CurrencyContainer then -- this may be removed, needs review
				for i = 1, widgetFrame.CurrencyContainer:GetNumChildren() do
					local bu = select(i, widgetFrame.CurrencyContainer:GetChildren())
					if bu and bu.Icon and not bu.styled then
						B.ReskinIcon(bu.Icon)
						bu.styled = true
					end
				end
			end
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_ShowBlock", function()
		local block = ScenarioChallengeModeBlock
		if not block.bg then
			block.TimerBG:Hide()
			block.TimerBGBack:Hide()
			block.timerbg = B.CreateBDFrame(block.TimerBGBack, .3)
			block.timerbg:SetPoint("TOPLEFT", block.TimerBGBack, 6, -2)
			block.timerbg:SetPoint("BOTTOMRIGHT", block.TimerBGBack, -6, -5)

			block.StatusBar:SetStatusBarTexture(DB.normTex)
			block.StatusBar:SetStatusBarColor(r, g, b)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = B.SetBD(block, nil, 4, -2, -4, 0)
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_SetUpAffixes", B.AffixesSetup)

	-- Reskin Headers
	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end

	-- Minimize Button
	local mainMinimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	reskinMinimizeButton(mainMinimize)
	mainMinimize.bg:SetBackdropBorderColor(1, .8, 0, .5)

	for _, header in pairs(headers) do
		local minimize = header.MinimizeButton
		if minimize then
			reskinMinimizeButton(minimize)
		end
	end

	-- MawBuffsBlock
	ScenarioBlocksFrame.MawBuffsBlock.Container:HookScript("OnClick", function(container)
		local direc = GetMawBuffsAnchor(container)
		if not container.lastDirec or container.lastDirec ~= direc then
			container.List:ClearAllPoints()
			if direc == "LEFT" then
				container.List:SetPoint("TOPLEFT", container, "TOPRIGHT", 15, 1)
			else
				container.List:SetPoint("TOPRIGHT", container, "TOPLEFT", 15, 1)
			end
			container.lastDirec = direc
		end
	end)
end)