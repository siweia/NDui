local F, C = unpack(select(2, ...))

C.themes["Blizzard_DebugTools"] = function()
	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	ScriptErrorsFrame:SetSize(386, 274)
	ScriptErrorsFrame:DisableDrawLayer("OVERLAY")
	ScriptErrorsFrameTitleBG:Hide()
	ScriptErrorsFrameDialogBG:Hide()
	F.CreateBD(ScriptErrorsFrame)
	F.CreateSD(ScriptErrorsFrame)

	FrameStackTooltip:SetScale(UIParent:GetScale())
	FrameStackTooltip:SetBackdrop(nil)

	local bg = CreateFrame("Frame", nil, FrameStackTooltip)
	bg:SetPoint("TOPLEFT")
	bg:SetPoint("BOTTOMRIGHT")
	bg:SetFrameLevel(FrameStackTooltip:GetFrameLevel()-1)
	F.CreateBD(bg, .6)
	F.CreateSD(bg)

	F.ReskinClose(ScriptErrorsFrameClose)
	F.ReskinScroll(ScriptErrorsFrameScrollFrameScrollBar)
	F.Reskin(select(4, ScriptErrorsFrame:GetChildren()))
	F.ReskinArrow(select(5, ScriptErrorsFrame:GetChildren()), "left")
	F.ReskinArrow(select(6, ScriptErrorsFrame:GetChildren()), "right")
	F.Reskin(select(7, ScriptErrorsFrame:GetChildren()))

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
	F.CreateBD(bu.bg, .6)

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

	for i=1, #texs do
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end
end