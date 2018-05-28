local F, C = unpack(select(2, ...))

C.themes["Blizzard_InspectUI"] = function()
	InspectModelFrame:DisableDrawLayer("OVERLAY")

	InspectTalentFrame:GetRegions():Hide()
	select(2, InspectTalentFrame:GetRegions()):Hide()
	InspectGuildFrameBG:Hide()
	for i = 1, 5 do
		select(i, InspectModelFrame:GetRegions()):Hide()
	end
	F.Reskin(InspectPaperDollFrame.ViewButton)
	InspectPaperDollFrame.ViewButton:ClearAllPoints()
	InspectPaperDollFrame.ViewButton:SetPoint("TOP", InspectFrame, 0, -45)

	-- Character

	select(11, InspectMainHandSlot:GetRegions()):Hide()

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]
		local border = slot.IconBorder

		_G["Inspect"..slots[i].."SlotFrame"]:Hide()

		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		border:SetPoint("TOPLEFT", -1.2, 1.2)
		border:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
		border:SetDrawLayer("BACKGROUND")
		F.CreateBDFrame(slot, .25)
		slot.icon:SetTexCoord(.08, .92, .08, .92)
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		button.IconBorder:SetTexture(C.media.backdrop)
		button.icon:SetShown(button.hasItem)
	end)

	-- PVP

	InspectPVPFrame.BG:Hide()

	-- Talents

	local inspectSpec = InspectTalentFrame.InspectSpec

	inspectSpec.ring:Hide()

	for i = 1, 7 do
		local row = InspectTalentFrame.InspectTalents["tier"..i]
		for j = 1, 3 do
			local bu = row["talent"..j]

			bu.Slot:Hide()
			bu.border:SetTexture("")

			bu.icon:SetDrawLayer("ARTWORK")
			bu.icon:SetTexCoord(.08, .92, .08, .92)

			F.CreateBG(bu.icon)
		end
	end

	inspectSpec.specIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(inspectSpec.specIcon)

	local function updateIcon(self)
		local spec = nil
		if INSPECTED_UNIT ~= nil then
			spec = GetInspectSpecialization(INSPECTED_UNIT)
		end
		if spec ~= nil and spec > 0 then
			local role1 = GetSpecializationRoleByID(spec)
			if role1 ~= nil then
				local _, _, _, icon = GetSpecializationInfoByID(spec)
				self.specIcon:SetTexture(icon)
			end
		end
	end

	inspectSpec:HookScript("OnShow", updateIcon)
	InspectTalentFrame:HookScript("OnEvent", function(self, event, unit)
		if not InspectFrame:IsShown() then return end
		if event == "INSPECT_READY" and InspectFrame.unit and UnitGUID(InspectFrame.unit) == unit then
			updateIcon(self.InspectSpec)
		end
	end)

	local roleIcon = inspectSpec.roleIcon
	roleIcon:SetTexture(C.media.roleIcons)
	local bg = F.CreateBDFrame(roleIcon, 1)
	bg:SetPoint("TOPLEFT", roleIcon, 2, -1)
	bg:SetPoint("BOTTOMRIGHT", roleIcon, -1, 2)

	for i = 1, 4 do
		local tab = _G["InspectFrameTab"..i]
		F.ReskinTab(tab)
		if i ~= 1 then
			tab:SetPoint("LEFT", _G["InspectFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end

	F.ReskinPortraitFrame(InspectFrame, true)
end