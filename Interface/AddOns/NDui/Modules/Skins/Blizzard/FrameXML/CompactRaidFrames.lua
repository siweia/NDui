local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	if not CompactRaidFrameManagerToggleButton then return end

	CompactRaidFrameManagerToggleButton:SetNormalTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
	CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	CompactRaidFrameManagerToggleButton:SetSize(15, 15)
	hooksecurefunc("CompactRaidFrameManager_Collapse", function()
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	end)
	hooksecurefunc("CompactRaidFrameManager_Expand", function()
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.86, 1, 0, 1)
	end)

	if DB.isWW then
		B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameModeControlDropdown)
		B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
		if CompactRaidFrameManagerDisplayFrameBottomButtonsLeavePartyButton then
			B.Reskin(CompactRaidFrameManagerDisplayFrameBottomButtonsLeavePartyButton)
		end
		if CompactRaidFrameManagerDisplayFrameBottomButtonsLeaveInstanceGroupButton then
			B.Reskin(CompactRaidFrameManagerDisplayFrameBottomButtonsLeaveInstanceGroupButton)
		end
	else
		local buttons = {
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleTank,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleHealer,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterRoleDamager,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup1,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup2,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup3,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup4,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup5,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup6,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup7,
			CompactRaidFrameManagerDisplayFrameFilterOptionsFilterGroup8,
			CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll,
			CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdown,
			CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,
			CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,
			CompactRaidFrameManagerDisplayFrameLockedModeToggle,
			CompactRaidFrameManagerDisplayFrameHiddenModeToggle,
			CompactRaidFrameManagerDisplayFrameConvertToRaid,
			CompactRaidFrameManagerDisplayFrameEditMode,
		}
		for _, button in pairs(buttons) do
			B.StripTextures(button, 0)
			B.Reskin(button)
		end

		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetNormalTexture("Interface\\RaidFrame\\Raid-WorldPing")
	end

	B.StripTextures(CompactRaidFrameManager, 0)
	if not DB.isWW then
		select(1, CompactRaidFrameManagerDisplayFrameFilterOptions:GetRegions()):SetAlpha(0)
		select(4, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)
	end
	select(1, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)

	local bd = B.SetBD(CompactRaidFrameManager)
	bd:SetPoint("TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", -9, 9)
	B.ReskinCheck(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
end)