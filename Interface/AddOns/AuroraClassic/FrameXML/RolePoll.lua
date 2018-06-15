local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.CreateBD(RolePollPopup)
	F.CreateSD(RolePollPopup)
	F.Reskin(RolePollPopupAcceptButton)
	F.ReskinClose(RolePollPopupCloseButton)

	for _, roleButton in pairs({RolePollPopupRoleButtonTank, RolePollPopupRoleButtonHealer, RolePollPopupRoleButtonDPS}) do
		roleButton.cover:SetTexture(C.media.roleIcons)
		roleButton:SetNormalTexture(C.media.roleIcons)
		roleButton.checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)
		local bg = F.CreateBDFrame(roleButton, 1)
		bg:SetPoint("TOPLEFT", 9, -7)
		bg:SetPoint("BOTTOMRIGHT", -9, 11)

		F.ReskinRadio(roleButton.checkButton)
	end
end)