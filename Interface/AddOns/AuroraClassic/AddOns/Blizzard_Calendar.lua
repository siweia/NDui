local F, C = unpack(select(2, ...))

C.themes["Blizzard_Calendar"] = function()
	local r, g, b = C.r, C.g, C.b

	CalendarFrame:DisableDrawLayer("BORDER")

	for i = 1, 9 do
		select(i, CalendarViewEventFrame:GetRegions()):Hide()
	end
	select(15, CalendarViewEventFrame:GetRegions()):Hide()

	for i = 1, 9 do
		select(i, CalendarViewHolidayFrame:GetRegions()):Hide()
		select(i, CalendarViewRaidFrame:GetRegions()):Hide()
	end

	for i = 1, 3 do
		select(i, CalendarCreateEventTitleFrame:GetRegions()):Hide()
		select(i, CalendarViewEventTitleFrame:GetRegions()):Hide()
		select(i, CalendarViewHolidayTitleFrame:GetRegions()):Hide()
		select(i, CalendarViewRaidTitleFrame:GetRegions()):Hide()
		select(i, CalendarMassInviteTitleFrame:GetRegions()):Hide()
	end

	for i = 1, 42 do
		_G["CalendarDayButton"..i.."DarkFrame"]:SetAlpha(.5)
		local bu = _G["CalendarDayButton"..i]
		bu:DisableDrawLayer("BACKGROUND")
		bu:SetHighlightTexture(C.media.backdrop)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(r, g, b, .2)
		hl.SetAlpha = F.dummy
	end

	for i = 1, 7 do
		_G["CalendarWeekday"..i.."Background"]:SetAlpha(0)
	end

	CalendarViewEventDivider:Hide()
	CalendarCreateEventDivider:Hide()
	CalendarViewEventInviteList:GetRegions():Hide()
	CalendarViewEventDescriptionContainer:GetRegions():Hide()
	select(5, CalendarCreateEventCloseButton:GetRegions()):Hide()
	select(5, CalendarViewEventCloseButton:GetRegions()):Hide()
	select(5, CalendarViewHolidayCloseButton:GetRegions()):Hide()
	select(5, CalendarViewRaidCloseButton:GetRegions()):Hide()
	select(5, CalendarMassInviteCloseButton:GetRegions()):Hide()
	CalendarCreateEventBackground:Hide()
	CalendarCreateEventFrameButtonBackground:Hide()
	CalendarCreateEventMassInviteButtonBorder:Hide()
	CalendarCreateEventCreateButtonBorder:Hide()
	CalendarCreateEventIcon:SetTexCoord(.08, .92, .08, .92)
	CalendarCreateEventIcon.SetTexCoord = F.dummy
	F.CreateBG(CalendarCreateEventIcon)
	CalendarEventPickerTitleFrameBackgroundLeft:Hide()
	CalendarEventPickerTitleFrameBackgroundMiddle:Hide()
	CalendarEventPickerTitleFrameBackgroundRight:Hide()
	CalendarEventPickerFrameButtonBackground:Hide()
	CalendarEventPickerCloseButtonBorder:Hide()
	CalendarCreateEventRaidInviteButtonBorder:Hide()
	CalendarMonthBackground:SetAlpha(0)
	CalendarYearBackground:SetAlpha(0)
	CalendarFrameModalOverlay:SetAlpha(.25)
	CalendarViewHolidayInfoTexture:SetAlpha(0)
	CalendarTexturePickerTitleFrameBackgroundLeft:Hide()
	CalendarTexturePickerTitleFrameBackgroundMiddle:Hide()
	CalendarTexturePickerTitleFrameBackgroundRight:Hide()
	CalendarTexturePickerFrameButtonBackground:Hide()
	CalendarTexturePickerAcceptButtonBorder:Hide()
	CalendarTexturePickerCancelButtonBorder:Hide()
	CalendarClassTotalsButtonBackgroundTop:Hide()
	CalendarClassTotalsButtonBackgroundMiddle:Hide()
	CalendarClassTotalsButtonBackgroundBottom:Hide()
	CalendarFilterFrameLeft:Hide()
	CalendarFilterFrameMiddle:Hide()
	CalendarFilterFrameRight:Hide()

	F.SetBD(CalendarFrame, 12, 0, -9, 4)
	F.CreateBD(CalendarClassTotalsButton)
	F.CreateBD(CalendarViewEventInviteList, .25)
	F.CreateBD(CalendarViewEventDescriptionContainer, .25)
	F.CreateBD(CalendarCreateEventInviteList, .25)
	F.CreateBD(CalendarCreateEventDescriptionContainer, .25)
	F.CreateBD(CalendarEventPickerFrame, .25)

	local frames = {
		CalendarViewEventFrame, CalendarViewHolidayFrame, CalendarViewRaidFrame, CalendarCreateEventFrame, CalendarTexturePickerFrame, CalendarMassInviteFrame
	}
	for _, frame in next, frames do
		F.CreateBD(frame)
		F.CreateSD(frame)
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
		edgeFile = C.media.backdrop,
		edgeSize = 1.2,
	})
	CalendarTodayFrame:SetBackdropBorderColor(r, g, b)

	for i, class in ipairs(CLASS_SORT_ORDER) do
		local bu = _G["CalendarClassButton"..i]
		bu:GetRegions():Hide()
		F.CreateBG(bu)

		local tcoords = CLASS_ICON_TCOORDS[class]
		local ic = bu:GetNormalTexture()
		ic:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02)
	end

	local bd = CreateFrame("Frame", nil, CalendarFilterFrame)
	bd:SetPoint("TOPLEFT", 40, 0)
	bd:SetPoint("BOTTOMRIGHT", -19, 0)
	bd:SetFrameLevel(CalendarFilterFrame:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	F.CreateGradient(bd)

	local downtex = CalendarFilterButton:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture(C.media.arrowDown)
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)

	for i = 1, 6 do
		local vline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		vline:SetHeight(546)
		vline:SetWidth(1)
		vline:SetPoint("TOP", _G["CalendarDayButton"..i], "TOPRIGHT")
		F.CreateBD(vline)
	end
	for i = 1, 36, 7 do
		local hline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		hline:SetWidth(637)
		hline:SetHeight(1)
		hline:SetPoint("LEFT", _G["CalendarDayButton"..i], "TOPLEFT")
		F.CreateBD(hline)
	end

	if AuroraConfig.tooltips then
		local tooltips = {CalendarContextMenu, CalendarInviteStatusContextMenu}

		for _, tooltip in pairs(tooltips) do
			tooltip:SetBackdrop(nil)
			local bg = CreateFrame("Frame", nil, tooltip)
			bg:SetPoint("TOPLEFT", 2, -2)
			bg:SetPoint("BOTTOMRIGHT", -1, 2)
			bg:SetFrameLevel(tooltip:GetFrameLevel()-1)
			F.CreateBD(bg)
			F.CreateSD(bg)
		end
	end

	CalendarViewEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -8, -24)
	CalendarViewHolidayFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -8, -24)
	CalendarViewRaidFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -8, -24)
	CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", -8, -24)
	CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 1, 1)
	CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)

	CalendarCreateEventHourDropDown:SetWidth(80)
	CalendarCreateEventMinuteDropDown:SetWidth(80)
	CalendarCreateEventAMPMDropDown:SetWidth(90)

	local line = CalendarMassInviteFrame:CreateTexture(nil, "BACKGROUND")
	line:SetSize(240, 1)
	line:SetPoint("TOP", CalendarMassInviteFrame, "TOP", 0, -150)
	line:SetTexture(C.media.backdrop)
	line:SetVertexColor(0, 0, 0)

	CalendarMassInviteFrame:ClearAllPoints()
	CalendarMassInviteFrame:SetPoint("BOTTOMLEFT", CalendarCreateEventFrame, "BOTTOMRIGHT", 28, 0)

	CalendarTexturePickerFrame:ClearAllPoints()
	CalendarTexturePickerFrame:SetPoint("TOPLEFT", CalendarCreateEventFrame, "TOPRIGHT", 28, 0)

	local cbuttons = {"CalendarViewEventAcceptButton", "CalendarViewEventTentativeButton", "CalendarViewEventDeclineButton", "CalendarViewEventRemoveButton", "CalendarCreateEventMassInviteButton", "CalendarCreateEventCreateButton", "CalendarCreateEventInviteButton", "CalendarEventPickerCloseButton", "CalendarCreateEventRaidInviteButton", "CalendarTexturePickerAcceptButton", "CalendarTexturePickerCancelButton", "CalendarFilterButton", "CalendarMassInviteAcceptButton"}
	for i = 1, #cbuttons do
		local cbutton = _G[cbuttons[i]]
		if not cbutton then
			print(cbuttons[i])
		else
			F.Reskin(cbutton)
		end
	end

	CalendarViewEventAcceptButton.flashTexture:SetTexture("")
	CalendarViewEventTentativeButton.flashTexture:SetTexture("")
	CalendarViewEventDeclineButton.flashTexture:SetTexture("")

	F.ReskinClose(CalendarCloseButton, "TOPRIGHT", CalendarFrame, "TOPRIGHT", -14, -4)
	F.ReskinClose(CalendarCreateEventCloseButton)
	F.ReskinClose(CalendarViewEventCloseButton)
	F.ReskinClose(CalendarViewHolidayCloseButton)
	F.ReskinClose(CalendarViewRaidCloseButton)
	F.ReskinClose(CalendarMassInviteCloseButton)
	F.ReskinScroll(CalendarTexturePickerScrollBar)
	F.ReskinScroll(CalendarViewEventInviteListScrollFrameScrollBar)
	F.ReskinScroll(CalendarViewEventDescriptionScrollFrameScrollBar)
	F.ReskinScroll(CalendarCreateEventInviteListScrollFrameScrollBar)
	F.ReskinScroll(CalendarCreateEventDescriptionScrollFrameScrollBar)
	F.ReskinDropDown(CalendarCreateEventTypeDropDown)
	F.ReskinDropDown(CalendarCreateEventHourDropDown)
	F.ReskinDropDown(CalendarCreateEventMinuteDropDown)
	F.ReskinDropDown(CalendarCreateEventAMPMDropDown)
	F.ReskinDropDown(CalendarCreateEventDifficultyOptionDropDown)
	F.ReskinDropDown(CalendarMassInviteCommunityDropDown)
	F.ReskinDropDown(CalendarMassInviteRankMenu)
	F.ReskinInput(CalendarCreateEventTitleEdit)
	F.ReskinInput(CalendarCreateEventInviteEdit)
	F.ReskinInput(CalendarMassInviteMinLevelEdit)
	F.ReskinInput(CalendarMassInviteMaxLevelEdit)
	F.ReskinArrow(CalendarPrevMonthButton, "left")
	F.ReskinArrow(CalendarNextMonthButton, "right")
	CalendarPrevMonthButton:SetSize(19, 19)
	CalendarNextMonthButton:SetSize(19, 19)
	F.ReskinCheck(CalendarCreateEventLockEventCheck)

	CalendarCreateEventDifficultyOptionDropDown:SetWidth(150)
end