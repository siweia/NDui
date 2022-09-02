local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if DB.isNewPatch then return end
	-- todo

	local styled

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if styled then return end

		B.StripTextures(InterfaceOptionsFrameTab1)
		B.StripTextures(InterfaceOptionsFrameTab2)
		B.StripTextures(InterfaceOptionsFrameCategories)
		B.StripTextures(InterfaceOptionsFramePanelContainer)
		B.StripTextures(InterfaceOptionsFrameAddOns)

		B.SetBD(InterfaceOptionsFrame)
		InterfaceOptionsFrame.Border:Hide()
		B.StripTextures(InterfaceOptionsFrame.Header)
		InterfaceOptionsFrame.Header:ClearAllPoints()
		InterfaceOptionsFrame.Header:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		B.Reskin(InterfaceOptionsFrameDefaults)
		B.Reskin(InterfaceOptionsFrameOkay)
		B.Reskin(InterfaceOptionsFrameCancel)

		if CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG then
			CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()
		end

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetColorTexture(1, 1, 1, .25)

		local interfacePanels = {
			"InterfaceOptionsControlsPanel",
			"InterfaceOptionsCombatPanel",
			"InterfaceOptionsDisplayPanel",
			"InterfaceOptionsSocialPanel",
			"InterfaceOptionsActionBarsPanel",
			"InterfaceOptionsNamesPanel",
			"InterfaceOptionsNamesPanelFriendly",
			"InterfaceOptionsNamesPanelEnemy",
			"InterfaceOptionsNamesPanelUnitNameplates",
			"InterfaceOptionsCameraPanel",
			"InterfaceOptionsMousePanel",
			"InterfaceOptionsAccessibilityPanel",
			"InterfaceOptionsColorblindPanel",
			"CompactUnitFrameProfiles",
			"CompactUnitFrameProfilesGeneralOptionsFrame",
		}
		for _, name in pairs(interfacePanels) do
			local frame = _G[name]
			if frame then
				for i = 1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:IsObjectType("CheckButton") then
						B.ReskinCheck(child)
					elseif child:IsObjectType("Button") then
						B.Reskin(child)
					elseif child:IsObjectType("Slider") then
						B.ReskinSlider(child)
					elseif child:IsObjectType("Frame") and child.Left and child.Middle and child.Right then
						B.ReskinDropDown(child)
					end
				end
			else
				if DB.isDeveloper then print(name, "not found.") end
			end
		end

		styled = true
	end)

	hooksecurefunc("InterfaceOptions_AddCategory", function()
		for i = 1, #INTERFACEOPTIONS_ADDONCATEGORIES do
			local bu = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu:GetPushedTexture():SetAlpha(0)

				bu.styled = true
			end
		end
	end)
end)