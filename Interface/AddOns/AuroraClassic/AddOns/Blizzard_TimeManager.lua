local F, C = unpack(select(2, ...))

C.themes["Blizzard_TimeManager"] = function()
	TimeManagerGlobe:Hide()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
	TimeManagerStopwatchCheck:SetCheckedTexture(C.media.checked)
	F.CreateBG(TimeManagerStopwatchCheck)

	TimeManagerAlarmHourDropDown:SetWidth(80)
	TimeManagerAlarmMinuteDropDown:SetWidth(80)
	TimeManagerAlarmAMPMDropDown:SetWidth(90)

	F.ReskinPortraitFrame(TimeManagerFrame, true)
	F.ReskinDropDown(TimeManagerAlarmHourDropDown)
	F.ReskinDropDown(TimeManagerAlarmMinuteDropDown)
	F.ReskinDropDown(TimeManagerAlarmAMPMDropDown)
	F.ReskinInput(TimeManagerAlarmMessageEditBox)
	F.ReskinCheck(TimeManagerAlarmEnabledButton)
	F.ReskinCheck(TimeManagerMilitaryTimeCheck)
	F.ReskinCheck(TimeManagerLocalTimeCheck)

	F.StripTextures(StopwatchFrame)
	F.StripTextures(StopwatchTabFrame)
	F.SetBD(StopwatchFrame)
	F.ReskinClose(StopwatchCloseButton, "TOPRIGHT", StopwatchFrame, "TOPRIGHT", -2, -2)

	local reset = StopwatchResetButton
	reset:GetNormalTexture():SetTexCoord(.25, .75, .27, .75)
	reset:SetSize(18, 18)
	reset:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	reset:SetPoint("BOTTOMRIGHT", -5, 7)
	local play = StopwatchPlayPauseButton
	play:GetNormalTexture():SetTexCoord(.25, .75, .27, .75)
	play:SetSize(18, 18)
	play:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	play:SetPoint("RIGHT", reset, "LEFT", -2, 0)
end