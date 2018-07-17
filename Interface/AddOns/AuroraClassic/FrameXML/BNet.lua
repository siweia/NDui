local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	-- Battlenet toast frame
	F.CreateBD(BNToastFrame)
	F.CreateSD(BNToastFrame)
	F.CreateBD(BNToastFrame.TooltipFrame)
	F.CreateSD(BNToastFrame.TooltipFrame)

	-- Battletag invite frame
	F.CreateBD(BattleTagInviteFrame)
	F.CreateSD(BattleTagInviteFrame)
	local send, cancel = BattleTagInviteFrame:GetChildren()
	F.Reskin(send)
	F.Reskin(cancel)
end)