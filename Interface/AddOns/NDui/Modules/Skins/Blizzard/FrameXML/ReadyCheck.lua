local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Ready check
	B.StripTextures(ReadyCheckListenerFrame)
	B.SetBD(ReadyCheckListenerFrame, nil, 30, -1, 1, -1)
	ReadyCheckPortrait:SetAlpha(0)

	B.Reskin(ReadyCheckFrameYesButton)
	B.Reskin(ReadyCheckFrameNoButton)

	-- Role poll
	B.StripTextures(RolePollPopup)
	B.SetBD(RolePollPopup)
	B.Reskin(RolePollPopupAcceptButton)
	B.ReskinClose(RolePollPopupCloseButton)

	B.ReskinRole(RolePollPopupRoleButtonTank, "TANK")
	B.ReskinRole(RolePollPopupRoleButtonHealer, "HEALER")
	B.ReskinRole(RolePollPopupRoleButtonDPS, "DPS")
end)