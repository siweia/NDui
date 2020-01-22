local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ChatConfigFrame)
	B.SetBD(ChatConfigFrame)
	B.StripTextures(ChatConfigFrame.Header)
	ChatConfigFrame.Header:SetPoint("TOP", ChatConfigFrame, 0, 0)

	hooksecurefunc("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable)
		if frame.styled then return end

		frame:SetBackdrop(nil)
		for index in ipairs(checkBoxTable) do
			local checkBoxName = frame:GetName().."CheckBox"..index
			local checkbox = _G[checkBoxName]

			checkbox:SetBackdrop(nil)
			local bg = B.CreateBDFrame(checkbox, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 1)

			local swatch = _G[checkBoxName.."ColorSwatch"]
			if swatch then
				B.ReskinColorSwatch(_G[checkBoxName.."ColorSwatch"])
			end
			B.ReskinCheck(_G[checkBoxName.."Check"])
		end

		frame.styled = true
	end)

	hooksecurefunc("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		if frame.styled then return end

		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = frame:GetName().."CheckBox"..index
			B.ReskinCheck(_G[checkBoxName])

			if value.subTypes then
				for k in ipairs(value.subTypes) do
					B.ReskinCheck(_G[checkBoxName.."_"..k])
				end
			end
		end

		frame.styled = true
	end)

	hooksecurefunc("ChatConfig_CreateColorSwatches", function(frame, swatchTable)
		if frame.styled then return end

		frame:SetBackdrop(nil)
		for index in ipairs(swatchTable) do
			local swatchName = frame:GetName().."Swatch"..index
			local swatch = _G[swatchName]

			swatch:SetBackdrop(nil)
			local bg = B.CreateBDFrame(swatch, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 1)

			B.ReskinColorSwatch(_G[swatchName.."ColorSwatch"])
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
		_G["CombatConfigTab"..i.."Left"]:Hide()
		_G["CombatConfigTab"..i.."Middle"]:Hide()
		_G["CombatConfigTab"..i.."Right"]:Hide()
	end

	local line = ChatConfigFrame:CreateTexture()
	line:SetSize(1, 460)
	line:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT")
	line:SetColorTexture(1, 1, 1, .2)

	ChatConfigCategoryFrame:SetBackdrop(nil)
	ChatConfigBackgroundFrame:SetBackdrop(nil)
	ChatConfigCombatSettingsFilters:SetBackdrop(nil)
	CombatConfigColorsHighlighting:SetBackdrop(nil)
	CombatConfigColorsColorizeUnitName:SetBackdrop(nil)
	CombatConfigColorsColorizeSpellNames:SetBackdrop(nil)
	CombatConfigColorsColorizeDamageNumber:SetBackdrop(nil)
	CombatConfigColorsColorizeDamageSchool:SetBackdrop(nil)
	CombatConfigColorsColorizeEntireLine:SetBackdrop(nil)

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

	for _, box in next, combatBoxes do
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
	B.ReskinArrow(ChatConfigMoveFilterUpButton, "up")
	B.ReskinArrow(ChatConfigMoveFilterDownButton, "down")
	B.ReskinInput(CombatConfigSettingsNameEditBox)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineBySource)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineByTarget)
	B.ReskinColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	B.ReskinColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)
	B.ReskinScroll(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
	ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Hide()

	ChatConfigMoveFilterUpButton:SetSize(28, 28)
	ChatConfigMoveFilterDownButton:SetSize(28, 28)

	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, 0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)
end)