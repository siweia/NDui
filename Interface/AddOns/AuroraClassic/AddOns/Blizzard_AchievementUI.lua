local F, C = unpack(select(2, ...))

C.themes["Blizzard_AchievementUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.StripTextures(AchievementFrame, true)
	F.SetBD(AchievementFrame)
	AchievementFrameCategories:SetBackdrop(nil)
	AchievementFrameSummary:SetBackdrop(nil)
	AchievementFrameSummaryBackground:Hide()
	AchievementFrameSummary:GetChildren():Hide()
	AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)

	for i = 1, 4 do
		select(i, AchievementFrameHeader:GetRegions()):Hide()
	end
	AchievementFrameHeaderRightDDLInset:SetAlpha(0)
	AchievementFrameHeaderLeftDDLInset:SetAlpha(0)

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
	AchievementFrameComparisonHeaderPortraitBg:Hide()
	AchievementFrameComparisonBackground:Hide()
	AchievementFrameComparisonDark:SetAlpha(0)
	AchievementFrameComparisonSummaryPlayerBackground:Hide()
	AchievementFrameComparisonSummaryFriendBackground:Hide()

	local function SetupButtonHighlight(button, bg)
		button:SetHighlightTexture(C.media.backdrop)
		local hl = button:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
	end

	hooksecurefunc("AchievementFrameCategories_DisplayButton", function(bu)
		if bu.styled then return end

		bu.background:Hide()
		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 0, -1)
		bg:SetPoint("BOTTOMRIGHT")
		SetupButtonHighlight(bu, bg)

		bu.styled = true
	end)

	AchievementFrameHeaderPoints:SetPoint("TOP", AchievementFrame, "TOP", 0, -6)
	AchievementFrameFilterDropDown:ClearAllPoints()
	AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", -120, 0)
	AchievementFrameFilterDropDownText:ClearAllPoints()
	AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)

	F.StripTextures(AchievementFrameSummaryCategoriesStatusBar)
	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(C.media.backdrop)
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
	AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)
	F.CreateBDFrame(AchievementFrameSummaryCategoriesStatusBar, .25)

	for i = 1, 3 do
		local tab = _G["AchievementFrameTab"..i]
		if tab then
			F.ReskinTab(tab)
		end
	end

	for i = 1, 7 do
		local bu = _G["AchievementFrameAchievementsContainerButton"..i]
		F.StripTextures(bu, true)
		bu.highlight:SetAlpha(0)
		bu.icon.frame:Hide()

		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		F.ReskinIcon(bu.icon.texture)

		-- can't get a backdrop frame to appear behind the checked texture for some reason
		local ch = bu.tracked
		ch:SetNormalTexture("")
		ch:SetPushedTexture("")
		ch:SetHighlightTexture(C.media.backdrop)

		local hl = ch:GetHighlightTexture()
		hl:SetPoint("TOPLEFT", 4, -4)
		hl:SetPoint("BOTTOMRIGHT", -4, 4)
		hl:SetVertexColor(r, g, b, .25)

		local check = ch:GetCheckedTexture()
		check:SetDesaturated(true)
		check:SetVertexColor(r, g, b)

		local tex = F.CreateGradient(ch)
		tex:SetPoint("TOPLEFT", 4, -4)
		tex:SetPoint("BOTTOMRIGHT", -4, 4)
		F.CreateBDFrame(tex)
	end

	AchievementFrameAchievementsContainerButton1.background:SetPoint("TOPLEFT", AchievementFrameAchievementsContainerButton1, "TOPLEFT", 2, -3)

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
			F.StripTextures(bar)
			bar:SetStatusBarTexture(C.media.backdrop)
			F.CreateBDFrame(bar, .25)

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
				bu:DisableDrawLayer("BORDER")

				local bd = bu.background
				bd:SetTexture(C.media.backdrop)
				bd:SetVertexColor(0, 0, 0, .25)

				bu.titleBar:Hide()
				bu.glow:Hide()
				bu.highlight:SetAlpha(0)
				bu.icon.frame:Hide()
				F.ReskinIcon(bu.icon.texture)

				local bg = F.CreateBDFrame(bu, 0)
				bg:SetPoint("TOPLEFT", 2, -2)
				bg:SetPoint("BOTTOMRIGHT", -2, 2)

				bu.styled = true
			end

			bu.description:SetTextColor(.9, .9, .9)
		end
	end)

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		F.StripTextures(bu)
		bu:SetStatusBarTexture(C.media.backdrop)
		bu:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		F.CreateBDFrame(bu, .25)

		bu.label:SetTextColor(1, 1, 1)
		bu.label:SetPoint("LEFT", bu, "LEFT", 6, 0)
		bu.text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
		_G[bu:GetName().."ButtonHighlight"]:SetAlpha(0)
	end

	for i = 1, 20 do
		local bu = _G["AchievementFrameStatsContainerButton"..i]
		F.StripTextures(bu)
		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 2, -C.mult)
		bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
		SetupButtonHighlight(bu, bg)
	end

	AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 39, 26)
	local headerbg = F.CreateBDFrame(AchievementFrameComparisonHeader)
	headerbg:SetPoint("TOPLEFT", 20, -20)
	headerbg:SetPoint("BOTTOMRIGHT", -28, -5)
	F.CreateSD(headerbg)

	local summaries = {AchievementFrameComparisonSummaryPlayer, AchievementFrameComparisonSummaryFriend}
	for _, frame in pairs(summaries) do
		frame:SetBackdrop(nil)
		local bg = F.CreateBDFrame(frame, .25)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 0)
	end

	local bars = {AchievementFrameComparisonSummaryPlayerStatusBar, AchievementFrameComparisonSummaryFriendStatusBar}
	for _, bar in pairs(bars) do
		F.StripTextures(bar)
		bar:SetStatusBarTexture(C.media.backdrop)
		bar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		bar.title:SetTextColor(1, 1, 1)
		bar.title:SetPoint("LEFT", bar, "LEFT", 6, 0)
		bar.text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		F.CreateBDFrame(bar, .25)
	end

	for _, name in pairs({"Player", "Friend"}) do
		for i = 1, 9 do
			local button = _G["AchievementFrameComparisonContainerButton"..i..name]
			button:DisableDrawLayer("BORDER")
			button.background:Hide()
			local bg = F.CreateBDFrame(button, .25)
			bg:SetPoint("TOPLEFT", 2, -1)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)

			button.titleBar:Hide()
			button.glow:Hide()
			button.icon.frame:Hide()
			F.ReskinIcon(button.icon.texture)
		end
	end

	hooksecurefunc("AchievementFrameComparison_DisplayAchievement", function(button)
		button.player.description:SetTextColor(.9, .9, .9)
	end)

	F.ReskinClose(AchievementFrameCloseButton)
	F.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
	F.ReskinScroll(AchievementFrameStatsContainerScrollBar)
	F.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
	F.ReskinScroll(AchievementFrameComparisonContainerScrollBar)
	F.ReskinDropDown(AchievementFrameFilterDropDown)
	F.ReskinInput(AchievementFrame.searchBox)
	AchievementFrame.searchBox:ClearAllPoints()
	AchievementFrame.searchBox:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -25, -5)
	AchievementFrame.searchBox:SetPoint("BOTTOMLEFT", AchievementFrame, "TOPRIGHT", -130, -25)

	F.StripTextures(AchievementFrame.searchPreviewContainer)
	AchievementFrame.searchPreviewContainer:ClearAllPoints()
	AchievementFrame.searchPreviewContainer:SetPoint("TOPLEFT", AchievementFrame, "TOPRIGHT", 7, -1)
	local bg = F.CreateBDFrame(AchievementFrame.searchPreviewContainer)
	bg:SetPoint("TOPLEFT", -2, 2)
	bg:SetPoint("BOTTOMRIGHT", AchievementFrame.showAllSearchResults, 2, -2)
	F.CreateSD(bg)

	for i = 1, 5 do
		F.StyleSearchButton(AchievementFrame.searchPreview[i])
	end
	F.StyleSearchButton(AchievementFrame.showAllSearchResults)

	do
		local result = AchievementFrame.searchResults
		result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 15, -1)
		F.StripTextures(result)
		local bg = F.CreateBDFrame(result)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")
		F.CreateSD(bg)
		F.ReskinClose(result.closeButton)
		F.ReskinScroll(AchievementFrameScrollFrameScrollBar)
		for i = 1, 8 do
			local bu = _G["AchievementFrameScrollFrameButton"..i]
			F.StripTextures(bu)
			F.ReskinIcon(bu.icon)
			F.CreateBD(bu, .25)
			SetupButtonHighlight(bu, bu)
		end
	end

	for i = 1, 20 do
		local bu = _G["AchievementFrameComparisonStatsContainerButton"..i]
		F.StripTextures(bu)
		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 2, -C.mult)
		bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
		SetupButtonHighlight(bu, bg)
	end
	F.ReskinScroll(AchievementFrameComparisonStatsContainerScrollBar)
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