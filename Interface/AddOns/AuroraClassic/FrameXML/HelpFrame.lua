local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
    local r, g, b = C.r, C.g, C.b

	F.StripTextures(HelpFrame)
	F.SetBD(HelpFrame)
	HelpFrameHeader:Hide()
    F.ReskinClose(HelpFrameCloseButton)

	F.StripTextures(HelpFrameMainInset)
	F.StripTextures(HelpFrameLeftInset)
	F.StripTextures(HelpBrowser.BrowserInset)

	F.CreateBD(HelpFrameGM_ResponseScrollFrame1, .25)
	F.CreateBD(HelpFrameGM_ResponseScrollFrame2, .25)
	F.CreateBD(HelpFrameReportBugScrollFrame, .25)
	F.CreateBD(HelpFrameSubmitSuggestionScrollFrame, .25)
	F.CreateBD(ReportCheatingDialogCommentFrame, .25)
	for i = 1, 9 do
		select(i, ReportCheatingDialogCommentFrame:GetRegions()):Hide()
	end

	local scrolls = {
		"HelpFrameKnowledgebaseScrollFrameScrollBar",
		"HelpFrameReportBugScrollFrameScrollBar",
		"HelpFrameSubmitSuggestionScrollFrameScrollBar",
		"HelpFrameGM_ResponseScrollFrame1ScrollBar",
		"HelpFrameGM_ResponseScrollFrame2ScrollBar",
		"HelpFrameKnowledgebaseScrollFrame2ScrollBar",
	}
	for _, scroll in next, scrolls do
		F.ReskinScroll(_G[scroll])
	end

	local buttons = {
		"HelpFrameAccountSecurityOpenTicket",
		"HelpFrameCharacterStuckStuck",
		"HelpFrameOpenTicketHelpOpenTicket",
		"HelpFrameKnowledgebaseSearchButton",
		"HelpFrameGM_ResponseNeedMoreHelp",
		"HelpFrameGM_ResponseCancel",
		"HelpFrameReportBugSubmit",
		"HelpFrameSubmitSuggestionSubmit"
	}
	for _, button in next, buttons do
		F.Reskin(_G[button])
	end

	F.StripTextures(HelpFrameKnowledgebase)
	F.ReskinInput(HelpFrameKnowledgebaseSearchBox)

	select(3, HelpFrameReportBug:GetChildren()):Hide()
	select(3, HelpFrameSubmitSuggestion:GetChildren()):Hide()
	select(5, HelpFrameGM_Response:GetChildren()):Hide()
	select(6, HelpFrameGM_Response:GetChildren()):Hide()
	HelpFrameReportBugScrollFrameScrollBar:SetPoint("TOPLEFT", HelpFrameReportBugScrollFrame, "TOPRIGHT", 1, -16)
	HelpFrameSubmitSuggestionScrollFrameScrollBar:SetPoint("TOPLEFT", HelpFrameSubmitSuggestionScrollFrame, "TOPRIGHT", 1, -16)
	HelpFrameGM_ResponseScrollFrame1ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame1, "TOPRIGHT", 1, -16)
	HelpFrameGM_ResponseScrollFrame2ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame2, "TOPRIGHT", 1, -16)

	for i = 1, 15 do
		local bu = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
		bu:DisableDrawLayer("ARTWORK")
		F.CreateBD(bu, 0)

		F.CreateGradient(bu)
	end

	local function colourTab(f)
		f.text:SetTextColor(1, 1, 1)
	end

	local function clearTab(f)
		f.text:SetTextColor(1, .82, 0)
	end

	local function styleTab(bu)
		bu.selected:SetColorTexture(r, g, b, .2)
		bu.selected:SetDrawLayer("BACKGROUND")
		bu.text:SetFont(C.media.font, 14, "OUTLINE")
		F.Reskin(bu, true)
		bu:SetScript("OnEnter", colourTab)
		bu:SetScript("OnLeave", clearTab)
	end

	for i = 1, 6 do
		styleTab(_G["HelpFrameButton"..i])
	end
	styleTab(HelpFrameButton16)

	HelpFrameAccountSecurityOpenTicket.text:SetFont(C.media.font, 14, "OUTLINE")
	HelpFrameOpenTicketHelpOpenTicket.text:SetFont(C.media.font, 14, "OUTLINE")

	HelpFrameCharacterStuckHearthstone:SetSize(56, 56)
	F.CreateBG(HelpFrameCharacterStuckHearthstone)
	HelpFrameCharacterStuckHearthstoneIconTexture:SetTexCoord(.08, .92, .08, .92)

	F.Reskin(HelpBrowserNavHome)
	F.Reskin(HelpBrowserNavReload)
	F.Reskin(HelpBrowserNavStop)
	F.Reskin(HelpBrowserBrowserSettings)
	F.ReskinArrow(HelpBrowserNavBack, "left")
	F.ReskinArrow(HelpBrowserNavForward, "right")

	HelpBrowserNavHome:SetSize(18, 18)
	HelpBrowserNavReload:SetSize(18, 18)
	HelpBrowserNavStop:SetSize(18, 18)
	HelpBrowserBrowserSettings:SetSize(18, 18)

	HelpBrowserNavHome:SetPoint("BOTTOMLEFT", HelpBrowser, "TOPLEFT", 2, 4)
	HelpBrowserBrowserSettings:SetPoint("TOPRIGHT", HelpFrameCloseButton, "BOTTOMLEFT", -4, -1)
	LoadingIcon:ClearAllPoints()
	LoadingIcon:SetPoint("LEFT", HelpBrowserNavStop, "RIGHT")

	for i = 1, 9 do
		select(i, BrowserSettingsTooltip:GetRegions()):Hide()
	end

	F.CreateBD(BrowserSettingsTooltip)
	F.Reskin(BrowserSettingsTooltip.CacheButton)
	F.Reskin(BrowserSettingsTooltip.CookiesButton)
	F.Reskin(ReportCheatingDialogReportButton)
	F.Reskin(ReportCheatingDialogCancelButton)

	F.CreateBD(TicketStatusFrameButton)
	F.CreateSD(TicketStatusFrameButton)
	F.CreateBD(ReportCheatingDialog)
	F.CreateSD(ReportCheatingDialog)
end)