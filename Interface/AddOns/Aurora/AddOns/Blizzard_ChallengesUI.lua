local F, C = unpack(select(2, ...))

C.themes["Blizzard_ChallengesUI"] = function()
	-- Reskin Affixes
	local function AffixesSetup(parent)
		for i, frame in ipairs(parent) do
			frame.Border:SetTexture(nil)
			frame.Portrait:SetTexture(nil)
			if not frame.bg then
				frame.bg = F.ReskinIcon(frame.Portrait)
			end

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
		end
	end

	-- Reskin ChallengsFrame
	local ChallengesFrame = ChallengesFrame

	ChallengesFrameInset:DisableDrawLayer("BORDER")
	ChallengesFrameInsetBg:Hide()
	for i = 1, 2 do
		select(i, ChallengesFrame:GetRegions()):Hide()
	end

	select(1, ChallengesFrame.GuildBest:GetRegions()):Hide()
	select(3, ChallengesFrame.GuildBest:GetRegions()):Hide()
	F.CreateBD(ChallengesFrame.GuildBest, .3)

	local angryStyle
	ChallengesFrame:HookScript("OnShow", function()
		for i = 1, 13 do
			local bu = ChallengesFrame.DungeonIcons[i]
			if bu and not bu.styled then
				bu:GetRegions():SetAlpha(0)
				bu.Icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBD(bu, .3)
				bu.styled = true
			end
		end

		if IsAddOnLoaded("AngryKeystones") and not angryStyle then
			local scheduel = select(6, ChallengesFrame:GetChildren())
			select(1, scheduel:GetRegions()):SetAlpha(0)
			select(3, scheduel:GetRegions()):SetAlpha(0)
			F.CreateBD(scheduel, .3)

			if scheduel.Entries then
				for i = 1, 4 do
					AffixesSetup(scheduel.Entries[i].Affixes)
				end
			end
			angryStyle = true
		end
	end)

	local keystone = ChallengesKeystoneFrame
	F.SetBD(keystone)
	F.ReskinClose(keystone.CloseButton)
	F.Reskin(keystone.StartButton)

	hooksecurefunc(keystone, "Reset", function(self)
		select(1, self:GetRegions()):SetAlpha(0)
		self.InstructionBackground:SetAlpha(0)
	end)

	hooksecurefunc(keystone, "OnKeystoneSlotted", function(self) AffixesSetup(self.Affixes) end)
	hooksecurefunc(ChallengesFrame.WeeklyBest, "SetUp", function(self) AffixesSetup(self.Child.Affixes) end)

	-- Fix blizz
	ChallengesFrame.WeeklyBest:ClearAllPoints()
	ChallengesFrame.WeeklyBest:SetPoint("TOP", 0, -5)
	ChallengesFrame.GuildBest:SetPoint("TOPLEFT", ChallengesFrame.WeeklyBest.Child.Star, "BOTTOMRIGHT", -16, 30)
end