local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(ColorPickerFrame.Header)
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 10)
	ColorPickerFrame.Border:Hide()

	B.SetBD(ColorPickerFrame)
	B.Reskin(ColorPickerFrame.Footer.OkayButton)
	B.Reskin(ColorPickerFrame.Footer.CancelButton)
end)