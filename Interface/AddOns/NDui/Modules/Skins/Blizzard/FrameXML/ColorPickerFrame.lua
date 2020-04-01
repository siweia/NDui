local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ColorPickerFrame.Header)
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 0)
	ColorPickerFrame.Border:Hide()

	B.SetBD(ColorPickerFrame)
	B.Reskin(ColorPickerOkayButton)
	B.Reskin(ColorPickerCancelButton)
	B.ReskinSlider(OpacitySliderFrame, true)
end)