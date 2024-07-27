local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinOptionCheck(button)
	B.ReskinCheck(button)
	button.bg:SetInside(button, 6, 6)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local frame = EditModeManagerFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.Reskin(frame.RevertAllChangesButton)
	B.Reskin(frame.SaveChangesButton)
	B.ReskinDropDown(frame.LayoutDropdown)
	reskinOptionCheck(frame.ShowGridCheckButton.Button)
	reskinOptionCheck(frame.EnableSnapCheckButton.Button)
	reskinOptionCheck(frame.EnableAdvancedOptionsCheckButton.Button)
	B.ReskinStepperSlider(frame.GridSpacingSlider.Slider, true)
	if frame.Tutorial then
		frame.Tutorial.Ring:Hide()
	end

	local dialog = EditModeSystemSettingsDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)
	frame.AccountSettings.SettingsContainer.BorderArt:Hide()
	B.CreateBDFrame(frame.AccountSettings.SettingsContainer, .25)
	B.ReskinTrimScroll(frame.AccountSettings.SettingsContainer.ScrollBar)

	local function reskinOptionChecks(settings)
		for i = 1, settings:GetNumChildren() do
			local option = select(i, settings:GetChildren())
			if option.Button and not option.styled then
				reskinOptionCheck(option.Button)
				option.styled = true
			end
		end
	end

	hooksecurefunc(frame.AccountSettings, "OnEditModeEnter", function(self)
		local basicOptions = self.SettingsContainer.ScrollChild.BasicOptionsContainer
		if basicOptions then
			reskinOptionChecks(basicOptions)
		end

		local advancedOptions = self.SettingsContainer.ScrollChild.AdvancedOptionsContainer
		if advancedOptions.FramesContainer then
			reskinOptionChecks(advancedOptions.FramesContainer)
		end
		if advancedOptions.CombatContainer then
			reskinOptionChecks(advancedOptions.CombatContainer)
		end
		if advancedOptions.MiscContainer then
			reskinOptionChecks(advancedOptions.MiscContainer)
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
				B.ReskinDropDown(dropdown.Dropdown)
				dropdown.styled = true
			end
		end

		for slider in self.pools:EnumerateActiveByTemplate("EditModeSettingSliderTemplate") do
			if not slider.styled then
				B.ReskinStepperSlider(slider.Slider, true)
				slider.styled = true
			end
		end
	end)

	local dialog = EditModeUnsavedChangesDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.Reskin(dialog.SaveAndProceedButton)
	B.Reskin(dialog.ProceedButton)
	B.Reskin(dialog.CancelButton)

	local function ReskinLayoutDialog(dialog)
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.Reskin(dialog.AcceptButton)
		B.Reskin(dialog.CancelButton)

		local check = dialog.CharacterSpecificLayoutCheckButton
		if check then
			B.ReskinCheck(check.Button)
			check.Button.bg:SetInside(nil, 6, 6)
		end

		local editbox = dialog.LayoutNameEditBox
		if editbox then
			B.ReskinEditBox(editbox)
			editbox.__bg:SetPoint("TOPLEFT", -5, -5)
			editbox.__bg:SetPoint("BOTTOMRIGHT", 5, 5)
		end

		local importBox = dialog.ImportBox
		if importBox then
			B.StripTextures(importBox)
			B.CreateBDFrame(importBox, .25)
		end
	end

	ReskinLayoutDialog(EditModeNewLayoutDialog)
	ReskinLayoutDialog(EditModeImportLayoutDialog)
end)