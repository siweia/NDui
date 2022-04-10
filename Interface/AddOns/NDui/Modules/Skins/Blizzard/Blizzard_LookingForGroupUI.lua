local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_LookingForGroupUI"] = function()
	local closeButton = select(3, LFGParentFrame:GetChildren())
	if not LFGParentFrame.CloseButton then
		LFGParentFrame.CloseButton = closeButton
	end
	B.ReskinPortraitFrame(LFGParentFrame, 19, -10, -30, 75)
	LFGParentFrameIcon:SetAlpha(0)
	LFGParentFrameBackground:SetAlpha(0)

	for i = 1, 3 do
		B.ReskinDropDown(_G["LFGFrameTypeDropDown"..i])
		B.ReskinDropDown(_G["LFGFrameActivityDropDown"..i])

		local bg = _G["LFGSearchBg"..i]
		bg:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		B.ReskinIcon(bg)
		local icon = _G["LFGSearchIcon"..i]
		icon:SetAllPoints(bg)
		icon:SetTexCoord(.03, .78, .03, .71)
	end

	B.ReskinInput(LFGComment)
	B.Reskin(LFGFrameClearAllButton)
	B.Reskin(LFGFramePostButton)
	B.ReskinTab(LFGParentFrameTab1)
	B.ReskinTab(LFGParentFrameTab2)

	-- LFM Frame
	for i = 1, 4 do
		B.StripTextures(_G["LFMFrameColumnHeader"..i])
	end

	B.ReskinDropDown(LFMFrameTypeDropDown)
	B.ReskinDropDown(LFMFrameActivityDropDown)
	B.Reskin(LFMFrameSearchButton)
	B.Reskin(LFMFrameSendMessageButton)
	B.Reskin(LFMFrameGroupInviteButton)
	B.StripTextures(LFMFrameInset)
	local bg = B.CreateBDFrame(LFMFrameInset, .25)
	bg:SetInside(nil, 2, 2)

	for i = 1, 16 do
		_G["LFMFrameButton"..i.."Level"]:SetWidth(24)
	end
end