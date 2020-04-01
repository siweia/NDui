local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

    local r, g, b = DB.r, DB.g, DB.b

	B.StripTextures(HelpFrame)
	B.SetBD(HelpFrame)
	B.StripTextures(HelpFrame.Header)
    B.ReskinClose(HelpFrameCloseButton)

	B.StripTextures(HelpFrameMainInset)
	B.StripTextures(HelpFrameLeftInset)
	B.StripTextures(HelpBrowser.BrowserInset)

	B.CreateBDFrame(HelpFrameGM_ResponseScrollFrame1, .25)
	B.CreateBDFrame(HelpFrameGM_ResponseScrollFrame2, .25)
	B.CreateBDFrame(HelpFrameReportBugScrollFrame, .25)
	B.CreateBDFrame(HelpFrameSubmitSuggestionScrollFrame, .25)
	B.StripTextures(ReportCheatingDialogCommentFrame)
	B.CreateBDFrame(ReportCheatingDialogCommentFrame, .25)

	local scrolls = {
		"HelpFrameKnowledgebaseScrollFrameScrollBar",
		"HelpFrameReportBugScrollFrameScrollBar",
		"HelpFrameSubmitSuggestionScrollFrameScrollBar",
		"HelpFrameGM_ResponseScrollFrame1ScrollBar",
		"HelpFrameGM_ResponseScrollFrame2ScrollBar",
		"HelpFrameKnowledgebaseScrollFrame2ScrollBar",
	}
	for _, scroll in next, scrolls do
		B.ReskinScroll(_G[scroll])
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
		B.Reskin(_G[button])
	end

	B.StripTextures(HelpFrameKnowledgebase)
	B.ReskinInput(HelpFrameKnowledgebaseSearchBox)

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
		B.CreateBD(bu, 0)
		B.CreateGradient(bu)
	end

	local function colourTab(f)
		f.text:SetTextColor(1, 1, 1)
	end

	local function clearTab(f)
		f.text:SetTextColor(1, .8, 0)
	end

	local function styleTab(bu)
		bu.selected:SetColorTexture(r, g, b, .2)
		bu.selected:SetDrawLayer("BACKGROUND")
		bu.text:SetFont(DB.Font[1], 14, DB.Font[3])
		B.Reskin(bu, true)
		bu:SetScript("OnEnter", colourTab)
		bu:SetScript("OnLeave", clearTab)
	end

	for i = 1, 6 do
		styleTab(_G["HelpFrameButton"..i])
	end
	styleTab(HelpFrameButton16)

	HelpFrameAccountSecurityOpenTicket.text:SetFont(DB.Font[1], 14, DB.Font[3])
	HelpFrameOpenTicketHelpOpenTicket.text:SetFont(DB.Font[1], 14, DB.Font[3])

	HelpFrameCharacterStuckHearthstone:SetSize(56, 56)
	B.ReskinIcon(HelpFrameCharacterStuckHearthstone.IconTexture)

	B.Reskin(HelpBrowserNavHome)
	B.Reskin(HelpBrowserNavReload)
	B.Reskin(HelpBrowserNavStop)
	B.Reskin(HelpBrowserBrowserSettings)
	B.ReskinArrow(HelpBrowserNavBack, "left")
	B.ReskinArrow(HelpBrowserNavForward, "right")

	HelpBrowserNavHome:SetSize(18, 18)
	HelpBrowserNavReload:SetSize(18, 18)
	HelpBrowserNavStop:SetSize(18, 18)
	HelpBrowserBrowserSettings:SetSize(18, 18)

	HelpBrowserNavHome:SetPoint("BOTTOMLEFT", HelpBrowser, "TOPLEFT", 2, 4)
	HelpBrowserBrowserSettings:SetPoint("TOPRIGHT", HelpFrameCloseButton, "BOTTOMLEFT", -4, -1)
	LoadingIcon:ClearAllPoints()
	LoadingIcon:SetPoint("LEFT", HelpBrowserNavStop, "RIGHT")

	B.StripTextures(BrowserSettingsTooltip)
	B.SetBD(BrowserSettingsTooltip)
	B.Reskin(BrowserSettingsTooltip.CookiesButton)
	B.Reskin(ReportCheatingDialogReportButton)
	B.Reskin(ReportCheatingDialogCancelButton)

	B.StripTextures(TicketStatusFrameButton)
	B.SetBD(TicketStatusFrameButton)
	B.SetBD(ReportCheatingDialog)
	ReportCheatingDialog.Border:Hide()
end)