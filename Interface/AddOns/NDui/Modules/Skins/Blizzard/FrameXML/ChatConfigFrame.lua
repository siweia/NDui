local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function reskinPickerOptions(self)
	local scrollTarget = self.ScrollBox.ScrollTarget
	if scrollTarget then
		for i = 1, scrollTarget:GetNumChildren() do
			local child = select(i, scrollTarget:GetChildren())
			if not child.styled then
				child.UnCheck:SetTexture(nil)
				child.Highlight:SetColorTexture(r, g, b, .25)

				local check = child.Check
				check:SetColorTexture(r, g, b, .6)
				check:SetSize(10, 10)
				check:SetPoint("LEFT", 2, 0)
				B.CreateBDFrame(check, .25)

				child.styled = true
			end
		end
	end
end

local function ReskinVoicePicker(voicePicker)
	local customFrame = voicePicker:GetChildren()
	B.StripTextures(customFrame)
	B.SetBD(customFrame, .7)
	voicePicker:HookScript("OnShow", reskinPickerOptions)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ChatConfigFrame)
	B.SetBD(ChatConfigFrame)
	B.StripTextures(ChatConfigFrame.Header)

	hooksecurefunc("ChatConfig_UpdateCheckboxes", function(frame)
		if not FCF_GetCurrentChatFrame() then return end

		local nameString = frame:GetName().."CheckBox"
		for index in ipairs(frame.checkBoxTable) do
			local checkBoxName = nameString..index
			local checkbox = _G[checkBoxName]
			if checkbox and not checkbox.styled then
				checkbox:HideBackdrop()
				local bg = B.CreateBDFrame(checkbox, .25)
				bg:SetInside()
				B.ReskinCheck(_G[checkBoxName.."Check"])

				checkbox.styled = true
			end
		end
	end)

	hooksecurefunc("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		if frame.styled then return end

		local nameString = frame:GetName().."CheckBox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = nameString..index
			B.ReskinCheck(_G[checkBoxName])

			if value.subTypes then
				for i in ipairs(value.subTypes) do
					B.ReskinCheck(_G[checkBoxName.."_"..i])
				end
			end
		end

		frame.styled = true
	end)

	hooksecurefunc(ChatConfigFrameChatTabManager, "UpdateWidth", function(self)
		for tab in self.tabPool:EnumerateActive() do
			if not tab.styled then
				B.StripTextures(tab)

				tab.styled = true
			end
		end
	end)

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]
		if tab then
			B.StripTextures(tab)
			if tab.Text then
				tab.Text:SetWidth(tab.Text:GetWidth() + 10)
			end
		end
	end

	local line = ChatConfigFrame:CreateTexture()
	line:SetSize(C.mult, 460)
	line:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT")
	line:SetColorTexture(1, 1, 1, .25)

	local backdrops = {
		ChatConfigCategoryFrame,
		ChatConfigBackgroundFrame,
		ChatConfigCombatSettingsFilters,
		CombatConfigColorsHighlighting,
		CombatConfigColorsColorizeUnitName,
		CombatConfigColorsColorizeSpellNames,
		CombatConfigColorsColorizeDamageNumber,
		CombatConfigColorsColorizeDamageSchool,
		CombatConfigColorsColorizeEntireLine,
		ChatConfigChatSettingsLeft,
		ChatConfigOtherSettingsCombat,
		ChatConfigOtherSettingsPVP,
		ChatConfigOtherSettingsSystem,
		ChatConfigOtherSettingsCreature,
		ChatConfigChannelSettingsLeft,
		CombatConfigMessageSourcesDoneBy,
		CombatConfigColorsUnitColors,
		CombatConfigMessageSourcesDoneTo,
	}
	for _, frame in pairs(backdrops) do
		B.StripTextures(frame)
	end

	local combatBoxes = {
		CombatConfigColorsHighlightingLine,
		CombatConfigColorsHighlightingAbility,
		CombatConfigColorsHighlightingDamage,
		CombatConfigColorsHighlightingSchool,
		CombatConfigColorsColorizeUnitNameCheck,
		CombatConfigColorsColorizeSpellNamesCheck,
		CombatConfigColorsColorizeSpellNamesSchoolColoring,
		CombatConfigColorsColorizeDamageNumberCheck,
		CombatConfigColorsColorizeDamageNumberSchoolColoring,
		CombatConfigColorsColorizeDamageSchoolCheck,
		CombatConfigColorsColorizeEntireLineCheck,
		CombatConfigFormattingShowTimeStamp,
		CombatConfigFormattingShowBraces,
		CombatConfigFormattingUnitNames,
		CombatConfigFormattingSpellNames,
		CombatConfigFormattingItemNames,
		CombatConfigFormattingFullText,
		CombatConfigSettingsShowQuickButton,
		CombatConfigSettingsSolo,
		CombatConfigSettingsParty,
		CombatConfigSettingsRaid
	}
	for _, box in pairs(combatBoxes) do
		B.ReskinCheck(box)
	end

	hooksecurefunc("ChatConfig_UpdateSwatches", function(frame)
		if not frame.swatchTable then return end

		local nameString = frame:GetName().."Swatch"
		local baseName, colorSwatch
		for index in ipairs(frame.swatchTable) do
			baseName = nameString..index
			local bu = _G[baseName]
			if not bu.styled then
				B.StripTextures(bu)
				B.CreateBDFrame(bu, .25):SetInside()
				B.ReskinColorSwatch(_G[baseName.."ColorSwatch"])
				bu.styled = true
			end
		end
	end)

	local bg = B.CreateBDFrame(ChatConfigCombatSettingsFilters, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", 0, 1)

	B.Reskin(CombatLogDefaultButton)
	B.Reskin(ChatConfigCombatSettingsFiltersCopyFilterButton)
	B.Reskin(ChatConfigCombatSettingsFiltersAddFilterButton)
	B.Reskin(ChatConfigCombatSettingsFiltersDeleteButton)
	B.Reskin(CombatConfigSettingsSaveButton)
	B.Reskin(ChatConfigFrameOkayButton)
	B.Reskin(ChatConfigFrameDefaultButton)
	B.Reskin(ChatConfigFrameRedockButton)
	B.Reskin(ChatConfigFrame.ToggleChatButton)
	B.ReskinArrow(ChatConfigMoveFilterUpButton, "up")
	B.ReskinArrow(ChatConfigMoveFilterDownButton, "down")
	B.ReskinInput(CombatConfigSettingsNameEditBox)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineBySource)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineByTarget)
	B.ReskinColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	B.ReskinColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)
	B.ReskinTrimScroll(ChatConfigCombatSettingsFilters.ScrollBar)

	ChatConfigMoveFilterUpButton:SetSize(22, 22)
	ChatConfigMoveFilterDownButton:SetSize(22, 22)

	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, 0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)

	-- TextToSpeech
	B.StripTextures(TextToSpeechButton, 5)

	B.Reskin(TextToSpeechFramePlaySampleButton)
	B.Reskin(TextToSpeechFramePlaySampleAlternateButton)
	B.Reskin(TextToSpeechDefaultButton)
	B.ReskinCheck(TextToSpeechCharacterSpecificButton)

	B.ReskinDropDown(TextToSpeechFrameTtsVoiceDropdown)
	B.ReskinDropDown(TextToSpeechFrameTtsVoiceAlternateDropdown)
	B.ReskinSlider(TextToSpeechFrameAdjustRateSlider)
	B.ReskinSlider(TextToSpeechFrameAdjustVolumeSlider)

	local checkboxes = {
		"PlayActivitySoundWhenNotFocusedCheckButton",
		"PlaySoundSeparatingChatLinesCheckButton",
		"AddCharacterNameToSpeechCheckButton",
		"NarrateMyMessagesCheckButton",
		"UseAlternateVoiceForSystemMessagesCheckButton",
	}
	for _, checkbox in pairs(checkboxes) do
		local check = TextToSpeechFramePanelContainer[checkbox]
		B.ReskinCheck(check)
		check.bg:SetInside(check, 6, 6)
	end

	hooksecurefunc("TextToSpeechFrame_UpdateMessageCheckboxes", function(frame)
		local checkBoxTable = frame.checkBoxTable
		if checkBoxTable then
			local checkBoxNameString = frame:GetName().."CheckBox"
			local checkBoxName, checkBox
			for index in ipairs(checkBoxTable) do
				checkBoxName = checkBoxNameString..index
				checkBox = _G[checkBoxName]
				if checkBox and not checkBox.styled then
					B.ReskinCheck(checkBox)
					checkBox.bg:SetInside(checkBox, 6, 6)
					checkBox.styled = true
				end
			end
		end
	end)

	-- voice pickers
	ReskinVoicePicker(TextToSpeechFrameTtsVoicePicker)
	ReskinVoicePicker(TextToSpeechFrameTtsVoiceAlternatePicker)

	B.StripTextures(ChatConfigTextToSpeechChannelSettingsLeft)
end)