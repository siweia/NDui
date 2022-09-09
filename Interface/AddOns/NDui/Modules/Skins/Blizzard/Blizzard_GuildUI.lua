local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function updateClassIcons()
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
			B.ClassIconTexCoord(bu.icon, classFileName)
			bu.bg:Show()
		else
			bu.bg:Hide()
		end
	end
end

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

C.themes["Blizzard_GuildUI"] = function()
	B.ReskinPortraitFrame(GuildFrame)
	B.StripTextures(GuildMemberDetailFrame)
	B.SetBD(GuildMemberDetailFrame)
	GuildMemberNoteBackground:HideBackdrop()
	B.CreateBDFrame(GuildMemberNoteBackground, .25)
	GuildMemberOfficerNoteBackground:HideBackdrop()
	B.CreateBDFrame(GuildMemberOfficerNoteBackground, .25)
	B.SetBD(GuildLogFrame)
	B.CreateBDFrame(GuildLogContainer, .25)
	B.SetBD(GuildNewsFiltersFrame)
	B.SetBD(GuildTextEditFrame)
	B.StripTextures(GuildTextEditContainer)
	B.CreateBDFrame(GuildTextEditContainer, .25)
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
	B.StripTextures(GuildInfoFrameInfo)
	B.StripTextures(GuildInfoFrameTab1)
	GuildMemberDetailCorner:Hide()
	B.StripTextures(GuildLogFrame)
	B.StripTextures(GuildLogContainer)
	B.StripTextures(GuildNewsFiltersFrame)
	B.StripTextures(GuildTextEditFrame)
	GuildAllPerksFrame:GetRegions():Hide()
	GuildNewsFrame:GetRegions():Hide()
	GuildRewardsFrame:GetRegions():Hide()
	GuildNewsBossModelShadowOverlay:Hide()
	GuildNewsFrameHeader:SetAlpha(0)

	GuildFrameBottomInset:DisableDrawLayer("BACKGROUND")
	GuildFrameBottomInset:DisableDrawLayer("BORDER")
	GuildInfoFrameInfoBar1Left:SetAlpha(0)
	GuildInfoFrameInfoBar2Left:SetAlpha(0)
	for i = 1, 4 do
		_G["GuildRosterColumnButton"..i]:DisableDrawLayer("BACKGROUND")
	end
	GuildNewsBossModel:DisableDrawLayer("BACKGROUND")
	GuildNewsBossModel:DisableDrawLayer("OVERLAY")
	GuildNewsBossNameText:SetDrawLayer("ARTWORK")
	B.StripTextures(GuildNewsBossModelTextFrame)

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
	B.ReskinDropDown(GuildRosterViewDropdown)
	B.ReskinDropDown(GuildMemberRankDropdown)

	B.ReskinCheck(GuildRosterShowOfflineButton)
	for i = 1, 7 do
		B.ReskinCheck(GuildNewsFiltersFrame.GuildNewsFilterButtons[i])
	end

	local a1, p, a2, x, y = GuildNewsBossModel:GetPoint()
	GuildNewsBossModel:ClearAllPoints()
	GuildNewsBossModel:SetPoint(a1, p, a2, x + 7, y)

	local f = B.SetBD(GuildNewsBossModel)
	f:SetPoint("BOTTOMRIGHT", 2, -52)

	GuildNewsFiltersFrame:SetWidth(224)
	GuildNewsFiltersFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 3, -20)
	GuildMemberDetailFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 3, -28)
	GuildLogFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 3, 0)
	GuildTextEditFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 3, 0)

	GuildFactionBarProgress:SetTexture(DB.bdTex)
	GuildFactionBarLeft:Hide()
	GuildFactionBarMiddle:Hide()
	GuildFactionBarRight:Hide()
	GuildFactionBarShadow:SetAlpha(0)
	GuildFactionBarBG:Hide()
	GuildFactionBarCap:SetAlpha(0)
	local bg = B.CreateBDFrame(GuildFactionFrame, .25)
	bg:SetPoint("TOPLEFT", GuildFactionFrame, -1, -1)
	bg:SetPoint("BOTTOMRIGHT", GuildFactionFrame, -3, 0)
	bg:SetFrameLevel(0)

	for _, button in pairs(GuildPerksContainer.buttons) do
		B.ReskinIcon(button.icon)
		B.StripTextures(button)
		button.bg = B.CreateBDFrame(button, .25)
		button.bg:ClearAllPoints()
		button.bg:SetPoint("TOPLEFT", button.icon, 0, C.mult)
		button.bg:SetPoint("BOTTOMLEFT", button.icon, 0, -C.mult)
		button.bg:SetWidth(button:GetWidth())
	end
	GuildPerksContainerButton1:SetPoint("LEFT", -1, 0)

	hooksecurefunc("GuildRewards_Update", function()
		local buttons = GuildRewardsContainer.buttons
		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu.bg then
				bu:SetNormalTexture(DB.blankTex)
				bu:SetHighlightTexture(DB.blankTex)
				B.ReskinIcon(bu.icon)
				bu.disabledBG:Hide()
				bu.disabledBG.Show = B.Dummy

				bu.bg = B.CreateBDFrame(bu, .25)
				bu.bg:SetInside()
			end
		end
	end)

	hooksecurefunc("GuildRoster_Update", updateClassIcons)
	hooksecurefunc(GuildRosterContainer, "update", updateClassIcons)

	B.Reskin(select(4, GuildTextEditFrame:GetChildren()))
	B.Reskin(select(3, GuildLogFrame:GetChildren()))

	local gbuttons = {
		"GuildAddMemberButton",
		"GuildViewLogButton",
		"GuildControlButton",
		"GuildTextEditFrameAcceptButton",
		"GuildMemberGroupInviteButton",
		"GuildMemberRemoveButton",
	}
	for i = 1, #gbuttons do
		B.Reskin(_G[gbuttons[i]])
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
					B.StripTextures(header, 5)
					header.bg = B.CreateBDFrame(header, .25)
					header.bg:SetAllPoints()

					header:SetHighlightTexture(DB.bdTex)
					local hl = header:GetHighlightTexture()
					hl:SetVertexColor(r, g, b, .25)
					hl:SetInside()
				end
			end
		end
	end)

	-- Font width fix
	local done
	GuildRosterContainer:HookScript("OnShow", function()
		if not done then
			updateLevelString(GetCVar("guildRosterView"))
			done = true
		end
	end)
	hooksecurefunc("GuildRoster_SetView", updateLevelString)
end