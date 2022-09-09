local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not DB.isNewPatch then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local frame = SettingsPanel

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.ClosePanelButton)
	B.ReskinEditBox(frame.SearchBox)
	B.Reskin(frame.Container.SettingsList.Header.DefaultsButton)
	B.Reskin(frame.CloseButton)
end)