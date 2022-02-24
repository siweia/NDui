local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- ready dialog
	local PVPReadyDialog = PVPReadyDialog

	B.StripTextures(PVPReadyDialog)
	PVPReadyDialogBackground:Hide()
	B.SetBD(PVPReadyDialog)
	PVPReadyDialogRoleIconTexture:SetTexture(DB.rolesTex)
	B.CreateBDFrame(PVPReadyDialogRoleIcon)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, _, _, role)
		if self.roleIcon:IsShown() then
			self.roleIcon.texture:SetTexCoord(B.GetRoleTexCoord(role))
		end
	end)

	B.Reskin(PVPReadyDialog.enterButton)
	B.Reskin(PVPReadyDialog.leaveButton)
	B.ReskinClose(PVPReadyDialogCloseButton)

	local function stripBorders(self)
		B.StripTextures(self)
	end

	ReadyStatus.Border:SetAlpha(0)
	B.SetBD(ReadyStatus)
	B.ReskinClose(ReadyStatus.CloseButton)

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