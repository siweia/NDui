local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ReforgingUI"] = function()
	B.ReskinPortraitFrame(ReforgingFrame)
	ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1)
	B.StripTextures(ReforgingFrameButtonFrame)
	B.Reskin(ReforgingFrameRestoreButton)
	B.Reskin(ReforgingFrameReforgeButton)
end