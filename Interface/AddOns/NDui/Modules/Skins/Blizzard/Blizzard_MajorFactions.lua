local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_MajorFactions"] = function()
	if DB.isNewPatch then return end -- unseen, needs review

	local frame = _G.MajorFactionRenownFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	frame.NineSlice:SetAlpha(0)
	frame.Background:SetAlpha(0)
	B.Reskin(frame.LevelSkipButton)
end