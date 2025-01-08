local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	local function forceSaturation(self, _, force)
		if force then return end
		self:SetVertexColor(cr, cg, cb)
		self:SetDesaturated(true, true)
	end

	B.ReskinPortraitFrame(AddonList)
	B.ReskinDropDown(AddonList.Dropdown)
	B.ReskinTrimScroll(AddonList.ScrollBar)

	if DB.isNewPatch then
		B.Reskin(AddonList.EnableAllButton)
		B.Reskin(AddonList.DisableAllButton)
		B.Reskin(AddonList.CancelButton)
		B.Reskin(AddonList.OkayButton)
		B.ReskinCheck(AddonList.ForceLoad)
		B.ReskinEditBox(AddonList.SearchBox)
	
		hooksecurefunc("AddonList_InitAddon", function(entry)
			if not entry.styled then
				B.ReskinCheck(entry.Enabled, true)
				B.Reskin(entry.LoadAddonButton)
				hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)
	
				B.ReplaceIconString(entry.Title)
				hooksecurefunc(entry.Title, "SetText", B.ReplaceIconString)
	
				entry.styled = true
			end
		end)
	else
		B.Reskin(AddonListEnableAllButton)
		B.Reskin(AddonListDisableAllButton)
		B.Reskin(AddonListCancelButton)
		B.Reskin(AddonListOkayButton)
		B.ReskinCheck(AddonListForceLoad)
	
		AddonListForceLoad:SetSize(26, 26)
	
		hooksecurefunc("AddonList_InitButton", function(entry)
			if not entry.styled then
				B.ReskinCheck(entry.Enabled, true)
				B.Reskin(entry.LoadAddonButton)
				hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)
	
				B.ReplaceIconString(entry.Title)
				hooksecurefunc(entry.Title, "SetText", B.ReplaceIconString)
	
				entry.styled = true
			end
		end)
	end
end)