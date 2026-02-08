local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.SetBD(ReadyCheckFrame)
	ReadyCheckPortrait:SetAlpha(0)
	select(2, ReadyCheckListenerFrame:GetRegions()):Hide()

	ReadyCheckFrame:HookScript("OnShow", function(self)
		if self.initiator and UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

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