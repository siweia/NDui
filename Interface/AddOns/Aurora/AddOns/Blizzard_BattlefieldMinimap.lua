local F, C = unpack(select(2, ...))

C.themes["Blizzard_BattlefieldMinimap"] = function()
	F.SetBD(BattlefieldMinimap, -1, 1, -5, 3)
	BattlefieldMinimapCorner:Hide()
	BattlefieldMinimapBackground:Hide()
	BattlefieldMinimapCloseButton:Hide()
end