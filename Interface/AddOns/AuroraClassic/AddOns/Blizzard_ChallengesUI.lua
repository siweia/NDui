local F, C = unpack(select(2, ...))

C.themes["Blizzard_ChallengesUI"] = function()
	ChallengesFrameInset:DisableDrawLayer("BORDER")
	ChallengesFrameInsetBg:Hide()
	for i = 1, 2 do
		select(i, ChallengesFrame:GetRegions()):Hide()
	end

	local angryStyle
	local function UpdateIcons(self)
		for i = 1, #self.maps do
			local bu = self.DungeonIcons[i]
			if bu and not bu.styled then
				bu:GetRegions():SetAlpha(0)
				bu.Icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBD(bu, 0)

				bu.styled = true
			end
		end

		if IsAddOnLoaded("AngryKeystones") and not angryStyle then
			local scheduel, party = select(4, self:GetChildren())

			scheduel:GetRegions():SetAlpha(0)
			select(3, scheduel:GetRegions()):SetAlpha(0)
			F.CreateBD(scheduel, .3)
			if scheduel.Entries then
				for i = 1, 3 do
					F.AffixesSetup(scheduel.Entries[i])
				end
			end

			party:GetRegions():SetAlpha(0)
			select(3, party:GetRegions()):SetAlpha(0)
			F.CreateBD(party, .3)

			angryStyle = true
		end
	end
	hooksecurefunc("ChallengesFrame_Update", UpdateIcons)

	hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(self)
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if affixes then
			F.AffixesSetup(self.Child)
		end
	end)

	local keystone = ChallengesKeystoneFrame
	F.SetBD(keystone)
	F.ReskinClose(keystone.CloseButton)
	F.Reskin(keystone.StartButton)

	hooksecurefunc(keystone, "Reset", function(self)
		self:GetRegions():SetAlpha(0)
		self.InstructionBackground:SetAlpha(0)
	end)

	hooksecurefunc(keystone, "OnKeystoneSlotted", F.AffixesSetup)
end