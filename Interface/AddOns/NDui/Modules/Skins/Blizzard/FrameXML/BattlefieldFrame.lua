local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	-- WorldStateScoreFrame
	B.ReskinPortraitFrame(WorldStateScoreFrame)
	B.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreScrollFrameScrollBar:SetPoint("TOPLEFT", WorldStateScoreScrollFrame, "TOPRIGHT", 38, -16) -- don't overlay with scroll buttons
	for i = 1, 3 do
		B.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end
	B.Reskin(WorldStateScoreFrameLeaveButton)

	-- ArenaRegistrarFrame
	ArenaAvailableServicesText:SetTextColor(1, 1, 1)
	ArenaAvailableServicesText:SetShadowColor(0, 0, 0)

	B.ReskinPortraitFrame(ArenaRegistrarFrame)
	B.StripTextures(ArenaRegistrarGreetingFrame)
	ArenaRegistrarFrameEditBox:SetHeight(20)
	ArenaRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	B.ReskinEditBox(ArenaRegistrarFrameEditBox)
	B.Reskin(ArenaRegistrarFrameGoodbyeButton)
	B.Reskin(ArenaRegistrarFramePurchaseButton)
	B.Reskin(ArenaRegistrarFrameCancelButton)
end)