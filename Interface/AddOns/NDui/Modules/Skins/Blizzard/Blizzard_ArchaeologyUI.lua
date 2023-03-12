local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ArchaeologyUI"] = function()
	B.ReskinPortraitFrame(ArchaeologyFrame)
	ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
	B.Reskin(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	B.Reskin(ArchaeologyFrameArtifactPageBackButton)

	ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, .8, 0)
	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
	ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)
	ArchaeologyFrameSummaryPagePageText:SetTextColor(1, 1, 1)
	for i = 1, ARCHAEOLOGY_MAX_RACES do
		local bu = _G["ArchaeologyFrameSummaryPageRace"..i]
		bu.raceName:SetTextColor(1, 1, 1)
	end

	for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local buttonName = "ArchaeologyFrameCompletedPageArtifact"..i
		local button = _G[buttonName]
		local icon = _G[buttonName.."Icon"]
		local name = _G[buttonName.."ArtifactName"]
		local subText = _G[buttonName.."ArtifactSubText"]
		B.StripTextures(button)
		B.ReskinIcon(icon)
		name:SetTextColor(1, .8, 0)
		subText:SetTextColor(1, 1, 1)
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", -4, 4)
		bg:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)
	ArchaeologyFrameSummarytButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -50)
	ArchaeologyFrameSummarytButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)
	ArchaeologyFrameCompletedButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -120)
	ArchaeologyFrameCompletedButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)

	B.ReskinDropDown(ArchaeologyFrameRaceFilter)
	if DB.isPatch10_1 then
		B.ReskinTrimScroll(ArchaeologyFrameArtifactPageHistoryScroll.ScrollBar)
	else
		B.ReskinScroll(ArchaeologyFrameArtifactPageHistoryScrollScrollBar)
	end
	B.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, "left")
	B.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, "right")
	ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()
	B.ReskinArrow(ArchaeologyFrameSummaryPagePrevPageButton, "left")
	B.ReskinArrow(ArchaeologyFrameSummaryPageNextPageButton, "right")
	ArchaeologyFrameSummaryPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameSummaryPageNextPageButtonIcon:Hide()

	B.StripTextures(ArchaeologyFrameRankBar)
	ArchaeologyFrameRankBarBar:SetTexture(DB.bdTex)
	ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", CreateColor(0, .65, 0, 1), CreateColor(0, .75, 0, 1))
	ArchaeologyFrameRankBar:SetHeight(14)
	B.CreateBDFrame(ArchaeologyFrameRankBar, .25)
	B.ReskinIcon(ArchaeologyFrameArtifactPageIcon)

	B.StripTextures(ArchaeologyFrameArtifactPageSolveFrameStatusBar)
	B.CreateBDFrame(ArchaeologyFrameArtifactPageSolveFrameStatusBar, .25)
	local barTexture = ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetStatusBarTexture()
	barTexture:SetTexture(DB.bdTex)
	barTexture:SetGradient("VERTICAL", CreateColor(.65, .25, 0, 1), CreateColor(.75, .35, .1, 1))

	-- ArcheologyDigsiteProgressBar
	B.StripTextures(ArcheologyDigsiteProgressBar)
	B.SetBD(ArcheologyDigsiteProgressBar.FillBar)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(DB.bdTex)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(.7, .3, .2)

	local ticks = {}
	ArcheologyDigsiteProgressBar:HookScript("OnShow", function(self)
		local bar = self.FillBar
		if not bar then return end
		B:CreateAndUpdateBarTicks(bar, ticks, bar.fillBarMax)
	end)
end