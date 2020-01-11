local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local function stripBorders(self)
		B.StripTextures(self)
	end

	-- match score
	B.SetBD(PVPMatchScoreboard)
	PVPMatchScoreboard:HookScript("OnShow", stripBorders)
	B.ReskinClose(PVPMatchScoreboard.CloseButton)

	local content = PVPMatchScoreboard.Content
	local tabContainer = content.TabContainer

	B.StripTextures(content)
	local bg = B.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	B.ReskinScroll(content.ScrollFrame.ScrollBar)

	B.StripTextures(tabContainer)
	for i = 1, 3 do
		B.ReskinTab(tabContainer.TabGroup["Tab"..i])
	end

	-- match results
	B.SetBD(PVPMatchResults)
	PVPMatchResults:HookScript("OnShow", stripBorders)
	B.ReskinClose(PVPMatchResults.CloseButton)
	B.StripTextures(PVPMatchResults.overlay)

	local content = PVPMatchResults.content
	local tabContainer = content.tabContainer

	B.StripTextures(content)
	local bg = B.CreateBDFrame(content, .25)
	bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
	B.StripTextures(content.earningsArt)
	B.ReskinScroll(content.scrollFrame.scrollBar)

	B.StripTextures(tabContainer)
	for i = 1, 3 do
		B.ReskinTab(tabContainer.tabGroup["tab"..i])
	end

	local buttonContainer = PVPMatchResults.buttonContainer
	B.Reskin(buttonContainer.leaveButton)
	B.Reskin(buttonContainer.requeueButton)
end)