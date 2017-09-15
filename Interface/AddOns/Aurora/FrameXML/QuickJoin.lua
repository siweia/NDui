local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
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
	for i = 1, 9 do
		select(i, QuickJoinRoleSelectionFrame:GetRegions()):Hide()
	end

	for _, bu in pairs({QuickJoinRoleSelectionFrame.RoleButtonTank, QuickJoinRoleSelectionFrame.RoleButtonHealer, QuickJoinRoleSelectionFrame.RoleButtonDPS}) do
		bu.Cover:SetTexture(C.media.roleIcons)
		bu:SetNormalTexture(C.media.roleIcons)
		bu.CheckButton:SetFrameLevel(bu:GetFrameLevel() + 2)
		F.ReskinCheck(bu.CheckButton)

		local left = QuickJoinRoleSelectionFrame:CreateTexture(nil, "OVERLAY")
		left:SetWidth(1.2)
		left:SetTexture(C.media.backdrop)
		left:SetVertexColor(0, 0, 0)
		left:SetPoint("TOPLEFT", bu, 8, -6)
		left:SetPoint("BOTTOMLEFT", bu, 8, 10)

		local right = QuickJoinRoleSelectionFrame:CreateTexture(nil, "OVERLAY")
		right:SetWidth(1.2)
		right:SetTexture(C.media.backdrop)
		right:SetVertexColor(0, 0, 0)
		right:SetPoint("TOPRIGHT", bu, -8, -6)
		right:SetPoint("BOTTOMRIGHT", bu, -8, 10)

		local top = QuickJoinRoleSelectionFrame:CreateTexture(nil, "OVERLAY")
		top:SetHeight(1.2)
		top:SetTexture(C.media.backdrop)
		top:SetVertexColor(0, 0, 0)
		top:SetPoint("TOPLEFT", bu, 8, -6)
		top:SetPoint("TOPRIGHT", bu, -8, -6)

		local bottom = QuickJoinRoleSelectionFrame:CreateTexture(nil, "OVERLAY")
		bottom:SetHeight(1.2)
		bottom:SetTexture(C.media.backdrop)
		bottom:SetVertexColor(0, 0, 0)
		bottom:SetPoint("BOTTOMLEFT", bu, 8, 10)
		bottom:SetPoint("BOTTOMRIGHT", bu, -8, 10)
	end
end)