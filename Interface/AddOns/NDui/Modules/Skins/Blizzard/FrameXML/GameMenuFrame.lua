local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	GameMenuFrame.Header = GameMenuFrame.Header or GameMenuFrameHeader -- deprecated in 8.3
	if DB.isNewPatch then
		B.StripTextures(GameMenuFrame.Header)
	else
		GameMenuFrame.Header:SetAlpha(0)
	end
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	B.SetBD(GameMenuFrame)
	GameMenuFrame.Border:Hide()

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue
	}

	for _, button in next, buttons do
		B.Reskin(button)
	end
end)