local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_DebugTools"] = function()
	-- EventTraceFrame
	B.StripTextures(EventTraceFrame)
	B.SetBD(EventTraceFrame)
	B.ReskinClose(EventTraceFrameCloseButton, "TOPRIGHT", EventTraceFrame, "TOPRIGHT", -7, -7)

	local bg, bu = EventTraceFrameScroll:GetRegions()
	bg:Hide()
	bu:SetAlpha(0)
	bu:SetWidth(16)
	bu.bg = B.CreateBDFrame(EventTraceFrame, 0)
	bu.bg:SetAllPoints(bu)
	B.CreateGradient(bu.bg)

	-- Table Attribute Display
	local function reskinTableAttribute(frame)
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
		B.ReskinScroll(frame.LinesScrollFrame.ScrollBar)
	end

	reskinTableAttribute(TableAttributeDisplay)
	hooksecurefunc(TableInspectorMixin, "InspectTable", reskinTableAttribute)
end