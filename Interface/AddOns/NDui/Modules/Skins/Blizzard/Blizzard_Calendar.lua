local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_Calendar"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	for i = 1, 42 do
		local dayButtonName = "CalendarDayButton"..i
		local bu = _G[dayButtonName]
		bu:DisableDrawLayer("BACKGROUND")
		bu:SetHighlightTexture(DB.bdTex)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .25)
		hl.SetAlpha = B.Dummy

		_G[dayButtonName.."DarkFrame"]:SetAlpha(.5)

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
	CalendarViewEventInviteList:GetRegions():Hide()
	CalendarViewEventDescriptionContainer:GetRegions():Hide()
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
	CalendarViewHolidayInfoTexture:SetAlpha(0)
	CalendarTexturePickerAcceptButtonBorder:Hide()
	CalendarTexturePickerCancelButtonBorder:Hide()
	B.StripTextures(CalendarClassTotalsButton)

	B.StripTextures(CalendarFrame)
	B.SetBD(CalendarFrame, 12, 0, -9, 4)
	B.CreateBD(CalendarClassTotalsButton)
	B.CreateBD(CalendarViewEventInviteList, .25)
	B.CreateBD(CalendarViewEventDescriptionContainer, .25)
	B.CreateBD(CalendarCreateEventInviteList, .25)
	B.CreateBD(CalendarCreateEventDescriptionContainer, .25)

	local function reskinCalendarPage(frame)
		B.StripTextures(frame)
		B.SetBD(frame)
		B.StripTextures(frame.Header)
	end
	reskinCalendarPage(CalendarViewHolidayFrame)
	reskinCalendarPage(CalendarCreateEventFrame)
	reskinCalendarPage(CalendarTexturePickerFrame)
	reskinCalendarPage(CalendarEventPickerFrame)

	local frames = {
		CalendarViewEventTitleFrame, CalendarViewHolidayTitleFrame, CalendarViewRaidTitleFrame, CalendarCreateEventTitleFrame, CalendarTexturePickerTitleFrame, CalendarMassInviteTitleFrame
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

	CalendarTodayFrame:SetBackdrop({
		edgeFile = DB.bdTex,
		edgeSize = C.mult,
	})
	CalendarTodayFrame:SetBackdropBorderColor(r, g, b)

	for i, class in ipairs(CLASS_SORT_ORDER) do
		local bu = _G["CalendarClassButton"..i]
		bu:GetRegions():Hide()
		B.CreateBDFrame(bu)

		local tcoords = CLASS_ICON_TCOORDS[class]
		local ic = bu:GetNormalTexture()
		ic:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02)
	end

	B.StripTextures(CalendarFilterFrame)
	local bg = B.CreateBDFrame(CalendarFilterFrame, 0)
	bg:SetPoint("TOPLEFT", 35, -1)
	bg:SetPoint("BOTTOMRIGHT", -18, 1)
	B.CreateGradient(bg)
	B.ReskinArrow(CalendarFilterButton, "down")

	for i = 1, 6 do
		local vline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		vline:SetHeight(546)
		vline:SetWidth(1)
		vline:SetPoint("TOP", _G["CalendarDayButton"..i], "TOPRIGHT")
		B.CreateBD(vline)
	end
	for i = 1, 36, 7 do
		local hline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		hline:SetWidth(637)
		hline:SetHeight(1)
		hline:SetPoint("LEFT", _G["CalendarDayButton"..i], "TOPLEFT")
		B.CreateBD(hline)
	end

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
	line:SetSize(240, 1)
	line:SetPoint("TOP", CalendarMassInviteFrame, "TOP", 0, -150)
	line:SetTexture(DB.bdTex)
	line:SetVertexColor(0, 0, 0)

	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:SetPoint("BOTTOMLEFT", CalendarCreateEventFrame, "BOTTOMRIGHT", 28, 0)

	CalendarTexturePickerFrame:ClearAllPoints()
	CalendarTexturePickerFrame:SetPoint("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 28, 0)

	local cbuttons = {"CalendarViewEventAcceptButton", "CalendarViewEventTentativeButton", "CalendarViewEventDeclineButton", "CalendarViewEventRemoveButton", "CalendarCreateEventMassInviteButton", "CalendarCreateEventCreateButton", "CalendarCreateEventInviteButton", "CalendarEventPickerCloseButton", "CalendarCreateEventRaidInviteButton", "CalendarTexturePickerAcceptButton", "CalendarTexturePickerCancelButton", "CalendarMassInviteAcceptButton"}
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

	B.ReskinClose(CalendarCloseButton, "TOPRIGHT", CalendarFrame, "TOPRIGHT", -14, -4)
	B.ReskinClose(CalendarCreateEventCloseButton)
	B.ReskinClose(CalendarViewEventCloseButton)
	B.ReskinClose(CalendarViewHolidayCloseButton)
	B.ReskinClose(CalendarViewRaidCloseButton)
	B.ReskinClose(CalendarMassInviteCloseButton)
	B.ReskinScroll(CalendarTexturePickerScrollBar)
	B.ReskinScroll(CalendarViewEventInviteListScrollFrameScrollBar)
	B.ReskinScroll(CalendarViewEventDescriptionScrollFrameScrollBar)
	B.ReskinScroll(CalendarCreateEventInviteListScrollFrameScrollBar)
	B.ReskinScroll(CalendarCreateEventDescriptionScrollFrameScrollBar)
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