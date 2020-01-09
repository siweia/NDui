local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(AddonList)
	B.Reskin(AddonListEnableAllButton)
	B.Reskin(AddonListDisableAllButton)
	B.Reskin(AddonListCancelButton)
	B.Reskin(AddonListOkayButton)
	B.ReskinCheck(AddonListForceLoad)
	B.ReskinDropDown(AddonCharacterDropDown)
	B.ReskinScroll(AddonListScrollFrameScrollBar)

	AddonListForceLoad:SetSize(26, 26)
	AddonCharacterDropDown:SetWidth(170)

	for i = 1, MAX_ADDONS_DISPLAYED do
		local checkbox = _G["AddonListEntry"..i.."Enabled"]
		B.ReskinCheck(checkbox, true)
		B.Reskin(_G["AddonListEntry"..i.."Load"])
	end
end)