local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- BattlefieldFrame
	B.ReskinPortraitFrame(BattlefieldFrame, 15, -15, -35, 73)
	B.ReskinScroll(BattlefieldListScrollFrameScrollBar)
	B.Reskin(BattlefieldFrameJoinButton)
	B.Reskin(BattlefieldFrameCancelButton)
	B.Reskin(BattlefieldFrameGroupJoinButton)
	BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)

	-- WorldStateScoreFrame
	B.ReskinPortraitFrame(WorldStateScoreFrame, 13, -15, -108, 70)
	B.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	for i = 1, 3 do
		B.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end
	B.Reskin(WorldStateScoreFrameLeaveButton)
end)