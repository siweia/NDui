local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinEventList(frame)
	B.StripTextures(frame)
	B.CreateBDFrame(frame, .25)
	if frame.ScrollBar then
		B.ReskinTrimScroll(frame.ScrollBar)
	end
end

local function ReskinCalendarPage(frame)
	B.StripTextures(frame)
	B.SetBD(frame)
	B.StripTextures(frame.Header)
	if frame.ScrollBar then
		B.ReskinTrimScroll(frame.ScrollBar)
	end
end

C.themes["Blizzard_Calendar"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	for i = 1, 42 do
		local dayButtonName = "CalendarDayButton"..i
		local bu = _G[dayButtonName]
		bu:DisableDrawLayer("BACKGROUND")
		bu:SetHighlightTexture(DB.bdTex)
		local bg = B.CreateBDFrame(bu, .25)
		bg:SetInside()
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl:SetInside(bg)
		hl.SetAlpha = B.Dummy

		_G[dayButtonName.."DarkFrame"]:SetAlpha(.5)
		_G[dayButtonName.."EventTexture"]:SetInside(bg)
		_G[dayButtonName.."EventBackgroundTexture"]:SetAlpha(0)
		_G[dayButtonName.."OverlayFrameTexture"]:SetInside(bg)

		local eventButtonIndex = 1
		local eventButton = _G[dayButtonName.."EventButton"..eventButtonIndex]
		while eventButton do
			eventButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			eventButton.black:SetTexture(nil)
			eventButtonIndex = eventButtonIndex + 1
			eventButton = _G[dayButtonName.."EventButton"..eventButtonIndex]
		end
	end

	for i = 1, 7 do
		_G["CalendarWeekday"..i.."Background"]:SetAlpha(0)
	end

	CalendarViewEventDivider:Hide()
	CalendarCreateEventDivider:Hide()
	CalendarCreateEventFrameButtonBackground:Hide()
	CalendarCreateEventMassInviteButtonBorder:Hide()
	CalendarCreateEventCreateButtonBorder:Hide()
	B.ReskinIcon(CalendarCreateEventIcon)
	CalendarCreateEventIcon.SetTexCoord = B.Dummy
	CalendarEventPickerCloseButtonBorder:Hide()
	CalendarCreateEventRaidInviteButtonBorder:Hide()
	CalendarMonthBackground:SetAlpha(0)
	CalendarYearBackground:SetAlpha(0)
	CalendarFrameModalOverlay:SetAlpha(.25)
	CalendarViewHolidayFrame.Texture:SetAlpha(0)
	CalendarTexturePickerAcceptButtonBorder:Hide()
	CalendarTexturePickerCancelButtonBorder:Hide()
	B.StripTextures(CalendarClassTotalsButton)

	B.StripTextures(CalendarFrame)
	B.SetBD(CalendarFrame, nil, 9, 0, -7, 1)
	B.CreateBDFrame(CalendarClassTotalsButton)

	ReskinEventList(CalendarViewEventInviteList)
	ReskinEventList(CalendarViewEventDescriptionContainer)
	ReskinEventList(CalendarCreateEventInviteList)
	ReskinEventList(CalendarCreateEventDescriptionContainer)

	ReskinCalendarPage(CalendarViewHolidayFrame)
	ReskinCalendarPage(CalendarCreateEventFrame)
	ReskinCalendarPage(CalendarViewEventFrame)
	ReskinCalendarPage(CalendarTexturePickerFrame)
	ReskinCalendarPage(CalendarEventPickerFrame)
	ReskinCalendarPage(CalendarViewRaidFrame)

	local frames = {
		CalendarViewEventTitleFrame,
		CalendarViewHolidayTitleFrame,
		CalendarViewRaidTitleFrame,
		CalendarCreateEventTitleFrame,
		CalendarTexturePickerTitleFrame,
		CalendarMassInviteTitleFrame
	}
	for _, titleFrame in next, frames do
		B.StripTextures(titleFrame)
		local parent = titleFrame:GetParent()
		B.StripTextures(parent)
		B.SetBD(parent)
	end

	CalendarWeekdaySelectedTexture:SetDesaturated(true)
	CalendarWeekdaySelectedTexture:SetVertexColor(r, g, b)

	hooksecurefunc("CalendarFrame_SetToday", function()
		CalendarTodayFrame:SetAllPoints()
	end)

	CalendarTodayFrame:SetScript("OnUpdate", nil)
	CalendarTodayTextureGlow:Hide()
	CalendarTodayTexture:Hide()

	local bg = B.CreateBDFrame(CalendarTodayFrame, 0)
	bg:SetInside()
	bg:SetBackdropBorderColor(r, g, b)

	for i, class in ipairs(CLASS_SORT_ORDER) do
		local bu = _G["CalendarClassButton"..i]
		bu:GetRegions():Hide()
		B.CreateBDFrame(bu)
		B.ClassIconTexCoord(bu:GetNormalTexture(), class)
	end

	B.StripTextures(CalendarFilterFrame)
	local bg = B.CreateBDFrame(CalendarFilterFrame, 0, true)
	bg:SetPoint("TOPLEFT", 35, -1)
	bg:SetPoint("BOTTOMRIGHT", -18, 1)
	B.ReskinArrow(CalendarFilterButton, "down")

	CalendarViewEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -6, -24)
	CalendarViewHolidayFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -6, -24)
	CalendarViewRaidFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -6, -24)
	CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -6, -24)
	CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 1, 1)
	CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)

	CalendarCreateEventHourDropDown:SetWidth(80)
	CalendarCreateEventMinuteDropDown:SetWidth(80)
	CalendarCreateEventAMPMDropDown:SetWidth(90)

	local line = CalendarMassInviteFrame:CreateTexture(nil, "BACKGROUND")
	line:SetSize(240, C.mult)
	line:SetPoint("TOP", CalendarMassInviteFrame, "TOP", 0, -150)
	line:SetTexture(DB.bdTex)
	line:SetVertexColor(0, 0, 0)

	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:SetPoint("BOTTOMLEFT", CalendarCreateEventFrame, "BOTTOMRIGHT", 28, 0)
	CalendarTexturePickerFrame:ClearAllPoints()
	CalendarTexturePickerFrame:SetPoint("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 28, 0)

	local cbuttons = {
		"CalendarViewEventAcceptButton",
		"CalendarViewEventTentativeButton",
		"CalendarViewEventDeclineButton",
		"CalendarViewEventRemoveButton",
		"CalendarCreateEventMassInviteButton",
		"CalendarCreateEventCreateButton",
		"CalendarCreateEventInviteButton",
		"CalendarEventPickerCloseButton",
		"CalendarCreateEventRaidInviteButton",
		"CalendarTexturePickerAcceptButton",
		"CalendarTexturePickerCancelButton",
		"CalendarMassInviteAcceptButton"
	}
	for i = 1, #cbuttons do
		local cbutton = _G[cbuttons[i]]
		if not cbutton then
			print(cbuttons[i])
		else
			B.Reskin(cbutton)
		end
	end

	CalendarViewEventAcceptButton.flashTexture:SetTexture("")
	CalendarViewEventTentativeButton.flashTexture:SetTexture("")
	CalendarViewEventDeclineButton.flashTexture:SetTexture("")

	B.ReskinClose(CalendarCloseButton, CalendarFrame, -14, -4)
	B.ReskinClose(CalendarCreateEventCloseButton)
	B.ReskinClose(CalendarViewEventCloseButton)
	B.ReskinClose(CalendarViewHolidayCloseButton)
	B.ReskinClose(CalendarViewRaidCloseButton)
	B.ReskinClose(CalendarMassInviteCloseButton)

	B.ReskinDropDown(CalendarCreateEventCommunityDropDown)
	B.ReskinDropDown(CalendarCreateEventTypeDropDown)
	B.ReskinDropDown(CalendarCreateEventHourDropDown)
	B.ReskinDropDown(CalendarCreateEventMinuteDropDown)
	B.ReskinDropDown(CalendarCreateEventAMPMDropDown)
	B.ReskinDropDown(CalendarCreateEventDifficultyOptionDropDown)
	B.ReskinDropDown(CalendarMassInviteCommunityDropDown)
	B.ReskinDropDown(CalendarMassInviteRankMenu)
	B.ReskinInput(CalendarCreateEventTitleEdit)
	B.ReskinInput(CalendarCreateEventInviteEdit)
	B.ReskinInput(CalendarMassInviteMinLevelEdit)
	B.ReskinInput(CalendarMassInviteMaxLevelEdit)
	B.ReskinArrow(CalendarPrevMonthButton, "left")
	B.ReskinArrow(CalendarNextMonthButton, "right")
	CalendarPrevMonthButton:SetSize(19, 19)
	CalendarNextMonthButton:SetSize(19, 19)
	B.ReskinCheck(CalendarCreateEventLockEventCheck)

	CalendarCreateEventDifficultyOptionDropDown:SetWidth(150)
end