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
	B.ReskinTrimScroll(AddonList.ScrollBar)

	AddonListForceLoad:SetSize(26, 26)
	AddonCharacterDropDown:SetWidth(170)

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
end)