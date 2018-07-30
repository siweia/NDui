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

	F.StripTextures(StopwatchFrame)
	F.StripTextures(StopwatchTabFrame)
	F.SetBD(StopwatchFrame)
	F.ReskinDropDown(TimeManagerAlarmHourDropDown)
	F.ReskinDropDown(TimeManagerAlarmMinuteDropDown)
	F.ReskinDropDown(TimeManagerAlarmAMPMDropDown)
	F.ReskinInput(TimeManagerAlarmMessageEditBox)
	F.ReskinCheck(TimeManagerAlarmEnabledButton)
	F.ReskinCheck(TimeManagerMilitaryTimeCheck)
	F.ReskinCheck(TimeManagerLocalTimeCheck)
	F.ReskinClose(StopwatchCloseButton, "TOPRIGHT", StopwatchFrame, "TOPRIGHT", -2, -2)
end