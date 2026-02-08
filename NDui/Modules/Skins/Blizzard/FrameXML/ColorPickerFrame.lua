local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	ColorPickerFrameHeader:SetAlpha(0)
	ColorPickerFrameHeader:ClearAllPoints()
	ColorPickerFrameHeader:SetPoint("TOP", ColorPickerFrame, 0, 10)

	ColorPickerFrame:SetBackdrop(nil)
	B.SetBD(ColorPickerFrame)
	B.Reskin(ColorPickerOkayButton)
	B.Reskin(ColorPickerCancelButton)
	B.ReskinSlider(OpacitySliderFrame, true)

	ColorPickerCancelButton:ClearAllPoints()
	ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 1, 6)
	ColorPickerOkayButton:ClearAllPoints()
	ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOM", -1, 6)
end)