local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	ColorPickerFrame.Header = ColorPickerFrame.Header or ColorPickerFrameHeader -- deprecated in 8.3
	if C.isNewPatch then
		F.StripTextures(ColorPickerFrame.Header)
	else
		ColorPickerFrame.Header:SetAlpha(0)
	end
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 0)
	ColorPickerFrame.Border:Hide()

	F.CreateBD(ColorPickerFrame)
	F.CreateSD(ColorPickerFrame)
	F.Reskin(ColorPickerOkayButton)
	F.Reskin(ColorPickerCancelButton)
	F.ReskinSlider(OpacitySliderFrame, true)
end)