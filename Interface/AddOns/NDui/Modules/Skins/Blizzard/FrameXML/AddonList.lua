local _, ns = ...
local B, C, L, DB = unpack(ns)

if DB.isNewPatch then


function B:ReplaceIconString(text)
	if not text then text = self:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
	if count > 0 then self:SetFormattedText("%s", newText) end
end

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
end)

else

tinsert(C.defaultThemes, function()
	local cr, cg, cb = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(AddonList)
	B.Reskin(AddonListEnableAllButton)
	B.Reskin(AddonListDisableAllButton)
	B.Reskin(AddonListCancelButton)
	B.Reskin(AddonListOkayButton)
	B.ReskinCheck(AddonListForceLoad)
	B.ReskinScroll(AddonListScrollFrameScrollBar)

	AddonListForceLoad:SetSize(26, 26)
	B.ReskinDropDown(AddonList.Dropdown)

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

end