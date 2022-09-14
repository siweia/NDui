local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(AddonList)
	B.Reskin(AddonListEnableAllButton)
	B.Reskin(AddonListDisableAllButton)
	B.Reskin(AddonListCancelButton)
	B.Reskin(AddonListOkayButton)
	B.ReskinCheck(AddonListForceLoad)
	B.ReskinDropDown(AddonCharacterDropDown)
	if DB.isNewPatch then
		B.ReskinTrimScroll(AddonList.ScrollBar)
	else
		B.ReskinScroll(AddonListScrollFrameScrollBar)
	end

	AddonListForceLoad:SetSize(26, 26)
	AddonCharacterDropDown:SetWidth(170)

	if DB.isNewPatch then
		local function forceSaturation(self, _, force)
			if force then return end
			self:SetVertexColor(cr, cg, cb)
			self:SetDesaturated(true, true)
		end

		hooksecurefunc(AddonList.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					B.ReskinCheck(child.Enabled, true)
					B.Reskin(child.LoadAddonButton)
					hooksecurefunc(child.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)

					child.styled = true
				end
			end
		end)
	else
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
	end
end)