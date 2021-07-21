local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function ReskinMissionPage(self)
	B.StripTextures(self)
	local bg = B.CreateBDFrame(self, .25)
	bg:SetPoint("TOPLEFT", 3, 2)
	bg:SetPoint("BOTTOMRIGHT", -3, -10)

	self.Stage.Header:SetAlpha(0)
	if self.StartMissionFrame then B.StripTextures(self.StartMissionFrame) end
	self.StartMissionButton.Flash:SetTexture("")
	B.Reskin(self.StartMissionButton)
	B.ReskinClose(self.CloseButton)
	self.CloseButton:ClearAllPoints()
	self.CloseButton:SetPoint("TOPRIGHT", -10, -5)
	if self.EnemyBackground then self.EnemyBackground:Hide() end
	if self.FollowerBackground then self.FollowerBackground:Hide() end

	if self.Followers then
		for i = 1, 3 do
			local follower = self.Followers[i]
			follower:GetRegions():Hide()
			B.CreateBDFrame(follower, .25)
			B.ReskinGarrisonPortrait(follower.PortraitFrame)
			follower.PortraitFrame:ClearAllPoints()
			follower.PortraitFrame:SetPoint("TOPLEFT", 0, -3)
		end
	end

	if self.RewardsFrame then
		for i = 1, 10 do
			select(i, self.RewardsFrame:GetRegions()):Hide()
		end
		B.CreateBDFrame(self.RewardsFrame, .25)

		local overmaxItem = self.RewardsFrame.OvermaxItem
		overmaxItem.IconBorder:SetAlpha(0)
		B.ReskinIcon(overmaxItem.Icon)
	end

	local env = self.Stage.MissionEnvIcon
	env.bg = B.ReskinIcon(env.Texture)

	if self.CostFrame then
		self.CostFrame.CostIcon:SetTexCoord(unpack(DB.TexCoord))
	end
end

local function ReskinMissionTabs(self)
	for i = 1, 2 do
		local tab = _G[self:GetName().."Tab"..i]
		if tab then
			B.StripTextures(tab)
			tab.bg = B.CreateBDFrame(tab, .25)
			if i == 1 then
				tab.bg:SetBackdropColor(r, g, b, .2)
			end
		end
	end
end

local function ReskinXPBar(self)
	local xpBar = self.XPBar
	if xpBar then
		xpBar:GetRegions():Hide()
		xpBar.XPLeft:Hide()
		xpBar.XPRight:Hide()
		select(4, xpBar:GetRegions()):Hide()
		xpBar:SetStatusBarTexture(DB.bdTex)
		B.CreateBDFrame(xpBar, .25)
	end
end

local function ReskinGarrMaterial(self)
	local frame = self.MaterialFrame
	frame.BG:Hide()
	if frame.LeftFiligree then frame.LeftFiligree:Hide() end
	if frame.RightFiligree then frame.RightFiligree:Hide() end

	B.ReskinIcon(frame.Icon)
	local bg = B.CreateBDFrame(frame, .25)
	bg:SetPoint("TOPLEFT", 5, -5)
	bg:SetPoint("BOTTOMRIGHT", -5, 6)
end

local function ReskinMissionList(self)
	local buttons = self.listScroll.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		if not button.styled then
			local rareOverlay = button.RareOverlay
			local rareText = button.RareText

			button.LocBG:SetDrawLayer("BACKGROUND")
			if button.ButtonBG then button.ButtonBG:Hide() end
			B.StripTextures(button)
			B.CreateBDFrame(button, .25, true)
			button.Highlight:SetColorTexture(.6, .8, 1, .15)
			button.Highlight:SetAllPoints()

			if button.CompleteCheck then
				button.CompleteCheck:SetAtlas("Adventures-Checkmark")
			end
			if rareText then
				rareText:ClearAllPoints()
				rareText:SetPoint("BOTTOMLEFT", button, 20, 10)
			end
			if rareOverlay then
				rareOverlay:SetDrawLayer("BACKGROUND")
				rareOverlay:SetTexture(DB.bdTex)
				rareOverlay:SetAllPoints()
				rareOverlay:SetVertexColor(.098, .537, .969, .2)
			end
			if button.Overlay and button.Overlay.Overlay then
				button.Overlay.Overlay:SetAllPoints()
			end

			button.styled = true
		end
	end
end

local function ReskinMissionComplete(self)
	local missionComplete = self.MissionComplete
	local bonusRewards = missionComplete.BonusRewards
	if bonusRewards then
		select(11, bonusRewards:GetRegions()):SetTextColor(1, .8, 0)
		B.StripTextures(bonusRewards.Saturated)
		for i = 1, 9 do
			select(i, bonusRewards:GetRegions()):SetAlpha(0)
		end
		B.CreateBDFrame(bonusRewards)
	end
	if missionComplete.NextMissionButton then
		B.Reskin(missionComplete.NextMissionButton)
	end
	if missionComplete.CompleteFrame then
		B.StripTextures(missionComplete)
		local bg = B.CreateBDFrame(missionComplete, .25)
		bg:SetPoint("TOPLEFT", 3, 2)
		bg:SetPoint("BOTTOMRIGHT", -3, -10)

		B.StripTextures(missionComplete.CompleteFrame)
		B.Reskin(missionComplete.CompleteFrame.ContinueButton)
		B.Reskin(missionComplete.CompleteFrame.SpeedButton)
		B.Reskin(missionComplete.RewardsScreen.FinalRewardsPanel.ContinueButton)
	end
	if missionComplete.MissionInfo then
		B.StripTextures(missionComplete.MissionInfo)
	end
	if missionComplete.EnemyBackground then missionComplete.EnemyBackground:Hide() end
	if missionComplete.FollowerBackground then missionComplete.FollowerBackground:Hide() end
end

local function ReskinFollowerTab(self)
	for i = 1, 2 do
		local trait = self.Traits[i]
		trait.Border:Hide()
		B.ReskinIcon(trait.Portrait)

		local equipment = self.EquipmentFrame.Equipment[i]
		equipment.BG:Hide()
		equipment.Border:Hide()
		B.ReskinIcon(equipment.Icon)
	end
end

local function UpdateFollowerQuality(self, followerInfo)
	if followerInfo then
		local color = DB.QualityColors[followerInfo.quality or 1]
		self.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

local function UpdateFollowerList(self)
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
			button.bg = B.CreateBDFrame(button, .25)

			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(r, g, b, .1)
			hl:ClearAllPoints()
			hl:SetInside(button.bg)

			if portrait then
				B.ReskinGarrisonPortrait(portrait)
				portrait:ClearAllPoints()
				portrait:SetPoint("TOPLEFT", 4, -1)
				hooksecurefunc(portrait, "SetupPortrait", UpdateFollowerQuality)
			end

			if button.BusyFrame then
				button.BusyFrame:SetInside(button.bg)
			end

			button.restyled = true
		end

		if button.Counters then
			for i = 1, #button.Counters do
				local counter = button.Counters[i]
				if counter and not counter.bg then
					counter.bg = B.ReskinIcon(counter.Icon)
				end
			end
		end

		if button.Selection:IsShown() then
			button.bg:SetBackdropColor(r, g, b, .2)
		else
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end
end

local function UpdateSpellAbilities(self, followerInfo)
	local autoSpellInfo = followerInfo.autoSpellAbilities
	for _ in ipairs(autoSpellInfo) do
		local abilityFrame = self.autoSpellPool:Acquire()
		if not abilityFrame.styled then
			B.ReskinIcon(abilityFrame.Icon)
			if abilityFrame.IconMask then abilityFrame.IconMask:Hide() end
			if abilityFrame.SpellBorder then abilityFrame.SpellBorder:Hide() end

			abilityFrame.styled = true
		end
	end
end

local function UpdateFollowerAbilities(followerList)
	local followerTab = followerList.followerTab
	local abilitiesFrame = followerTab.AbilitiesFrame
	if not abilitiesFrame then return end

	local abilities = abilitiesFrame.Abilities
	if abilities then
		for i = 1, #abilities do
			local iconButton = abilities[i].IconButton
			local icon = iconButton and iconButton.Icon
			if icon and not icon.bg then
				iconButton.Border:SetAlpha(0)
				icon.bg = B.ReskinIcon(icon)
			end
		end
	end

	local equipment = abilitiesFrame.Equipment
	if equipment then
		for i = 1, #equipment do
			local equip = equipment[i]
			if equip and not equip.bg then
				equip.Border:SetAlpha(0)
				equip.BG:SetAlpha(0)
				equip.bg = B.ReskinIcon(equip.Icon)
				equip.bg:SetBackdropColor(1, 1, 1, .15)
			end
		end
	end

	local combatAllySpell = abilitiesFrame.CombatAllySpell
	if combatAllySpell then
		for i = 1, #combatAllySpell do
			local icon = combatAllySpell[i].iconTexture
			if icon and not icon.bg then
				icon.bg = B.ReskinIcon(icon)
			end
		end
	end
end

local function reskinFollowerItem(item)
	if not item then return end

	local icon = item.Icon
	item.Border:Hide()
	B.ReskinIcon(icon)

	local bg = B.CreateBDFrame(item, .25)
	bg:SetPoint("TOPLEFT", 41, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 1)
end

local function ReskinMissionFrame(self)
	B.StripTextures(self)
	B.SetBD(self)
	B.StripTextures(self.CloseButton)
	B.ReskinClose(self.CloseButton)
	self.GarrCorners:Hide()
	if self.OverlayElements then self.OverlayElements:SetAlpha(0) end
	if self.ClassHallIcon then self.ClassHallIcon:Hide() end
	if self.TitleScroll then
		B.StripTextures(self.TitleScroll)
		select(4, self.TitleScroll:GetRegions()):SetTextColor(1, .8, 0)
	end
	for i = 1, 3 do
		local tab = _G[self:GetName().."Tab"..i]
		if tab then B.ReskinTab(tab) end
	end
	if self.MapTab then self.MapTab.ScrollContainer.Child.TiledBackground:Hide() end

	ReskinMissionComplete(self)
	ReskinMissionPage(self.MissionTab.MissionPage)
	B.StripTextures(self.FollowerTab)
	ReskinXPBar(self.FollowerTab)
	hooksecurefunc(self.FollowerTab, "UpdateCombatantStats", UpdateSpellAbilities)

	reskinFollowerItem(self.FollowerTab.ItemWeapon)
	reskinFollowerItem(self.FollowerTab.ItemArmor)

	local missionList = self.MissionTab.MissionList
	B.StripTextures(missionList)
	B.ReskinScroll(missionList.listScroll.scrollBar)
	ReskinGarrMaterial(missionList)
	ReskinMissionTabs(missionList)
	B.Reskin(missionList.CompleteDialog.BorderFrame.ViewButton)
	hooksecurefunc(missionList, "Update", ReskinMissionList)

	local FollowerList = self.FollowerList
	B.StripTextures(FollowerList)
	if FollowerList.SearchBox then B.ReskinInput(FollowerList.SearchBox) end
	B.ReskinScroll(FollowerList.listScroll.scrollBar)
	ReskinGarrMaterial(FollowerList)
	hooksecurefunc(FollowerList, "UpdateData", UpdateFollowerList)
	hooksecurefunc(FollowerList, "ShowFollower", UpdateFollowerAbilities)
end

-- Missions board in 9.0
local function reskinAbilityIcon(self, anchor, yOffset)
	self:ClearAllPoints()
	self:SetPoint(anchor, self:GetParent().squareBG, "LEFT", -3, yOffset)
	self.Border:SetAlpha(0)
	self.CircleMask:Hide()
	B.ReskinIcon(self.Icon)
end

local function updateFollowerColorOnBoard(self, _, info)
	if self.squareBG then
		local color = DB.QualityColors[info.quality or 1]
		self.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

local function resetFollowerColorOnBoard(self)
	if self.squareBG then
		self.squareBG:SetBackdropBorderColor(0, 0, 0)
	end
end

local function reskinFollowerBoard(self, group)
	for socketTexture in self[group.."SocketFramePool"]:EnumerateActive() do
		socketTexture:DisableDrawLayer("BACKGROUND") -- we need the bufficons
	end
	for frame in self[group.."FramePool"]:EnumerateActive() do
		if not frame.styled then
			B.ReskinGarrisonPortrait(frame)
			frame.PuckShadow:SetAlpha(0)
			reskinAbilityIcon(frame.AbilityOne, "BOTTOMRIGHT", 1)
			reskinAbilityIcon(frame.AbilityTwo, "TOPRIGHT", -1)
			if frame.SetFollowerGUID then
				hooksecurefunc(frame, "SetFollowerGUID", updateFollowerColorOnBoard)
			end
			if frame.SetEmpty then
				hooksecurefunc(frame, "SetEmpty", resetFollowerColorOnBoard)
			end

			frame.styled = true
		end
	end
end

local function ReskinMissionBoards(self)
	reskinFollowerBoard(self, "enemy")
	reskinFollowerBoard(self, "follower")
end

C.themes["Blizzard_GarrisonUI"] = function()
	-- Tooltips
	B.ReskinGarrisonTooltip(GarrisonFollowerAbilityWithoutCountersTooltip)
	B.ReskinGarrisonTooltip(GarrisonFollowerMissionAbilityWithoutCountersTooltip)

	-- Building frame
	local GarrisonBuildingFrame = GarrisonBuildingFrame
	B.StripTextures(GarrisonBuildingFrame)
	B.SetBD(GarrisonBuildingFrame)
	B.ReskinClose(GarrisonBuildingFrame.CloseButton)
	GarrisonBuildingFrame.GarrCorners:Hide()

	-- Tutorial button
	local mainHelpButton = GarrisonBuildingFrame.MainHelpButton
	mainHelpButton.Ring:Hide()
	mainHelpButton:SetPoint("TOPLEFT", GarrisonBuildingFrame, "TOPLEFT", -12, 12)

	-- Building list
	local buildingList = GarrisonBuildingFrame.BuildingList
	buildingList:DisableDrawLayer("BORDER")
	ReskinGarrMaterial(buildingList)

	for i = 1, GARRISON_NUM_BUILDING_SIZES do
		local tab = buildingList["Tab"..i]
		tab:GetNormalTexture():SetAlpha(0)

		local bg = B.CreateBDFrame(tab, .25)
		bg:SetPoint("TOPLEFT", 6, -7)
		bg:SetPoint("BOTTOMRIGHT", -6, 7)
		tab.bg = bg

		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(r, g, b, .1)
		hl:ClearAllPoints()
		hl:SetInside(bg)
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
				B.ReskinIcon(button.Icon)

				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 44, -5)
				bg:SetPoint("BOTTOMRIGHT", 0, 6)

				button.SelectedBG:SetColorTexture(r, g, b, .2)
				button.SelectedBG:ClearAllPoints()
				button.SelectedBG:SetInside(bg)

				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .1)
				hl:SetAllPoints(button.SelectedBG)

				button.styled = true
			end
		end
	end)

	-- Follower list
	local followerList = GarrisonBuildingFrame.FollowerList
	followerList:ClearAllPoints()
	followerList:SetPoint("BOTTOMLEFT", 24, 34)
	followerList:DisableDrawLayer("BACKGROUND")
	followerList:DisableDrawLayer("BORDER")
	B.ReskinScroll(followerList.listScroll.scrollBar)
	hooksecurefunc(followerList, "UpdateData", UpdateFollowerList)
	hooksecurefunc(followerList, "ShowFollower", UpdateFollowerAbilities)

	-- Info box
	local infoBox = GarrisonBuildingFrame.InfoBox
	local townHallBox = GarrisonBuildingFrame.TownHallBox
	B.StripTextures(infoBox)
	B.CreateBDFrame(infoBox, .25)
	B.StripTextures(townHallBox)
	B.CreateBDFrame(townHallBox, .25)
	B.Reskin(infoBox.UpgradeButton)
	B.Reskin(townHallBox.UpgradeButton)
	GarrisonBuildingFrame.MapFrame.TownHall.TownHallName:SetTextColor(1, .8, 0)

	local followerPortrait = infoBox.FollowerPortrait
	B.ReskinGarrisonPortrait(followerPortrait)
	followerPortrait:SetPoint("BOTTOMLEFT", 230, 10)
	followerPortrait.RemoveFollowerButton:ClearAllPoints()
	followerPortrait.RemoveFollowerButton:SetPoint("TOPRIGHT", 4, 4)

	hooksecurefunc("GarrisonBuildingInfoBox_ShowFollowerPortrait", function(_, _, infoBox)
		local portrait = infoBox.FollowerPortrait
		if portrait:IsShown() then
			portrait.squareBG:SetBackdropBorderColor(portrait.PortraitRing:GetVertexColor())
		end
	end)

	-- Confirmation popup
	local confirmation = GarrisonBuildingFrame.Confirmation
	confirmation:GetRegions():Hide()
	B.CreateBDFrame(confirmation)
	B.Reskin(confirmation.CancelButton)
	B.Reskin(confirmation.BuildButton)
	B.Reskin(confirmation.UpgradeButton)
	B.Reskin(confirmation.UpgradeGarrisonButton)
	B.Reskin(confirmation.ReplaceButton)
	B.Reskin(confirmation.SwitchButton)

	-- Capacitive display frame
	local GarrisonCapacitiveDisplayFrame = GarrisonCapacitiveDisplayFrame
	GarrisonCapacitiveDisplayFrameLeft:Hide()
	GarrisonCapacitiveDisplayFrameMiddle:Hide()
	GarrisonCapacitiveDisplayFrameRight:Hide()
	B.CreateBDFrame(GarrisonCapacitiveDisplayFrame.Count, .25)
	GarrisonCapacitiveDisplayFrame.Count:SetWidth(38)
	GarrisonCapacitiveDisplayFrame.Count:SetTextInsets(3, 0, 0, 0)

	B.ReskinPortraitFrame(GarrisonCapacitiveDisplayFrame)
	B.Reskin(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)
	B.Reskin(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton, true)
	B.ReskinArrow(GarrisonCapacitiveDisplayFrame.DecrementButton, "left")
	B.ReskinArrow(GarrisonCapacitiveDisplayFrame.IncrementButton, "right")

	-- Capacitive display
	local capacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay
	capacitiveDisplay.IconBG:SetAlpha(0)
	B.ReskinIcon(capacitiveDisplay.ShipmentIconFrame.Icon)
	B.ReskinGarrisonPortrait(capacitiveDisplay.ShipmentIconFrame.Follower)

	local reagentIndex = 1
	hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function()
		local reagents = capacitiveDisplay.Reagents

		local reagent = reagents[reagentIndex]
		while reagent do
			reagent.NameFrame:SetAlpha(0)
			B.ReskinIcon(reagent.Icon)

			local bg = B.CreateBDFrame(reagent, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 2)

			reagentIndex = reagentIndex + 1
			reagent = reagents[reagentIndex]
		end
	end)

	-- Landing page
	local GarrisonLandingPage = GarrisonLandingPage
	B.StripTextures(GarrisonLandingPage)
	B.SetBD(GarrisonLandingPage)
	B.ReskinClose(GarrisonLandingPage.CloseButton)
	B.ReskinTab(GarrisonLandingPageTab1)
	B.ReskinTab(GarrisonLandingPageTab2)
	B.ReskinTab(GarrisonLandingPageTab3)

	GarrisonLandingPageTab1:ClearAllPoints()
	GarrisonLandingPageTab1:SetPoint("TOPLEFT", GarrisonLandingPage, "BOTTOMLEFT", 70, 2)

	-- Report
	local report = GarrisonLandingPage.Report
	B.StripTextures(report)
	B.StripTextures(report.List)

	local scrollFrame = report.List.listScroll
	B.ReskinScroll(scrollFrame.scrollBar)

	local buttons = scrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		button.BG:Hide()
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)

		for _, reward in pairs(button.Rewards) do
			reward:GetRegions():Hide()
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.IconBorder)
		end
	end

	for _, tab in pairs({report.InProgress, report.Available}) do
		tab:SetHighlightTexture("")
		tab.Text:ClearAllPoints()
		tab.Text:SetPoint("CENTER")

		local bg = B.CreateBDFrame(tab, 0, true)

		local selectedTex = bg:CreateTexture(nil, "BACKGROUND")
		selectedTex:SetAllPoints()
		selectedTex:SetColorTexture(r, g, b, .2)
		selectedTex:Hide()
		tab.selectedTex = selectedTex

		if tab == report.InProgress then
			bg:SetPoint("TOPLEFT", 5, 0)
			bg:SetPoint("BOTTOMRIGHT")
		else
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", -7, 0)
		end
	end

	hooksecurefunc("GarrisonLandingPageReport_SetTab", function(self)
		local unselectedTab = report.unselectedTab
		unselectedTab:SetHeight(36)
		unselectedTab:SetNormalTexture("")
		unselectedTab.selectedTex:Hide()
		self:SetNormalTexture("")
		self.selectedTex:Show()
	end)

	-- Follower list
	local followerList = GarrisonLandingPage.FollowerList
	B.StripTextures(followerList)
	B.ReskinInput(followerList.SearchBox)
	B.ReskinScroll(followerList.listScroll.scrollBar)
	hooksecurefunc(GarrisonLandingPageFollowerList, "UpdateData", UpdateFollowerList)
	hooksecurefunc(GarrisonLandingPageFollowerList, "ShowFollower", UpdateFollowerAbilities)

	-- Ship follower list
	local shipFollowerList = GarrisonLandingPage.ShipFollowerList
	B.StripTextures(shipFollowerList)
	B.ReskinInput(shipFollowerList.SearchBox)
	B.ReskinScroll(shipFollowerList.listScroll.scrollBar)

	-- Follower tab
	local followerTab = GarrisonLandingPage.FollowerTab
	ReskinXPBar(followerTab)
	hooksecurefunc(followerTab, "UpdateCombatantStats", UpdateSpellAbilities)

	-- Ship follower tab
	local followerTab = GarrisonLandingPage.ShipFollowerTab
	ReskinXPBar(followerTab)
	ReskinFollowerTab(followerTab)

	-- Mission UI
	local GarrisonMissionFrame = GarrisonMissionFrame
	ReskinMissionFrame(GarrisonMissionFrame)

	hooksecurefunc("GarrisonMissonListTab_SetSelected", function(tab, isSelected)
		if isSelected then
			tab.bg:SetBackdropColor(r, g, b, .2)
		else
			tab.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end)

	hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
		local ability = self.Abilities[index]

		if not ability.styled then
			local icon = ability.Icon
			icon:SetSize(19, 19)
			B.ReskinIcon(icon)

			ability.styled = true
		end
	end)

	hooksecurefunc("GarrisonFollowerButton_SetCounterButton", function(button, _, index)
		local counter = button.Counters[index]
		if counter and not counter.styled then
			B.ReskinIcon(counter.Icon)
			counter.styled = true
		end
	end)

	hooksecurefunc("GarrisonMissionButton_SetReward", function(frame)
		if not frame.bg then
			frame:GetRegions():Hide()
			frame.bg = B.ReskinIcon(frame.Icon)
			B.ReskinIconBorder(frame.IconBorder, true)
		end
	end)

	hooksecurefunc("GarrisonMissionPortrait_SetFollowerPortrait", function(portraitFrame, followerInfo)
		if not portraitFrame.styled then
			B.ReskinGarrisonPortrait(portraitFrame)
			portraitFrame.styled = true
		end

		local color = DB.QualityColors[followerInfo.quality]
		portraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		portraitFrame.squareBG:Show()
	end)

	hooksecurefunc("GarrisonMissionPage_SetReward", function(frame)
		if not frame.bg then
			B.ReskinIcon(frame.Icon)
			frame.BG:SetAlpha(0)
			frame.bg = B.CreateBDFrame(frame.BG, .25)
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
						B.ReskinIcon(counter.Icon)
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
					B.ReskinIcon(mechanic.Icon)
				end
				frame.styled = true
			end
		end
	end)

	hooksecurefunc(GarrisonMission, "UpdateMissionData", function(_, missionPage)
		local buffsFrame = missionPage.BuffsFrame
		if buffsFrame and buffsFrame:IsShown() then
			for i = 1, #buffsFrame.Buffs do
				local buff = buffsFrame.Buffs[i]
				if not buff.styled then
					B.ReskinIcon(buff.Icon)
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
					B.ReskinGarrisonPortrait(frame.PortraitFrame)

					local oldBg = frame:GetRegions()
					oldBg:Hide()
					frame.bg = B.CreateBDFrame(oldBg)
					frame.bg:SetPoint("TOPLEFT", frame.PortraitFrame, -1, 1)
					frame.bg:SetPoint("BOTTOMRIGHT", -10, 8)
				end

				local quality = select(4, C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]))
				if quality then
					local color = DB.QualityColors[quality]
					frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
					frame.PortraitFrame.squareBG:Show()
				end
			end
		end
	end)

	hooksecurefunc(GarrisonMission, "ShowMission", function(self)
		local envIcon = self:GetMissionPage().Stage.MissionEnvIcon
		if envIcon.bg then
			envIcon.bg:SetShown(envIcon.Texture:GetTexture())
		end
	end)

	-- Recruiter frame
	local GarrisonRecruiterFrame = GarrisonRecruiterFrame
	B.ReskinPortraitFrame(GarrisonRecruiterFrame)

	-- Pick
	local Pick = GarrisonRecruiterFrame.Pick
	B.Reskin(Pick.ChooseRecruits)
	B.ReskinDropDown(Pick.ThreatDropDown)
	B.ReskinRadio(Pick.Radio1)
	B.ReskinRadio(Pick.Radio2)

	-- Unavailable frame
	local UnavailableFrame = GarrisonRecruiterFrame.UnavailableFrame
	B.Reskin(UnavailableFrame:GetChildren())

	-- Recruiter select frame
	local GarrisonRecruitSelectFrame = GarrisonRecruitSelectFrame
	B.StripTextures(GarrisonRecruitSelectFrame)
	GarrisonRecruitSelectFrame.TitleText:Show()
	GarrisonRecruitSelectFrame.GarrCorners:Hide()
	B.CreateBDFrame(GarrisonRecruitSelectFrame)
	B.ReskinClose(GarrisonRecruitSelectFrame.CloseButton)

	-- Follower list
	local followerList = GarrisonRecruitSelectFrame.FollowerList
	followerList:DisableDrawLayer("BORDER")
	B.ReskinScroll(followerList.listScroll.scrollBar)
	B.ReskinInput(followerList.SearchBox)
	hooksecurefunc(followerList, "UpdateData", UpdateFollowerList)
	hooksecurefunc(followerList, "ShowFollower", UpdateFollowerAbilities)

	-- Follower selection
	local FollowerSelection = GarrisonRecruitSelectFrame.FollowerSelection
	FollowerSelection:DisableDrawLayer("BORDER")
	for i = 1, 3 do
		local recruit = FollowerSelection["Recruit"..i]
		B.ReskinGarrisonPortrait(recruit.PortraitFrame)
		B.Reskin(recruit.HireRecruits)
	end

	hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", function(waiting)
		if waiting then return end

		for i = 1, 3 do
			local frame = FollowerSelection["Recruit"..i]
			local portrait = frame.PortraitFrame
			portrait.squareBG:SetBackdropBorderColor(portrait.LevelBorder:GetVertexColor())

			if frame:IsShown() then
				local traits = frame.Traits.Entries
				if traits then
					for index = 1, #traits do
						local trait = traits[index]
						if not trait.bg then
							trait.bg = B.ReskinIcon(trait.Icon)
						end
					end
				end
				local abilities = frame.Abilities.Entries
				if abilities then
					for index = 1, #abilities do
						local ability = abilities[index]
						if not ability.bg then
							ability.bg = B.ReskinIcon(ability.Icon)
						end
					end
				end
			end
		end
	end)

	-- Monuments
	local GarrisonMonumentFrame = GarrisonMonumentFrame
	GarrisonMonumentFrame.Background:Hide()
	B.SetBD(GarrisonMonumentFrame, nil, 6, -10, -6, 4)

	for _, name in pairs({"Left", "Right"}) do
		local button = GarrisonMonumentFrame[name.."Btn"]
		button.Texture:Hide()
		B.ReskinArrow(button, strlower(name))
		button:SetSize(35, 35)
		button.__texture:SetSize(16, 16)
	end

	-- Shipyard
	local GarrisonShipyardFrame = GarrisonShipyardFrame
	B.StripTextures(GarrisonShipyardFrame)
	GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
	GarrisonShipyardFrame.BackgroundTile:Hide()
	B.SetBD(GarrisonShipyardFrame)
	B.ReskinInput(GarrisonShipyardFrameFollowers.SearchBox)
	B.ReskinScroll(GarrisonShipyardFrameFollowersListScrollFrameScrollBar)
	B.StripTextures(GarrisonShipyardFrameFollowers)
	ReskinGarrMaterial(GarrisonShipyardFrameFollowers)

	local shipyardTab = GarrisonShipyardFrame.FollowerTab
	shipyardTab:DisableDrawLayer("BORDER")
	ReskinXPBar(shipyardTab)
	ReskinFollowerTab(shipyardTab)

	B.ReskinClose(GarrisonShipyardFrame.BorderFrame.CloseButton2)
	B.ReskinTab(GarrisonShipyardFrameTab1)
	B.ReskinTab(GarrisonShipyardFrameTab2)

	local shipyardMission = GarrisonShipyardFrame.MissionTab.MissionPage
	B.StripTextures(shipyardMission)
	B.ReskinClose(shipyardMission.CloseButton)
	B.Reskin(shipyardMission.StartMissionButton)
	local smbg = B.CreateBDFrame(shipyardMission.Stage)
	smbg:SetPoint("TOPLEFT", 4, 1)
	smbg:SetPoint("BOTTOMRIGHT", -4, -1)

	B.StripTextures(shipyardMission.RewardsFrame)
	B.CreateBDFrame(shipyardMission.RewardsFrame, .25)

	GarrisonShipyardFrame.MissionCompleteBackground:GetRegions():Hide()
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog:GetRegions():Hide()
	B.Reskin(GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton)
	select(11, GarrisonShipyardFrame.MissionComplete.BonusRewards:GetRegions()):SetTextColor(1, .8, 0)
	B.Reskin(GarrisonShipyardFrame.MissionComplete.NextMissionButton)

	-- Orderhall UI
	local OrderHallMissionFrame = OrderHallMissionFrame
	ReskinMissionFrame(OrderHallMissionFrame)

	-- allies
	local combatAlly = OrderHallMissionFrameMissions.CombatAllyUI
	B.Reskin(combatAlly.InProgress.Unassign)
	combatAlly:GetRegions():Hide()
	B.CreateBDFrame(combatAlly, .25)
	B.ReskinIcon(combatAlly.InProgress.CombatAllySpell.iconTexture)

	local allyPortrait = combatAlly.InProgress.PortraitFrame
	B.ReskinGarrisonPortrait(allyPortrait)
	OrderHallMissionFrame:HookScript("OnShow", function()
		if allyPortrait:IsShown() then
			local color = DB.QualityColors[allyPortrait.quality or 1]
			allyPortrait.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
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
	B.StripTextures(ZoneSupportMissionPage)
	B.CreateBDFrame(ZoneSupportMissionPage, .25)
	B.ReskinClose(ZoneSupportMissionPage.CloseButton)
	B.Reskin(ZoneSupportMissionPage.StartMissionButton)
	B.ReskinIcon(ZoneSupportMissionPage.CombatAllySpell.iconTexture)
	ZoneSupportMissionPage.Follower1:GetRegions():Hide()
	B.CreateBDFrame(ZoneSupportMissionPage.Follower1, .25)
	B.ReskinGarrisonPortrait(ZoneSupportMissionPage.Follower1.PortraitFrame)

	-- BFA Mission UI
	local BFAMissionFrame = BFAMissionFrame
	ReskinMissionFrame(BFAMissionFrame)

	-- Covenant Mission UI
	local CovenantMissionFrame = CovenantMissionFrame
	ReskinMissionFrame(CovenantMissionFrame)
	CovenantMissionFrame.RaisedBorder:SetAlpha(0)
	CovenantMissionFrameMissions.RaisedFrameEdges:SetAlpha(0)

	hooksecurefunc(CovenantMissionFrame, "SetupTabs", function(self)
		self.MapTab:SetShown(not self.Tab2:IsShown())
	end)

	CombatLog:DisableDrawLayer("BACKGROUND")
	CombatLog.ElevatedFrame:SetAlpha(0)
	B.StripTextures(CombatLog.CombatLogMessageFrame)
	B.CreateBDFrame(CombatLog.CombatLogMessageFrame, .25)
	B.ReskinScroll(CombatLog.CombatLogMessageFrame.ScrollBar)

	B.Reskin(HealFollowerButtonTemplate)
	local bg = B.CreateBDFrame(CovenantMissionFrame.FollowerTab, .25)
	bg:SetPoint("TOPLEFT", 3, 2)
	bg:SetPoint("BOTTOMRIGHT", -3, -10)
	CovenantMissionFrame.FollowerTab.RaisedFrameEdges:SetAlpha(0)
	CovenantMissionFrame.FollowerTab.HealFollowerFrame.ButtonFrame:SetAlpha(0)
	CovenantMissionFrameFollowers.ElevatedFrame:SetAlpha(0)
	B.Reskin(CovenantMissionFrameFollowers.HealAllButton)
	B.ReskinIcon(CovenantMissionFrame.FollowerTab.HealFollowerFrame.CostFrame.CostIcon)

	CovenantMissionFrame.MissionTab.MissionPage.Board:HookScript("OnShow", ReskinMissionBoards)
	CovenantMissionFrame.MissionComplete.Board:HookScript("OnShow", ReskinMissionBoards)

	-- Addon supports

	local function buttonOnUpdate(MissionList)
		local buttons = MissionList.listScroll.buttons
		for i = 1, #buttons do
			local bu = select(3, buttons[i]:GetChildren())
			if bu and bu:IsObjectType("Button") and not bu.styled then
				B.Reskin(bu)
				bu:SetSize(60, 45)
				bu.styled = true
			end
		end
	end

	local function buttonOnShow(MissionPage)
		for i = 18, 27 do
			local bu = select(i, MissionPage:GetChildren())
			if bu and bu:IsObjectType("Button") and not bu.styled then
				B.Reskin(bu)
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
				if frame then
					hooksecurefunc(frame.MissionTab.MissionList, "Update", buttonOnUpdate)
					frame.MissionTab.MissionPage:HookScript("OnShow", buttonOnShow)
				end
			end

			f:UnregisterEvent(event)
		end
	end)

	local function reskinWidgetFont(font, r, g, b)
		if not C.db["Skins"]["FontOutline"] then return end
		if font and font.SetTextColor then
			font:SetTextColor(r, g, b)
		end
	end

	-- WarPlan
	if IsAddOnLoaded("WarPlan") then
		local function reskinWarPlanMissions(self)
			local missions = self.TaskBoard.Missions
			for i = 1, #missions do
				local button = missions[i]
				if not button.styled then
					reskinWidgetFont(button.XPReward, 1, 1, 1)
					reskinWidgetFont(button.Description, .8, .8, .8)
					reskinWidgetFont(button.CDTDisplay, 1, 1, 1)

					local groups = button.Groups
					if groups then
						for j = 1, #groups do
							local group = groups[j]
							B.Reskin(group)
							reskinWidgetFont(group.Features, 1, .8, 0)
						end
					end

					button.styled = true
				end
			end
		end

		C_Timer.After(.1, function()
			local WarPlanFrame = _G.WarPlanFrame
			if not WarPlanFrame then return end

			B.StripTextures(WarPlanFrame)
			B.SetBD(WarPlanFrame)
			B.StripTextures(WarPlanFrame.ArtFrame)
			B.ReskinClose(WarPlanFrame.ArtFrame.CloseButton)
			reskinWidgetFont(WarPlanFrame.ArtFrame.TitleText, 1, .8, 0)

			reskinWarPlanMissions(WarPlanFrame)
			WarPlanFrame:HookScript("OnShow", reskinWarPlanMissions)
			B.Reskin(WarPlanFrame.TaskBoard.AllPurposeButton)

			local entries = WarPlanFrame.HistoryFrame.Entries
			for i = 1, #entries do
				local entry = entries[i]
				entry:DisableDrawLayer("BACKGROUND")
				B.ReskinIcon(entry.Icon)
				entry.Name:SetFontObject("Number12Font")
				entry.Detail:SetFontObject("Number12Font")
			end
		end)
	end

	-- VenturePlan, 4.12a and higher
	if IsAddOnLoaded("VenturePlan") then
		local ANIMA_TEXTURE = 3528288
		local ANIMA_SPELLID = {[347555] = 3, [345706] = 5, [336327] = 35, [336456] = 250}
		local function GetAnimaMultiplier(itemID)
			local _, spellID = GetItemSpell(itemID)
			return ANIMA_SPELLID[spellID]
		end
		local function SetAnimaActualCount(self, text)
			local mult = GetAnimaMultiplier(self.__owner.itemID)
			if mult then
				if text == "" then text = 1 end
				text = text * mult
				self:SetFormattedText("%s", text)
				self.__owner.Icon:SetTexture(ANIMA_TEXTURE)
			end
		end

		function VPEX_OnUIObjectCreated(otype, widget, peek)
			if widget:IsObjectType("Frame") then
				if otype == "MissionButton" then
					B.Reskin(peek("ViewButton"))
					B.Reskin(peek("DoomRunButton"))
					B.Reskin(peek("TentativeClear"))
					reskinWidgetFont(peek("Description"), .8, .8, .8)
					reskinWidgetFont(peek("enemyHP"), 1, 1, 1)
					reskinWidgetFont(peek("enemyATK"), 1, 1, 1)
					reskinWidgetFont(peek("animaCost"), .6, .8, 1)
					reskinWidgetFont(peek("duration"), 1, .8, 0)
					reskinWidgetFont(widget.CDTDisplay:GetFontString(), 1, .8, 0)
				elseif otype == "CopyBoxUI" then
					B.Reskin(widget.ResetButton)
					B.ReskinClose(widget.CloseButton2)
					reskinWidgetFont(widget.Intro, 1, 1, 1)
					B.ReskinEditBox(widget.FirstInputBox)
					reskinWidgetFont(widget.FirstInputBoxLabel, 1, .8, 0)
					B.ReskinEditBox(widget.SecondInputBox)
					reskinWidgetFont(widget.SecondInputBoxLabel, 1, .8, 0)
					reskinWidgetFont(widget.VersionText, 1, 1, 1)
				elseif otype == "MissionList" then
					B.StripTextures(widget)
					local background = widget:GetChildren()
					B.StripTextures(background)
					B.CreateBDFrame(background, .25)
				elseif otype == "MissionPage" then
					B.StripTextures(widget)
					B.Reskin(peek("UnButton"))
				elseif otype == "ILButton" then
					widget:DisableDrawLayer("BACKGROUND")
					local bg = B.CreateBDFrame(widget, .25)
					bg:SetPoint("TOPLEFT", -3, 1)
					bg:SetPoint("BOTTOMRIGHT", 2, -2)
					B.CreateBDFrame(widget.Icon, .25)
				elseif otype == "IconButton" then
					B.ReskinIcon(widget:GetNormalTexture())
					widget:SetHighlightTexture(nil)
					widget:SetPushedTexture(DB.textures.pushed)
					widget.Icon:SetTexCoord(unpack(DB.TexCoord))
				elseif otype == "FollowerList" then
					B.StripTextures(widget)
					B.CreateBDFrame(widget, .25)
				elseif otype == "FollowerListButton" then
					peek("TextLabel"):SetFontObject("Game12Font")
				elseif otype == "ProgressBar" then
					B.StripTextures(widget)
					B.CreateBDFrame(widget, 1)
				elseif otype == "MissionToast" then
					B.SetBD(widget)
					if widget.Icon then widget.Icon:Show() end
					if widget.Background then widget.Background:Hide() end
					if widget.Detail then widget.Detail:SetFontObject("Game13Font") end
					if widget.Outcome then widget.Outcome:SetFontObject("Game13Font") end
				elseif otype == "RewardFrame" then
					if widget.Quantity then
						widget.Quantity.__owner = widget
						hooksecurefunc(widget.Quantity, "SetText", SetAnimaActualCount)
					end
				end
			end
		end
	end
end

local atlasToColor = {
	["none"] = {0, 0, 0},
	["orderhalltalents-spellborder"] = {0, 0, 0},
	["orderhalltalents-spellborder-green"] = {.08, .7, 0},
	["orderhalltalents-spellborder-yellow"] = {1, .8, 0},
}

local function updateTalentBorder(bu, atlas)
	if not bu.bg then return end

	local color = atlasToColor[atlas] or atlasToColor["none"]
	if color then
		bu.bg:SetBackdropBorderColor(color[1], color[2], color[3])
	end
end

C.themes["Blizzard_OrderHallUI"] = function()
	-- Talent Frame
	local OrderHallTalentFrame = OrderHallTalentFrame

	B.ReskinPortraitFrame(OrderHallTalentFrame)
	B.Reskin(OrderHallTalentFrame.BackButton)
	B.ReskinIcon(OrderHallTalentFrame.Currency.Icon)
	OrderHallTalentFrame.OverlayElements:SetAlpha(0)

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
		if self.CurrencyBG then self.CurrencyBG:SetAlpha(0) end
		B.StripTextures(self)

		if self.buttonPool then
			for bu in self.buttonPool:EnumerateActive() do
				bu.Border:SetAlpha(0)

				if not bu.bg then
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.bg = B.ReskinIcon(bu.Icon)

					updateTalentBorder(bu, bu.Border:GetAtlas())
					hooksecurefunc(bu, "SetBorder", updateTalentBorder)
				end
			end
		end
	end)
end