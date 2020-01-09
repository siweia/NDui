local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.ReskinScroll(QuickJoinScrollFrame.scrollBar)
	B.Reskin(QuickJoinFrame.JoinQueueButton)

	B.CreateBD(QuickJoinRoleSelectionFrame)
	B.CreateSD(QuickJoinRoleSelectionFrame)
	B.Reskin(QuickJoinRoleSelectionFrame.AcceptButton)
	B.Reskin(QuickJoinRoleSelectionFrame.CancelButton)
	B.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
	B.StripTextures(QuickJoinRoleSelectionFrame)

	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, "TANK")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, "HEALER")
	B.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, "DPS")
end)