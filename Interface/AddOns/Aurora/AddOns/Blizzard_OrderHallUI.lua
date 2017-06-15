local F, C = unpack(select(2, ...))

C.themes["Blizzard_OrderHallUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.Reskin(OrderHallMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton)
	F.Reskin(OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)
	F.Reskin(OrderHallMissionFrame.MissionTab.MissionPage.StartMissionButton)
	F.ReskinClose(OrderHallMissionFrame.CloseButton)
	F.ReskinClose(OrderHallMissionFrame.MissionTab.MissionPage.CloseButton)
	F.ReskinTab(OrderHallMissionFrameTab1)
	F.ReskinTab(OrderHallMissionFrameTab2)
	F.ReskinTab(OrderHallMissionFrameTab3)
	F.ReskinScroll(OrderHallMissionFrameMissionsListScrollFrameScrollBar)
	F.ReskinScroll(OrderHallMissionFrameFollowersListScrollFrameScrollBar)
	select(11, OrderHallMissionFrame.MissionComplete.BonusRewards:GetRegions()):SetTextColor(1, .8, 0)

	for i = 1, 18 do
		select(i, OrderHallMissionFrameMissions:GetRegions()):Hide()
	end
	do
		OrderHallMissionFrameMissions.MaterialFrame.Icon:SetTexCoord(.08, .92, .08, .92)
		OrderHallMissionFrameMissions.MaterialFrame:GetRegions():Hide()
		local bg = F.CreateBDFrame(OrderHallMissionFrameMissions.MaterialFrame, .25)
		bg:SetPoint("TOPLEFT", 5, -5)
		bg:SetPoint("BOTTOMRIGHT", -5, 6)
	end
	OrderHallMissionFrameMissions.CombatAllyUI:GetRegions():Hide()
	F.CreateBDFrame(OrderHallMissionFrameMissions.CombatAllyUI, .25)

	for i = 1, 14 do
		select(i, OrderHallMissionFrame:GetRegions()):Hide()
	end
	OrderHallMissionFrame.TitleText:Show()
	F.SetBD(OrderHallMissionFrame)
	OrderHallMissionFrame.ClassHallIcon:Hide()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame.BackgroundTile:Hide()
	OrderHallMissionFrame.BackgroundTile.Show = F.dummy

	for i = 1, 20 do
		select(i, OrderHallMissionFrameFollowers:GetRegions()):Hide()
	end
	F.ReskinInput(OrderHallMissionFrameFollowers.SearchBox)

	do
		OrderHallMissionFrameFollowers.MaterialFrame.Icon:SetTexCoord(.08, .92, .08, .92)
		OrderHallMissionFrameFollowers.MaterialFrame:GetRegions():Hide()
		local bg = F.CreateBDFrame(OrderHallMissionFrameFollowers.MaterialFrame, .25)
		bg:SetPoint("TOPLEFT", 5, -5)
		bg:SetPoint("BOTTOMRIGHT", -5, 6)
	end

	local FollowerTab = OrderHallMissionFrame.FollowerTab
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

	-- Mission UI

	for i = 1, 2 do
		local tab = _G["OrderHallMissionFrameMissionsTab"..i]
		tab.Left:Hide()
		tab.Middle:Hide()
		tab.Right:Hide()
		tab.SelectedLeft:SetTexture("")
		tab.SelectedMid:SetTexture("")
		tab.SelectedRight:SetTexture("")
		F.CreateBD(tab, .25)
	end
	OrderHallMissionFrameMissionsTab1:SetBackdropColor(r, g, b, .2)

	local MissionList = OrderHallMissionFrame.MissionTab.MissionList
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

	local MissionPage = OrderHallMissionFrame.MissionTab.MissionPage
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
	MissionPage.CostFrame.CostIcon:SetTexCoord(.08, .92, .08, .92)
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

	local buffFrame = MissionPage.BuffsFrame
	buffFrame.BuffsBG:Hide()
	hooksecurefunc(GarrisonMission, "UpdateMissionData", function()
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

	for i = 1, 3 do
		local num = 1
		local enemy = MissionPage.Enemies[i].Mechanics
		local mec = enemy[num]
		while mec do
			mec.Icon:SetDrawLayer("BORDER", 1)
			F.ReskinIcon(mec.Icon)
			num = num + 1
			mec = enemy[num]
		end
	end

	local rewardFrame = MissionPage.RewardsFrame
	for i = 1, 10 do
		select(i, rewardFrame:GetRegions()):Hide()
	end
	F.CreateBD(rewardFrame, .25)

	local item = rewardFrame.OvermaxItem
	item.Icon:SetDrawLayer("BORDER", 1)
	F.ReskinIcon(item.Icon)

	for i = 1, 2 do
		local reward = MissionPage.RewardsFrame.Rewards[i]
		local icon = reward.Icon
		reward.BG:Hide()
		icon:SetDrawLayer("BORDER", 1)
		F.ReskinIcon(icon)
		reward.ItemBurst:SetDrawLayer("BORDER", 2)
		F.CreateBD(reward, .15)
	end

	-- Mission Complete Page

	local missionComplete = OrderHallMissionFrame.MissionComplete
	local bonusRewards = missionComplete.BonusRewards
	select(11, bonusRewards:GetRegions()):SetTextColor(1, .8, 0)
	bonusRewards.Saturated:Hide()
	bonusRewards.Saturated.Show = F.dummy
	for i = 1, 9 do
		select(i, bonusRewards:GetRegions()):SetAlpha(0)
	end
	F.CreateBD(bonusRewards, .25)
	F.Reskin(missionComplete.NextMissionButton)

	-- Add Ally

	local allySpell = OrderHallMissionFrameMissions.CombatAllyUI.InProgress.CombatAllySpell
	allySpell.iconTexture:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(allySpell.iconTexture)

	local allyPortrait = OrderHallMissionFrameMissions.CombatAllyUI.InProgress.PortraitFrame
	F.ReskinGarrisonPortrait(allyPortrait)
	OrderHallMissionFrame:HookScript("OnShow", function(self)
		if allyPortrait:IsShown() then
			allyPortrait.squareBG:SetBackdropBorderColor(allyPortrait.PortraitRingQuality:GetVertexColor())
		end
		OrderHallMissionFrameMissions.CombatAllyUI.Available.AddFollowerButton.EmptyPortrait:SetAlpha(0)
		OrderHallMissionFrameMissions.CombatAllyUI.Available.AddFollowerButton.PortraitHighlight:SetAlpha(0)
	end)

	hooksecurefunc(OrderHallCombatAllyMixin, "SetMission", function(self)
		self.InProgress.PortraitFrame.LevelBorder:SetAlpha(0)
	end)

	hooksecurefunc(OrderHallCombatAllyMixin, "UnassignAlly", function(self)
		if self.InProgress.PortraitFrame.squareBG then
			self.InProgress.PortraitFrame.squareBG:Hide()
		end
	end)

	local zonesupport = OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage
	F.ReskinClose(zonesupport.CloseButton)
	F.Reskin(zonesupport.StartMissionButton)
	zonesupport.CombatAllySpell.iconTexture:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(zonesupport.CombatAllySpell.iconTexture)
	for i = 1, 10 do
		select(i, zonesupport:GetRegions()):Hide()
	end
	F.CreateBD(zonesupport, .3)
	zonesupport.Follower1:GetRegions():Hide()
	F.CreateBD(zonesupport.Follower1, .3)

	zonesupport.Follower1.PortraitFrame.Highlight:Hide()
	zonesupport.Follower1.PortraitFrame.PortraitFeedbackGlow:Hide()
	zonesupport.Follower1.PortraitFrame.PortraitRing:SetAlpha(0)
	zonesupport.Follower1.PortraitFrame.PortraitRingQuality:SetAlpha(0)
	zonesupport.Follower1.PortraitFrame.LevelBorder:SetAlpha(0)
	zonesupport.Follower1.PortraitFrame.Level:SetText("")
	zonesupport.Follower1.PortraitFrame.Empty:SetColorTexture(0,0,0)
	zonesupport.Follower1.PortraitFrame.Empty:SetAllPoints(zonesupport.Follower1.PortraitFrame.Portrait)

	-- Orderhall tooltips

	if AuroraConfig.tooltips then
		GarrisonFollowerAbilityWithoutCountersTooltip:DisableDrawLayer("BACKGROUND")
		GarrisonFollowerMissionAbilityWithoutCountersTooltip:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(GarrisonFollowerAbilityWithoutCountersTooltip)
		F.CreateBDFrame(GarrisonFollowerMissionAbilityWithoutCountersTooltip)
	end

	-- Talent Frame

	F.ReskinClose(OrderHallTalentFrameCloseButton)
	for i = 1, 15 do
		select(i, OrderHallTalentFrame:GetRegions()):Hide()
	end
	OrderHallTalentFrameTitleText:Show()
	OrderHallTalentFrameBg:Hide()
	F.CreateBD(OrderHallTalentFrame)
	F.CreateSD(OrderHallTalentFrame)
	ClassHallTalentInset:Hide()
	OrderHallTalentFramePortrait:Hide()
	OrderHallTalentFramePortraitFrame:Hide()
	F.Reskin(OrderHallTalentFrame.BackButton)

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function()
		for i = 34, OrderHallTalentFrame:GetNumRegions() do
			select(i, OrderHallTalentFrame:GetRegions()):SetAlpha(0)
		end

		for i = 1, OrderHallTalentFrame:GetNumChildren() do
			local bu = select(i, OrderHallTalentFrame:GetChildren())
			if bu.Icon then
				if not bu.styled then
					bu.Icon:SetTexCoord(.08, .92, .08, .92)
					bu.Border:SetAlpha(0)
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.bg = F.CreateBDFrame(bu.Border)
					bu.bg:SetPoint("TOPLEFT", -1.2, 1.2)
					bu.bg:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
					bu.styled = true
				end

				if bu and bu.talent then
					if bu.talent.selected then
						bu.bg:SetBackdropBorderColor(1, 1, 0)
					else
						bu.bg:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end)

	-- Addon Supports
	do
		if IsAddOnLoaded("GarrisonMissionManager") then
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
		end
	end
end