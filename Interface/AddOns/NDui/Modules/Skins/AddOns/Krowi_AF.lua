local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local _G = _G
local strfind = strfind
local cr, cg, cb = DB.r, DB.g, DB.b

local function SetupButtonHighlight(button, bg)
	if button.Highlight then
		B.StripTextures(button.Highlight)
	end
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(cr, cg, cb, .25)
	hl:SetInside(bg)
end

local function SetupStatusbar(bar)
	B.StripTextures(bar)
	bar:SetStatusBarTexture(DB.bdTex)
	bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, .4, 0, 1), CreateColor(0, .6, 0, 1))
	B.CreateBDFrame(bar, .25)
end

local function updateAchievementLabel(button)
	if button.DateCompleted:IsShown() then
		if button.Achievement.IsAccountWide then
			button.Header:SetTextColor(0, .6, 1)
		else
			button.Header:SetTextColor(.9, .9, .9)
		end
	else
		if button.Achievement.IsAccountWide then
			button.Header:SetTextColor(0, .3, .5)
		else
			button.Header:SetTextColor(.65, .65, .65)
		end
	end

	if button.Description then
		button.Description:SetTextColor(1, 1, 1)
	end
end

local function SetupAchivementButton(button)
	B.StripTextures(button, true)
	button.Icon.Border:Hide()
	B.ReskinIcon(button.Icon.Texture)
	if button.Tracked then
		B.ReskinCheck(button.Tracked)
		button.Tracked:SetSize(20, 20)
		button.Check:SetAlpha(0)
	end

	hooksecurefunc(button, "UpdatePlusMinusTexture", updateAchievementLabel)
	local bg = B.CreateBDFrame(button, .25)
	bg:SetInside()
	SetupButtonHighlight(button, bg)
end

function S:KrowiAF()
	if not IsAddOnLoaded("Krowi_AchievementFilter") then return end

	for i = 4, 8 do
		local tab = _G["AchievementFrameTab"..i]
		if tab and not tab.bg then
			B.ReskinTab(tab)
		end
	end

	B.ReskinFilterButton(KrowiAF_AchievementFrameFilterButton)
	KrowiAF_AchievementFrameFilterButton:SetPoint("TOPLEFT", 24, 0)
	B.ReskinEditBox(KrowiAF_SearchBoxFrame)
	KrowiAF_SearchOptionsMenuButton:DisableDrawLayer("BACKGROUND")
	KrowiAF_AchievementFrameSummaryFrameAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
	KrowiAF_AchievementFrameSummaryFrameCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)

	local frame = KrowiAF_CategoriesFrame
	if frame then
		B.StripTextures(frame)
		B.ReskinScroll(frame.ScrollFrame.ScrollBar)

		local buttons = frame.ScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			B.StripTextures(button)
			local bg = B.CreateBDFrame(button, .25)
			bg:SetPoint("TOPLEFT", 0, -1)
			bg:SetPoint("BOTTOMRIGHT")
			SetupButtonHighlight(button, bg)
		end
	end

	local frame = KrowiAF_AchievementFrameSummaryFrame
	if frame then
		B.StripTextures(frame)
		frame:GetChildren():Hide()
		B.ReskinScroll(frame.ScrollFrameBorder.ScrollFrame.ScrollBar)

		local buttons = frame.ScrollFrameBorder.ScrollFrame.buttons
		for i = 1, #buttons do
			SetupAchivementButton(buttons[i])
		end
	end

	local frame = KrowiAF_AchievementsFrame
	if frame then
		B.StripTextures(frame)
		B.ReskinScroll(frame.ScrollFrame.ScrollBar)

		local buttons = frame.ScrollFrame.buttons
		for i = 1, #buttons do
			SetupAchivementButton(buttons[i])
		end
	end

	for i = 1, 16 do
		local bar = _G["Krowi_ProgressBar"..i]
		if bar then
			B.StripTextures(bar)
			if i ~= 1 then
				bar.BorderLeftTop:SetPoint("TOPLEFT", -1, 10)
			end
			local bg = B.CreateBDFrame(bar.Background, .25)
			if bar.Button then
				B.StripTextures(bar.Button)
				SetupButtonHighlight(bar.Button, bg)
			end
			for _, fill in next, bar.Fill do
				fill:SetTexture(DB.bdTex)
			end
			bar:SetColors({R = 0, G = .4, B = 0}, {R = 0, G = .6, B = 0})
		end
	end

	if AchievementButton_LocalizeProgressBar then
		hooksecurefunc("AchievementButton_LocalizeProgressBar", function(bar)
			if bar.styled then return end
			local barName = bar.GetName and bar:GetName()
			if barName and strfind(barName, "Krowi") then
				SetupStatusbar(bar)
				bar.styled = true
			end
		end)
	end

	hooksecurefunc(AchievementFrame, "Show", function(self)
		for i = 1, 10 do
			local button = _G["AchievementFrameSideButton"..i]
			if not button then break end
			if not button.bg then
				button.Background:SetTexture("")
				button.Icon.Overlay:SetTexture("")
				button.bg = B.SetBD(button)
				button.bg:SetPoint("TOPLEFT", 6, -9)
				button.bg:SetPoint("BOTTOMRIGHT", 2, 12)
			end
		end
	end)

	local button = KrowiAF_AchievementCalendarButton
	if button then
		B.StripTextures(button)
		local icon = button:CreateTexture()
		icon:SetAllPoints()
		icon:SetTexture(DB.garrTex)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", AchievementFrame, -12, 12)
	end

	local frame = KrowiAF_AchievementCalendarFrame
	if frame then
		B.StripTextures(frame)
		B.SetBD(frame)
		B.ReskinArrow(frame.PrevMonthButton, "left")
		B.ReskinArrow(frame.NextMonthButton, "right")
		B.ReskinClose(frame.CloseButton)

		for i = 1, 42 do
			local button = frame.DayButtons[i]
			if button then
				button:DisableDrawLayer("BACKGROUND")
				button.DarkFrame:SetAlpha(.5)
				button:SetHighlightTexture(DB.bdTex)
				local bg = B.CreateBDFrame(button, .25)
				bg:SetInside()
				local hl = button:GetHighlightTexture()
				hl:SetVertexColor(cr, cg, cb, .25)
				hl:SetInside(bg)
			end
		end

		frame.TodayFrame:SetSize(90, 90)
		B.StripTextures(frame.TodayFrame)
		local bg = B.CreateBDFrame(frame.TodayFrame, 0)
		bg:SetInside()
		bg:SetBackdropBorderColor(cr, cg, cb)
	end

	local container = KrowiAF_SearchPreviewContainer
	if container then
		B.StripTextures(container)
		for i = 1, 5 do
			local preview = _G["KrowiAF_SearchPreview"..i]
			if preview then
				B.StyleSearchButton(preview)
			end
		end

		local showAllResults = container.ShowFullSearchResultsButton
		local bg = B.SetBD(container)
		bg:SetPoint("TOPLEFT", -3, 3)
		bg:SetPoint("BOTTOMRIGHT", showAllResults, 3, -3)
		B.StyleSearchButton(showAllResults)
	end
end

S:RegisterSkin("Blizzard_AchievementUI", S.KrowiAF)