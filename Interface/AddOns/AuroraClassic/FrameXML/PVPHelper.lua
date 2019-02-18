local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local PVPReadyDialog = PVPReadyDialog

	F.StripTextures(PVPReadyDialog)
	PVPReadyDialogBackground:Hide()
	F.SetBD(PVPReadyDialog)
	PVPReadyDialogRoleIconTexture:SetTexture(C.media.roleIcons)
	F.CreateBDFrame(PVPReadyDialogRoleIcon)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, _, _, role)
		if self.roleIcon:IsShown() then
			self.roleIcon.texture:SetTexCoord(F.GetRoleTexCoord(role))
		end
	end)

	F.Reskin(PVPReadyDialog.enterButton)
	F.Reskin(PVPReadyDialog.leaveButton)
	F.ReskinClose(PVPReadyDialogCloseButton)
end)