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
	F.ReskinXPBar(FollowerTab)

	-- Mission UI

	F.ReskinMissionTabs("OrderHallMissionFrameMissionsTab")

	local MissionList = OrderHallMissionFrame.MissionTab.MissionList
	F.ReskinMissionList(MissionList)

	local MissionPage = OrderHallMissionFrame.MissionTab.MissionPage
	F.ReskinMissionPage(MissionPage)
	F.ReskinMissionComplete(OrderHallMissionFrame)

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