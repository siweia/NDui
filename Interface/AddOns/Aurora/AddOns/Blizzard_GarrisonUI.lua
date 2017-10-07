local F, C = unpack(select(2, ...))

C.themes["Blizzard_GarrisonUI"] = function()
	local r, g, b = C.r, C.g, C.b

	-- [[ Building frame ]]

	local GarrisonBuildingFrame = GarrisonBuildingFrame

	for i = 1, 14 do
		select(i, GarrisonBuildingFrame:GetRegions()):Hide()
	end

	GarrisonBuildingFrame.TitleText:Show()

	F.CreateBD(GarrisonBuildingFrame)
	F.CreateSD(GarrisonBuildingFrame)
	F.ReskinClose(GarrisonBuildingFrame.CloseButton)
	GarrisonBuildingFrame.GarrCorners:Hide()

	-- Tutorial button

	local MainHelpButton = GarrisonBuildingFrame.MainHelpButton

	MainHelpButton.Ring:Hide()
	MainHelpButton:SetPoint("TOPLEFT", GarrisonBuildingFrame, "TOPLEFT", -12, 12)

	-- Building list

	local BuildingList = GarrisonBuildingFrame.BuildingList

	BuildingList:DisableDrawLayer("BORDER")
	BuildingList.MaterialFrame:GetRegions():Hide()

	for i = 1, GARRISON_NUM_BUILDING_SIZES do
		local tab = BuildingList["Tab"..i]

		tab:GetNormalTexture():SetAlpha(0)

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetPoint("TOPLEFT", 6, -7)
		bg:SetPoint("BOTTOMRIGHT", -6, 7)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		F.CreateBD(bg, .25)
		tab.bg = bg

		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(r, g, b, .1)
		hl:ClearAllPoints()
		hl:SetPoint("TOPLEFT", bg, 1, -1)
		hl:SetPoint("BOTTOMRIGHT", bg, -1, 1)
	end

	hooksecurefunc("GarrisonBuildingList_SelectTab", function(tab)
		local list = GarrisonBuildingFrame.BuildingList

		for i = 1, GARRISON_NUM_BUILDING_SIZES do
			local otherTab = list["Tab"..i]
			if i ~= tab:GetID() then
				otherTab.bg:SetBackdropColor(0, 0, 0, .25)
			end
		end
		tab.bg:SetBackdropColor(r, g, b, .2)

		for _, button in pairs(list.Buttons) do
			if not button.styled then
				button.BG:Hide()

				F.ReskinIcon(button.Icon)

				local bg = CreateFrame("Frame", nil, button)
				bg:SetPoint("TOPLEFT", 44, -5)
				bg:SetPoint("BOTTOMRIGHT", 0, 6)
				bg:SetFrameLevel(button:GetFrameLevel()-1)
				F.CreateBD(bg, .25)

				button.SelectedBG:SetColorTexture(r, g, b, .2)
				button.SelectedBG:ClearAllPoints()
				button.SelectedBG:SetPoint("TOPLEFT", bg, 1, -1)
				button.SelectedBG:SetPoint("BOTTOMRIGHT", bg, -1, 1)

				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .1)
				hl:ClearAllPoints()
				hl:SetPoint("TOPLEFT", bg, 1, -1)
				hl:SetPoint("BOTTOMRIGHT", bg, -1, 1)

				button.styled = true
			end
		end
	end)

	-- Building level tooltip

	if AuroraConfig.tooltips then
		local BuildingLevelTooltip = GarrisonBuildingFrame.BuildingLevelTooltip

		for i = 1, 9 do
			select(i, BuildingLevelTooltip:GetRegions()):Hide()
			F.CreateBD(BuildingLevelTooltip)
		end
	end

	-- Follower list

	local FollowerList = GarrisonBuildingFrame.FollowerList

	FollowerList:DisableDrawLayer("BACKGROUND")
	FollowerList:DisableDrawLayer("BORDER")
	F.ReskinScroll(FollowerList.listScroll.scrollBar)

	FollowerList:ClearAllPoints()
	FollowerList:SetPoint("BOTTOMLEFT", 24, 34)

	-- Info box

	local InfoBox = GarrisonBuildingFrame.InfoBox
	local TownHallBox = GarrisonBuildingFrame.TownHallBox

	for i = 1, 25 do
		select(i, InfoBox:GetRegions()):Hide()
		select(i, TownHallBox:GetRegions()):Hide()
	end

	F.CreateBD(InfoBox, .25)
	F.CreateBD(TownHallBox, .25)
	F.Reskin(InfoBox.UpgradeButton)
	F.Reskin(TownHallBox.UpgradeButton)
	GarrisonBuildingFrame.MapFrame.TownHall.TownHallName:SetTextColor(1, .8, 0)

	do
		local FollowerPortrait = InfoBox.FollowerPortrait

		F.ReskinGarrisonPortrait(FollowerPortrait)

		FollowerPortrait:SetPoint("BOTTOMLEFT", 230, 10)
		FollowerPortrait.RemoveFollowerButton:ClearAllPoints()
		FollowerPortrait.RemoveFollowerButton:SetPoint("TOPRIGHT", 4, 4)
	end

	hooksecurefunc("GarrisonBuildingInfoBox_ShowFollowerPortrait", function(_, _, infoBox)
		local portrait = infoBox.FollowerPortrait

		if portrait:IsShown() then
			portrait.squareBG:SetBackdropBorderColor(portrait.PortraitRing:GetVertexColor())
		end
	end)

	-- Confirmation popup

	local Confirmation = GarrisonBuildingFrame.Confirmation

	Confirmation:GetRegions():Hide()

	F.CreateBD(Confirmation)

	F.Reskin(Confirmation.CancelButton)
	F.Reskin(Confirmation.BuildButton)
	F.Reskin(Confirmation.UpgradeButton)
	F.Reskin(Confirmation.UpgradeGarrisonButton)
	F.Reskin(Confirmation.ReplaceButton)
	F.Reskin(Confirmation.SwitchButton)

	-- [[ Capacitive display frame ]]

	local GarrisonCapacitiveDisplayFrame = GarrisonCapacitiveDisplayFrame

	GarrisonCapacitiveDisplayFrameLeft:Hide()
	GarrisonCapacitiveDisplayFrameMiddle:Hide()
	GarrisonCapacitiveDisplayFrameRight:Hide()
	F.CreateBD(GarrisonCapacitiveDisplayFrame.Count, .25)
	GarrisonCapacitiveDisplayFrame.Count:SetWidth(38)
	GarrisonCapacitiveDisplayFrame.Count:SetTextInsets(3, 0, 0, 0)

	F.ReskinPortraitFrame(GarrisonCapacitiveDisplayFrame, true)
	F.Reskin(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)
	F.Reskin(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton, true)
	F.ReskinArrow(GarrisonCapacitiveDisplayFrame.DecrementButton, "left")
	F.ReskinArrow(GarrisonCapacitiveDisplayFrame.IncrementButton, "right")

	-- Capacitive display

	local CapacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay

	CapacitiveDisplay.IconBG:SetAlpha(0)

	do
		local icon = CapacitiveDisplay.ShipmentIconFrame.Icon

		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(icon)
		F.ReskinGarrisonPortrait(CapacitiveDisplay.ShipmentIconFrame.Follower)
	end

	do
		local reagentIndex = 1

		hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function(self)
			local reagents = CapacitiveDisplay.Reagents

			local reagent = reagents[reagentIndex]
			while reagent do
				reagent.NameFrame:SetAlpha(0)

				reagent.Icon:SetTexCoord(.08, .92, .08, .92)
				reagent.Icon:SetDrawLayer("BORDER")
				F.CreateBG(reagent.Icon)

				local bg = CreateFrame("Frame", nil, reagent)
				bg:SetPoint("TOPLEFT")
				bg:SetPoint("BOTTOMRIGHT", 0, 2)
				bg:SetFrameLevel(reagent:GetFrameLevel() - 1)
				F.CreateBD(bg, .25)

				reagentIndex = reagentIndex + 1
				reagent = reagents[reagentIndex]
			end
		end)
	end

	-- [[ Landing page ]]

	local GarrisonLandingPage = GarrisonLandingPage

	for i = 1, 10 do
		select(i, GarrisonLandingPage:GetRegions()):Hide()
	end

	F.CreateBD(GarrisonLandingPage)
	F.CreateSD(GarrisonLandingPage)
	F.ReskinClose(GarrisonLandingPage.CloseButton)
	F.ReskinTab(GarrisonLandingPageTab1)
	F.ReskinTab(GarrisonLandingPageTab2)
	F.ReskinTab(GarrisonLandingPageTab3)

	GarrisonLandingPageTab1:ClearAllPoints()
	GarrisonLandingPageTab1:SetPoint("TOPLEFT", GarrisonLandingPage, "BOTTOMLEFT", 70, 2)

	-- Report

	local Report = GarrisonLandingPage.Report

	select(2, Report:GetRegions()):Hide()
	Report.List:GetRegions():Hide()

	local scrollFrame = Report.List.listScroll

	F.ReskinScroll(scrollFrame.scrollBar)

	local buttons = scrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]

		button.BG:Hide()

		local bg = CreateFrame("Frame", nil, button)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		bg:SetFrameLevel(button:GetFrameLevel() - 1)

		for _, reward in pairs(button.Rewards) do
			reward:GetRegions():Hide()
			reward.Icon:SetTexCoord(.08, .92, .08, .92)
			reward.IconBorder:SetAlpha(0)
			F.CreateBG(reward.Icon)
			reward:ClearAllPoints()
			reward:SetPoint("TOPRIGHT", -4, -4)
		end

		F.CreateBD(bg, .25)
	end

	for _, tab in pairs({Report.InProgress, Report.Available}) do
		tab:SetHighlightTexture("")

		tab.Text:ClearAllPoints()
		tab.Text:SetPoint("CENTER")

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetFrameLevel(tab:GetFrameLevel() - 1)
		F.CreateBD(bg, .25)

		F.CreateGradient(bg)

		local selectedTex = bg:CreateTexture(nil, "BACKGROUND")
		selectedTex:SetAllPoints()
		selectedTex:SetColorTexture(r, g, b, .2)
		selectedTex:Hide()
		tab.selectedTex = selectedTex

		if tab == Report.InProgress then
			bg:SetPoint("TOPLEFT", 5, 0)
			bg:SetPoint("BOTTOMRIGHT")
		else
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", -7, 0)
		end
	end

	hooksecurefunc("GarrisonLandingPageReport_SetTab", function(self)
		local unselectedTab = Report.unselectedTab

		unselectedTab:SetHeight(36)

		unselectedTab:SetNormalTexture("")
		unselectedTab.selectedTex:Hide()
		self:SetNormalTexture("")
		self.selectedTex:Show()
	end)

	-- Follower list

	local FollowerList = GarrisonLandingPage.FollowerList

	FollowerList:GetRegions():Hide()
	select(2, FollowerList:GetRegions()):Hide()

	F.ReskinInput(FollowerList.SearchBox)

	local scrollFrame = FollowerList.listScroll

	F.ReskinScroll(scrollFrame.scrollBar)

	-- Ship follower list

	local FollowerList = GarrisonLandingPage.ShipFollowerList

	FollowerList:GetRegions():Hide()
	select(2, FollowerList:GetRegions()):Hide()

	F.ReskinInput(FollowerList.SearchBox)

	local scrollFrame = FollowerList.listScroll

	F.ReskinScroll(scrollFrame.scrollBar)

	-- Follower tab

	local FollowerTab = GarrisonLandingPage.FollowerTab

	do
		local xpBar = FollowerTab.XPBar

		select(1, xpBar:GetRegions()):Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()

		xpBar:SetStatusBarTexture(C.media.backdrop)

		F.CreateBDFrame(xpBar)
	end

	-- Ship follower tab

	local FollowerTab = GarrisonLandingPage.ShipFollowerTab

	do
		local xpBar = FollowerTab.XPBar

		select(1, xpBar:GetRegions()):Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()

		xpBar:SetStatusBarTexture(C.media.backdrop)

		F.CreateBDFrame(xpBar)
	end

	for i = 1, 2 do
		local trait = FollowerTab.Traits[i]

		trait.Border:Hide()
		F.ReskinIcon(trait.Portrait)

		local equipment = FollowerTab.EquipmentFrame.Equipment[i]

		equipment.BG:Hide()
		equipment.Border:Hide()

		F.ReskinIcon(equipment.Icon)
	end

	-- [[ Mission UI ]]

	local GarrisonMissionFrame = GarrisonMissionFrame

	for i = 1, 14 do
		select(i, GarrisonMissionFrame:GetRegions()):Hide()
	end
	GarrisonMissionFrame.TitleText:Show()
	GarrisonMissionFrame.GarrCorners:Hide()

	F.CreateBD(GarrisonMissionFrame)
	F.CreateSD(GarrisonMissionFrame)
	F.ReskinClose(GarrisonMissionFrame.CloseButton)
	F.ReskinTab(GarrisonMissionFrameTab1)
	F.ReskinTab(GarrisonMissionFrameTab2)

	GarrisonMissionFrameTab1:ClearAllPoints()
	GarrisonMissionFrameTab1:SetPoint("BOTTOMLEFT", 11, -40)

	-- Mission Complete Page

	local missionComplete = GarrisonMissionFrame.MissionComplete
	local bonusRewards = missionComplete.BonusRewards
	select(11, bonusRewards:GetRegions()):SetTextColor(1, .8, 0)
	bonusRewards.Saturated:Hide()
	bonusRewards.Saturated.Show = F.dummy
	for i = 1, 9 do
		select(i, bonusRewards:GetRegions()):SetAlpha(0)
	end
	F.CreateBD(bonusRewards, .25)
	F.Reskin(missionComplete.NextMissionButton)

	-- Follower list

	local FollowerList = GarrisonMissionFrame.FollowerList

	FollowerList:DisableDrawLayer("BORDER")
	FollowerList.MaterialFrame:GetRegions():Hide()

	F.ReskinInput(FollowerList.SearchBox)
	F.ReskinScroll(FollowerList.listScroll.scrollBar)

	local MissionTab = GarrisonMissionFrame.MissionTab

	-- Mission list

	local MissionList = MissionTab.MissionList

	MissionList:DisableDrawLayer("BORDER")

	F.ReskinScroll(MissionList.listScroll.scrollBar)

	for i = 1, 2 do
		local tab = _G["GarrisonMissionFrameMissionsTab"..i]

		tab.Left:Hide()
		tab.Middle:Hide()
		tab.Right:Hide()
		tab.SelectedLeft:SetTexture("")
		tab.SelectedMid:SetTexture("")
		tab.SelectedRight:SetTexture("")

		F.CreateBD(tab, .25)
	end

	GarrisonMissionFrameMissionsTab1:SetBackdropColor(r, g, b, .2)

	hooksecurefunc("GarrisonMissonListTab_SetSelected", function(tab, isSelected)
		if isSelected then
			tab:SetBackdropColor(r, g, b, .2)
		else
			tab:SetBackdropColor(0, 0, 0, .25)
		end
	end)

	do
		MissionList.MaterialFrame:GetRegions():Hide()
		local bg = F.CreateBDFrame(MissionList.MaterialFrame, .25)
		bg:SetPoint("TOPLEFT", 5, -5)
		bg:SetPoint("BOTTOMRIGHT", -5, 6)
	end

	F.Reskin(MissionList.CompleteDialog.BorderFrame.ViewButton)

	local buttons = MissionList.listScroll.buttons
	for i = 1, #buttons do
		local button = buttons[i]

		for i = 1, 12 do
			local rareOverlay = button.RareOverlay
			local rareText = button.RareText

			select(i, button:GetRegions()):Hide()

			F.CreateBD(button, .25)

			rareText:ClearAllPoints()
			rareText:SetPoint("BOTTOMLEFT", button, 20, 10)

			rareOverlay:SetDrawLayer("BACKGROUND")
			rareOverlay:SetTexture(C.media.backdrop)
			rareOverlay:ClearAllPoints()
			rareOverlay:SetAllPoints()
			rareOverlay:SetVertexColor(0.098, 0.537, 0.969, 0.2)
		end
	end

	hooksecurefunc("GarrisonMissionButton_SetRewards", function(self, rewards, numRewards)
		if IsAddOnLoaded("GarrisonMaster") then return end

		if self.numRewardsStyled == nil then
			self.numRewardsStyled = 0
		end

		while self.numRewardsStyled < numRewards do
			self.numRewardsStyled = self.numRewardsStyled + 1

			local reward = self.Rewards[self.numRewardsStyled]
			reward:GetRegions():Hide()
			reward.Icon:SetTexCoord(.08, .92, .08, .92)
			reward.IconBorder:SetAlpha(0)
			F.CreateBG(reward.Icon)
		end
	end)

	-- Mission page

	local MissionPage = MissionTab.MissionPage

	for i = 1, 15 do
		select(i, MissionPage:GetRegions()):Hide()
	end
	select(18, MissionPage:GetRegions()):Hide()
	select(19, MissionPage:GetRegions()):Hide()
	select(20, MissionPage:GetRegions()):Hide()
	MissionPage.StartMissionButton.Flash:SetTexture("")

	F.Reskin(MissionPage.StartMissionButton)
	F.ReskinClose(MissionPage.CloseButton)

	MissionPage.CloseButton:ClearAllPoints()
	MissionPage.CloseButton:SetPoint("TOPRIGHT", -10, -5)

	select(4, MissionPage.Stage:GetRegions()):Hide()
	select(5, MissionPage.Stage:GetRegions()):Hide()

	do
		local bg = CreateFrame("Frame", nil, MissionPage.Stage)
		bg:SetPoint("TOPLEFT", 4, 1)
		bg:SetPoint("BOTTOMRIGHT", -4, -1)
		bg:SetFrameLevel(MissionPage.Stage:GetFrameLevel() - 1)
		F.CreateBD(bg)

		local overlay = MissionPage.Stage:CreateTexture()
		overlay:SetDrawLayer("ARTWORK", 3)
		overlay:SetAllPoints(bg)
		overlay:SetColorTexture(0, 0, 0, .5)

		local iconbg = select(16, MissionPage:GetRegions())
		iconbg:ClearAllPoints()
		iconbg:SetPoint("TOPLEFT", 3, -1)
	end

	for i = 1, 3 do
		local follower = MissionPage.Followers[i]
		follower:GetRegions():Hide()
		F.CreateBD(follower, .25)

		follower.PortraitFrame.Highlight:Hide()
		follower.PortraitFrame.PortraitFeedbackGlow:Hide()
		follower.PortraitFrame.PortraitRing:SetAlpha(0)
		follower.PortraitFrame.PortraitRingQuality:SetAlpha(0)
		follower.PortraitFrame.LevelBorder:SetAlpha(0)
		follower.PortraitFrame.Level:SetText("")
		follower.PortraitFrame.Empty:SetColorTexture(0,0,0)
		follower.PortraitFrame.Empty:SetAllPoints(follower.PortraitFrame.Portrait)
	end

	local function onAssignFollowerToMission(self, frame)
		frame.PortraitFrame.LevelBorder:SetAlpha(0)
	end

	local function onRemoveFollowerFromMission(self, frame)
		if frame.PortraitFrame.squareBG then
			frame.PortraitFrame.squareBG:Hide()
		end
	end

	hooksecurefunc(GarrisonMissionFrame, "AssignFollowerToMission", onAssignFollowerToMission)
	hooksecurefunc(GarrisonMissionFrame, "RemoveFollowerFromMission", onRemoveFollowerFromMission)

	for i = 1, 10 do
		select(i, MissionPage.RewardsFrame:GetRegions()):Hide()
	end

	F.CreateBD(MissionPage.RewardsFrame, .25)

	for i = 1, 2 do
		local reward = MissionPage.RewardsFrame.Rewards[i]
		local icon = reward.Icon

		reward.BG:Hide()

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetDrawLayer("BORDER", 1)
		F.CreateBG(icon)

		reward.ItemBurst:SetDrawLayer("BORDER", 2)

		F.CreateBD(reward, .15)
	end

	local buffFrame = MissionPage.BuffsFrame
	buffFrame.BuffsBG:Hide()
	hooksecurefunc(GarrisonMissionFrame, "UpdateMissionData", function()
		local buffIndex = 1
		local buff = buffFrame.Buffs[buffIndex]
		while buff do
			if not buff.styled then
				buff.Icon:SetDrawLayer("BORDER", 1)
				F.ReskinIcon(buff.Icon)
				buff.styled = true
			end
			buffIndex = buffIndex + 1
			buff = buffFrame.Buffs[buffIndex]
		end
	end)

	local env = MissionPage.Stage.MissionEnvIcon
	env.Texture:SetDrawLayer("BORDER", 1)
	F.ReskinIcon(env.Texture)

	-- Follower tab

	local FollowerTab = GarrisonMissionFrame.FollowerTab

	FollowerTab:DisableDrawLayer("BORDER")

	do
		local xpBar = FollowerTab.XPBar

		select(1, xpBar:GetRegions()):Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()

		xpBar:SetStatusBarTexture(C.media.backdrop)

		F.CreateBDFrame(xpBar)
	end

	for _, item in pairs({FollowerTab.ItemWeapon, FollowerTab.ItemArmor}) do
		local icon = item.Icon

		item.Border:Hide()

		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(icon)

		local bg = F.CreateBDFrame(item, .25)
		bg:SetPoint("TOPLEFT", 41, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
	end

	-- Portraits

	hooksecurefunc("GarrisonMissionPortrait_SetFollowerPortrait", function(portraitFrame, followerInfo)
		if not portraitFrame.styled then
			F.ReskinGarrisonPortrait(portraitFrame)
			portraitFrame.styled = true
		end

		local color = BAG_ITEM_QUALITY_COLORS[followerInfo.quality]

		portraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		portraitFrame.squareBG:Show()
	end)

	hooksecurefunc(GarrisonFollowerMission, "AssignFollowerToMission", function(self, frame)
		frame.PortraitFrame.LevelBorder:SetAlpha(0)
	end)

	hooksecurefunc(GarrisonFollowerMission, "RemoveFollowerFromMission", function(self, frame)
		if frame.PortraitFrame.squareBG then
			frame.PortraitFrame.squareBG:Hide()
		end
	end)

	-- Mechanic tooltip

	if AuroraConfig.tooltips then
		GarrisonMissionMechanicTooltip:SetBackdrop(nil)
		GarrisonMissionMechanicFollowerCounterTooltip:SetBackdrop(nil)
		F.CreateBDFrame(GarrisonMissionMechanicTooltip, .6)
		F.CreateBDFrame(GarrisonMissionMechanicFollowerCounterTooltip, .6)
	end

	-- [[ Recruiter frame ]]

	local GarrisonRecruiterFrame = GarrisonRecruiterFrame

	for i = 18, 22 do
		select(i, GarrisonRecruiterFrame:GetRegions()):Hide()
	end

	F.ReskinPortraitFrame(GarrisonRecruiterFrame, true)

	-- Pick

	local Pick = GarrisonRecruiterFrame.Pick

	F.Reskin(Pick.ChooseRecruits)
	F.ReskinDropDown(Pick.ThreatDropDown)
	F.ReskinRadio(Pick.Radio1)
	F.ReskinRadio(Pick.Radio2)

	-- Unavailable frame

	local UnavailableFrame = GarrisonRecruiterFrame.UnavailableFrame

	F.Reskin(UnavailableFrame:GetChildren())

	-- [[ Recruiter select frame ]]

	local GarrisonRecruitSelectFrame = GarrisonRecruitSelectFrame

	for i = 1, 14 do
		select(i, GarrisonRecruitSelectFrame:GetRegions()):Hide()
	end
	GarrisonRecruitSelectFrame.TitleText:Show()
	GarrisonRecruitSelectFrame.GarrCorners:Hide()

	F.CreateBD(GarrisonRecruitSelectFrame)
	F.ReskinClose(GarrisonRecruitSelectFrame.CloseButton)

	-- Follower list

	local FollowerList = GarrisonRecruitSelectFrame.FollowerList

	FollowerList:DisableDrawLayer("BORDER")

	F.ReskinScroll(FollowerList.listScroll.scrollBar)
	F.ReskinInput(FollowerList.SearchBox)

	-- Follower selection

	local FollowerSelection = GarrisonRecruitSelectFrame.FollowerSelection

	FollowerSelection:DisableDrawLayer("BORDER")

	for i = 1, 3 do
		local recruit = FollowerSelection["Recruit"..i]

		F.ReskinGarrisonPortrait(recruit.PortraitFrame)

		F.Reskin(recruit.HireRecruits)
	end

	hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", function(waiting)
		if waiting then return end

		for i = 1, 3 do
			local recruit = FollowerSelection["Recruit"..i]
			local portrait = recruit.PortraitFrame

			portrait.squareBG:SetBackdropBorderColor(portrait.LevelBorder:GetVertexColor())
		end
	end)

	-- [[ Monuments ]]

	local GarrisonMonumentFrame = GarrisonMonumentFrame

	GarrisonMonumentFrame.Background:Hide()
	F.SetBD(GarrisonMonumentFrame, 6, -10, -6, 4)

	do
		local left = GarrisonMonumentFrame.LeftBtn
		local right = GarrisonMonumentFrame.RightBtn

		left.Texture:Hide()
		right.Texture:Hide()

		F.ReskinArrow(left, "left")
		F.ReskinArrow(right, "right")
		left:SetSize(35, 35)
		left.bgTex:SetSize(16, 16)
		right:SetSize(35, 35)
		right.bgTex:SetSize(16, 16)
	end

	-- [[ Shared templates ]]

	local function onUpdateData(self)
		local followerFrame = self:GetParent()
		local followers = followerFrame.FollowerList.followers
		local followersList = followerFrame.FollowerList.followersList
		local numFollowers = #followersList
		local scrollFrame = followerFrame.FollowerList.listScroll
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local numButtons = #buttons

		for i = 1, #buttons do
			local button = buttons[i].Follower
			local portrait = button.PortraitFrame

			if not button.restyled then
				button.BG:Hide()
				button.Selection:SetTexture("")
				button.AbilitiesBG:SetTexture("")

				F.CreateBD(button, .25)

				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .1)
				hl:ClearAllPoints()
				hl:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
				hl:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

				if portrait then
					F.ReskinGarrisonPortrait(portrait)
					portrait:ClearAllPoints()
					portrait:SetPoint("TOPLEFT", 4, -1)
				end

				button.restyled = true
			end

			if button.Selection:IsShown() then
				button:SetBackdropColor(r, g, b, .2)
			else
				button:SetBackdropColor(0, 0, 0, .25)
			end

			if portrait and portrait.quality then
				local color = BAG_ITEM_QUALITY_COLORS[portrait.quality]
				portrait.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end

	hooksecurefunc(GarrisonMissionFrameFollowers, "UpdateData", onUpdateData)
	hooksecurefunc(GarrisonLandingPageFollowerList, "UpdateData", onUpdateData)
	hooksecurefunc(GarrisonFollowerList, "UpdateData", onUpdateData)

	hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
		local ability = self.Abilities[index]

		if not ability.styled then
			local icon = ability.Icon

			icon:SetSize(19, 19)
			icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(icon)

			ability.styled = true
		end
	end)

	local function onShowFollower(self, followerId)
		local followerList = self
		local self = self.followerTab

		local abilities = self.AbilitiesFrame.Abilities

		if self.numAbilitiesStyled == nil then
			self.numAbilitiesStyled = 1
		end

		local numAbilitiesStyled = self.numAbilitiesStyled

		local ability = abilities[numAbilitiesStyled]
		while ability do
			local icon = ability.IconButton.Icon

			icon:SetTexCoord(.08, .92, .08, .92)
			icon:SetDrawLayer("BACKGROUND", 1)
			F.CreateBG(icon)

			numAbilitiesStyled = numAbilitiesStyled + 1
			ability = abilities[numAbilitiesStyled]
		end

		self.numAbilitiesStyled = numAbilitiesStyled

		local ally = self.AbilitiesFrame.CombatAllySpell[1].iconTexture
		ally:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ally)

		for i = 1, 3 do
			if not self.AbilitiesFrame.Equipment then return end
			local equip = self.AbilitiesFrame.Equipment[i]
			equip.Border:Hide()
			equip.BG:Hide()
			equip.Icon:SetTexCoord(.08, .92, .08, .92)
			if not equip.bg then
				equip.bg = F.CreateBDFrame(equip.Icon)
			end
		end
	end

	hooksecurefunc(GarrisonMissionFrame.FollowerList, "ShowFollower", onShowFollower)
	hooksecurefunc(GarrisonLandingPageFollowerList, "ShowFollower", onShowFollower)
	hooksecurefunc(GarrisonFollowerList, "ShowFollower", onShowFollower)

	-- [[ Shipyard ]]

	if AuroraConfig.tooltips then
		F.CreateBD(GarrisonShipyardMapMissionTooltip)
	end

	-- Follower tab

	local FollowerTab = GarrisonShipyardFrame.FollowerTab

	for i = 1, 2 do
		local trait = FollowerTab.Traits[i]

		trait.Border:Hide()
		F.ReskinIcon(trait.Portrait)

		local equipment = FollowerTab.EquipmentFrame.Equipment[i]

		equipment.BG:Hide()
		equipment.Border:Hide()

		F.ReskinIcon(equipment.Icon)
	end

	-- GarrisonShipyardFrame, need review

	for i = 1, 14 do
		select(i, GarrisonShipyardFrame.BorderFrame:GetRegions()):Hide()
	end

	GarrisonShipyardFrame.BorderFrame.TitleText:Show()
	GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
	GarrisonShipyardFrame.BackgroundTile:Hide()

	local sbg = CreateFrame("Frame", nil, GarrisonShipyardFrame)
	sbg:SetAllPoints()
	sbg:SetFrameLevel(GarrisonShipyardFrame:GetFrameLevel() - 1)
	F.CreateBD(sbg)
	F.CreateSD(sbg)

	F.ReskinInput(GarrisonShipyardFrameFollowers.SearchBox)
	F.ReskinScroll(GarrisonShipyardFrameFollowersListScrollFrameScrollBar)
	GarrisonShipyardFrameFollowers:GetRegions():Hide()
	select(2, GarrisonShipyardFrameFollowers:GetRegions()):Hide()
	GarrisonShipyardFrameFollowers:DisableDrawLayer("BORDER")
	GarrisonShipyardFrameFollowers.MaterialFrame:GetRegions():Hide()

	local shipyardTab = GarrisonShipyardFrame.FollowerTab
	shipyardTab:DisableDrawLayer("BORDER")
	
	do
		local xpBar = shipyardTab.XPBar

		select(1, xpBar:GetRegions()):Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()

		xpBar:SetStatusBarTexture(C.media.backdrop)

		F.CreateBDFrame(xpBar)
	end

	F.ReskinClose(GarrisonShipyardFrame.BorderFrame.CloseButton2)
	F.ReskinTab(GarrisonShipyardFrameTab1)
	F.ReskinTab(GarrisonShipyardFrameTab2)
	F.ReskinClose(GarrisonShipyardFrame.MissionTab.MissionPage.CloseButton)
	F.Reskin(GarrisonShipyardFrame.MissionTab.MissionPage.StartMissionButton)
	GarrisonShipyardFrame.MissionCompleteBackground:GetRegions():Hide()
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog:GetRegions():Hide()
	F.Reskin(GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton)

	-- [[ Addon supports ]]

	do
		local skinIndex = 0
		local f = CreateFrame("Frame")
		f:RegisterEvent("ADDON_LOADED")
		f:SetScript("OnEvent", function(_, event, addon)
			if addon == "MasterPlan" then
				local minimize = MissionPage.MinimizeButton

				F.ReskinTab(GarrisonMissionFrameTab3)
				F.ReskinTab(GarrisonMissionFrameTab4)
				F.ReskinTab(GarrisonShipyardFrameTab3)
				F.ReskinTab(GarrisonLandingPageTab4)
				F.Reskin(MPPokeTentativeParties)
				F.Reskin(MPCompleteAll)

				MissionPage.CloseButton:SetSize(17, 17)
				MissionPage.CloseButton:ClearAllPoints()
				MissionPage.CloseButton:SetPoint("TOPRIGHT", -10, -5)

				F.ReskinExpandOrCollapse(minimize)
				minimize:SetSize(17, 17)
				minimize:ClearAllPoints()
				minimize:SetPoint("RIGHT", MissionPage.CloseButton, "LEFT", -1, 0)
				minimize.plus:Hide()

				local function reskinBar(bar)
					for i = 2, 5 do
						select(i, bar:GetRegions()):Hide()
					end
					F.Reskin(bar.Up, true)
					F.Reskin(bar.Down, true)

					local bu = bar:GetRegions()
					bu:SetAlpha(0)
					bu:SetWidth(17)
					bu.bg = CreateFrame("Frame", nil, bar)
					bu.bg:SetPoint("TOPLEFT", bu, 0, -2)
					bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 4)
					F.CreateBD(bu.bg, 0)
					local tex = F.CreateGradient(bar)
					tex:SetPoint("TOPLEFT", bu.bg, 1, -1)
					tex:SetPoint("BOTTOMRIGHT", bu.bg, -1, 1)

					local uptex = bar.Up:CreateTexture(nil, "ARTWORK")
					uptex:SetTexture(C.media.arrowUp)
					uptex:SetSize(8, 8)
					uptex:SetPoint("CENTER")
					uptex:SetVertexColor(1, 1, 1)

					local downtex = bar.Down:CreateTexture(nil, "ARTWORK")
					downtex:SetTexture(C.media.arrowDown)
					downtex:SetSize(8, 8)
					downtex:SetPoint("CENTER")
					downtex:SetVertexColor(1, 1, 1)
				end
				reskinBar(MasterPlanMissionList.List.Bar)
				reskinBar(MPShipMoI.List.Bar)
				reskinBar(MPLandingPageAlts.List.Bar)

				skinIndex = skinIndex + 1

			elseif addon == "GarrisonMissionManager" then
				hooksecurefunc(MissionList, "Update", function()
					local buttons = MissionList.listScroll.buttons
					for i = 1, #buttons do
						local bu = select(3, buttons[i]:GetChildren())
						if bu and bu:GetObjectType() == "Button" and not bu.styled then
							F.Reskin(bu)
							bu:SetSize(60, 45)
							bu.styled = true
						end
					end
				end)

				MissionPage:HookScript("OnShow", function()
					for i = 18, 26 do
						local bu = select(i, MissionPage:GetChildren())
						if bu and bu:GetObjectType() == "Button" and not bu.styled then
							F.Reskin(bu)
							bu:SetSize(50, 45)
							bu.styled = true
						end
					end
				end)

				skinIndex = skinIndex + 1
			end

			if skinIndex == 2 then f:UnregisterEvent(event) end
		end)
	end
end