local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinOptionCheck(button)
	B.ReskinCheck(button)
	button.bg:SetInside(button, 6, 6)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	if not DB.isNewPatch then return end

	local frame = EditModeManagerFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.Reskin(frame.RevertAllChangesButton)
	B.Reskin(frame.SaveChangesButton)
	B.ReskinDropDown(frame.LayoutDropdown.DropDownMenu)
	reskinOptionCheck(frame.ShowGridCheckButton.Button)
	if frame.Tutorial then
		frame.Tutorial.Ring:Hide()
	end

	local dialog = EditModeSystemSettingsDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)

	hooksecurefunc(frame.AccountSettings, "OnEditModeEnter", function(self)
		for i = 1, self.Settings:GetNumChildren() do
			local option = select(i, self.Settings:GetChildren())
			if option.Button and not option.styled then
				reskinOptionCheck(option.Button)
				option.styled = true
			end
		end
	end)

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
				check.Button.bg:SetInside(nil, 6, 6)
				check.styled = true
			end
		end

		for dropdown in self.pools:EnumerateActiveByTemplate("EditModeSettingDropdownTemplate") do
			if not dropdown.styled then
				B.ReskinDropDown(dropdown.Dropdown.DropDownMenu)
				dropdown.styled = true
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