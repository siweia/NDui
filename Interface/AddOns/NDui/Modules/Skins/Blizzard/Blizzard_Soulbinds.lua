local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Soulbinds"] = function()
	B.ReskinClose(SoulbindViewer.CloseButton)
	B.Reskin(SoulbindViewer.ActivateButton)
end