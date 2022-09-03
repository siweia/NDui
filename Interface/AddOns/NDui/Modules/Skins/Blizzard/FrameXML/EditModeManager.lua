local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	if not DB.isNewPatch then return end

	local frame = EditModeManagerFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.Reskin(frame.RevertAllChangesButton)
	B.Reskin(frame.SaveChangesButton)

	local dialog = EditModeSystemSettingsDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)

	hooksecurefunc(dialog, "UpdateExtraButtons", function(self)
		local revertButton = self.Buttons and self.Buttons.RevertChangesButton
		if revertButton and not revertButton.styled then
			B.Reskin(revertButton)
			revertButton.styled = true
		end

		for button in self.pools:EnumerateActiveByTemplate("EditModeSystemSettingsDialogExtraButtonTemplate") do
			if not button.styled then
				B.Reskin(button)
				button.styled = true
			end
		end

		for check in self.pools:EnumerateActiveByTemplate("EditModeSettingCheckboxTemplate") do
			if not check.styled then
				B.ReskinCheck(check.Button)
				check.styled = true
			end
		end
	end)

	local dialog = EditModeUnsavedChangesDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.Reskin(dialog.SaveAndProceedButton)
	B.Reskin(dialog.ProceedButton)
	B.Reskin(dialog.CancelButton)
end)