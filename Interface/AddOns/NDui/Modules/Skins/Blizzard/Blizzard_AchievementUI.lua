local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AchievementUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.StripTextures(AchievementFrame, true)
	B.SetBD(AchievementFrame)
	AchievementFrameCategories:HideBackdrop()
	AchievementFrameSummaryBackground:Hide()
	AchievementFrameSummary:GetChildren():Hide()
	AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)

	for i = 1, 4 do
		select(i, AchievementFrameHeader:GetRegions()):Hide()
	end
	AchievementFrameHeaderRightDDLInset:SetAlpha(0)

	select(2, AchievementFrameAchievements:GetChildren()):Hide()
	AchievementFrameAchievementsBackground:Hide()
	select(3, AchievementFrameAchievements:GetRegions()):Hide()

	AchievementFrameStatsBG:Hide()
	AchievementFrameSummaryAchievementsHeaderHeader:Hide()
	AchievementFrameSummaryCategoriesHeaderTexture:Hide()
	select(3, AchievementFrameStats:GetChildren()):Hide()
	select(5, AchievementFrameComparison:GetChildren()):Hide()
	AchievementFrameComparisonHeaderBG:Hide()
	AchievementFrameComparisonHeaderPortrait:Hide()
	AchievementFrameComparisonBackground:Hide()
	AchievementFrameComparisonDark:SetAlpha(0)
	AchievementFrameComparisonSummaryPlayerBackground:Hide()
	AchievementFrameComparisonSummaryFriendBackground:Hide()

	local function SetupButtonHighlight(button, bg)
		button:SetHighlightTexture(DB.bdTex)
		local hl = button:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetInside(bg)
	end

	hooksecurefunc("AchievementFrameCategories_DisplayButton", function(bu)
		if bu.styled then return end

		bu.background:Hide()
		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 0, -1)
		bg:SetPoint("BOTTOMRIGHT")
		SetupButtonHighlight(bu, bg)

		bu.styled = true
	end)

	AchievementFrameHeaderPoints:SetPoint("TOP", AchievementFrame, "TOP", 0, -6)
	B.ReskinFilterButton(AchievementFrameFilterDropdown)
	AchievementFrameFilterDropdown:ClearAllPoints()
	AchievementFrameFilterDropdown:SetPoint("TOPLEFT", 25, -5)

	B.StripTextures(AchievementFrameSummaryCategoriesStatusBar)
	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(DB.bdTex)
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
	AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
	AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)
	B.CreateBDFrame(AchievementFrameSummaryCategoriesStatusBar, .25)

	for i = 1, 3 do
		local tab = _G["AchievementFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end

	for i = 1, 7 do
		local bu = _G["AchievementFrameAchievementsContainerButton"..i]
		B.StripTextures(bu, true)
		bu.highlight:SetAlpha(0)
		bu.icon.frame:Hide()

		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		B.ReskinIcon(bu.icon.texture)

		-- can't get a backdrop frame to appear behind the checked texture for some reason
		local ch = bu.tracked
		ch:SetNormalTexture(0)
		ch:SetPushedTexture(0)
		ch:SetHighlightTexture(DB.bdTex)

		local check = ch:GetCheckedTexture()
		check:SetDesaturated(true)
		check:SetVertexColor(r, g, b)

		local bg = B.CreateBDFrame(ch, 0, true)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 2)

		local hl = ch:GetHighlightTexture()
		hl:SetInside(bg)
		hl:SetVertexColor(r, g, b, .25)
	end

	hooksecurefunc("AchievementButton_DisplayAchievement", function(button, category, achievement)
		local _, _, _, completed = GetAchievementInfo(category, achievement)
		if completed then
			if button.accountWide then
				button.label:SetTextColor(0, .6, 1)
			else
				button.label:SetTextColor(.9, .9, .9)
			end
		else
			if button.accountWide then
				button.label:SetTextColor(0, .3, .5)
			else
				button.label:SetTextColor(.65, .65, .65)
			end
		end
		button.description:SetTextColor(.9, .9, .9)
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(_, id)
		for i = 1, GetAchievementNumCriteria(id) do
			local name = _G["AchievementFrameCriteria"..i.."Name"]
			if name and select(2, name:GetTextColor()) == 0 then
				name:SetTextColor(1, 1, 1)
			end

			local bu = _G["AchievementFrameMeta"..i]
			if bu and select(2, bu.label:GetTextColor()) == 0 then
				bu.label:SetTextColor(1, 1, 1)
			end
		end
	end)

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local bar = _G["AchievementFrameProgressBar"..index]
		if not bar.styled then
			B.StripTextures(bar)
			bar:SetStatusBarTexture(DB.bdTex)
			B.CreateBDFrame(bar, .25)

			bar.styled = true
		end
	end)

	-- this is hidden behind other stuff in default UI
	AchievementFrameSummaryAchievementsEmptyText:SetText("")

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G["AchievementFrameSummaryAchievement"..i]
			if bu.accountWide then
				bu.label:SetTextColor(0, .6, 1)
			else
				bu.label:SetTextColor(.9, .9, .9)
			end

			if not bu.styled then
				bu:DisableDrawLayer("ARTWORK")
				bu:DisableDrawLayer("BORDER")
				bu:DisableDrawLayer("BACKGROUND")
				bu:HideBackdrop()

				bu.titleBar:Hide()
				bu.highlight:SetAlpha(0)
				bu.icon.frame:Hide()
				B.ReskinIcon(bu.icon.texture)

				local bg = B.CreateBDFrame(bu, .25)
				bg:SetInside(nil, 2, 2)

				bu.styled = true
			end

			bu.description:SetTextColor(.9, .9, .9)
		end
	end)

	for i = 1, 8 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		B.StripTextures(bu)
		bu:SetStatusBarTexture(DB.bdTex)
		bu:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
		B.CreateBDFrame(bu, .25)

		bu.text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
		_G[bu:GetName().."ButtonHighlight"]:SetAlpha(0)
	end

	for i = 1, 20 do
		local bu = _G["AchievementFrameStatsContainerButton"..i]
		B.StripTextures(bu)
		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 2, -C.mult)
		bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
		SetupButtonHighlight(bu, bg)
	end

	AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 39, 26)
	local headerbg = B.SetBD(AchievementFrameComparisonHeader)
	headerbg:SetPoint("TOPLEFT", 20, -20)
	headerbg:SetPoint("BOTTOMRIGHT", -28, -5)

	local summaries = {AchievementFrameComparisonSummaryPlayer, AchievementFrameComparisonSummaryFriend}
	for _, frame in pairs(summaries) do
		frame:HideBackdrop()
		local bg = B.CreateBDFrame(frame, .25)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 0)
	end

	local bars = {AchievementFrameComparisonSummaryPlayerStatusBar, AchievementFrameComparisonSummaryFriendStatusBar}
	for _, bar in pairs(bars) do
		B.StripTextures(bar)
		bar:SetStatusBarTexture(DB.bdTex)
		bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
		bar.title:SetTextColor(1, 1, 1)
		bar.title:SetPoint("LEFT", bar, "LEFT", 6, 0)
		bar.text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		B.CreateBDFrame(bar, .25)
	end

	for _, name in pairs({"Player", "Friend"}) do
		for i = 1, 9 do
			local button = _G["AchievementFrameComparisonContainerButton"..i..name]
			button:DisableDrawLayer("ARTWORK")
			button:DisableDrawLayer("BORDER")
			button:DisableDrawLayer("BACKGROUND")
			button:HideBackdrop()
			local bg = B.CreateBDFrame(button, .25)
			bg:SetPoint("TOPLEFT", 2, -1)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)

			button.icon.frame:Hide()
			B.ReskinIcon(button.icon.texture)
		end
	end

	hooksecurefunc("AchievementFrameComparison_DisplayAchievement", function(button)
		button.player.description:SetTextColor(.9, .9, .9)
	end)

	B.ReskinClose(AchievementFrameCloseButton)
	B.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
	B.ReskinScroll(AchievementFrameStatsContainerScrollBar)
	B.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
	B.ReskinScroll(AchievementFrameComparisonContainerScrollBar)

	for i = 1, 20 do
		local bu = _G["AchievementFrameComparisonStatsContainerButton"..i]
		B.StripTextures(bu)
		local bg = B.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 2, -C.mult)
		bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
		SetupButtonHighlight(bu, bg)
	end
	B.ReskinScroll(AchievementFrameComparisonStatsContainerScrollBar)
	AchievementFrameComparisonWatermark:SetAlpha(0)

	-- Font width fix
	local fixedIndex = 1
	hooksecurefunc("AchievementObjectives_DisplayProgressiveAchievement", function()
		local mini = _G["AchievementFrameMiniAchievement"..fixedIndex]
		while mini do
			mini.points:SetWidth(22)
			mini.points:ClearAllPoints()
			mini.points:SetPoint("BOTTOMRIGHT", 2, 2)

			fixedIndex = fixedIndex + 1
			mini = _G["AchievementFrameMiniAchievement"..fixedIndex]
		end
	end)
end