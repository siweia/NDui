local F, C = unpack(select(2, ...))

C.themes["Blizzard_GarrisonUI"] = function()
	local r, g, b = C.r, C.g, C.b

	-- [[ Shared codes ]]

	function F:ReskinMissionPage()
		F.StripTextures(self)
		self.StartMissionButton.Flash:SetTexture("")
		F.Reskin(self.StartMissionButton)
		F.ReskinClose(self.CloseButton)

		self.CloseButton:ClearAllPoints()
		self.CloseButton:SetPoint("TOPRIGHT", -10, -5)
		select(4, self.Stage:GetRegions()):Hide()
		select(5, self.Stage:GetRegions()):Hide()

		local bg = F.CreateBDFrame(self.Stage)
		bg:SetPoint("TOPLEFT", 4, 1)
		bg:SetPoint("BOTTOMRIGHT", -4, -1)
		local overlay = self.Stage:CreateTexture()
		overlay:SetDrawLayer("ARTWORK", 3)
		overlay:SetAllPoints(bg)
		overlay:SetColorTexture(0, 0, 0, .5)
		local iconbg = select(16, self:GetRegions())
		iconbg:ClearAllPoints()
		iconbg:SetPoint("TOPLEFT", 3, -1)

		for i = 1, 3 do
			local follower = self.Followers[i]
			follower:GetRegions():Hide()
			F.CreateBD(follower, .25)
			F.ReskinGarrisonPortrait(follower.PortraitFrame)
			follower.PortraitFrame:ClearAllPoints()
			follower.PortraitFrame:SetPoint("TOPLEFT", 0, -3)
		end

		for i = 1, 10 do
			select(i, self.RewardsFrame:GetRegions()):Hide()
		end
		F.CreateBD(self.RewardsFrame, .25)

		local env = self.Stage.MissionEnvIcon
		env.Texture:SetDrawLayer("BORDER", 1)
		F.ReskinIcon(env.Texture)

		local item = self.RewardsFrame.OvermaxItem
		item.Icon:SetDrawLayer("BORDER", 1)
		F.ReskinIcon(item.Icon)
	end

	function F:ReskinMissionTabs()
		for i = 1, 2 do
			local tab = _G[self:GetName().."Tab"..i]
			F.StripTextures(tab)
			F.CreateBD(tab, .25)
			if i == 1 then
				tab:SetBackdropColor(r, g, b, .2)
			end
		end
	end

	function F:ReskinXPBar()
		local xpBar = self.XPBar
		xpBar:GetRegions():Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()
		xpBar:SetStatusBarTexture(C.media.backdrop)
		F.CreateBDFrame(xpBar, .25)
	end

	function F:ReskinGarrMaterial()
		self.MaterialFrame.Icon:SetTexCoord(.08, .92, .08, .92)
		self.MaterialFrame:GetRegions():Hide()
		local bg = F.CreateBDFrame(self.MaterialFrame, .25)
		bg:SetPoint("TOPLEFT", 5, -5)
		bg:SetPoint("BOTTOMRIGHT", -5, 6)
	end

	function F:ReskinMissionList()
		local buttons = self.listScroll.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.styled then
				local rareOverlay = button.RareOverlay
				local rareText = button.RareText

				F.StripTextures(button)
				F.CreateBD(button, .25)

				rareText:ClearAllPoints()
				rareText:SetPoint("BOTTOMLEFT", button, 20, 10)
				rareOverlay:SetDrawLayer("BACKGROUND")
				rareOverlay:SetTexture(C.media.backdrop)
				rareOverlay:SetAllPoints()
				rareOverlay:SetVertexColor(.098, .537, .969, .2)

				button.styled = true
			end
		end
	end

	function F:ReskinMissionComplete()
		local missionComplete = self.MissionComplete
		local bonusRewards = missionComplete.BonusRewards
		select(11, bonusRewards:GetRegions()):SetTextColor(1, .8, 0)
		F.StripTextures(bonusRewards.Saturated)
		for i = 1, 9 do
			select(i, bonusRewards:GetRegions()):SetAlpha(0)
		end
		F.CreateBD(bonusRewards)
		F.Reskin(missionComplete.NextMissionButton)
	end

	function F:ReskinFollowerTab()
		for i = 1, 2 do
			local trait = self.Traits[i]
			trait.Border:Hide()
			F.ReskinIcon(trait.Portrait)

			local equipment = self.EquipmentFrame.Equipment[i]
			equipment.BG:Hide()
			equipment.Border:Hide()
			F.ReskinIcon(equipment.Icon)
		end
	end

	local function onUpdateData(self)
		local followerFrame = self:GetParent()
		local scrollFrame = followerFrame.FollowerList.listScroll
		local buttons = scrollFrame.buttons

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

	local function onShowFollower(followerList)
		local self = followerList.followerTab
		local abilities = self.AbilitiesFrame.Abilities
		if not abilities then return end
		if not self.numAbilitiesStyled then self.numAbilitiesStyled = 1 end

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

		if self.AbilitiesFrame.Equipment then
			for i = 1, 3 do
				local equip = self.AbilitiesFrame.Equipment[i]
				if equip and not equip.bg then
					equip.Border:SetAlpha(0)
					equip.BG:SetAlpha(0)
					equip.Icon:SetTexCoord(.08, .92, .08, .92)
					equip.bg = F.CreateBDFrame(equip.Icon)
					equip.bg:SetBackdropColor(1, 1, 1, .15)
				end
			end
		end

		local iconTexture = self.AbilitiesFrame.CombatAllySpell[1].iconTexture
		if not iconTexture.styled then
			F.ReskinIcon(iconTexture)
			iconTexture.styled = true
		end
	end

	function F:ReskinMissionFrame()
		F.StripTextures(self)
		F.SetBD(self)
		F.StripTextures(self.CloseButton)
		F.ReskinClose(self.CloseButton)
		self.GarrCorners:Hide()
		if self.ClassHallIcon then self.ClassHallIcon:Hide() end
		if self.TitleScroll then
			F.StripTextures(self.TitleScroll)
			select(4, self.TitleScroll:GetRegions()):SetTextColor(1, .8, 0)
		end
		for i = 1, 3 do
			local tab = _G[self:GetName().."Tab"..i]
			if tab then F.ReskinTab(tab) end
		end
		if self.MapTab then self.MapTab.ScrollContainer.Child.TiledBackground:Hide() end

		F.ReskinMissionComplete(self)
		F.ReskinMissionPage(self.MissionTab.MissionPage)
		F.StripTextures(self.FollowerTab)
		F.ReskinXPBar(self.FollowerTab)

		for _, item in pairs({self.FollowerTab.ItemWeapon, self.FollowerTab.ItemArmor}) do
			if item then
				local icon = item.Icon
				item.Border:Hide()
				icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(icon)

				local bg = F.CreateBDFrame(item, .25)
				bg:SetPoint("TOPLEFT", 41, -1)
				bg:SetPoint("BOTTOMRIGHT", 0, 1)
			end
		end

		local missionList = self.MissionTab.MissionList
		F.StripTextures(missionList)
		F.ReskinScroll(missionList.listScroll.scrollBar)
		F.ReskinGarrMaterial(missionList)
		F.ReskinMissionTabs(missionList)
		F.Reskin(missionList.CompleteDialog.BorderFrame.ViewButton)
		hooksecurefunc(missionList, "Update", F.ReskinMissionList)

		local FollowerList = self.FollowerList
		F.StripTextures(FollowerList)
		F.ReskinInput(FollowerList.SearchBox)
		F.ReskinScroll(FollowerList.listScroll.scrollBar)
		F.ReskinGarrMaterial(FollowerList)
		hooksecurefunc(FollowerList, "UpdateData", onUpdateData)
		hooksecurefunc(FollowerList, "ShowFollower", onShowFollower)
	end

	-- [[ Garrison system ]]

	-- Building frame
	local GarrisonBuildingFrame = GarrisonBuildingFrame
	F.StripTextures(GarrisonBuildingFrame)
	F.SetBD(GarrisonBuildingFrame)
	F.ReskinClose(GarrisonBuildingFrame.CloseButton)
	GarrisonBuildingFrame.GarrCorners:Hide()

	-- Tutorial button

	local MainHelpButton = GarrisonBuildingFrame.MainHelpButton
	MainHelpButton.Ring:Hide()
	MainHelpButton:SetPoint("TOPLEFT", GarrisonBuildingFrame, "TOPLEFT", -12, 12)

	-- Building list

	local BuildingList = GarrisonBuildingFrame.BuildingList

	BuildingList:DisableDrawLayer("BORDER")
	F.ReskinGarrMaterial(BuildingList)

	for i = 1, GARRISON_NUM_BUILDING_SIZES do
		local tab = BuildingList["Tab"..i]

		tab:GetNormalTexture():SetAlpha(0)

		local bg = F.CreateBDFrame(tab, .25)
		bg:SetPoint("TOPLEFT", 6, -7)
		bg:SetPoint("BOTTOMRIGHT", -6, 7)
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

				local bg = F.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 44, -5)
				bg:SetPoint("BOTTOMRIGHT", 0, 6)

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
		end
		F.CreateBD(BuildingLevelTooltip)
		F.CreateSD(BuildingLevelTooltip)
	end

	-- Follower list

	local FollowerList = GarrisonBuildingFrame.FollowerList

	FollowerList:DisableDrawLayer("BACKGROUND")
	FollowerList:DisableDrawLayer("BORDER")
	F.ReskinScroll(FollowerList.listScroll.scrollBar)

	FollowerList:ClearAllPoints()
	FollowerList:SetPoint("BOTTOMLEFT", 24, 34)

	hooksecurefunc(FollowerList, "UpdateData", onUpdateData)
	hooksecurefunc(FollowerList, "ShowFollower", onShowFollower)

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

	local reagentIndex = 1
	hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function()
		local reagents = CapacitiveDisplay.Reagents

		local reagent = reagents[reagentIndex]
		while reagent do
			reagent.NameFrame:SetAlpha(0)

			reagent.Icon:SetTexCoord(.08, .92, .08, .92)
			reagent.Icon:SetDrawLayer("BORDER")
			F.CreateBG(reagent.Icon)

			local bg = F.CreateBDFrame(reagent, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 2)

			reagentIndex = reagentIndex + 1
			reagent = reagents[reagentIndex]
		end
	end)

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
		local bg = F.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)

		for _, reward in pairs(button.Rewards) do
			reward:GetRegions():Hide()
			reward.Icon:SetTexCoord(.08, .92, .08, .92)
			reward.IconBorder:SetAlpha(0)
			F.CreateBG(reward.Icon)
			reward:ClearAllPoints()
			reward:SetPoint("TOPRIGHT", -4, -4)
		end
	end

	for _, tab in pairs({Report.InProgress, Report.Available}) do
		tab:SetHighlightTexture("")
		tab.Text:ClearAllPoints()
		tab.Text:SetPoint("CENTER")

		local bg = F.CreateBDFrame(tab, .25)
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

	hooksecurefunc(GarrisonLandingPageFollowerList, "UpdateData", onUpdateData)
	hooksecurefunc(GarrisonLandingPageFollowerList, "ShowFollower", onShowFollower)

	-- Ship follower list

	local FollowerList = GarrisonLandingPage.ShipFollowerList

	FollowerList:GetRegions():Hide()
	select(2, FollowerList:GetRegions()):Hide()
	F.ReskinInput(FollowerList.SearchBox)

	local scrollFrame = FollowerList.listScroll

	F.ReskinScroll(scrollFrame.scrollBar)

	-- Follower tab

	local FollowerTab = GarrisonLandingPage.FollowerTab
	F.ReskinXPBar(FollowerTab)

	-- Ship follower tab

	local FollowerTab = GarrisonLandingPage.ShipFollowerTab
	F.ReskinXPBar(FollowerTab)
	F.ReskinFollowerTab(FollowerTab)

	-- [[ Mission UI ]]

	local GarrisonMissionFrame = GarrisonMissionFrame

	F.ReskinMissionFrame(GarrisonMissionFrame)

	hooksecurefunc("GarrisonMissonListTab_SetSelected", function(tab, isSelected)
		if isSelected then
			tab:SetBackdropColor(r, g, b, .2)
		else
			tab:SetBackdropColor(0, 0, 0, .25)
		end
	end)

	hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
		local ability = self.Abilities[index]

		if not ability.styled then
			local icon = ability.Icon
			icon:SetSize(19, 19)
			F.ReskinIcon(icon)

			ability.styled = true
		end
	end)

	hooksecurefunc("GarrisonFollowerButton_SetCounterButton", function(button, _, index)
		local counter = button.Counters[index]
		if counter and not counter.styled then
			F.ReskinIcon(counter.Icon)
			counter.styled = true
		end
	end)

	hooksecurefunc("GarrisonMissionButton_SetRewards", function(self, rewards)
		if not self.numRewardsStyled then self.numRewardsStyled = 0 end

		while self.numRewardsStyled < #rewards do
			self.numRewardsStyled = self.numRewardsStyled + 1
			local reward = self.Rewards[self.numRewardsStyled]
			reward:GetRegions():Hide()
			reward.IconBorder:SetAlpha(0)
			F.ReskinIcon(reward.Icon)
		end
	end)

	hooksecurefunc("GarrisonMissionPortrait_SetFollowerPortrait", function(portraitFrame, followerInfo)
		if not portraitFrame.styled then
			F.ReskinGarrisonPortrait(portraitFrame)
			portraitFrame.styled = true
		end

		local color = BAG_ITEM_QUALITY_COLORS[followerInfo.quality]
		portraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		portraitFrame.squareBG:Show()
	end)

	hooksecurefunc("GarrisonMissionPage_SetReward", function(frame)
		if not frame.bg then
			frame.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(frame.Icon)
			frame.BG:SetAlpha(0)
			frame.bg = F.CreateBDFrame(frame.BG, .25)
			frame.IconBorder:SetScale(.0001)
		end
	end)

	hooksecurefunc(GarrisonMission, "UpdateMissionParty", function(_, followers)
		for followerIndex = 1, #followers do
			local followerFrame = followers[followerIndex]
			if followerFrame.info then
				for i = 1, #followerFrame.Counters do
					local counter = followerFrame.Counters[i]
					if not counter.styled then
						F.ReskinIcon(counter.Icon)
						counter.styled = true
					end
				end
			end
		end
	end)

	hooksecurefunc(GarrisonMission, "RemoveFollowerFromMission", function(_, frame)
		if frame.PortraitFrame and frame.PortraitFrame.squareBG then
			frame.PortraitFrame.squareBG:Hide()
		end
	end)

	hooksecurefunc(GarrisonMission, "SetEnemies", function(_, missionPage, enemies)
		for i = 1, #enemies do
			local frame = missionPage.Enemies[i]
			if frame:IsShown() and not frame.styled then
				for j = 1, #frame.Mechanics do
					local mechanic = frame.Mechanics[j]
					F.ReskinIcon(mechanic.Icon)
				end
				frame.styled = true
			end
		end
	end)

	hooksecurefunc(GarrisonMission, "UpdateMissionData", function(_, missionPage)
		local buffsFrame = missionPage.BuffsFrame
		if buffsFrame:IsShown() then
			for i = 1, #buffsFrame.Buffs do
				local buff = buffsFrame.Buffs[i]
				if not buff.styled then
					F.ReskinIcon(buff.Icon)
					buff.styled = true
				end
			end
		end
	end)

	hooksecurefunc(GarrisonMission, "MissionCompleteInitialize", function(self, missionList, index)
		local mission = missionList[index]
		if not mission then return end

		for i = 1, #mission.followers do
			local frame = self.MissionComplete.Stage.FollowersFrame.Followers[i]
			if frame.PortraitFrame then
				if not frame.bg then
					frame.PortraitFrame:ClearAllPoints()
					frame.PortraitFrame:SetPoint("TOPLEFT", 0, -10)
					F.ReskinGarrisonPortrait(frame.PortraitFrame)

					local oldBg = frame:GetRegions()
					oldBg:Hide()
					frame.bg = F.CreateBDFrame(oldBg)
					frame.bg:SetPoint("TOPLEFT", frame.PortraitFrame, -1, 1)
					frame.bg:SetPoint("BOTTOMRIGHT", -10, 8)
				end

				local quality = select(4, C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]))
				if quality then
					local color = BAG_ITEM_QUALITY_COLORS[quality]
					frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
					frame.PortraitFrame.squareBG:Show()
				end
			end
		end
	end)

	-- Mechanic tooltip

	if AuroraConfig.tooltips then
		GarrisonMissionMechanicTooltip:SetBackdrop(nil)
		F.CreateBDFrame(GarrisonMissionMechanicTooltip)
		F.CreateSD(GarrisonMissionMechanicTooltip)
		GarrisonMissionMechanicFollowerCounterTooltip:SetBackdrop(nil)
		F.CreateBDFrame(GarrisonMissionMechanicFollowerCounterTooltip)
		F.CreateSD(GarrisonMissionMechanicFollowerCounterTooltip)
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

	hooksecurefunc(FollowerList, "UpdateData", onUpdateData)
	hooksecurefunc(FollowerList, "ShowFollower", onShowFollower)

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

	-- [[ Shipyard ]]

	local GarrisonShipyardFrame = GarrisonShipyardFrame

	if AuroraConfig.tooltips then
		F.CreateBD(GarrisonShipyardMapMissionTooltip)
		F.CreateSD(GarrisonShipyardMapMissionTooltip)
	end

	for i = 1, 14 do
		select(i, GarrisonShipyardFrame.BorderFrame:GetRegions()):Hide()
	end

	GarrisonShipyardFrame.BorderFrame.TitleText:Show()
	GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
	GarrisonShipyardFrame.BackgroundTile:Hide()
	F.SetBD(GarrisonShipyardFrame)
	F.ReskinInput(GarrisonShipyardFrameFollowers.SearchBox)
	F.ReskinScroll(GarrisonShipyardFrameFollowersListScrollFrameScrollBar)
	GarrisonShipyardFrameFollowers:GetRegions():Hide()
	select(2, GarrisonShipyardFrameFollowers:GetRegions()):Hide()
	GarrisonShipyardFrameFollowers:DisableDrawLayer("BORDER")
	F.ReskinGarrMaterial(GarrisonShipyardFrameFollowers)

	local shipyardTab = GarrisonShipyardFrame.FollowerTab
	shipyardTab:DisableDrawLayer("BORDER")
	F.ReskinXPBar(shipyardTab)
	F.ReskinFollowerTab(shipyardTab)

	F.ReskinClose(GarrisonShipyardFrame.BorderFrame.CloseButton2)
	F.ReskinTab(GarrisonShipyardFrameTab1)
	F.ReskinTab(GarrisonShipyardFrameTab2)

	local shipyardMission = GarrisonShipyardFrame.MissionTab.MissionPage
	F.StripTextures(shipyardMission)
	F.ReskinClose(shipyardMission.CloseButton)
	F.Reskin(shipyardMission.StartMissionButton)
	local smbg = F.CreateBDFrame(shipyardMission.Stage)
	smbg:SetPoint("TOPLEFT", 4, 1)
	smbg:SetPoint("BOTTOMRIGHT", -4, -1)

	for i = 1, 10 do
		select(i, shipyardMission.RewardsFrame:GetRegions()):Hide()
	end
	F.CreateBD(shipyardMission.RewardsFrame, .25)

	GarrisonShipyardFrame.MissionCompleteBackground:GetRegions():Hide()
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog:GetRegions():Hide()
	F.Reskin(GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton)
	select(11, GarrisonShipyardFrame.MissionComplete.BonusRewards:GetRegions()):SetTextColor(1, .8, 0)
	F.Reskin(GarrisonShipyardFrame.MissionComplete.NextMissionButton)

	-- [[ Orderhall UI]]

	local OrderHallMissionFrame = OrderHallMissionFrame
	F.ReskinMissionFrame(OrderHallMissionFrame)

	-- Ally
	local combatAlly = OrderHallMissionFrameMissions.CombatAllyUI
	F.Reskin(combatAlly.InProgress.Unassign)
	combatAlly:GetRegions():Hide()
	F.CreateBDFrame(combatAlly, .25)
	F.ReskinIcon(combatAlly.InProgress.CombatAllySpell.iconTexture)

	local allyPortrait = combatAlly.InProgress.PortraitFrame
	F.ReskinGarrisonPortrait(allyPortrait)
	OrderHallMissionFrame:HookScript("OnShow", function()
		if allyPortrait:IsShown() then
			allyPortrait.squareBG:SetBackdropBorderColor(allyPortrait.PortraitRingQuality:GetVertexColor())
		end
		combatAlly.Available.AddFollowerButton.EmptyPortrait:SetAlpha(0)
		combatAlly.Available.AddFollowerButton.PortraitHighlight:SetAlpha(0)
	end)

	hooksecurefunc(OrderHallCombatAllyMixin, "UnassignAlly", function(self)
		if self.InProgress.PortraitFrame.squareBG then
			self.InProgress.PortraitFrame.squareBG:Hide()
		end
	end)

	-- Zone support
	local ZoneSupportMissionPage = OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage
	F.StripTextures(ZoneSupportMissionPage)
	F.CreateBD(ZoneSupportMissionPage, .25)
	F.ReskinClose(ZoneSupportMissionPage.CloseButton)
	F.Reskin(ZoneSupportMissionPage.StartMissionButton)
	F.ReskinIcon(ZoneSupportMissionPage.CombatAllySpell.iconTexture)
	ZoneSupportMissionPage.Follower1:GetRegions():Hide()
	F.CreateBD(ZoneSupportMissionPage.Follower1, .25)
	F.ReskinGarrisonPortrait(ZoneSupportMissionPage.Follower1.PortraitFrame)

	-- [[ BFA Mission UI]]

	local BFAMissionFrame = BFAMissionFrame
	F.ReskinMissionFrame(BFAMissionFrame)

	-- [[ Addon supports ]]

	local function buttonOnUpdate(MissionList)
		local buttons = MissionList.listScroll.buttons
		for i = 1, #buttons do
			local bu = select(3, buttons[i]:GetChildren())
			if bu and bu:GetObjectType() == "Button" and not bu.styled then
				F.Reskin(bu)
				bu:SetSize(60, 45)
				bu.styled = true
			end
		end
	end

	local function buttonOnShow(MissionPage)
		for i = 18, 26 do
			local bu = select(i, MissionPage:GetChildren())
			if bu and bu:GetObjectType() == "Button" and not bu.styled then
				F.Reskin(bu)
				bu:SetSize(50, 45)
				bu.styled = true
			end
		end
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(_, event, addon)
		if addon == "GarrisonMissionManager" then
			for _, frame in next, {GarrisonMissionFrame, OrderHallMissionFrame, BFAMissionFrame} do
				hooksecurefunc(frame.MissionTab.MissionList, "Update", buttonOnUpdate)
				frame.MissionTab.MissionPage:HookScript("OnShow", buttonOnShow)
			end

			f:UnregisterEvent(event)
		end
	end)
end