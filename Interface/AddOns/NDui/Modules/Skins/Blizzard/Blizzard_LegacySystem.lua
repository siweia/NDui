local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function reskinProgressBar(bar)
	if bar.styled then return end
	bar.ProgressBarFrame:SetAlpha(0)
	bar:SetStatusBarTexture(DB.bdTex)
	bar:SetStatusBarColor(r, g, b)
	B.CreateBDFrame(bar, .25)
	bar.styled = true
end

local function updateSideTabIcon(tab)
	tab.Icon:SetSize(36, 36)
	tab.Icon:SetTexCoord(unpack(DB.TexCoord))
end

local function reskinSideTab(tab)
	tab.Background:SetAlpha(0)
	tab.Icon:RemoveMaskTexture(tab.Mask)
	tab.Mask:Hide()
	B.ReskinIcon(tab.Icon, true)

	for _, texture in ipairs({tab.SelectedTexture, tab.TabGlow}) do
		texture:SetColorTexture(r, g, b, .25)
		texture:SetAllPoints(tab.Icon)
	end
	tab.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	tab.HighlightTexture:SetAllPoints(tab.Icon)
	hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
end

local function updateCategory(button)
	if not button.styled then
		button.bg = B.CreateBDFrame(button, .25)
		button.bg:SetInside()
		hooksecurefunc(button, "RefreshCardArt", updateCategory)
		button.styled = true
	end

	button:GetNormalTexture():SetAlpha(0)
	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetAllPoints(button.bg)
	if button.selected then
		button.bg:SetBackdropColor(r, g, b, .25)
	else
		button.bg:SetBackdropColor(0, 0, 0, .25)
	end
end

local function reskinCategories(scrollBox)
	scrollBox:ForEachFrame(updateCategory)
end

local function reskinCriteria(objectives)
	for criteria in objectives.criteriaPool:EnumerateActive() do
		if not criteria.styled then
			criteria.Background:SetAlpha(0)
			criteria.ProgressBarBackground:SetAlpha(0)
			reskinProgressBar(criteria.ProgressBar)
			criteria.styled = true
		end
	end
end

local function updateChallenge(button)
	if not button.styled then
		for _, key in ipairs({"Background", "BackgroundTop", "BackgroundMiddle", "BackgroundBottom", "SelectedOverlay", "TitleBar"}) do
			button[key]:SetAlpha(0)
		end
		button.Icon.frame:SetAlpha(0)
		button.Icon.texture:RemoveMaskTexture(button.Icon.TextureMask)
		button.Icon.TextureMask:Hide()
		B.ReskinIcon(button.Icon.texture)
		button.Shield.CheckBackground:SetAlpha(0)
		B.ReskinCheck(button.Tracked)
		button.bg = B.CreateBDFrame(button, .25)
		button.bg:SetInside(nil, 1, 1)
		hooksecurefunc(button, "RefreshStateArt", updateChallenge)
		button.styled = true
	end

	local selected = button:IsSelected()
	if selected then
		button.bg:SetBackdropBorderColor(r, g, b)
	else
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end
	local color = (button.completed or selected) and .9 or .65
	button.Description:SetTextColor(color, color, color)
	button.HiddenDescription:SetTextColor(color, color, color)
	if button.accountWide then
		button.Label:SetTextColor(0, .6, 1)
	else
		button.Label:SetTextColor(color, color, color)
	end
end

local function reskinChallenges(scrollBox)
	scrollBox:ForEachFrame(updateChallenge)
end

local function updateTreeButton(button)
	if not button.styled then
		button.Background:SetAlpha(0)
		button.SelectedGlow:SetAlpha(0)
		button.styled = true
	end
end

local function reskinTreeButtons(panel)
	for _, button in ipairs(panel.treeButtons) do
		updateTreeButton(button)
	end
end

C.themes["Blizzard_LegacySystem"] = function()
	local frame = LegacySystemFrame
	B.ReskinPortraitFrame(frame)
	for _, tab in ipairs(frame.Tabs) do
		reskinSideTab(tab)
	end

	-- Reward track
	local rewards = frame.RewardTrackPage
	rewards.Background:SetAlpha(0)

	-- Challenges
	local challenges = frame.ChallengesPage
	challenges.Background:SetAlpha(0)
	challenges.VerticalDivider:SetAlpha(0)
	local summary = challenges.LegacyChallengePointSummary
	summary.ProgressBarBackground:SetAlpha(0)
	reskinProgressBar(summary.PointsBar)
	local categories = challenges.CategoryList
	B.ReskinEditBox(categories.SearchBox)
	B.ReskinFilterButton(categories.FilterDropdown)
	B.ReskinTrimScroll(categories.ScrollBar)
	hooksecurefunc(categories.ScrollBox, "Update", reskinCategories)
	reskinCategories(categories.ScrollBox)
	local details = challenges.DetailPane
	B.ReskinTrimScroll(details.ScrollBar)
	hooksecurefunc(details.ScrollBox, "Update", reskinChallenges)
	reskinChallenges(details.ScrollBox)
	hooksecurefunc(LegacyChallengeObjectives, "Display", reskinCriteria)
	reskinCriteria(LegacyChallengeObjectives)

	-- Legacy trees
	local tree = frame.TreePage
	tree.Background:SetAlpha(0)
	tree.VerticalDivider:SetAlpha(0)
	local summary = tree.LegacyTreePointSummary
	summary.Border:SetAlpha(0)
	local bg = B.CreateBDFrame(summary, .25)
	bg:SetOutside(summary.AvailablePointsLabel)
	local panel = tree.LegacyTreeTraitPanel
	B.Reskin(panel.ApplyButton)
	B.Reskin(panel.ResetButton)
	B.Reskin(panel.UndoButton)
	B.ReskinEditBox(panel.SearchBox)
	B.StripTextures(panel.SearchPreviewContainer)
	B.SetBD(panel.SearchPreviewContainer)
	B.CreateBDFrame(panel, .25):SetInside(nil, 10, 10)

	local selection = tree.LegacyTreeSelectionPanel
	hooksecurefunc(selection, "RefreshTreeButtons", reskinTreeButtons)
	reskinTreeButtons(selection)
end