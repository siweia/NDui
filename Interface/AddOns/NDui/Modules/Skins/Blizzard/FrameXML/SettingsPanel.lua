local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local frame = SettingsPanel

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.ClosePanelButton)
	B.ReskinEditBox(frame.SearchBox)
	B.Reskin(frame.ApplyButton)
	B.Reskin(frame.CloseButton)

	local function resetTabAnchor(tab)
		tab.Text:SetPoint("BOTTOM", 0, 4)
	end
	local function reskinSettingsTab(tab)
		if not tab then return end
		B.StripTextures(tab, 0)
		resetTabAnchor(tab)
		hooksecurefunc(tab, "OnSelected", resetTabAnchor)
	end
	reskinSettingsTab(frame.GameTab)
	reskinSettingsTab(frame.AddOnsTab)

	local bg = B.CreateBDFrame(frame.CategoryList, .25)
	bg:SetInside()
	bg:SetPoint("TOPLEFT", 1, 6)
	hooksecurefunc(frame.CategoryList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				if child.Background then
					child.Background:SetAlpha(0)

					local line = child:CreateTexture(nil, "ARTWORK")
					line:SetPoint("BOTTOMRIGHT", child, -15, 3)
					line:SetAtlas("Options_HorizontalDivider")
					line:SetSize(170, C.mult)
				end

				local toggle = child.Toggle
				if toggle then
					B.ReskinCollapse(toggle)
					toggle:GetPushedTexture():SetAlpha(0)
					toggle.bg:SetPoint("TOPLEFT", 2, -4)
				end

				child.styled = true
			end
		end
	end)

	local bg = B.CreateBDFrame(frame.Container, .25)
	bg:SetInside()
	bg:SetPoint("TOPLEFT", 1, 6)
	B.Reskin(frame.Container.SettingsList.Header.DefaultsButton)
	B.ReskinTrimScroll(frame.Container.SettingsList.ScrollBar)

	local function ReskinDropdown(option)
		B.Reskin(option.Dropdown)
		B.Reskin(option.DecrementButton)
		B.Reskin(option.IncrementButton)
	end

	local function UpdateKeybindButtons(self)
		if not self.bindingsPool then return end
		for panel in self.bindingsPool:EnumerateActive() do
			if not panel.styled then
				B.Reskin(panel.Button1)
				B.Reskin(panel.Button2)
				if panel.CustomButton then B.Reskin(panel.CustomButton) end
				panel.styled = true
			end
		end
	end

	local function UpdateHeaderExpand(self, expanded)
		local atlas = expanded and "Soulbinds_Collection_CategoryHeader_Collapse" or "Soulbinds_Collection_CategoryHeader_Expand"
		self.__texture:SetAtlas(atlas, true)

		UpdateKeybindButtons(self)
	end

	local function forceSaturation(self)
		if self.Checkbox then
			self.Checkbox:DesaturateHierarchy(1)
		end
	end

	local function ReskinControlsGroup(controls)
		for i = 1, controls:GetNumChildren() do
			local element = select(i, controls:GetChildren())
			if element.SliderWithSteppers then
				B.ReskinStepperSlider(element.SliderWithSteppers)
			end
			if element.Control then
				ReskinDropdown(element.Control)
			end
			if element.Checkbox then
				B.ReskinCheck(element.Checkbox)
				element.Checkbox.bg:SetInside(nil, 6, 6)
				hooksecurefunc(element, "DesaturateHierarchy", forceSaturation)
			end
		end
	end

	hooksecurefunc(frame.Container.SettingsList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				if child.NineSlice then
					child.NineSlice:SetAlpha(0)
					local bg = B.CreateBDFrame(child, .25)
					bg:SetPoint("TOPLEFT", 15, -30)
					bg:SetPoint("BOTTOMRIGHT", -30, -5)
				end
				if child.Checkbox then
					B.ReskinCheck(child.Checkbox)
					child.Checkbox.bg:SetInside(nil, 6, 6)
					hooksecurefunc(child, "DesaturateHierarchy", forceSaturation)
				end
				if child.Control then
					ReskinDropdown(child.Control)
				end
				if child.Button then
					if child.Button:GetWidth() < 250 then
						B.Reskin(child.Button)
					else
						B.StripTextures(child.Button)
						child.Button.Right:SetAlpha(0)
						local bg = B.CreateBDFrame(child.Button, .25)
						bg:SetPoint("TOPLEFT", 2, -1)
						bg:SetPoint("BOTTOMRIGHT", -2, 3)
						local hl = child.Button:CreateTexture(nil, "HIGHLIGHT")
						hl:SetColorTexture(cr, cg, cb, .25)
						hl:SetInside(bg)
						hl:SetBlendMode("ADD")

						child.__texture = bg:CreateTexture(nil, "OVERLAY")
						child.__texture:SetPoint("RIGHT", -10, 0)
						UpdateHeaderExpand(child, false)
						hooksecurefunc(child, "EvaluateVisibility", UpdateHeaderExpand)
					end
				end
				if child.ToggleTest then
					B.Reskin(child.ToggleTest)
					B.StripTextures(child.VUMeter)
					local bg = B.CreateBDFrame(child.VUMeter, .3)
					bg:SetInside(nil, 4, 4)
					child.VUMeter.Status:SetStatusBarTexture(DB.bdTex)
					child.VUMeter.Status:SetInside(bg)
				end
				if child.PushToTalkKeybindButton then
					B.Reskin(child.PushToTalkKeybindButton)
				end
				if child.SliderWithSteppers then
					B.ReskinStepperSlider(child.SliderWithSteppers)
				end
				if child.Button1 and child.Button2 then
					B.Reskin(child.Button1)
					B.Reskin(child.Button2)
				end
				if child.Controls then
					for i = 1, #child.Controls do
						local control = child.Controls[i]
						if control.SliderWithSteppers then
							B.ReskinStepperSlider(control.SliderWithSteppers)
						end
					end
				end
				if child.BaseTab then
					B.StripTextures(child.BaseTab, 0)
				end
				if child.RaidTab then
					B.StripTextures(child.RaidTab, 0)
				end
				if child.BaseQualityControls then
					ReskinControlsGroup(child.BaseQualityControls)
				end
				if child.RaidQualityControls then
					ReskinControlsGroup(child.RaidQualityControls)
				end

				child.styled = true
			end
		end
	end)

	local CUFPanels = {
		"CompactUnitFrameProfiles",
		"CompactUnitFrameProfilesGeneralOptionsFrame",
	}
	for _, name in pairs(CUFPanels) do
		local frame = _G[name]
		if frame then
			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:IsObjectType("CheckButton") then
					B.ReskinCheck(child)
				elseif child:IsObjectType("Button") then
					B.Reskin(child)
				elseif child:IsObjectType("Frame") and child.Left and child.Middle and child.Right then
					B.ReskinDropDown(child)
				end
			end
		end
	end
	if CompactUnitFrameProfilesSeparator then
		CompactUnitFrameProfilesSeparator:SetAtlas("Options_HorizontalDivider")
	end
	if CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG then
		CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()
		B.CreateBDFrame(CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG, .25)
	end
end)