local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ColorPickerFrame.Header)
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 0)
	ColorPickerFrame.Border:Hide()

	B.CreateBD(ColorPickerFrame)
	B.CreateSD(ColorPickerFrame)
	B.Reskin(ColorPickerOkayButton)
	B.Reskin(ColorPickerCancelButton)
	B.ReskinSlider(OpacitySliderFrame, true)
end)