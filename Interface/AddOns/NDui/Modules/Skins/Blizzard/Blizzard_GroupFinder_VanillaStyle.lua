local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateSideTabIcon(tab)
	tab.Icon:SetSize(36, 36)
	tab.Icon:SetTexCoord(unpack(DB.TexCoord))
end

local function reskinSideTab(tab)
	tab.Background:SetAlpha(0)
	tab.Icon:RemoveMaskTexture(tab.Mask)
	B.ReskinIcon(tab.Icon, true)
	tab.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	tab.HighlightTexture:SetAllPoints(tab.Icon)
	tab.SelectedTexture:SetColorTexture(DB.r, DB.g, DB.b, .25)
	tab.SelectedTexture:SetAllPoints(tab.Icon)
	tab.TabGlow:SetColorTexture(DB.r, DB.g, DB.b, .25)
	tab.TabGlow:SetAllPoints(tab.Icon)
	hooksecurefunc(tab, "UpdateIconInterior", updateSideTabIcon)
	updateSideTabIcon(tab)
end

local function reskinCategoryButton(button)
	if button.styled then return end
	button.Cover:Hide()
	B.Reskin(button)
	button.Icon:SetTexCoord(.01, .99, .01, .99)
	button.__bg:SetOutside(button.Icon)
	button.styled = true
end

local function reskinActivityButton(button, elementData, isCollapsed)
	if elementData and elementData.GetData then
		isCollapsed = elementData:IsCollapsed()
		elementData = elementData:GetData()
	end
	local groupID = elementData and elementData.activityGroupID
	local isPartial = groupID and not LFGListingFrame:AreAllActivitiesForActivityGroupSelected(groupID)
		and LFGListingFrame:IsAnyActivityForActivityGroupSelected(groupID)
	local checked = button.CheckButton:GetCheckedTexture()
	if not button.styled then
		B.ReskinCheck(button.CheckButton)
		local toggle = button.ExpandOrCollapseButton
		B.ReskinCollapse(toggle)
		button.styled = true
	end
	button.ExpandOrCollapseButton.__texture:DoCollapse(isCollapsed)
	-- Blizzard resets the check texture when recycling rows, including partial groups.
	if isPartial then
		checked:SetTexture("Interface\\Buttons\\UI-MultiCheck-Up")
	else
		checked:SetAtlas("checkmark-minimal")
	end
	checked:SetDesaturated(true)
	checked:SetTexCoord(0, 1, 0, 1)
	checked:SetVertexColor(DB.r, DB.g, DB.b)
end

local function reskinSearchEntry(button)
	if button.styled then return end
	button.ResultBG:SetColorTexture(0, 0, 0, .25)
	B.CreateBDFrame(button.ResultBG, .25)
	button.Highlight:SetColorTexture(1, 1, 1, .15)
	button.Highlight:SetBlendMode("BLEND")
	if button.Selected then
		button.Selected:SetColorTexture(DB.r, DB.g, DB.b, .25)
		button.Selected:SetBlendMode("BLEND")
	end
	if button.DataDisplay then
		B.Reskin(button.DataDisplay.DelistButton)
	end
	button.styled = true
end

local function reskinWhoEntry(button)
	if button.styled then return end
	button.Background:SetColorTexture(0, 0, 0, .25)
	B.CreateBDFrame(button.Background, .25)
	button.Selected:SetColorTexture(DB.r, DB.g, DB.b, .25)
	button.Selected:SetBlendMode("BLEND")
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .15)
	B.Reskin(button.InviteButton)
	button.styled = true
end

local function reskinScrollBox(scrollBox, reskin)
	local function update(self)
		self:ForEachFrame(reskin)
	end
	hooksecurefunc(scrollBox, "Update", update)
	update(scrollBox)
end

C.themes["Blizzard_GroupFinder_VanillaStyle"] = function()
	B.SetBD(LFGParentFrame)
	B.ReskinClose(LFGParentFrameCloseButton)
	LFGParentFramePortrait:SetAlpha(0)
	for _, key in ipairs({"ListingTab", "BrowsingTab", "WhoListingTab"}) do
		reskinSideTab(LFGParentFrame[key])
	end
	for _, frame in ipairs({LFGListingFrame, LFGBrowseFrame, LFGWhoListFrame}) do
		B.StripTextures(frame, 0)
		if frame.PortraitContainer then frame.PortraitContainer:SetAlpha(0) end
		if frame.Inset then B.StripTextures(frame.Inset, 0) end
	end

	-- Create a listing.
	local listing = LFGListingFrame
	B.StripTextures(listing.RolesSection, 0)
	listing.DividerFrame.Divider:SetAlpha(0)
	B.Reskin(listing.BackButton)
	B.Reskin(listing.PostButton)
	for _, key in ipairs({"Tank", "Healer", "DPS"}) do
		local button = listing.SoloRoleButtons[key]
		button.Background:SetAlpha(0)
		B.ReskinCheck(button.CheckButton)
	end
	listing.GroupRoleButtons.RoleIcon.Background:SetAlpha(0)
	B.Reskin(listing.GroupRoleButtons.RolePollButton)
	B.ReskinDropDown(listing.GroupRoleButtons.RoleDropdown)
	B.ReskinCheck(listing.NewPlayerFriendlyButton.CheckButton)
	local categories = listing.CategoryView.CategorySelection
	local function updateCategories(self)
		if self.CategoryButtons then
			for _, button in ipairs(self.CategoryButtons) do
				reskinCategoryButton(button)
			end
		end
	end
	hooksecurefunc("LFGListingCategorySelection_UpdateCategoryButtons", updateCategories)
	updateCategories(categories)

	local activity = listing.ActivityView
	B.StripTextures(activity, 0)
	B.ReskinDropDown(activity.PlayStyleDropdown)
	B.ReskinDropDown(activity.VoiceChatDropdown)
	B.ReskinCheck(activity.LevelRangesCheckbox.Checkbox)
	B.ReskinTrimScroll(activity.ScrollBar)
	B.StripTextures(activity.Comment)
	B.CreateBDFrame(activity.Comment, .25)
	B.ReskinScroll(activity.Comment.ScrollBar)
	reskinScrollBox(activity.ScrollBox, reskinActivityButton)
	hooksecurefunc("LFGListingActivityView_InitActivityGroupButton", reskinActivityButton)
	hooksecurefunc("LFGListingActivityView_InitActivityButton", reskinActivityButton)

	-- Browse groups and players.
	local browse = LFGBrowseFrame
	B.ReskinDropDown(browse.CategoryDropdown)
	B.ReskinDropDown(browse.ActivityDropdown)
	B.ReskinFilterReset(browse.ActivityDropdown.ResetButton)
	B.Reskin(browse.RefreshButton)
	browse.RefreshButton.__bg:SetInside(nil, 5, 5)
	B.Reskin(browse.OptionsButton)
	B.Reskin(browse.SendMessageButton)
	B.Reskin(browse.GroupInviteButton)
	B.ReskinTrimScroll(browse.ScrollBar)
	reskinScrollBox(browse.ScrollBox, reskinSearchEntry)
	B.SetBD(LFGBrowseSearchEntryTooltip)

	local who = LFGWhoListFrame
	B.ReskinInput(who.EditBox)
	who.EditBox.__bg:SetPoint("TOPLEFT", -5, -6)
	who.EditBox.__bg:SetPoint("BOTTOMRIGHT", -3, 4)
	B.Reskin(who.WhoSearch)
	who.WhoSearch.__bg:SetInside(nil, 5, 5)
	B.ReskinFilterButton(who.FilterDropdown)
	B.ReskinTrimScroll(who.ScrollBar)
	reskinScrollBox(who.ScrollBox, reskinWhoEntry)
end
