local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Table Attribute Display
local function reskinTableAttribute(frame)
	if frame.styled then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinCheck(frame.VisibilityButton)
	B.ReskinCheck(frame.HighlightButton)
	B.ReskinCheck(frame.DynamicUpdateButton)
	B.ReskinInput(frame.FilterBox)

	B.ReskinArrow(frame.OpenParentButton, "up")
	B.ReskinArrow(frame.NavigateBackwardButton, "left")
	B.ReskinArrow(frame.NavigateForwardButton, "right")
	B.ReskinArrow(frame.DuplicateButton, "up")

	frame.NavigateBackwardButton:ClearAllPoints()
	frame.NavigateBackwardButton:SetPoint("LEFT", frame.OpenParentButton, "RIGHT")
	frame.NavigateForwardButton:ClearAllPoints()
	frame.NavigateForwardButton:SetPoint("LEFT", frame.NavigateBackwardButton, "RIGHT")
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT")

	B.StripTextures(frame.ScrollFrameArt)
	B.CreateBDFrame(frame.ScrollFrameArt, .25)
	B.ReskinTrimScroll(frame.LinesScrollFrame.ScrollBar)

	frame.styled = true
end

C.themes["Blizzard_DebugTools"] = function()
	reskinTableAttribute(TableAttributeDisplay)
	hooksecurefunc(TableInspectorMixin, "InspectTable", reskinTableAttribute)
end