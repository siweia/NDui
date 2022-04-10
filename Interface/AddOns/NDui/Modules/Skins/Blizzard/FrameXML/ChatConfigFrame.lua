local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.StripTextures(ChatConfigFrame)
	B.SetBD(ChatConfigFrame)
	ChatConfigFrameHeader:SetAlpha(0)

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
				local swatch = _G[checkBoxName.."ColorSwatch"]
				if swatch then
					B.ReskinColorSwatch(_G[checkBoxName.."ColorSwatch"])
				end

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
				for k in ipairs(value.subTypes) do
					B.ReskinCheck(_G[checkBoxName.."_"..k])
				end
			end
		end

		frame.styled = true
	end)

	hooksecurefunc("ChatConfig_CreateBoxes", function(frame, boxTable)
		local nameString = frame:GetName().."Box"
		for index in ipairs(boxTable) do
			local boxName = nameString..index
			local box = _G[boxName]
			if box and not box.styled then
				box:HideBackdrop()
				local bg = B.CreateBDFrame(box, .25)
				bg:SetInside()
				B.Reskin(_G[boxName.."Button"])

				box.styled = true
			end
		end
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
		B.StripTextures(_G["CombatConfigTab"..i])
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
		ChatConfigChannelSettingsAvailable,
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
	B.ReskinScroll(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
	ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Hide()

	ChatConfigMoveFilterUpButton:SetSize(22, 22)
	ChatConfigMoveFilterDownButton:SetSize(22, 22)

	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, 0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
end)