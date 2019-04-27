local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	GameMenuFrameHeader:SetAlpha(0)
	GameMenuFrameHeader:ClearAllPoints()
	GameMenuFrameHeader:SetPoint("TOP", GameMenuFrame, 0, 7)
	F.CreateBD(GameMenuFrame)
	F.CreateSD(GameMenuFrame)
	if C.isNewPatch then GameMenuFrame.Border:Hide() end

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
		F.Reskin(button)
	end
end)