local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	-- Battlenet toast frame
	B.CreateBD(BNToastFrame)
	B.CreateSD(BNToastFrame)
	B.CreateBD(BNToastFrame.TooltipFrame)
	B.CreateSD(BNToastFrame.TooltipFrame)

	-- Battletag invite frame
	B.CreateBD(BattleTagInviteFrame)
	B.CreateSD(BattleTagInviteFrame)
	local border, send, cancel = BattleTagInviteFrame:GetChildren()
	border:Hide()
	B.Reskin(send)
	B.Reskin(cancel)
end)