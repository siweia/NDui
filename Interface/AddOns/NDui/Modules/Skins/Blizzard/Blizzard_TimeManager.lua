local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TimeManager"] = function()
	TimeManagerGlobe:Hide()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
	TimeManagerStopwatchCheck:SetCheckedTexture(DB.textures.pushed)
	B.CreateBDFrame(TimeManagerStopwatchCheck)

	TimeManagerAlarmHourDropDown:SetWidth(80)
	TimeManagerAlarmMinuteDropDown:SetWidth(80)
	TimeManagerAlarmAMPMDropDown:SetWidth(90)

	B.ReskinPortraitFrame(TimeManagerFrame)
	B.ReskinDropDown(TimeManagerAlarmHourDropDown)
	B.ReskinDropDown(TimeManagerAlarmMinuteDropDown)
	B.ReskinDropDown(TimeManagerAlarmAMPMDropDown)
	B.ReskinInput(TimeManagerAlarmMessageEditBox)
	B.ReskinCheck(TimeManagerAlarmEnabledButton)
	B.ReskinCheck(TimeManagerMilitaryTimeCheck)
	B.ReskinCheck(TimeManagerLocalTimeCheck)

	B.StripTextures(StopwatchFrame)
	B.StripTextures(StopwatchTabFrame)
	B.SetBD(StopwatchFrame)
	B.ReskinClose(StopwatchCloseButton, StopwatchFrame, -2, -2)

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