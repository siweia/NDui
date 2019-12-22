local F, C = unpack(select(2, ...))

C.themes["Blizzard_ArchaeologyUI"] = function()
	F.ReskinPortraitFrame(ArchaeologyFrame)
	ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
	F.Reskin(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	F.Reskin(ArchaeologyFrameArtifactPageBackButton)

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
		F.StripTextures(button)
		F.ReskinIcon(icon)
		name:SetTextColor(1, .8, 0)
		subText:SetTextColor(1, 1, 1)
		local bg = F.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", -4, 4)
		bg:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)
	ArchaeologyFrameSummarytButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -50)
	ArchaeologyFrameSummarytButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)
	ArchaeologyFrameCompletedButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -120)
	ArchaeologyFrameCompletedButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)

	F.ReskinDropDown(ArchaeologyFrameRaceFilter)
	F.ReskinScroll(ArchaeologyFrameArtifactPageHistoryScrollScrollBar)
	F.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, "left")
	F.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, "right")
	ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()
	F.ReskinArrow(ArchaeologyFrameSummaryPagePrevPageButton, "left")
	F.ReskinArrow(ArchaeologyFrameSummaryPageNextPageButton, "right")
	ArchaeologyFrameSummaryPagePrevPageButtonIcon:Hide()
	ArchaeologyFrameSummaryPageNextPageButtonIcon:Hide()

	F.StripTextures(ArchaeologyFrameRankBar)
	ArchaeologyFrameRankBarBar:SetTexture(C.media.backdrop)
	ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", 0, .65, 0, 0, .75, 0)
	ArchaeologyFrameRankBar:SetHeight(14)
	F.CreateBD(ArchaeologyFrameRankBar, .25)
	F.ReskinIcon(ArchaeologyFrameArtifactPageIcon)

	F.StripTextures(ArchaeologyFrameArtifactPageSolveFrameStatusBar)
	F.CreateBDFrame(ArchaeologyFrameArtifactPageSolveFrameStatusBar, .25)
	local barTexture = ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetStatusBarTexture()
	barTexture:SetTexture(C.media.backdrop)
	barTexture:SetGradient("VERTICAL", .65, .25, 0, .75, .35, .1)

	-- ArcheologyDigsiteProgressBar
	F.StripTextures(ArcheologyDigsiteProgressBar)
	F.SetBD(ArcheologyDigsiteProgressBar.FillBar)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C.media.backdrop)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(.7, .3, .2)
end