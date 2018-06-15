local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	for i = 1, 3 do
		select(i, QuickJoinScrollFrame:GetRegions()):Hide()
	end
	F.ReskinScroll(QuickJoinScrollFrameScrollBar)
	F.Reskin(QuickJoinFrame.JoinQueueButton)

	F.CreateBD(QuickJoinRoleSelectionFrame)
	F.CreateSD(QuickJoinRoleSelectionFrame)
	F.Reskin(QuickJoinRoleSelectionFrame.AcceptButton)
	F.Reskin(QuickJoinRoleSelectionFrame.CancelButton)
	F.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
	F.StripTextures(QuickJoinRoleSelectionFrame)

	for _, bu in pairs({QuickJoinRoleSelectionFrame.RoleButtonTank, QuickJoinRoleSelectionFrame.RoleButtonHealer, QuickJoinRoleSelectionFrame.RoleButtonDPS}) do
		bu.Cover:SetTexture(C.media.roleIcons)
		bu:SetNormalTexture(C.media.roleIcons)
		bu.CheckButton:SetFrameLevel(bu:GetFrameLevel() + 2)
		F.ReskinCheck(bu.CheckButton)
		local bg = F.CreateBDFrame(QuickJoinRoleSelectionFrame, 1)
		bg:SetPoint("TOPLEFT", bu, 9, -7)
		bg:SetPoint("BOTTOMRIGHT", bu, -9, 11)
	end
end)