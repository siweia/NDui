local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["ObjectiveTracker"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local function reskinQuestIcon(_, block)
		local itemButton = block.itemButton
		if itemButton and not itemButton.styled then
			itemButton:SetNormalTexture("")
			itemButton:SetPushedTexture("")
			itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			itemButton.icon:SetTexCoord(.08, .92, .08, .92)
			local bg = B.CreateBDFrame(itemButton.icon)
			B.CreateSD(bg)

			itemButton.styled = true
		end

		local rightButton = block.rightButton
		if rightButton and not rightButton.styled then
			rightButton:SetNormalTexture("")
			rightButton:SetPushedTexture("")
			rightButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			local bg = B.CreateBDFrame(rightButton)
			B.CreateSD(bg)
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
		bg:SetPoint("BOTTOMLEFT", 0, -4)
		bg:SetSize(250, 30)
	end

	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
	}
	for _, header in pairs(headers) do reskinHeader(header) end

	-- Reskin Progressbars
	local function reskinBarTemplate(bar)
		B.StripTextures(bar)
		bar:SetStatusBarTexture(DB.bdTex)
		bar:GetStatusBarTexture():SetGradient("VERTICAL", r*.9, g*.9, b*.9, r*.4, g*.4, b*.4)
		bar.bg = B.CreateBDFrame(bar)
		B.CreateSD(bar.bg)
	end

	local function reskinProgressbar(_, _, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar
		local icon = bar.Icon

		if not bar.bg then
			bar:SetPoint("LEFT", 22, 0)
			reskinBarTemplate(bar)
			BonusObjectiveTrackerProgressBar_PlayFlareAnim = B.Dummy

			icon:SetMask(nil)
			icon:SetTexCoord(.08, .92, .08, .92)
			icon.bg = B.CreateBDFrame(icon)
			B.CreateSD(icon.bg)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 0)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, 0)
		end

		if icon.bg then
			icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", function(_, _, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar

		if not bar.bg then
			bar:ClearAllPoints()
			bar:SetPoint("LEFT")
			reskinBarTemplate(bar)
		end
	end)

	local function reskinTimerBar(_, _, line)
		local timerBar = line.TimerBar
		local bar = timerBar.Bar

		if not bar.bg then
			reskinBarTemplate(bar)
		end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)

	-- Reskin Blocks
	hooksecurefunc("ScenarioStage_CustomizeBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.CreateBDFrame(block.GlowTexture)
			block.bg:SetPoint("TOPLEFT", block.GlowTexture, 4, -2)
			block.bg:SetPoint("BOTTOMRIGHT", block.GlowTexture, -4, 0)
			B.CreateSD(block.bg)
		end
	end)

	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", function()
		local widgetContainer = ScenarioStageBlock.WidgetContainer
		if not widgetContainer then return end
		local widgetFrame = widgetContainer:GetChildren()
		if widgetFrame and widgetFrame.Frame then
			widgetFrame.Frame:SetAlpha(0)
			for _, bu in next, {widgetFrame.CurrencyContainer:GetChildren()} do
				if bu and not bu.styled then
					bu.Icon:SetTexCoord(.08, .92, .08, .92)
					B.CreateBDFrame(bu.Icon)

					bu.styled = true
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

			block.StatusBar:SetStatusBarTexture(DB.bdTex)
			block.StatusBar:GetStatusBarTexture():SetGradient("VERTICAL", r*.9, g*.9, b*.9, r*.4, g*.4, b*.4)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = B.CreateBDFrame(block)
			block.bg:SetPoint("TOPLEFT", 4, -2)
			block.bg:SetPoint("BOTTOMRIGHT", -4, 0)
			B.CreateSD(block.bg)
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_SetUpAffixes", B.AffixesSetup)

	-- Minimize Button
	local minimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	B.ReskinExpandOrCollapse(minimize)
	minimize:GetNormalTexture():SetAlpha(0)
	minimize.expTex:SetTexCoord(0.5625, 1, 0, 0.4375)
	hooksecurefunc("ObjectiveTracker_Collapse", function() minimize.expTex:SetTexCoord(0, .4375, 0, .4375) end)
	hooksecurefunc("ObjectiveTracker_Expand", function() minimize.expTex:SetTexCoord(.5625, 1, 0, .4375) end)
end)