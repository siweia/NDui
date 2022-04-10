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

	-- ArenaFrame
	B.ReskinPortraitFrame(ArenaFrame, 15, -15, -35, 73)
	B.Reskin(ArenaFrameJoinButton)
	B.Reskin(ArenaFrameCancelButton)
	B.Reskin(ArenaFrameGroupJoinButton)

	-- Temp fix for ArenaFrame label
	local relF, parent, relT, x, y = ArenaFrameFrameLabel:GetPoint()
	if parent == BattlefieldFrame then
		ArenaFrameFrameLabel:SetPoint(relF, ArenaFrame, relT, x, y)
	end

	-- ArenaRegistrarFrame
	ArenaAvailableServicesText:SetTextColor(1, 1, 1)
	ArenaAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(ArenaRegistrarFrame, 15, -15, -30, 65)
	B.StripTextures(ArenaRegistrarGreetingFrame)
	ArenaRegistrarFrameEditBox:SetHeight(20)
	ArenaRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(ArenaRegistrarFrameEditBox)
	B.Reskin(ArenaRegistrarFrameGoodbyeButton)
	B.Reskin(ArenaRegistrarFramePurchaseButton)
	B.Reskin(ArenaRegistrarFrameCancelButton)
end)