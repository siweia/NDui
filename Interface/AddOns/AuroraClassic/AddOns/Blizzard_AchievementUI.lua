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

	hooksecurefunc("AchievementFrameCategories_DisplayButton", function(bu)
		if bu.styled then return end

		bu.background:Hide()
		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 0, -1)
		bg:SetPoint("BOTTOMRIGHT")
		bu:SetHighlightTexture(C.media.backdrop)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
		hl:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)

		bu.styled = true
	end)

	AchievementFrameHeaderPoints:SetPoint("TOP", AchievementFrame, "TOP", 0, -6)
	AchievementFrameFilterDropDown:ClearAllPoints()
	AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", -120, 0)
	AchievementFrameFilterDropDownText:ClearAllPoints()
	AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)

	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(C.media.backdrop)
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
	AchievementFrameSummaryCategoriesStatusBarLeft:Hide()
	AchievementFrameSummaryCategoriesStatusBarMiddle:Hide()
	AchievementFrameSummaryCategoriesStatusBarRight:Hide()
	AchievementFrameSummaryCategoriesStatusBarFillBar:Hide()
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
		_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Hide()

		bu.description:SetTextColor(.9, .9, .9)
		bu.description.SetTextColor = F.dummy
		bu.description:SetShadowOffset(1, -1)
		bu.description.SetShadowOffset = F.dummy

		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		bu.icon.texture:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon.texture)

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
		if not bar.reskinned then
			bar:SetStatusBarTexture(C.media.backdrop)
			_G["AchievementFrameProgressBar"..index.."BG"]:SetColorTexture(0, 0, 0, .25)
			_G["AchievementFrameProgressBar"..index.."BorderLeft"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderCenter"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderRight"]:Hide()
			F.CreateBDFrame(bar, 0)

			bar.reskinned = true
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

			if not bu.reskinned then
				bu:DisableDrawLayer("BORDER")

				local bd = _G["AchievementFrameSummaryAchievement"..i.."Background"]
				bd:SetTexture(C.media.backdrop)
				bd:SetVertexColor(0, 0, 0, .25)

				_G["AchievementFrameSummaryAchievement"..i.."TitleBackground"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Glow"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:SetAlpha(0)
				_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Hide()

				local text = _G["AchievementFrameSummaryAchievement"..i.."Description"]
				text:SetTextColor(.9, .9, .9)
				text.SetTextColor = F.dummy
				text:SetShadowOffset(1, -1)
				text.SetShadowOffset = F.dummy

				local bg = CreateFrame("Frame", nil, bu)
				bg:SetPoint("TOPLEFT", 2, -2)
				bg:SetPoint("BOTTOMRIGHT", -2, 2)
				F.CreateBD(bg, 0)

				local ic = _G["AchievementFrameSummaryAchievement"..i.."IconTexture"]
				ic:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(ic)

				bu.reskinned = true
			end
		end
	end)

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local label = _G["AchievementFrameSummaryCategoriesCategory"..i.."Label"]

		_G["AchievementFrameSummaryCategoriesCategory"..i.."Left"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Middle"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Right"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."FillBar"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]:SetAlpha(0)

		bu:SetStatusBarTexture(C.media.backdrop)
		bu:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		label:SetTextColor(1, 1, 1)
		label:SetPoint("LEFT", bu, "LEFT", 6, 0)

		bu.text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)

		F.CreateBDFrame(bu, .25)
	end

	for i = 1, 20 do
		local bu = _G["AchievementFrameStatsContainerButton"..i]
		F.StripTextures(bu)
		bu:GetHighlightTexture():SetColorTexture(r, g, b, .25)
		bu:GetHighlightTexture():SetBlendMode("BLEND")
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
		local name = bar:GetName()
		bar:SetStatusBarTexture(C.media.backdrop)
		bar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		_G[name.."FillBar"]:Hide()
		_G[name.."Title"]:SetTextColor(1, 1, 1)
		_G[name.."Title"]:SetPoint("LEFT", bar, "LEFT", 6, 0)
		_G[name.."Text"]:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		F.CreateBDFrame(bar, .25)
	end

	for i = 1, 9 do
		local buttons = {_G["AchievementFrameComparisonContainerButton"..i.."Player"], _G["AchievementFrameComparisonContainerButton"..i.."Friend"]}

		for _, button in pairs(buttons) do
			button:DisableDrawLayer("BORDER")
			local bg = CreateFrame("Frame", nil, button)
			bg:SetPoint("TOPLEFT", 2, -3)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)
			F.CreateBD(bg, 0)
		end

		local bd = _G["AchievementFrameComparisonContainerButton"..i.."PlayerBackground"]
		bd:SetTexture(C.media.backdrop)
		bd:SetVertexColor(0, 0, 0, .25)

		local bd = _G["AchievementFrameComparisonContainerButton"..i.."FriendBackground"]
		bd:SetTexture(C.media.backdrop)
		bd:SetVertexColor(0, 0, 0, .25)

		local text = _G["AchievementFrameComparisonContainerButton"..i.."PlayerDescription"]
		text:SetTextColor(.9, .9, .9)
		text.SetTextColor = F.dummy
		text:SetShadowOffset(1, -1)
		text.SetShadowOffset = F.dummy

		_G["AchievementFrameComparisonContainerButton"..i.."PlayerTitleBackground"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."PlayerGlow"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."PlayerIconOverlay"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendTitleBackground"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendGlow"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendIconOverlay"]:Hide()

		local ic = _G["AchievementFrameComparisonContainerButton"..i.."PlayerIconTexture"]
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)

		local ic = _G["AchievementFrameComparisonContainerButton"..i.."FriendIconTexture"]
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)
	end

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

	local function styleSearchButton(result)
		F.StripTextures(result)
		if result.icon then
			F.ReskinIcon(result.icon)
		end
		F.CreateBD(result, .25)

		result:SetHighlightTexture(C.media.backdrop)
		local hl = result:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetPoint("TOPLEFT", 1, -2)
		hl:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	for i = 1, 5 do
		styleSearchButton(AchievementFrame.searchPreview[i])
	end
	styleSearchButton(AchievementFrame.showAllSearchResults)

	do
		local result = AchievementFrame.searchResults
		result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 10, 0)
		for i = 1, 14 do
			select(i, result:GetRegions()):Hide()
		end
		result.titleText:Show()
		local bg = F.CreateBDFrame(result)
		bg:SetPoint("TOPLEFT", -10, 0)
		bg:SetPoint("BOTTOMRIGHT")
		F.CreateSD(bg)
		F.ReskinClose(result.closeButton)
		F.ReskinScroll(AchievementFrameScrollFrameScrollBar)
		for i = 1, 8 do
			local ic = _G["AchievementFrameScrollFrameButton"..i]
			F.StripTextures(ic)
			F.ReskinIcon(ic.icon)
			F.CreateBD(ic, .25)
			ic:SetHighlightTexture(C.media.backdrop)
			local hl = ic:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .25)
			hl:SetPoint("TOPLEFT", C.mult, -C.mult)
			hl:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
		end
	end

	for i = 1, 20 do
		F.StripTextures(_G["AchievementFrameComparisonStatsContainerButton"..i])
	end
	F.ReskinScroll(AchievementFrameComparisonStatsContainerScrollBar)
	AchievementFrameComparisonWatermark:SetAlpha(0)

	-- Font width fix
	hooksecurefunc("AchievementObjectives_DisplayProgressiveAchievement", function()
		local index = 1
		local mini = _G["AchievementFrameMiniAchievement"..index]
		while mini do
			if not mini.fontStyled then
				mini.points:SetWidth(22)
				mini.points:ClearAllPoints()
				mini.points:SetPoint("BOTTOMRIGHT", 2, 2)
				mini.fontStyled = true
			end

			index = index + 1
			mini = _G["AchievementFrameMiniAchievement"..index]
		end
	end)
end