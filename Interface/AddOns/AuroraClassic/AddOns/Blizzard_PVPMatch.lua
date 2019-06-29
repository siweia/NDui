local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local function stripBorders(self)
		F.StripTextures(self)
	end

	-- match score
	F.SetBD(PVPMatchScoreboard)
	PVPMatchScoreboard:HookScript("OnShow", stripBorders)
	F.ReskinClose(PVPMatchScoreboard.CloseButton)

	local content = PVPMatchScoreboard.Content
	local tabContainer = content.TabContainer

	F.StripTextures(content)
	local bg = F.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	F.ReskinScroll(content.ScrollFrame.ScrollBar)

	F.StripTextures(tabContainer)
	for i = 1, 3 do
		F.ReskinTab(tabContainer.TabGroup["Tab"..i])
	end

	-- match results
	F.SetBD(PVPMatchResults)
	PVPMatchResults:HookScript("OnShow", stripBorders)
	F.ReskinClose(PVPMatchResults.CloseButton)
	F.StripTextures(PVPMatchResults.overlay)

	local content = PVPMatchResults.content
	local tabContainer = content.tabContainer

	F.StripTextures(content)
	local bg = F.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	F.StripTextures(content.earningsArt)
	F.ReskinScroll(content.scrollFrame.scrollBar)

	F.StripTextures(tabContainer)
	for i = 1, 3 do
		F.ReskinTab(tabContainer.tabGroup["tab"..i])
	end

	local buttonContainer = PVPMatchResults.buttonContainer
	F.Reskin(buttonContainer.leaveButton)
	F.Reskin(buttonContainer.requeueButton)
end)