local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function SetupButtonHighlight(button, bg)
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(r, g, b, .25)
	hl:SetInside(bg)
end

C.themes["Blizzard_AchievementUI"] = function()
	if DB.isNewPatch then
		B.StripTextures(AchievementFrame)
		B.SetBD(AchievementFrame)
		AchievementFrameWaterMark:SetAlpha(0)
		B.StripTextures(AchievementFrame.Header)
		AchievementFrame.Header.Title:Hide()
		AchievementFrame.Header.Points:SetPoint("TOP", AchievementFrame, 0, -3)

		for i = 1, 3 do
			local tab = _G["AchievementFrameTab"..i]
			if tab then
				B.ReskinTab(tab)
			end
		end

		B.ReskinDropDown(AchievementFrameFilterDropDown)
		AchievementFrameFilterDropDown:ClearAllPoints()
		AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", -120, 0)
		AchievementFrameFilterDropDownText:ClearAllPoints()
		AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)
		B.ReskinClose(AchievementFrameCloseButton)

		-- Search box
		B.ReskinInput(AchievementFrame.SearchBox)
		AchievementFrame.SearchBox:ClearAllPoints()
		AchievementFrame.SearchBox:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -25, -5)
		AchievementFrame.SearchBox:SetPoint("BOTTOMLEFT", AchievementFrame, "TOPRIGHT", -130, -25)

		local previewContainer = AchievementFrame.SearchPreviewContainer
		local showAllSearchResults = previewContainer.ShowAllSearchResults
		B.StripTextures(previewContainer)
		previewContainer:ClearAllPoints()
		previewContainer:SetPoint("TOPLEFT", AchievementFrame, "TOPRIGHT", 7, -2)
		local bg = B.SetBD(previewContainer)
		bg:SetPoint("TOPLEFT", -3, 3)
		bg:SetPoint("BOTTOMRIGHT", showAllSearchResults, 3, -3)

		for i = 1, 5 do
			B.StyleSearchButton(previewContainer["SearchPreview"..i])
		end
		B.StyleSearchButton(showAllSearchResults)

		local result = AchievementFrame.SearchResults
		result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 15, -1)
		B.StripTextures(result)
		local bg = B.SetBD(result)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")

		B.ReskinClose(result.CloseButton)
		B.ReskinTrimScroll(result.ScrollBar)
		hooksecurefunc(result.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					B.StripTextures(child, 2)
					B.ReskinIcon(child.Icon)
					local bg = B.CreateBDFrame(child, .25)
					bg:SetInside()
					SetupButtonHighlight(child, bg)

					child.styled = true
				end
			end
		end)

		-- AchievementFrameCategories
		B.StripTextures(AchievementFrameCategories)
		B.ReskinTrimScroll(AchievementFrameCategories.ScrollBar)
		hooksecurefunc(AchievementFrameCategories.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				local button = child.Button
				if button and not button.styled then
					button.Background:Hide()
					local bg = B.CreateBDFrame(button, .25)
					bg:SetPoint("TOPLEFT", 0, -1)
					bg:SetPoint("BOTTOMRIGHT")
					SetupButtonHighlight(button, bg)

					button.styled = true
				end
			end
		end)

		B.StripTextures(AchievementFrameAchievements)
		B.ReskinTrimScroll(AchievementFrameAchievements.ScrollBar)
		select(3, AchievementFrameAchievements:GetChildren()):Hide()

		local function updateAccountString(button)
			if button.DateCompleted:IsShown() then
				if button.accountWide then
					button.Label:SetTextColor(0, .6, 1)
				else
					button.Label:SetTextColor(.9, .9, .9)
				end
			else
				if button.accountWide then
					button.Label:SetTextColor(0, .3, .5)
				else
					button.Label:SetTextColor(.65, .65, .65)
				end
			end
		end

		hooksecurefunc(AchievementFrameAchievements.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if child and not child.styled then
					B.StripTextures(child, true)
					child.Background:SetAlpha(0)
					child.Highlight:SetAlpha(0)
					child.Icon.frame:Hide()
					child.Description:SetTextColor(.9, .9, .9)
					child.Description.SetTextColor = B.Dummy
		
					local bg = B.CreateBDFrame(child, .25)
					bg:SetPoint("TOPLEFT", 1, -1)
					bg:SetPoint("BOTTOMRIGHT", 0, 2)
					B.ReskinIcon(child.Icon.texture)

					B.ReskinCheck(child.Tracked)
					child.Tracked:SetSize(20, 20)
					child.Check:SetAlpha(0)

					hooksecurefunc(child, "UpdatePlusMinusTexture", updateAccountString)

					child.styled = true
				end
			end
		end)

		B.StripTextures(AchievementFrameSummary)
		AchievementFrameSummary:GetChildren():Hide()
		AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
		AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)

		hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
			for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				local bu = _G["AchievementFrameSummaryAchievement"..i]
				if bu.accountWide then
					bu.Label:SetTextColor(0, .6, 1)
				else
					bu.Label:SetTextColor(.9, .9, .9)
				end

				if not bu.styled then
					bu:DisableDrawLayer("BORDER")
					bu:HideBackdrop()

					local bd = bu.Background
					bd:SetTexture(DB.bdTex)
					bd:SetVertexColor(0, 0, 0, .25)

					bu.TitleBar:Hide()
					bu.Glow:Hide()
					bu.Highlight:SetAlpha(0)
					bu.Icon.frame:Hide()
					B.ReskinIcon(bu.Icon.texture)

					local bg = B.CreateBDFrame(bu, 0)
					bg:SetPoint("TOPLEFT", 2, -2)
					bg:SetPoint("BOTTOMRIGHT", -2, 2)

					bu.styled = true
				end

				bu.Description:SetTextColor(.9, .9, .9)
			end
		end)

		for i = 1, 12 do
			local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
			B.StripTextures(bu)
			bu:SetStatusBarTexture(DB.bdTex)
			bu:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
			B.CreateBDFrame(bu, .25)

			bu.Label:SetTextColor(1, 1, 1)
			bu.Label:SetPoint("LEFT", bu, "LEFT", 6, 0)
			bu.Text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
			_G[bu:GetName().."ButtonHighlight"]:SetAlpha(0)
		end

		local bar = AchievementFrameSummaryCategoriesStatusBar
		if bar then
			B.StripTextures(bar)
			bar:SetStatusBarTexture(DB.bdTex)
			bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
			B.CreateBDFrame(bar, .25)
			_G[bar:GetName().."Title"]:SetPoint("LEFT", bar, "LEFT", 6, 0)
			_G[bar:GetName().."Text"]:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		end

		AchievementFrameSummaryAchievementsEmptyText:SetText("")

		-- Summaries
		AchievementFrameStatsBG:Hide()
		select(4, AchievementFrameStats:GetChildren()):Hide()
		B.ReskinTrimScroll(AchievementFrameStats.ScrollBar)
		hooksecurefunc(AchievementFrameStats.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					B.StripTextures(child)
					local bg = B.CreateBDFrame(child, .25)
					bg:SetPoint("TOPLEFT", 2, -C.mult)
					bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
					SetupButtonHighlight(child, bg)

					child.styled = true
				end
			end
		end)

		-- Comparison

		AchievementFrameComparisonHeaderBG:Hide()
		AchievementFrameComparisonHeaderPortrait:Hide()
		AchievementFrameComparisonHeaderPortraitBg:Hide()
		AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 39, 26)
		local headerbg = B.SetBD(AchievementFrameComparisonHeader)
		headerbg:SetPoint("TOPLEFT", 20, -20)
		headerbg:SetPoint("BOTTOMRIGHT", -28, -5)

		B.StripTextures(AchievementFrameComparison)
		select(5, AchievementFrameComparison:GetChildren()):Hide()
		B.ReskinTrimScroll(AchievementFrameComparison.AchievementContainer.ScrollBar)

		local function handleCompareSummary(frame)
			B.StripTextures(frame)
			local bar = frame.StatusBar
			B.StripTextures(bar)
			bar:SetStatusBarTexture(DB.bdTex)
			bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
			bar.Title:SetTextColor(1, 1, 1)
			bar.Title:SetPoint("LEFT", bar, "LEFT", 6, 0)
			bar.Text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
			B.CreateBDFrame(bar, .25)
		end
		handleCompareSummary(AchievementFrameComparison.Summary.Player)
		handleCompareSummary(AchievementFrameComparison.Summary.Friend)

		local function handleCompareCategory(button)
			button:DisableDrawLayer("BORDER")
			button:HideBackdrop()
			button.Background:Hide()
			local bg = B.CreateBDFrame(button, .25)
			bg:SetInside(button, 2, 2)

			button.TitleBar:Hide()
			button.Glow:Hide()
			button.Icon.frame:Hide()
			B.ReskinIcon(button.Icon.texture)
		end

		hooksecurefunc(AchievementFrameComparison.AchievementContainer.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					handleCompareCategory(child.Player)
					child.Player.Description:SetTextColor(.9, .9, .9)
					child.Player.Description.SetTextColor = B.Dummy
					handleCompareCategory(child.Friend)

					child.styled = true
				end
			end
		end)
	else
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
		AchievementFrameFilterDropDown:ClearAllPoints()
		AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", -120, 0)
		AchievementFrameFilterDropDownText:ClearAllPoints()
		AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)

		B.StripTextures(AchievementFrameSummaryCategoriesStatusBar)
		AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(DB.bdTex)
		AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
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
			ch:SetNormalTexture("")
			ch:SetPushedTexture("")
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
					bu:DisableDrawLayer("BORDER")
					bu:HideBackdrop()

					local bd = bu.background
					bd:SetTexture(DB.bdTex)
					bd:SetVertexColor(0, 0, 0, .25)

					bu.titleBar:Hide()
					bu.glow:Hide()
					bu.highlight:SetAlpha(0)
					bu.icon.frame:Hide()
					B.ReskinIcon(bu.icon.texture)

					local bg = B.CreateBDFrame(bu, 0)
					bg:SetPoint("TOPLEFT", 2, -2)
					bg:SetPoint("BOTTOMRIGHT", -2, 2)

					bu.styled = true
				end

				bu.description:SetTextColor(.9, .9, .9)
			end
		end)

		for i = 1, 12 do
			local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
			B.StripTextures(bu)
			bu:SetStatusBarTexture(DB.bdTex)
			bu:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
			B.CreateBDFrame(bu, .25)

			bu.label:SetTextColor(1, 1, 1)
			bu.label:SetPoint("LEFT", bu, "LEFT", 6, 0)
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
			bar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
			bar.title:SetTextColor(1, 1, 1)
			bar.title:SetPoint("LEFT", bar, "LEFT", 6, 0)
			bar.text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
			B.CreateBDFrame(bar, .25)
		end

		for _, name in pairs({"Player", "Friend"}) do
			for i = 1, 9 do
				local button = _G["AchievementFrameComparisonContainerButton"..i..name]
				button:DisableDrawLayer("BORDER")
				button:HideBackdrop()
				button.background:Hide()
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 2, -1)
				bg:SetPoint("BOTTOMRIGHT", -2, 2)

				button.titleBar:Hide()
				button.glow:Hide()
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
		B.ReskinDropDown(AchievementFrameFilterDropDown)
		B.ReskinInput(AchievementFrame.searchBox)
		AchievementFrame.searchBox:ClearAllPoints()
		AchievementFrame.searchBox:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -25, -5)
		AchievementFrame.searchBox:SetPoint("BOTTOMLEFT", AchievementFrame, "TOPRIGHT", -130, -25)

		local showAllSearchResults = AchievementFrame.searchPreviewContainer.showAllSearchResults

		B.StripTextures(AchievementFrame.searchPreviewContainer)
		AchievementFrame.searchPreviewContainer:ClearAllPoints()
		AchievementFrame.searchPreviewContainer:SetPoint("TOPLEFT", AchievementFrame, "TOPRIGHT", 7, -2)
		local bg = B.SetBD(AchievementFrame.searchPreviewContainer)
		bg:SetPoint("TOPLEFT", -3, 3)
		bg:SetPoint("BOTTOMRIGHT", showAllSearchResults, 3, -3)

		for i = 1, 5 do
			B.StyleSearchButton(AchievementFrame.searchPreviewContainer["searchPreview"..i])
		end
		B.StyleSearchButton(showAllSearchResults)

		do
			local result = AchievementFrame.searchResults
			result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 15, -1)
			B.StripTextures(result)
			local bg = B.SetBD(result)
			bg:SetPoint("TOPLEFT", -10, 0)
			bg:SetPoint("BOTTOMRIGHT")

			B.ReskinClose(result.closeButton)
			B.ReskinScroll(AchievementFrameScrollFrameScrollBar)
			for i = 1, 8 do
				local bu = _G["AchievementFrameScrollFrameButton"..i]
				B.StripTextures(bu)
				B.ReskinIcon(bu.icon)
				local bg = B.CreateBDFrame(bu, .25)
				bg:SetInside()
				SetupButtonHighlight(bu, bg)
			end
		end

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
end