local _, ns = ...
local B, C, L, DB = unpack(ns)

local function oldDropdown(self)
	B.StripTextures(self)
	local frameName = self.GetName and self:GetName()
	local down = self.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])

	local bg = B.CreateBDFrame(self, 0, true)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)

	down:ClearAllPoints()
	down:SetPoint("RIGHT", bg, -2, 0)
	B.ReskinArrow(down, "down")
end

local function handleCheckButton(button)
	local checkbutton = button.CheckButton
	if checkbutton and not checkbutton.styled then
		B.ReskinCheck(checkbutton)
		checkbutton.styled = true
	end

	local collapse = button.ExpandOrCollapseButton
	if collapse and not collapse.styled then
		B.ReskinCollapse(collapse)
		collapse.__texture:DoCollapse(false)
		collapse.styled = true
	end
end

local function replaceRoleIcon(button, role)
	button:GetRegions():Hide()
	B.ReskinCheck(button.CheckButton)

	local nt = button:GetNormalTexture()
	nt:SetTexCoord(0,1,0,1)
	nt:SetAtlas("UI-LFG-RoleIcon-"..role)
end

C.themes["Blizzard_GroupFinder_VanillaStyle"] = function()
	local closeButton = LFGParentFrame:GetChildren()
	if not LFGParentFrame.CloseButton then
		LFGParentFrame.CloseButton = closeButton
	end
	B.ReskinPortraitFrame(LFGParentFrame, 19, -10, -30, 75)

	replaceRoleIcon(LFGListingFrame.SoloRoleButtons.Tank, "Tank")
	replaceRoleIcon(LFGListingFrame.SoloRoleButtons.Healer, "Healer")
	replaceRoleIcon(LFGListingFrame.SoloRoleButtons.DPS, "DPS")
	replaceRoleIcon(LFGListingFrame.NewPlayerFriendlyButton, "Leader")

	B.StripTextures(LFGListingFrame)
	B.ReskinInput(LFGListingComment)
	B.Reskin(LFGListingFrameBackButton)
	B.Reskin(LFGListingFramePostButton)
	B.ReskinTab(LFGParentFrameTab1)
	B.ReskinTab(LFGParentFrameTab2)

	B.StripTextures(LFGListingFrameActivityView)
	B.ReskinTrimScroll(LFGListingFrameActivityViewScrollBar)
	
	hooksecurefunc("LFGListingActivityView_InitActivityButton", handleCheckButton)
	hooksecurefunc("LFGListingActivityView_InitActivityGroupButton", handleCheckButton)

	B.StripTextures(LFGBrowseFrame)
	oldDropdown(LFGBrowseFrameCategoryDropDown)
	oldDropdown(LFGBrowseFrameActivityDropDown)
	B.Reskin(LFGBrowseFrameRefreshButton)
	LFGBrowseFrameRefreshButton.__bg:SetInside(nil, 6, 6)
	B.Reskin(LFGBrowseFrameSendMessageButton)
	B.Reskin(LFGBrowseFrameGroupInviteButton)

	hooksecurefunc("LFGListingCategorySelection_AddButton", function(self, btnIndex)
		local bu = self.CategoryButtons[btnIndex]
		if bu and not bu.styled then
			bu.Cover:Hide()
			bu.Icon:SetTexCoord(.01, .99, .01, .99)
			B.CreateBDFrame(bu.Icon)

			bu.styled = true
		end
	end)
end