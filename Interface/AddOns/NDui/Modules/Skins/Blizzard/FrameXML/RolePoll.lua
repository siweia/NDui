local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(RolePollPopup)
	B.SetBD(RolePollPopup)
	B.Reskin(RolePollPopupAcceptButton)
	B.ReskinClose(RolePollPopupCloseButton)

	B.ReskinRole(RolePollPopupRoleButtonTank, "TANK")
	B.ReskinRole(RolePollPopupRoleButtonHealer, "HEALER")
	B.ReskinRole(RolePollPopupRoleButtonDPS, "DPS")
end)