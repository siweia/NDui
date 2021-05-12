local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(VideoOptionsFrameCategoryFrame)
	B.StripTextures(VideoOptionsFramePanelContainer)
	B.StripTextures(VideoOptionsFrame.Header)
	VideoOptionsFrame.Header:ClearAllPoints()
	VideoOptionsFrame.Header:SetPoint("TOP", VideoOptionsFrame, 0, 0)

	B.SetBD(VideoOptionsFrame)
	VideoOptionsFrame.Border:Hide()
	B.Reskin(VideoOptionsFrameOkay)
	B.Reskin(VideoOptionsFrameCancel)
	B.Reskin(VideoOptionsFrameDefaults)
	B.Reskin(VideoOptionsFrameApply)

	VideoOptionsFrameOkay:SetPoint("BOTTOMRIGHT", VideoOptionsFrameCancel, "BOTTOMLEFT", -1, 0)

	local styledOptions = false
	VideoOptionsFrame:HookScript("OnShow", function()
		if styledOptions then return end

		local line = VideoOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 512)
		line:SetPoint("LEFT", 205, 30)
		line:SetColorTexture(1, 1, 1, .25)

		Display_:SetBackdrop(nil)
		Graphics_:SetBackdrop(nil)
		RaidGraphics_:SetBackdrop(nil)

		GraphicsButton:DisableDrawLayer("BACKGROUND")
		RaidButton:DisableDrawLayer("BACKGROUND")

		local hline = Display_:CreateTexture(nil, "ARTWORK")
		hline:SetSize(580, C.mult)
		hline:SetPoint("TOPLEFT", GraphicsButton, "BOTTOMLEFT", 14, -4)
		hline:SetColorTexture(1, 1, 1, .2)

		B.StripTextures(AudioOptionsSoundPanelPlayback)
		B.CreateBDFrame(AudioOptionsSoundPanelPlayback, .25)
		B.StripTextures(AudioOptionsSoundPanelHardware)
		B.CreateBDFrame(AudioOptionsSoundPanelHardware, .25)
		B.StripTextures(AudioOptionsSoundPanelVolume)
		B.CreateBDFrame(AudioOptionsSoundPanelVolume, .25)

		AudioOptionsSoundPanelPlaybackTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelPlayback, "TOPLEFT", 5, 2)
		AudioOptionsSoundPanelHardwareTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelHardware, "TOPLEFT", 5, 2)
		AudioOptionsSoundPanelVolumeTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelVolume, "TOPLEFT", 5, 2)

		local dropdowns = {
			"Display_DisplayModeDropDown",
			"Display_ResolutionDropDown",
			"Display_PrimaryMonitorDropDown",
			"Display_AntiAliasingDropDown",
			"Display_VerticalSyncDropDown",
			"Graphics_TextureResolutionDropDown",
			"Graphics_SpellDensityDropDown",
			"Graphics_ProjectedTexturesDropDown",
			"Graphics_ShadowsDropDown",
			"Graphics_LiquidDetailDropDown",
			"Graphics_SunshaftsDropDown",	-- isNewPatch, removed in 38627
			"Graphics_ParticleDensityDropDown",
			"Graphics_SSAODropDown",
			"Graphics_DepthEffectsDropDown",
			"Graphics_OutlineModeDropDown",
			"RaidGraphics_TextureResolutionDropDown",
			"RaidGraphics_SpellDensityDropDown",
			"RaidGraphics_ProjectedTexturesDropDown",
			"RaidGraphics_ShadowsDropDown",
			"RaidGraphics_LiquidDetailDropDown",
			"RaidGraphics_SunshaftsDropDown",	-- isNewPatch, removed in 38627
			"RaidGraphics_ParticleDensityDropDown",
			"RaidGraphics_SSAODropDown",
			"RaidGraphics_DepthEffectsDropDown",
			"RaidGraphics_OutlineModeDropDown",
			"Advanced_BufferingDropDown",
			"Advanced_FilteringDropDown",
			"Advanced_RTShadowQualityDropDown",
			"Advanced_SSAOTypeDropDown",
			"Advanced_MultisampleAntiAliasingDropDown",
			"Advanced_MultisampleAlphaTest",
			"Advanced_PostProcessAntiAliasingDropDown",
			"Advanced_ResampleQualityDropDown",
			"Advanced_PhysicsInteractionDropDown",
			"Advanced_AdapterDropDown",
			"Advanced_GraphicsAPIDropDown",
			"AudioOptionsSoundPanelHardwareDropDown",
			"AudioOptionsSoundPanelSoundChannelsDropDown",
			"AudioOptionsSoundPanelSoundCacheSizeDropDown",
			"AudioOptionsVoicePanelOutputDeviceDropdown",
			"AudioOptionsVoicePanelMicDeviceDropdown",
			"AudioOptionsVoicePanelChatModeDropdown",
			"InterfaceOptionsLanguagesPanelLocaleDropDown",
			"InterfaceOptionsLanguagesPanelAudioLocaleDropDown"
		}
		if DB.isNewPatch then
			tinsert(dropdowns, "Graphics_ComputeEffectsDropDown")
			tinsert(dropdowns, "RaidGraphics_ComputeEffectsDropDown")
			tremove(dropdowns, 11)
			tremove(dropdowns, 20)
		end
		for i = 1, #dropdowns do
			local dropdown = _G[dropdowns[i]]
			if not dropdown then
				if DB.isDeveloper then print(dropdowns[i], "not found.") end
			else
				B.ReskinDropDown(dropdown)
			end
		end

		local sliders = {
			"Display_RenderScaleSlider",
			"Display_UIScaleSlider",
			"Graphics_Quality",
			"Graphics_ViewDistanceSlider",
			"Graphics_EnvironmentalDetailSlider",
			"Graphics_GroundClutterSlider",
			"RaidGraphics_Quality",
			"RaidGraphics_ViewDistanceSlider",
			"RaidGraphics_EnvironmentalDetailSlider",
			"RaidGraphics_GroundClutterSlider",
			"Advanced_MaxFPSSlider",
			"Advanced_MaxFPSBKSlider",
			"Advanced_TargetFPSSlider",
			"Advanced_GammaSlider",
			"Advanced_ContrastSlider",
			"Advanced_BrightnessSlider",
			"AudioOptionsSoundPanelMasterVolume",
			"AudioOptionsSoundPanelSoundVolume",
			"AudioOptionsSoundPanelMusicVolume",
			"AudioOptionsSoundPanelAmbienceVolume",
			"AudioOptionsSoundPanelDialogVolume",
			"AudioOptionsVoicePanelVoiceChatVolume",
			"AudioOptionsVoicePanelVoiceChatDucking",
			"AudioOptionsVoicePanelVoiceChatMicVolume",
			"AudioOptionsVoicePanelVoiceChatMicSensitivity",
		}
		for i = 1, #sliders do
			local slider = _G[sliders[i]]
			if not slider then
				if DB.isDeveloper then print(sliders[i], "not found.") end
			else
				B.ReskinSlider(slider)
			end
		end

		local checkboxes = {
			"Display_UseUIScale",
			"Display_RaidSettingsEnabledCheckBox",
			"Advanced_MaxFPSCheckBox",
			"Advanced_MaxFPSBKCheckBox",
			"Advanced_TargetFPSCheckBox",
			"NetworkOptionsPanelOptimizeSpeed",
			"NetworkOptionsPanelUseIPv6",
			"NetworkOptionsPanelAdvancedCombatLogging",
			"AudioOptionsSoundPanelEnableSound",
			"AudioOptionsSoundPanelSoundEffects",
			"AudioOptionsSoundPanelErrorSpeech",
			"AudioOptionsSoundPanelEmoteSounds",
			"AudioOptionsSoundPanelPetSounds",
			"AudioOptionsSoundPanelMusic",
			"AudioOptionsSoundPanelLoopMusic",
			"AudioOptionsSoundPanelPetBattleMusic",
			"AudioOptionsSoundPanelAmbientSounds",
			"AudioOptionsSoundPanelDialogSounds",
			"AudioOptionsSoundPanelSoundInBG",
			"AudioOptionsSoundPanelReverb",
			"AudioOptionsSoundPanelHRTF",
		}
		for i = 1, #checkboxes do
			local checkbox = _G[checkboxes[i]]
			if not checkbox then
				if DB.isDeveloper then print(checkbox[i], "not found.") end
			else
				B.ReskinCheck(checkbox)
			end
		end

		local testInputDevie = AudioOptionsVoicePanelTestInputDevice
		B.Reskin(testInputDevie.ToggleTest)
		B.StripTextures(testInputDevie.VUMeter)
		testInputDevie.VUMeter.Status:SetStatusBarTexture(DB.bdTex)
		local bg = B.CreateBDFrame(testInputDevie.VUMeter, .3)
		bg:SetPoint("TOPLEFT", 4, -4)
		bg:SetPoint("BOTTOMRIGHT", -4, 4)

		styledOptions = true
	end)

	hooksecurefunc("AudioOptionsVoicePanel_InitializeCommunicationModeUI", function(self)
		if not self.styled then
			B.Reskin(self.PushToTalkKeybindButton)
			self.styled = true
		end
	end)

	-- Deprecated
	B.StripTextures(AudioOptionsFrame.Header)
	AudioOptionsFrame.Header:ClearAllPoints()
	AudioOptionsFrame.Header:SetPoint("TOP", AudioOptionsFrame, 0, 0)
	B.SetBD(AudioOptionsFrame)
	B.Reskin(AudioOptionsFrameOkay)
	B.Reskin(AudioOptionsFrameCancel)
	B.Reskin(AudioOptionsFrameDefaults)
end)