local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local cr, cg, cb = DB.r, DB.g, DB.b

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

	hooksecurefunc("AddonList_Update", function()
		for i = 1, MAX_ADDONS_DISPLAYED do
			local entry = _G["AddonListEntry"..i]
			if entry and entry:IsShown() then
				local checkbox = _G["AddonListEntry"..i.."Enabled"]
				if checkbox.forceSaturation then
					local tex = checkbox:GetCheckedTexture()
					if checkbox.state == 2 then
						tex:SetDesaturated(true)
						tex:SetVertexColor(cr, cg, cb)
					elseif checkbox.state == 1 then
						tex:SetVertexColor(1, .8, 0, .8)
					end
				end
			end
		end
	end)
end)