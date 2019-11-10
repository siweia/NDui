local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local restyled = false

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if restyled then return end

		F.StripTextures(InterfaceOptionsFrameCategories)
		F.StripTextures(InterfaceOptionsFramePanelContainer)
		F.StripTextures(InterfaceOptionsFrameAddOns)
		for i = 1, 2 do
			F.StripTextures(_G["InterfaceOptionsFrameTab"..i])
		end
		F.CreateBD(InterfaceOptionsFrame)
		F.CreateSD(InterfaceOptionsFrame)
		InterfaceOptionsFrame.Border:Hide()

		InterfaceOptionsFrame.Header = InterfaceOptionsFrame.Header or InterfaceOptionsFrameHeader -- deprecated in 8.3
		if C.isNewPatch then
			F.StripTextures(InterfaceOptionsFrame.Header)
		else
			InterfaceOptionsFrame.Header:SetTexture("")
		end
		InterfaceOptionsFrame.Header:ClearAllPoints()
		InterfaceOptionsFrame.Header:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetColorTexture(1, 1, 1, .25)

		local buttons = {
			InterfaceOptionsFrameDefaults,
			InterfaceOptionsFrameOkay,
			InterfaceOptionsFrameCancel,
			InterfaceOptionsSocialPanelRedockChat,
			InterfaceOptionsSocialPanelTwitterLoginButton,
			InterfaceOptionsDisplayPanelResetTutorials,
		}
		for _, button in next, buttons do
			F.Reskin(button)
		end

		local checkboxes = {
			InterfaceOptionsControlsPanelStickyTargeting,
			InterfaceOptionsControlsPanelAutoDismount,
			InterfaceOptionsControlsPanelAutoClearAFK,
			InterfaceOptionsControlsPanelAutoLootCorpse,
			InterfaceOptionsControlsPanelInteractOnLeftClick,
			InterfaceOptionsControlsPanelLootAtMouse,
			InterfaceOptionsCombatPanelTargetOfTarget,
			InterfaceOptionsCombatPanelFlashLowHealthWarning,
			InterfaceOptionsCombatPanelLossOfControl,
			InterfaceOptionsCombatPanelEnableFloatingCombatText,
			InterfaceOptionsCombatPanelAutoSelfCast,
			InterfaceOptionsDisplayPanelRotateMinimap,
			InterfaceOptionsDisplayPanelAJAlerts,
			InterfaceOptionsDisplayPanelShowTutorials,
			InterfaceOptionsSocialPanelProfanityFilter,
			InterfaceOptionsSocialPanelSpamFilter,
			InterfaceOptionsSocialPanelGuildMemberAlert,
			InterfaceOptionsSocialPanelBlockTrades,
			InterfaceOptionsSocialPanelBlockGuildInvites,
			InterfaceOptionsSocialPanelBlockChatChannelInvites,
			InterfaceOptionsSocialPanelShowAccountAchievments,
			InterfaceOptionsSocialPanelOnlineFriends,
			InterfaceOptionsSocialPanelOfflineFriends,
			InterfaceOptionsSocialPanelBroadcasts,
			InterfaceOptionsSocialPanelFriendRequests,
			InterfaceOptionsSocialPanelShowToastWindow,
			InterfaceOptionsSocialPanelEnableTwitter,
			InterfaceOptionsSocialPanelAutoAcceptQuickJoinRequests,
			InterfaceOptionsActionBarsPanelBottomLeft,
			InterfaceOptionsActionBarsPanelBottomRight,
			InterfaceOptionsActionBarsPanelRight,
			InterfaceOptionsActionBarsPanelRightTwo,
			InterfaceOptionsActionBarsPanelStackRightBars,
			InterfaceOptionsActionBarsPanelLockActionBars,
			InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
			InterfaceOptionsActionBarsPanelCountdownCooldowns,
			InterfaceOptionsNamesPanelMyName,
			InterfaceOptionsNamesPanelNonCombatCreature,
			InterfaceOptionsNamesPanelFriendlyPlayerNames,
			InterfaceOptionsNamesPanelFriendlyMinions,
			InterfaceOptionsNamesPanelEnemyPlayerNames,
			InterfaceOptionsNamesPanelEnemyMinions,
			InterfaceOptionsNamesPanelUnitNameplatesPersonalResource,
			InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy,
			InterfaceOptionsNamesPanelUnitNameplatesMakeLarger,
			InterfaceOptionsNamesPanelUnitNameplatesShowAll,
			InterfaceOptionsNamesPanelUnitNameplatesAggroFlash,
			InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions,
			InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions,
			InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus,
			InterfaceOptionsNamesPanelUnitNameplatesEnemies,
			InterfaceOptionsNamesPanelUnitNameplatesFriends,
			InterfaceOptionsCameraPanelWaterCollision,
			InterfaceOptionsMousePanelInvertMouse,
			InterfaceOptionsMousePanelEnableMouseSpeed,
			InterfaceOptionsMousePanelClickToMove,
			InterfaceOptionsMousePanelLockCursorToScreen,
			InterfaceOptionsAccessibilityPanelMovePad,
			InterfaceOptionsAccessibilityPanelCinematicSubtitles,
			InterfaceOptionsAccessibilityPanelColorblindMode
		}
		for _, checkbox in next, checkboxes do
			F.ReskinCheck(checkbox)
		end

		local dropdowns = {
			InterfaceOptionsControlsPanelAutoLootKeyDropDown,
			InterfaceOptionsCombatPanelFocusCastKeyDropDown,
			InterfaceOptionsCombatPanelSelfCastKeyDropDown,
			InterfaceOptionsDisplayPanelOutlineDropDown,
			InterfaceOptionsDisplayPanelSelfHighlightDropDown,
			InterfaceOptionsDisplayPanelDisplayDropDown,
			InterfaceOptionsDisplayPanelChatBubblesDropDown,
			InterfaceOptionsSocialPanelChatStyle,
			InterfaceOptionsSocialPanelTimestamps,
			InterfaceOptionsSocialPanelWhisperMode,
			InterfaceOptionsActionBarsPanelPickupActionKeyDropDown,
			InterfaceOptionsNamesPanelNPCNamesDropDown,
			InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown,
			InterfaceOptionsCameraPanelStyleDropDown,
			InterfaceOptionsMousePanelClickMoveStyleDropDown,
			InterfaceOptionsAccessibilityPanelColorFilterDropDown
		}
		for _, dropdown in next, dropdowns do
			F.ReskinDropDown(dropdown)
		end

		local sliders = {
			InterfaceOptionsCombatPanelSpellAlertOpacitySlider,
			InterfaceOptionsCameraPanelFollowSpeedSlider,
			InterfaceOptionsMousePanelMouseSensitivitySlider,
			InterfaceOptionsMousePanelMouseLookSpeedSlider,
			InterfaceOptionsAccessibilityPanelColorblindStrengthSlider
		}
		for _, slider in next, sliders do
			F.ReskinSlider(slider)
		end

		if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
			CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()

			local boxes = {
				CompactUnitFrameProfilesRaidStylePartyFrames,
				CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether,
				CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight,
				CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder,
				CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs,
				CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec3,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec4,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP,
				CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE
			}

			for _, box in next, boxes do
				F.ReskinCheck(box)
			end

			F.Reskin(CompactUnitFrameProfilesSaveButton)
			F.Reskin(CompactUnitFrameProfilesDeleteButton)
			F.Reskin(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
			F.ReskinDropDown(CompactUnitFrameProfilesProfileSelector)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider)
		end

		restyled = true
	end)

	hooksecurefunc("InterfaceOptions_AddCategory", function()
		local num = #INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, num do
			local bu = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
			if bu and not bu.reskinned then
				F.ReskinExpandOrCollapse(bu)
				bu:SetPushedTexture("")
				bu.SetPushedTexture = F.dummy
				bu.reskinned = true
			end
		end
	end)
end)