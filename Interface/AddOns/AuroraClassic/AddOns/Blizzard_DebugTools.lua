local F, C = unpack(select(2, ...))

C.themes["Blizzard_DebugTools"] = function()
	FrameStackTooltip:SetScale(UIParent:GetScale())
	FrameStackTooltip:SetBackdrop(nil)

	local bg = CreateFrame("Frame", nil, FrameStackTooltip)
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetFrameLevel(FrameStackTooltip:GetFrameLevel()-1)
	F.CreateBD(bg, .6)
	F.CreateSD(bg)

	-- EventTraceFrame

	F.CreateBD(EventTraceFrame)
	F.CreateSD(EventTraceFrame)
	F.ReskinClose(EventTraceFrameCloseButton)

	select(1, EventTraceFrameScroll:GetRegions()):Hide()
	local bu = select(2, EventTraceFrameScroll:GetRegions())
	bu:SetAlpha(0)
	bu:SetWidth(17)
	bu.bg = CreateFrame("Frame", nil, EventTraceFrame)
	bu.bg:SetPoint("TOPLEFT", bu, 0, 0)
	bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 0)
	F.CreateBD(bu.bg, 0)
	F.CreateGradient(bu.bg) 

	EventTraceTooltip:SetParent(UIParent)
	EventTraceTooltip:SetFrameStrata("TOOLTIP")
	EventTraceTooltip:SetBackdrop(nil)
	local bg = CreateFrame("Frame", nil, EventTraceTooltip)
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetFrameLevel(EventTraceTooltip:GetFrameLevel()-1)
	F.CreateBD(bg, .6)

	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}

	for i = 1, #texs do
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end

	-- Table Attribute Display

	local function reskinTableAttribute(frame)
		F.CreateBD(frame)
		F.CreateSD(frame)
		F.ReskinClose(frame.CloseButton)
		F.ReskinCheck(frame.VisibilityButton)
		F.ReskinCheck(frame.HighlightButton)
		F.ReskinCheck(frame.DynamicUpdateButton)
		F.ReskinInput(frame.FilterBox)

		F.ReskinArrow(frame.OpenParentButton, "up")
		F.ReskinArrow(frame.NavigateBackwardButton, "left")
		F.ReskinArrow(frame.NavigateForwardButton, "right")
		F.ReskinArrow(frame.DuplicateButton, "up")

		frame.NavigateBackwardButton:ClearAllPoints()
		frame.NavigateBackwardButton:SetPoint("LEFT", frame.OpenParentButton, "RIGHT")
		frame.NavigateForwardButton:ClearAllPoints()
		frame.NavigateForwardButton:SetPoint("LEFT", frame.NavigateBackwardButton, "RIGHT")
		frame.DuplicateButton:ClearAllPoints()
		frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT")

		for i = 1, 10 do
			select(i, frame:GetRegions()):Hide()
		end

		for i = 1, 8 do
			select(i, frame.ScrollFrameArt:GetRegions()):Hide()
		end
		F.CreateBD(frame.ScrollFrameArt, .3)
		F.ReskinScroll(frame.LinesScrollFrame.ScrollBar)
	end

	reskinTableAttribute(TableAttributeDisplay)

	hooksecurefunc(TableInspectorMixin, "InspectTable", function(self)
		reskinTableAttribute(self)
	end)
end