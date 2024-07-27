local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local toggleButton = CompactRaidFrameManagerToggleButton
	if not toggleButton then return end

	toggleButton:SetSize(16, 16)

	local nt = toggleButton:GetNormalTexture()

	local function updateArrow()
		if CompactRaidFrameManager.collapsed then
			B.SetupArrow(nt, "right")
		else
			B.SetupArrow(nt, "left")
		end
		nt:SetTexCoord(0, 1, 0, 1)
	end

	updateArrow()
	hooksecurefunc("CompactRaidFrameManager_Collapse", updateArrow)
	hooksecurefunc("CompactRaidFrameManager_Expand", updateArrow)

	if DB.isWW then
		B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameModeControlDropdown)
		B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)

		for _, button in pairs({CompactRaidFrameManager.displayFrame.BottomButtons:GetChildren()}) do
			if button:IsObjectType("Button") then
				B.Reskin(button)
			end
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