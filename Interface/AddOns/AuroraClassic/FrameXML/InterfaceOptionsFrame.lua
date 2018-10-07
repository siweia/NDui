local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local restyled = false

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if restyled then return end

		InterfaceOptionsFrameCategories:DisableDrawLayer("BACKGROUND")
		InterfaceOptionsFrameAddOns:DisableDrawLayer("BACKGROUND")
		InterfaceOptionsFramePanelContainer:DisableDrawLayer("BORDER")
		InterfaceOptionsFrameTab1TabSpacer:SetAlpha(0)
		for i = 1, 2 do
			_G["InterfaceOptionsFrameTab"..i.."Left"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."Middle"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."Right"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."LeftDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."MiddleDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."RightDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab2TabSpacer"..i]:SetAlpha(0)
		end

		F.CreateBD(InterfaceOptionsFrame)
		F.CreateSD(InterfaceOptionsFrame)
		F.Reskin(InterfaceOptionsFrameDefaults)
		F.Reskin(InterfaceOptionsFrameOkay)
		F.Reskin(InterfaceOptionsFrameCancel)
		F.Reskin(InterfaceOptionsSocialPanelRedockChat)
		F.Reskin(InterfaceOptionsSocialPanelTwitterLoginButton)
		F.Reskin(InterfaceOptionsDisplayPanelResetTutorials)

		InterfaceOptionsFrameHeader:SetTexture("")
		InterfaceOptionsFrameHeader:ClearAllPoints()
		InterfaceOptionsFrameHeader:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(1, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetColorTexture(1, 1, 1, .2)

		local checkboxes = {
			"InterfaceOptionsControlsPanelStickyTargeting",
			"InterfaceOptionsControlsPanelAutoDismount",
			"InterfaceOptionsControlsPanelAutoClearAFK",
			"InterfaceOptionsControlsPanelAutoLootCorpse",
			"InterfaceOptionsControlsPanelInteractOnLeftClick",
			"InterfaceOptionsControlsPanelLootAtMouse",
			"InterfaceOptionsCombatPanelTargetOfTarget",
			"InterfaceOptionsCombatPanelFlashLowHealthWarning",
			"InterfaceOptionsCombatPanelLossOfControl",
			"InterfaceOptionsCombatPanelEnableFloatingCombatText",
			"InterfaceOptionsCombatPanelAutoSelfCast",
			"InterfaceOptionsDisplayPanelRotateMinimap",
			"InterfaceOptionsDisplayPanelAJAlerts",
			"InterfaceOptionsDisplayPanelShowTutorials",
			"InterfaceOptionsSocialPanelProfanityFilter",
			"InterfaceOptionsSocialPanelSpamFilter",
			"InterfaceOptionsSocialPanelGuildMemberAlert",
			"InterfaceOptionsSocialPanelBlockTrades",
			"InterfaceOptionsSocialPanelBlockGuildInvites",
			"InterfaceOptionsSocialPanelBlockChatChannelInvites",
			"InterfaceOptionsSocialPanelShowAccountAchievments",
			"InterfaceOptionsSocialPanelOnlineFriends",
			"InterfaceOptionsSocialPanelOfflineFriends",
			"InterfaceOptionsSocialPanelBroadcasts",
			"InterfaceOptionsSocialPanelFriendRequests",
			"InterfaceOptionsSocialPanelShowToastWindow",
			"InterfaceOptionsSocialPanelEnableTwitter",
			"InterfaceOptionsSocialPanelAutoAcceptQuickJoinRequests",
			"InterfaceOptionsActionBarsPanelBottomLeft",
			"InterfaceOptionsActionBarsPanelBottomRight",
			"InterfaceOptionsActionBarsPanelRight",
			"InterfaceOptionsActionBarsPanelRightTwo",
			"InterfaceOptionsActionBarsPanelStackRightBars",
			"InterfaceOptionsActionBarsPanelLockActionBars",
			"InterfaceOptionsActionBarsPanelAlwaysShowActionBars",
			"InterfaceOptionsActionBarsPanelCountdownCooldowns",
			"InterfaceOptionsNamesPanelMyName",
			"InterfaceOptionsNamesPanelNonCombatCreature",
			"InterfaceOptionsNamesPanelFriendlyPlayerNames",
			"InterfaceOptionsNamesPanelFriendlyMinions",
			"InterfaceOptionsNamesPanelEnemyPlayerNames",
			"InterfaceOptionsNamesPanelEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesPersonalResource",
			"InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy",
			"InterfaceOptionsNamesPanelUnitNameplatesMakeLarger",
			"InterfaceOptionsNamesPanelUnitNameplatesShowAll",
			"InterfaceOptionsNamesPanelUnitNameplatesAggroFlash",
			"InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus",
			"InterfaceOptionsNamesPanelUnitNameplatesEnemies",
			"InterfaceOptionsNamesPanelUnitNameplatesFriends",
			"InterfaceOptionsCameraPanelWaterCollision",
			"InterfaceOptionsMousePanelInvertMouse",
			"InterfaceOptionsMousePanelEnableMouseSpeed",
			"InterfaceOptionsMousePanelClickToMove",
			"InterfaceOptionsMousePanelLockCursorToScreen",
			"InterfaceOptionsAccessibilityPanelMovePad",
			"InterfaceOptionsAccessibilityPanelCinematicSubtitles",
			"InterfaceOptionsAccessibilityPanelColorblindMode"
		}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end

		local dropdowns = {
			"InterfaceOptionsControlsPanelAutoLootKeyDropDown",
			"InterfaceOptionsCombatPanelFocusCastKeyDropDown",
			"InterfaceOptionsCombatPanelSelfCastKeyDropDown",
			"InterfaceOptionsDisplayPanelOutlineDropDown",
			"InterfaceOptionsDisplayPanelSelfHighlightDropDown",
			"InterfaceOptionsDisplayPanelDisplayDropDown",
			"InterfaceOptionsDisplayPanelChatBubblesDropDown",
			"InterfaceOptionsSocialPanelChatStyle",
			"InterfaceOptionsSocialPanelTimestamps",
			"InterfaceOptionsSocialPanelWhisperMode",
			"InterfaceOptionsActionBarsPanelPickupActionKeyDropDown",
			"InterfaceOptionsNamesPanelNPCNamesDropDown",
			"InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown",
			"InterfaceOptionsCameraPanelStyleDropDown",
			"InterfaceOptionsMousePanelClickMoveStyleDropDown",
			"InterfaceOptionsAccessibilityPanelColorFilterDropDown"
		}
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end

		local sliders = {
			"InterfaceOptionsCombatPanelSpellAlertOpacitySlider",
			"InterfaceOptionsCameraPanelFollowSpeedSlider",
			"InterfaceOptionsMousePanelMouseSensitivitySlider",
			"InterfaceOptionsMousePanelMouseLookSpeedSlider",
			"InterfaceOptionsAccessibilityPanelColorblindStrengthSlider"
		}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
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