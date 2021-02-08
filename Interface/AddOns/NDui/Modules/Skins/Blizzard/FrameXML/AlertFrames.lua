local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Fix Alertframe bg
local function fixBg(frame)
	if frame:IsObjectType("AnimationGroup") then
		frame = frame:GetParent()
	end
	if frame.bg then
		frame.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
		if frame.bg.__shadow then
			frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, .4)
		end
	end
end

local function fixParentbg(frame)
	frame = frame:GetParent():GetParent()
	if frame.bg then
		frame.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
		if frame.bg.__shadow then
			frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, .4)
		end
	end
end

local function fixAnim(frame)
	if frame.hooked then return end

	frame:HookScript("OnEnter", fixBg)
	frame:HookScript("OnShow", fixBg)
	frame.animIn:HookScript("OnFinished", fixBg)
	if frame.animArrows then
		frame.animArrows:HookScript("OnPlay", fixBg)
		frame.animArrows:HookScript("OnFinished", fixBg)
	end
	if frame.Arrows and frame.Arrows.ArrowsAnim then
		frame.Arrows.ArrowsAnim:HookScript("OnPlay", fixParentbg)
		frame.Arrows.ArrowsAnim:HookScript("OnFinished", fixParentbg)
	end

	frame.hookded = true
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["AlertFrames"] then return end

	hooksecurefunc("AlertFrame_PauseOutAnimation", fixBg)

	-- AlertFrames
	hooksecurefunc(AlertFrame, "AddAlertFrame", function(_, frame)
		if frame.queue == AchievementAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 0, -7)
				frame.bg:SetPoint("BOTTOMRIGHT", 0, 8)

				frame.Unlocked:SetTextColor(1, 1, 1)
				frame.GuildName:ClearAllPoints()
				frame.GuildName:SetPoint("TOPLEFT", 50, -14)
				frame.GuildName:SetPoint("TOPRIGHT", -50, -14)
				B.ReskinIcon(frame.Icon.Texture)

				frame.GuildBanner:SetTexture("")
				frame.OldAchievement:SetTexture("")
				frame.GuildBorder:SetTexture("")
				frame.Icon.Bling:SetTexture("")
			end
			frame.glow:SetTexture("")
			frame.Background:SetTexture("")
			frame.Icon.Overlay:SetTexture("")
			-- otherwise it hides
			frame.Shield.Points:Show()
			frame.Shield.Icon:Show()
		elseif frame.queue == CriteriaAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", frame, -18, 5)
				frame.bg:SetPoint("BOTTOMRIGHT", frame, 18, -1)

				frame.Icon:SetScale(.8)
				frame.Unlocked:SetTextColor(1, 1, 1)
				B.ReskinIcon(frame.Icon.Texture)
				frame.Background:SetTexture("")
				frame.Icon.Bling:SetTexture("")
				frame.Icon.Overlay:SetTexture("")
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == LootAlertSystem then
			local lootItem = frame.lootItem
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", frame, 13, -15)
				frame.bg:SetPoint("BOTTOMRIGHT", frame, -13, 13)

				B.ReskinIcon(lootItem.Icon)
				lootItem.SpecRing:SetTexture("")
				lootItem.SpecIcon:SetPoint("TOPLEFT", lootItem.Icon, -5, 5)
				lootItem.SpecIcon.bg = B.ReskinIcon(lootItem.SpecIcon)
			end
			frame.glow:SetTexture("")
			frame.shine:SetTexture("")
			frame.Background:SetTexture("")
			frame.PvPBackground:SetTexture("")
			frame.BGAtlas:SetTexture("")
			lootItem.IconBorder:SetTexture("")
			lootItem.SpecIcon.bg:SetShown(lootItem.SpecIcon:IsShown() and lootItem.SpecIcon:GetTexture() ~= nil)
		elseif frame.queue == LootUpgradeAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 10, -13)
				frame.bg:SetPoint("BOTTOMRIGHT", -12, 11)

				B.ReskinIcon(frame.Icon)
				frame.Icon:ClearAllPoints()
				frame.Icon:SetPoint("CENTER", frame.BaseQualityBorder)

				frame.BaseQualityBorder:SetSize(52, 52)
				frame.BaseQualityBorder:SetTexture(DB.bdTex)
				frame.UpgradeQualityBorder:SetTexture(DB.bdTex)
				frame.UpgradeQualityBorder:SetSize(52, 52)
				frame.Background:SetTexture("")
				frame.Sheen:SetTexture("")
				frame.BorderGlow:SetTexture("")
			end
			frame.BaseQualityBorder:SetTexture("")
			frame.UpgradeQualityBorder:SetTexture("")
		elseif frame.queue == MoneyWonAlertSystem or frame.queue == HonorAwardedAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 7, -7)
				frame.bg:SetPoint("BOTTOMRIGHT", -7, 7)

				B.ReskinIcon(frame.Icon)
				frame.Background:SetTexture("")
				frame.IconBorder:SetTexture("")
			end
		elseif frame.queue == NewRecipeLearnedAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 10, -5)
				frame.bg:SetPoint("BOTTOMRIGHT", -10, 5)

				frame:GetRegions():SetTexture("")
				B.CreateBDFrame(frame.Icon)
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
			frame.Icon:SetMask(nil)
			frame.Icon:SetTexCoord(unpack(DB.TexCoord))
		elseif frame.queue == WorldQuestCompleteAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 4, -7)
				frame.bg:SetPoint("BOTTOMRIGHT", -4, 8)

				B.ReskinIcon(frame.QuestTexture)
				frame.shine:SetTexture("")
				frame:DisableDrawLayer("BORDER")
				frame.ToastText:SetFontObject(NumberFont_GameNormal)
			end
		elseif frame.queue == GarrisonTalentAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 11)

				B.ReskinIcon(frame.Icon)
				frame:GetRegions():Hide()
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == GarrisonFollowerAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 16, -3)
				frame.bg:SetPoint("BOTTOMRIGHT", -16, 16)

				frame:GetRegions():Hide()
				select(5, frame:GetRegions()):Hide()
				B.ReskinGarrisonPortrait(frame.PortraitFrame)
				frame.PortraitFrame:ClearAllPoints()
				frame.PortraitFrame:SetPoint("TOPLEFT", 22, -8)

				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
			frame.FollowerBG:SetTexture("")
		elseif frame.queue == GarrisonMissionAlertSystem or frame.queue == GarrisonRandomMissionAlertSystem or frame.queue == GarrisonShipMissionAlertSystem or frame.queue == GarrisonShipFollowerAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 10)

				if frame.Blank then frame.Blank:Hide() end
				if frame.IconBG then frame.IconBG:Hide() end
				frame.Background:Hide()
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end

			-- Anchor fix in 8.2
			if frame.Level then
				if frame.ItemLevel:IsShown() and frame.Rare:IsShown() then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -14)
					frame.ItemLevel:SetPoint("TOP", frame, "TOP", -115, -37)
					frame.Rare:SetPoint("TOP", frame, "TOP", -115, -48)
				elseif frame.Rare:IsShown() then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -19)
					frame.Rare:SetPoint("TOP", frame, "TOP", -115, -45)
				elseif frame.ItemLevel:IsShown() then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -19)
					frame.ItemLevel:SetPoint("TOP", frame, "TOP", -115, -45)
				else
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -28)
				end
			end
		elseif frame.queue == GarrisonBuildingAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 9, -9)
				frame.bg:SetPoint("BOTTOMRIGHT", -9, 11)

				B.ReskinIcon(frame.Icon)
				frame:GetRegions():Hide()
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == DigsiteCompleteAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 8)

				frame:GetRegions():Hide()
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == GuildChallengeAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -12)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 13)

				select(2, frame:GetRegions()):SetTexture("")
				frame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == DungeonCompletionAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 3, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -3, 8)

				B.ReskinIcon(frame.dungeonTexture)
				frame:DisableDrawLayer("Border")
				frame.heroicIcon:SetTexture("")
				frame.glowFrame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == ScenarioAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 5, -5)
				frame.bg:SetPoint("BOTTOMRIGHT", -5, 5)

				B.ReskinIcon(frame.dungeonTexture)
				frame:GetRegions():Hide()
				select(3, frame:GetRegions()):Hide()
				frame.glowFrame.glow:SetTexture("")
				frame.shine:SetTexture("")
			end
		elseif frame.queue == LegendaryItemAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 25, -22)
				frame.bg:SetPoint("BOTTOMRIGHT", -25, 22)
				frame:HookScript("OnUpdate", fixBg)

				B.ReskinIcon(frame.Icon)
				frame.Icon:ClearAllPoints()
				frame.Icon:SetPoint("TOPLEFT", frame.bg, 12, -12)

				frame.Background:SetTexture("")
				frame.Background2:SetTexture("")
				frame.Background3:SetTexture("")
				frame.glow:SetTexture("")
			end
		elseif frame.queue == NewPetAlertSystem or frame.queue == NewMountAlertSystem or frame.queue == NewToyAlertSystem or frame.queue == NewRuneforgePowerAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 12, -13)
				frame.bg:SetPoint("BOTTOMRIGHT", -12, 10)

				B.ReskinIcon(frame.Icon)
				frame.IconBorder:Hide()
				frame.Background:SetTexture("")
				frame.shine:SetTexture("")
				frame.glow:SetTexture("")
			end
		elseif frame.queue == InvasionAlertSystem then
			if not frame.bg then
				frame.bg = B.SetBD(frame)
				frame.bg:SetPoint("TOPLEFT", 6, -6)
				frame.bg:SetPoint("BOTTOMRIGHT", -6, 6)

				local bg, icon = frame:GetRegions()
				bg:Hide()
				B.ReskinIcon(icon)
			end
		end

		fixAnim(frame)
	end)

	-- Reward Icons
	hooksecurefunc("StandardRewardAlertFrame_AdjustRewardAnchors", function(frame)
		if frame.RewardFrames then
			for i = 1, frame.numUsedRewardFrames do
				local reward = frame.RewardFrames[i]
				if not reward.bg then
					select(2, reward:GetRegions()):SetTexture("")
					reward.texture:ClearAllPoints()
					reward.texture:SetPoint("TOPLEFT", 6, -6)
					reward.texture:SetPoint("BOTTOMRIGHT", -6, 6)
					reward.bg = B.ReskinIcon(reward.texture)
				end
			end
		end
	end)

	-- BonusRollLootWonFrame
	hooksecurefunc("LootWonAlertFrame_SetUp", function(frame)
		local lootItem = frame.lootItem
		if not frame.bg then
			frame.bg = B.SetBD(frame)
			frame.bg:SetPoint("TOPLEFT", 10, -10)
			frame.bg:SetPoint("BOTTOMRIGHT", -10, 10)
			fixAnim(frame)

			frame.shine:SetTexture("")
			B.ReskinIcon(lootItem.Icon)

			lootItem.SpecRing:SetTexture("")
			lootItem.SpecIcon:SetPoint("TOPLEFT", lootItem.Icon, -5, 5)
			lootItem.SpecIcon.bg = B.ReskinIcon(lootItem.SpecIcon)
			lootItem.SpecIcon.bg:SetShown(lootItem.SpecIcon:IsShown() and lootItem.SpecIcon:GetTexture() ~= nil)
		end

		frame.glow:SetTexture("")
		frame.Background:SetTexture("")
		frame.PvPBackground:SetTexture("")
		frame.BGAtlas:SetAlpha(0)
		lootItem.IconBorder:SetTexture("")
	end)

	-- BonusRollMoneyWonFrame
	hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
		if not frame.bg then
			frame.bg = B.SetBD(frame)
			frame.bg:SetPoint("TOPLEFT", 5, -5)
			frame.bg:SetPoint("BOTTOMRIGHT", -5, 5)
			fixAnim(frame)

			frame.Background:SetTexture("")
			B.ReskinIcon(frame.Icon)
			frame.IconBorder:SetTexture("")
		end
	end)
end)