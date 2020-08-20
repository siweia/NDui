local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Soulbinds"] = function()
	B.StripTextures(SoulbindViewer)
	SoulbindViewer.Background:SetAlpha(0)
	B.SetBD(SoulbindViewer)
	B.ReskinClose(SoulbindViewer.CloseButton)
	B.Reskin(SoulbindViewer.CommitConduitsButton)
	B.Reskin(SoulbindViewer.ActivateSoulbindButton)
end