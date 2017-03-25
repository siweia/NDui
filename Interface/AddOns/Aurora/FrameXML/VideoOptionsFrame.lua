local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	VideoOptionsFrameCategoryFrame:DisableDrawLayer("BACKGROUND")
	VideoOptionsFramePanelContainer:DisableDrawLayer("BORDER")

	VideoOptionsFrameHeader:SetTexture("")
	VideoOptionsFrameHeader:ClearAllPoints()
	VideoOptionsFrameHeader:SetPoint("TOP", VideoOptionsFrame, 0, 0)

	F.CreateBD(VideoOptionsFrame)
	F.CreateSD(VideoOptionsFrame)
	F.Reskin(VideoOptionsFrameOkay)
	F.Reskin(VideoOptionsFrameCancel)
	F.Reskin(VideoOptionsFrameDefaults)
	F.Reskin(VideoOptionsFrameApply)

	VideoOptionsFrameOkay:SetPoint("BOTTOMRIGHT", VideoOptionsFrameCancel, "BOTTOMLEFT", -1, 0)

	local styledOptions = false
	VideoOptionsFrame:HookScript("OnShow", function()
		if styledOptions then return end

		local line = VideoOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(1, 512)
		line:SetPoint("LEFT", 205, 30)
		line:SetColorTexture(1, 1, 1, .2)

		Display_:SetBackdrop(nil)
		Graphics_:SetBackdrop(nil)
		RaidGraphics_:SetBackdrop(nil)

		GraphicsButton:DisableDrawLayer("BACKGROUND")
		RaidButton:DisableDrawLayer("BACKGROUND")

		local hline = Display_:CreateTexture(nil, "ARTWORK")
		hline:SetSize(580, 1)
		hline:SetPoint("TOPLEFT", GraphicsButton, "BOTTOMLEFT", 14, -4)
		hline:SetColorTexture(1, 1, 1, .2)

		F.CreateBD(AudioOptionsSoundPanelPlayback, .25)
		F.CreateBD(AudioOptionsSoundPanelHardware, .25)
		F.CreateBD(AudioOptionsSoundPanelVolume, .25)
		F.CreateBD(AudioOptionsVoicePanelTalking, .25)
		F.CreateBD(AudioOptionsVoicePanelBinding, .25)
		F.CreateBD(AudioOptionsVoicePanelListening, .25)

		AudioOptionsSoundPanelPlaybackTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelPlayback, "TOPLEFT", 5, 2)
		AudioOptionsSoundPanelHardwareTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelHardware, "TOPLEFT", 5, 2)
		AudioOptionsSoundPanelVolumeTitle:SetPoint("BOTTOMLEFT", AudioOptionsSoundPanelVolume, "TOPLEFT", 5, 2)
		AudioOptionsVoicePanelTalkingTitle:SetPoint("BOTTOMLEFT", AudioOptionsVoicePanelTalking, "TOPLEFT", 5, 2)
		AudioOptionsVoicePanelListeningTitle:SetPoint("BOTTOMLEFT", AudioOptionsVoicePanelListening, "TOPLEFT", 5, 2)

		local dropdowns = {
			"Display_DisplayModeDropDown",
			"Display_ResolutionDropDown",
			"Display_RefreshDropDown",
			"Display_PrimaryMonitorDropDown",
			"Display_AntiAliasingDropDown",
			"Display_VerticalSyncDropDown",
			"Graphics_TextureResolutionDropDown",
			"Graphics_FilteringDropDown",
			"Graphics_ProjectedTexturesDropDown",
			"Graphics_ShadowsDropDown",
			"Graphics_LiquidDetailDropDown",
			"Graphics_SunshaftsDropDown",
			"Graphics_ParticleDensityDropDown",
			"Graphics_SSAODropDown",
			"Graphics_DepthEffectsDropDown",
			"Graphics_LightingQualityDropDown",
			"Graphics_OutlineModeDropDown",
			"RaidGraphics_TextureResolutionDropDown",
			"RaidGraphics_FilteringDropDown",
			"RaidGraphics_ProjectedTexturesDropDown",
			"RaidGraphics_ShadowsDropDown",
			"RaidGraphics_LiquidDetailDropDown",
			"RaidGraphics_SunshaftsDropDown",
			"RaidGraphics_ParticleDensityDropDown",
			"RaidGraphics_SSAODropDown",
			"RaidGraphics_DepthEffectsDropDown",
			"RaidGraphics_LightingQualityDropDown",
			"RaidGraphics_OutlineModeDropDown",
			"Advanced_BufferingDropDown",
			"Advanced_LagDropDown",
			"Advanced_HardwareCursorDropDown",
			"Advanced_MultisampleAntiAliasingDropDown",
			"Advanced_MultisampleAlphaTest",
			"Advanced_PostProcessAntiAliasingDropDown",
			"Advanced_ResampleQualityDropDown",
			"Advanced_PhysicsInteractionDropDown",
			"AudioOptionsSoundPanelHardwareDropDown",
			"AudioOptionsSoundPanelSoundChannelsDropDown",
			"AudioOptionsSoundPanelSoundCacheSizeDropDown",
			"AudioOptionsVoicePanelInputDeviceDropDown",
			"AudioOptionsVoicePanelChatModeDropDown",
			"AudioOptionsVoicePanelOutputDeviceDropDown",
			"InterfaceOptionsLanguagesPanelLocaleDropDown",
			"InterfaceOptionsLanguagesPanelAudioLocaleDropDown"
		}
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end

		local sliders = {
			"Graphics_Quality",
			"Graphics_ViewDistanceSlider",
			"Graphics_EnvironmentalDetailSlider",
			"Graphics_GroundClutterSlider",
			"RaidGraphics_Quality",
			"RaidGraphics_ViewDistanceSlider",
			"RaidGraphics_EnvironmentalDetailSlider",
			"RaidGraphics_GroundClutterSlider",
			"Advanced_UIScaleSlider",
			"Advanced_MaxFPSSlider",
			"Advanced_MaxFPSBKSlider",
			"Advanced_RenderScaleSlider",
			"Advanced_GammaSlider",
			"AudioOptionsSoundPanelMasterVolume",
			"AudioOptionsSoundPanelSoundVolume",
			"AudioOptionsSoundPanelMusicVolume",
			"AudioOptionsSoundPanelAmbienceVolume",
			"AudioOptionsSoundPanelDialogVolume",
			"AudioOptionsVoicePanelMicrophoneVolume",
			"AudioOptionsVoicePanelSpeakerVolume",
			"AudioOptionsVoicePanelSoundFade",
			"AudioOptionsVoicePanelMusicFade",
			"AudioOptionsVoicePanelAmbienceFade"
		}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end

		local checkboxes = {
			"Display_RaidSettingsEnabledCheckBox",
			"Advanced_UseUIScale",
			"Advanced_MaxFPSCheckBox",
			"Advanced_MaxFPSBKCheckBox",
			"Advanced_ShowHDModels",
			"Advanced_DesktopGamma",
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
			"AudioOptionsSoundPanelEnableDSPs",
			"AudioOptionsVoicePanelEnableVoice",
			"AudioOptionsVoicePanelEnableMicrophone",
			"AudioOptionsVoicePanelPushToTalkSound"
		}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end

		F.Reskin(RecordLoopbackSoundButton)
		F.Reskin(PlayLoopbackSoundButton)
		F.Reskin(AudioOptionsVoicePanelChatMode1KeyBindingButton)

		styledOptions = true
	end)
end)