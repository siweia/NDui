local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.StripTextures(PVPMatchScoreboard)
	F.SetBD(PVPMatchScoreboard)
	F.ReskinClose(PVPMatchScoreboard.CloseButton)

	F.StripTextures(PVPMatchScoreboard.Content)
	F.ReskinScroll(PVPMatchScoreboard.Content.ScrollFrame.ScrollBar)
	F.StripTextures(PVPMatchScoreboard.Content.TabContainer)
	for i = 1, 3 do
		F.ReskinTab(PVPMatchScoreboard.Content.TabContainer.TabGroup["Tab"..i])
	end

	F.StripTextures(PVPMatchResults)
	F.SetBD(PVPMatchResults)
	F.ReskinClose(PVPMatchResults.CloseButton)

	F.StripTextures(PVPMatchResults.content)
	F.StripTextures(PVPMatchResults.content.earningsArt)
	F.ReskinScroll(PVPMatchResults.content.scrollFrame.scrollBar)
	F.StripTextures(PVPMatchResults.content.tabContainer)
	for i = 1, 3 do
		F.ReskinTab(PVPMatchResults.content.tabContainer.tabGroup["tab"..i])
	end
	F.Reskin(PVPMatchResults.buttonContainer.leaveButton)
	F.Reskin(PVPMatchResults.buttonContainer.requeueButton)
end)