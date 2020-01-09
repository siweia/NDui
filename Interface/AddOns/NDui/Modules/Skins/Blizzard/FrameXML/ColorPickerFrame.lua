local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	ColorPickerFrame.Header = ColorPickerFrame.Header or ColorPickerFrameHeader -- deprecated in 8.3
	if DB.isNewPatch then
		B.StripTextures(ColorPickerFrame.Header)
	else
		ColorPickerFrame.Header:SetAlpha(0)
	end
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 0)
	ColorPickerFrame.Border:Hide()

	B.CreateBD(ColorPickerFrame)
	B.CreateSD(ColorPickerFrame)
	B.Reskin(ColorPickerOkayButton)
	B.Reskin(ColorPickerCancelButton)
	B.ReskinSlider(OpacitySliderFrame, true)
end)