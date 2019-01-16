local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(AddonList)
	F.Reskin(AddonListEnableAllButton)
	F.Reskin(AddonListDisableAllButton)
	F.Reskin(AddonListCancelButton)
	F.Reskin(AddonListOkayButton)
	F.ReskinCheck(AddonListForceLoad)
	F.ReskinDropDown(AddonCharacterDropDown)
	F.ReskinScroll(AddonListScrollFrameScrollBar)

	AddonCharacterDropDown:SetWidth(170)

	local r, g, b = C.r, C.g, C.b
	hooksecurefunc("AddonList_Update", function()
		for i = 1, MAX_ADDONS_DISPLAYED do
			local checkbox = _G["AddonListEntry"..i.."Enabled"]
			if not checkbox.styled then
				F.ReskinCheck(checkbox)
				checkbox.styled = true
			end
			local ch = checkbox:GetCheckedTexture()
			ch:SetDesaturated(true)
			ch:SetVertexColor(r, g, b)
			F.Reskin(_G["AddonListEntry"..i.."Load"])
		end
	end)
end)