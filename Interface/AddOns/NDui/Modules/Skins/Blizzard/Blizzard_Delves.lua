local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinButton(button)
	if button.styled then return end
	if button.Border then button.Border:SetAlpha(0) end
	if button.Icon then B.ReskinIcon(button.Icon) end
	button.styled = true
end

local function updateButton(self)
	self:ForEachFrame(reskinButton)
end

local function reskinOptionSlot(frame, skip)
	local option = frame.OptionsList
	B.StripTextures(option)
	local bg = B.SetBD(option, nil, -5, 5, 5, -5)
	bg:SetFrameLevel(3)
	if not skip then
		hooksecurefunc(option.ScrollBox, "Update", updateButton)
	end
end

C.themes["Blizzard_DelvesCompanionConfiguration"] = function()
	B.ReskinPortraitFrame(DelvesCompanionConfigurationFrame)
	B.Reskin(DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot, true)
	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot)
	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot)

	B.ReskinPortraitFrame(DelvesCompanionAbilityListFrame)
	B.ReskinDropDown(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, "left")
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, "right")

	hooksecurefunc(DelvesCompanionAbilityListFrame, "UpdatePaginatedButtonDisplay", function(self)
		for _, button in pairs(self.buttons) do
			if not button.styled then
				if button.Icon then B.ReskinIcon(button.Icon) end

				button.styled = true
			end
		end
	end)
end

C.themes["Blizzard_DelvesDashboardUI"] = function()
	DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
	B.Reskin(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

local function handleRewards(self)
	for rewardFrame in self.rewardPool:EnumerateActive() do
		if not rewardFrame.bg then
			B.CreateBDFrame(rewardFrame, .25)
			rewardFrame.NameFrame:SetAlpha(0)
			rewardFrame.bg = B.ReskinIcon(rewardFrame.Icon)
			B.ReskinIconBorder(rewardFrame.IconBorder, true)
		end
	end
end

C.themes["Blizzard_DelvesDifficultyPicker"] = function()
	B.ReskinPortraitFrame(DelvesDifficultyPickerFrame)
	B.ReskinDropDown(DelvesDifficultyPickerFrame.Dropdown)
	B.Reskin(DelvesDifficultyPickerFrame.EnterDelveButton)

	DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:HookScript("OnShow", handleRewards)
	hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, "SetRewards", handleRewards)
end