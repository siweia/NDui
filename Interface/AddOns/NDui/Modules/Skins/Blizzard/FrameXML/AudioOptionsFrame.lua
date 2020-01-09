local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	AudioOptionsFrame.Header = AudioOptionsFrame.Header or AudioOptionsFrameHeader -- deprecated in 8.3
	if DB.isNewPatch then
		B.StripTextures(AudioOptionsFrame.Header)
	else
		AudioOptionsFrame.Header:SetAlpha(0)
	end
	AudioOptionsFrame.Header:ClearAllPoints()
	AudioOptionsFrame.Header:SetPoint("TOP", AudioOptionsFrame, 0, 0)
	B.CreateBD(AudioOptionsFrame)
	B.CreateSD(AudioOptionsFrame)
	B.Reskin(AudioOptionsFrameOkay)
	B.Reskin(AudioOptionsFrameCancel)
	B.Reskin(AudioOptionsFrameDefaults)
end)