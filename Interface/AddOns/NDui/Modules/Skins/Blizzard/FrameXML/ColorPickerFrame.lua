local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ColorPickerFrame.Header)
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 10)
	ColorPickerFrame.Border:Hide()

	B.SetBD(ColorPickerFrame)
	if not DB.isNewPatch then
		B.Reskin(ColorPickerOkayButton)
		B.Reskin(ColorPickerCancelButton)
		B.ReskinSlider(OpacitySliderFrame, true)

		ColorPickerCancelButton:ClearAllPoints()
		ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 1, 6)
		ColorPickerOkayButton:ClearAllPoints()
		ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOM", -1, 6)
	else

	B.Reskin(ColorPickerFrame.Footer.OkayButton)
	B.Reskin(ColorPickerFrame.Footer.CancelButton)

	end
end)