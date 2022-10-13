local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GenericTraitUI"] = function()
	local frame = GenericTraitFrame

	B.StripTextures(frame)
	B.ReskinClose(frame.CloseButton)
	B.SetBD(frame)

	B.ReplaceIconString(frame.Currency.UnspentPointsCount)
	hooksecurefunc(frame.Currency.UnspentPointsCount, "SetText", B.ReplaceIconString)
end