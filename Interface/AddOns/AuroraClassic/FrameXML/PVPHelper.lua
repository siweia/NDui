local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local PVPReadyDialog = PVPReadyDialog

	PVPReadyDialogBackground:Hide()
	PVPReadyDialogBottomArt:Hide()
	PVPReadyDialogFiligree:Hide()
	PVPReadyDialogRoleIconTexture:SetTexture(C.media.roleIcons)

	local bg = F.CreateBDFrame(PVPReadyDialogRoleIcon, 1)
	bg:SetPoint("TOPLEFT", 9, -7)
	bg:SetPoint("BOTTOMRIGHT", -8, 10)

	F.CreateBD(PVPReadyDialog)
	F.CreateSD(PVPReadyDialog)
	PVPReadyDialog.SetBackdrop = F.dummy

	F.Reskin(PVPReadyDialog.enterButton)
	F.Reskin(PVPReadyDialog.leaveButton)
	F.ReskinClose(PVPReadyDialogCloseButton)
end)