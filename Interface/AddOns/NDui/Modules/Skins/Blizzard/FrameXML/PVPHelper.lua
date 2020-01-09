local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

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
end)