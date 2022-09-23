local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(HelpFrame)
	B.SetBD(HelpFrame)
	if DB.isNewPatch then
		B.ReskinClose(HelpFrame.CloseButton)
	else
		B.ReskinClose(HelpFrameCloseButton)
	end
	B.StripTextures(HelpBrowser.BrowserInset)

	B.StripTextures(BrowserSettingsTooltip)
	B.SetBD(BrowserSettingsTooltip)
	B.Reskin(BrowserSettingsTooltip.CookiesButton)

	B.StripTextures(TicketStatusFrameButton)
	B.SetBD(TicketStatusFrameButton)

	B.SetBD(ReportCheatingDialog)
	ReportCheatingDialog.Border:Hide()
	B.Reskin(ReportCheatingDialogReportButton)
	B.Reskin(ReportCheatingDialogCancelButton)
	B.StripTextures(ReportCheatingDialogCommentFrame)
	B.CreateBDFrame(ReportCheatingDialogCommentFrame, .25)
end)