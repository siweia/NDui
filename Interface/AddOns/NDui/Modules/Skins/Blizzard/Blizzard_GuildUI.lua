local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GuildUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(GuildFrame)
	B.StripTextures(GuildMemberDetailFrame)
	B.SetBD(GuildMemberDetailFrame)
	B.CreateBD(GuildMemberNoteBackground, .25)
	B.CreateBD(GuildMemberOfficerNoteBackground, .25)
	B.SetBD(GuildLogFrame)
	B.CreateBD(GuildLogContainer, .25)
	B.CreateBD(GuildNewsFiltersFrame)
	B.SetBD(GuildTextEditFrame)
	B.CreateBD(GuildTextEditContainer, .25)
	B.CreateBD(GuildRecruitmentInterestFrame, .25)
	B.CreateBD(GuildRecruitmentAvailabilityFrame, .25)
	B.CreateBD(GuildRecruitmentRolesFrame, .25)
	B.CreateBD(GuildRecruitmentLevelFrame, .25)
	for i = 1, 5 do
		B.ReskinTab(_G["GuildFrameTab"..i])
	end
	if GetLocale() == "zhTW" then
		GuildFrameTab1:ClearAllPoints()
		GuildFrameTab1:SetPoint("TOPLEFT", GuildFrame, "BOTTOMLEFT", -7, 2)
	end
	GuildFrameTabardBackground:Hide()
	GuildFrameTabardEmblem:Hide()
	GuildFrameTabardBorder:Hide()
	select(5, GuildInfoFrameInfo:GetRegions()):Hide()
	GuildMemberDetailCorner:Hide()
	for i = 1, 9 do
		select(i, GuildLogFrame:GetRegions()):Hide()
		select(i, GuildNewsFiltersFrame:GetRegions()):Hide()
		select(i, GuildTextEditFrame:GetRegions()):Hide()
	end
	GuildAllPerksFrame:GetRegions():Hide()
	GuildNewsFrame:GetRegions():Hide()
	GuildRewardsFrame:GetRegions():Hide()
	GuildNewsBossModelShadowOverlay:Hide()
	GuildInfoFrameInfoHeader1:SetAlpha(0)
	GuildInfoFrameInfoHeader2:SetAlpha(0)
	GuildInfoFrameInfoHeader3:SetAlpha(0)
	select(9, GuildInfoFrameInfo:GetRegions()):Hide()
	GuildRecruitmentCommentInputFrameTop:Hide()
	GuildRecruitmentCommentInputFrameTopLeft:Hide()
	GuildRecruitmentCommentInputFrameTopRight:Hide()
	GuildRecruitmentCommentInputFrameBottom:Hide()
	GuildRecruitmentCommentInputFrameBottomLeft:Hide()
	GuildRecruitmentCommentInputFrameBottomRight:Hide()
	GuildRecruitmentInterestFrameBg:Hide()
	GuildRecruitmentAvailabilityFrameBg:Hide()
	GuildRecruitmentRolesFrameBg:Hide()
	GuildRecruitmentLevelFrameBg:Hide()
	GuildRecruitmentCommentFrameBg:Hide()
	GuildNewsFrameHeader:SetAlpha(0)

	GuildFrameBottomInset:DisableDrawLayer("BACKGROUND")
	GuildFrameBottomInset:DisableDrawLayer("BORDER")
	GuildInfoFrameInfoBar1Left:SetAlpha(0)
	GuildInfoFrameInfoBar2Left:SetAlpha(0)
	select(2, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
	select(4, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
	GuildRosterColumnButton1:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton2:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton3:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton4:DisableDrawLayer("BACKGROUND")
	GuildNewsBossModel:DisableDrawLayer("BACKGROUND")
	GuildNewsBossModel:DisableDrawLayer("OVERLAY")
	GuildNewsBossNameText:SetDrawLayer("ARTWORK")
	GuildNewsBossModelTextFrame:DisableDrawLayer("BACKGROUND")
	for i = 2, 6 do
		select(i, GuildNewsBossModelTextFrame:GetRegions()):Hide()
	end

	GuildMemberRankDropdown:HookScript("OnShow", function()
		GuildMemberDetailRankText:Hide()
	end)
	GuildMemberRankDropdown:HookScript("OnHide", function()
		GuildMemberDetailRankText:Show()
	end)

	hooksecurefunc("GuildNews_Update", function()
		local buttons = GuildNewsContainer.buttons
		for i = 1, #buttons do
			buttons[i].header:SetAlpha(0)
		end
	end)

	B.ReskinClose(GuildNewsFiltersFrameCloseButton)
	B.ReskinClose(GuildLogFrameCloseButton)
	B.ReskinClose(GuildMemberDetailCloseButton)
	B.ReskinClose(GuildTextEditFrameCloseButton)
	B.ReskinScroll(GuildPerksContainerScrollBar)
	B.ReskinScroll(GuildRosterContainerScrollBar)
	B.ReskinScroll(GuildNewsContainerScrollBar)
	B.ReskinScroll(GuildRewardsContainerScrollBar)
	B.ReskinScroll(GuildInfoFrameInfoMOTDScrollFrameScrollBar)
	B.ReskinScroll(GuildInfoDetailsFrameScrollBar)
	B.ReskinScroll(GuildLogScrollFrameScrollBar)
	B.ReskinScroll(GuildTextEditScrollFrameScrollBar)
	B.ReskinScroll(GuildRecruitmentCommentInputFrameScrollFrameScrollBar)
	B.ReskinScroll(GuildInfoFrameApplicantsContainerScrollBar)
	B.ReskinDropDown(GuildRosterViewDropdown)
	B.ReskinDropDown(GuildMemberRankDropdown)
	B.ReskinInput(GuildRecruitmentCommentInputFrame)

	GuildRecruitmentCommentInputFrame:SetWidth(312)
	GuildRecruitmentCommentEditBox:SetWidth(284)
	GuildRecruitmentCommentFrame:ClearAllPoints()
	GuildRecruitmentCommentFrame:SetPoint("TOPLEFT", GuildRecruitmentLevelFrame, "BOTTOMLEFT", 0, 1)

	B.ReskinCheck(GuildRosterShowOfflineButton)
	for i = 1, 7 do
		B.ReskinCheck(GuildNewsFiltersFrame.GuildNewsFilterButtons[i])
	end

	local a1, p, a2, x, y = GuildNewsBossModel:GetPoint()
	GuildNewsBossModel:ClearAllPoints()
	GuildNewsBossModel:SetPoint(a1, p, a2, x+5, y)

	local f = B.CreateBDFrame(GuildNewsBossModel)
	f:SetPoint("TOPLEFT", 0, 1)
	f:SetPoint("BOTTOMRIGHT", 1, -52)

	local line = B.CreateBDFrame(GuildNewsBossModel, 0)
	line:ClearAllPoints()
	line:SetPoint("BOTTOMLEFT", 0, -1)
	line:SetPoint("BOTTOMRIGHT", 0, -1)
	line:SetHeight(1)

	GuildNewsFiltersFrame:SetWidth(224)
	GuildNewsFiltersFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -20)
	GuildMemberDetailFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -28)
	GuildLogFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)
	GuildTextEditFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	for i = 1, 5 do
		local bu = _G["GuildInfoFrameApplicantsContainerButton"..i]

		bu:SetBackdrop(nil)
		bu:SetHighlightTexture("")

		local bg = B.CreateBDFrame(bu, .25)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", 0, 0)
		bg:SetPoint("BOTTOMRIGHT", 0, 1)

		bu:GetRegions():SetTexture(DB.bdTex)
		bu:GetRegions():SetVertexColor(r, g, b, .2)
	end

	GuildFactionBarProgress:SetTexture(DB.bdTex)
	GuildFactionBarLeft:Hide()
	GuildFactionBarMiddle:Hide()
	GuildFactionBarRight:Hide()
	GuildFactionBarShadow:SetAlpha(0)
	GuildFactionBarBG:Hide()
	GuildFactionBarCap:SetAlpha(0)
	GuildFactionBar.bg = CreateFrame("Frame", nil, GuildFactionFrame)
	GuildFactionBar.bg:SetPoint("TOPLEFT", GuildFactionFrame, -1, -1)
	GuildFactionBar.bg:SetPoint("BOTTOMRIGHT", GuildFactionFrame, -3, 0)
	GuildFactionBar.bg:SetFrameLevel(0)
	B.CreateBD(GuildFactionBar.bg, .25)

	for _, bu in pairs(GuildPerksContainer.buttons) do
		for i = 1, 4 do
			select(i, bu:GetRegions()):SetAlpha(0)
		end

		local bg = B.CreateBDFrame(bu, .25)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", 1, -3)
		bg:SetPoint("BOTTOMRIGHT", 0, 4)
		B.ReskinIcon(bu.icon)
	end
	GuildPerksContainerButton1:SetPoint("LEFT", -1, 0)

	hooksecurefunc("GuildRewards_Update", function()
		local buttons = GuildRewardsContainer.buttons
		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu.bg then
				bu:SetNormalTexture("")
				bu:SetHighlightTexture("")
				B.ReskinIcon(bu.icon)
				bu.disabledBG:Hide()
				bu.disabledBG.Show = B.Dummy

				bu.bg = B.CreateBDFrame(bu, .25)
				bu.bg:ClearAllPoints()
				bu.bg:SetPoint("TOPLEFT", 1, -1)
				bu.bg:SetPoint("BOTTOMRIGHT", 0, 0)
			end
		end
	end)

	local function UpdateIcons()
		local index
		local offset = HybridScrollFrame_GetOffset(GuildRosterContainer)
		local totalMembers, _, onlineAndMobileMembers = GetNumGuildMembers()
		local visibleMembers = onlineAndMobileMembers
		local numbuttons = #GuildRosterContainer.buttons
		if GetGuildRosterShowOffline() then
			visibleMembers = totalMembers
		end

		for i = 1, numbuttons do
			local bu = GuildRosterContainer.buttons[i]

			if not bu.bg then
				bu:SetHighlightTexture(DB.bdTex)
				bu:GetHighlightTexture():SetVertexColor(r, g, b, .2)

				bu.bg = B.CreateBDFrame(bu.icon)
			end

			index = offset + i
			local name, _, _, _, _, _, _, _, _, _, classFileName = GetGuildRosterInfo(index)
			if name and index <= visibleMembers and bu.icon:IsShown() then
				local tcoords = CLASS_ICON_TCOORDS[classFileName]
				bu.icon:SetTexCoord(tcoords[1] + 0.022, tcoords[2] - 0.025, tcoords[3] + 0.022, tcoords[4] - 0.025)
				bu.bg:Show()
			else
				bu.bg:Hide()
			end
		end
	end

	hooksecurefunc("GuildRoster_Update", UpdateIcons)
	hooksecurefunc(GuildRosterContainer, "update", UpdateIcons)

	B.Reskin(select(4, GuildTextEditFrame:GetChildren()))
	B.Reskin(select(3, GuildLogFrame:GetChildren()))

	local gbuttons = {"GuildAddMemberButton", "GuildViewLogButton", "GuildControlButton", "GuildTextEditFrameAcceptButton", "GuildMemberGroupInviteButton", "GuildMemberRemoveButton", "GuildRecruitmentInviteButton", "GuildRecruitmentMessageButton", "GuildRecruitmentDeclineButton", "GuildRecruitmentListGuildButton"}
	for i = 1, #gbuttons do
		B.Reskin(_G[gbuttons[i]])
	end

	local checkboxes = {"GuildRecruitmentQuestButton", "GuildRecruitmentDungeonButton", "GuildRecruitmentRaidButton", "GuildRecruitmentPvPButton", "GuildRecruitmentRPButton", "GuildRecruitmentWeekdaysButton", "GuildRecruitmentWeekendsButton"}
	for i = 1, #checkboxes do
		B.ReskinCheck(_G[checkboxes[i]])
	end

	B.ReskinCheck(GuildRecruitmentTankButton:GetChildren())
	B.ReskinCheck(GuildRecruitmentHealerButton:GetChildren())
	B.ReskinCheck(GuildRecruitmentDamagerButton:GetChildren())

	B.ReskinRadio(GuildRecruitmentLevelAnyButton)
	B.ReskinRadio(GuildRecruitmentLevelMaxButton)

	for i = 1, 3 do
		for j = 1, 6 do
			select(j, _G["GuildInfoFrameTab"..i]:GetRegions()):Hide()
			select(j, _G["GuildInfoFrameTab"..i]:GetRegions()).Show = B.Dummy
		end
	end

	-- Tradeskill View
	hooksecurefunc("GuildRoster_UpdateTradeSkills", function()
		local buttons = GuildRosterContainer.buttons
		for i = 1, #buttons do
			local index = HybridScrollFrame_GetOffset(GuildRosterContainer) + i
			local str = _G["GuildRosterContainerButton"..i.."String1"]
			local header = _G["GuildRosterContainerButton"..i.."HeaderButton"]
			if header then
				local _, _, _, headerName = GetGuildTradeSkillInfo(index)
				if headerName then
					str:Hide()
				else
					str:Show()
				end

				if not header.bg then
					for j = 1, 3 do
						select(j, header:GetRegions()):Hide()
					end

					header.bg = B.CreateBDFrame(header, .25)
					header.bg:SetAllPoints()
					header:SetHighlightTexture(DB.bdTex)
					header:GetHighlightTexture():SetVertexColor(r, g, b, .25)
				end
			end
		end
	end)

	-- Font width fix
	local function updateLevelString(view)
		if view == "playerStatus" or view == "reputation" or view == "achievement" then
			local buttons = GuildRosterContainer.buttons
			for i = 1, #buttons do
				local str = _G["GuildRosterContainerButton"..i.."String1"]
				str:SetWidth(32)
				str:SetJustifyH("LEFT")
			end

			if view == "achievement" then
				for i = 1, #buttons do
					local str = _G["GuildRosterContainerButton"..i.."BarLabel"]
					str:SetWidth(60)
					str:SetJustifyH("LEFT")
				end
			end
		end
	end

	local done
	GuildRosterContainer:HookScript("OnShow", function()
		if not done then
			updateLevelString(GetCVar("guildRosterView"))
			done = true
		end
	end)
	hooksecurefunc("GuildRoster_SetView", updateLevelString)
end