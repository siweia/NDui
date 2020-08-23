local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TorghastLevelPicker"] = function()
	local frame = TorghastLevelPickerFrame

	B.ReskinClose(frame.CloseButton, "TOPRIGHT", frame, "TOPRIGHT", -60, -60)
	B.Reskin(frame.OpenPortalButton)
	B.ReskinArrow(frame.Pager.PreviousPage, "left")
	B.ReskinArrow(frame.Pager.NextPage, "right")
end