local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local frame = QuickKeybindFrame
	B.StripTextures(frame)
	B.StripTextures(frame.Header)
	B.SetBD(frame)
	B.ReskinCheck(frame.UseCharacterBindingsButton)
	frame.UseCharacterBindingsButton:SetSize(24, 24)
	B.Reskin(frame.OkayButton)
	B.Reskin(frame.DefaultsButton)
	B.Reskin(frame.CancelButton)
end)