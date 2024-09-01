local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if DB.isNewPatch then return end

	AudioOptionsFrameHeader:SetAlpha(0)
	AudioOptionsFrameHeader:ClearAllPoints()
	AudioOptionsFrameHeader:SetPoint("TOP", AudioOptionsFrame, 0, 0)
	B.StripTextures(AudioOptionsFrame)
	B.SetBD(AudioOptionsFrame)
	B.Reskin(AudioOptionsFrameOkay)
	B.Reskin(AudioOptionsFrameCancel)
	B.Reskin(AudioOptionsFrameDefaults)
end)