local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	if not CompactRaidFrameManagerToggleButton then LoadAddOn("Blizzard_CompactRaidFrames") end		-- just in case

	CompactRaidFrameManagerToggleButton:SetNormalTexture("Interface\\Buttons\\UI-ColorPicker-Buttons")
	CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	CompactRaidFrameManagerToggleButton:SetSize(15, 15)
	hooksecurefunc("CompactRaidFrameManager_Collapse", function(self)
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.15, .39, 0, 1)
	end)
	hooksecurefunc("CompactRaidFrameManager_Expand", function(self)
		CompactRaidFrameManagerToggleButton:GetNormalTexture():SetTexCoord(.86, 1, 0, 1)
	end)

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
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck,
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton,
		CompactRaidFrameManagerDisplayFrameLockedModeToggle,
		CompactRaidFrameManagerDisplayFrameHiddenModeToggle,
		CompactRaidFrameManagerDisplayFrameConvertToRaid
	}
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.SetNormalTexture = function() end
	for _, button in pairs(buttons) do
		for i = 1, 9 do
			select(i, button:GetRegions()):SetAlpha(0)
		end
		F.Reskin(button)
	end

	for i = 1, 8 do
		select(i, CompactRaidFrameManager:GetRegions()):SetAlpha(0)
	end
	select(1, CompactRaidFrameManagerDisplayFrameFilterOptions:GetRegions()):SetAlpha(0)
	select(1, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)
	select(4, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)

	local bd = CreateFrame("Frame", nil, CompactRaidFrameManager)
	bd:SetFrameLevel(CompactRaidFrameManager:GetFrameLevel() - 1)
	F.CreateBD(bd)
	F.CreateSD(bd)
	bd:SetPoint("TOPLEFT", CompactRaidFrameManager, "TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", CompactRaidFrameManager, "BOTTOMRIGHT", -9, 9)
	F.ReskinDropDown(CompactRaidFrameManagerDisplayFrameProfileSelector)
	F.ReskinCheck(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
end)