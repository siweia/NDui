local F, C = unpack(select(2, ...))

C.themes["Blizzard_LookingForGuildUI"] = function()
	local r, g, b = C.r, C.g, C.b

	local styled
	hooksecurefunc("LookingForGuildFrame_CreateUIElements", function()
		if styled then return end

		F.StripTextures(LookingForGuildFrame)
		F.SetBD(LookingForGuildFrame)
		F.CreateBD(LookingForGuildInterestFrame, .25)
		LookingForGuildInterestFrameBg:Hide()
		F.CreateBD(LookingForGuildAvailabilityFrame, .25)
		LookingForGuildAvailabilityFrameBg:Hide()
		F.CreateBD(LookingForGuildRolesFrame, .25)
		LookingForGuildRolesFrameBg:Hide()
		F.CreateBD(LookingForGuildCommentFrame, .25)
		LookingForGuildCommentFrameBg:Hide()
		F.CreateBD(LookingForGuildCommentInputFrame, .12)
		LookingForGuildFrameInset:DisableDrawLayer("BACKGROUND")
		LookingForGuildFrameInset:DisableDrawLayer("BORDER")
		F.CreateBD(GuildFinderRequestMembershipFrame)
		F.CreateSD(GuildFinderRequestMembershipFrame)
		for i = 1, 9 do
			select(i, LookingForGuildCommentInputFrame:GetRegions()):Hide()
		end
		for i = 1, 3 do
			for j = 1, 6 do
				select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()):Hide()
				select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()).Show = F.dummy
			end
		end
		for i = 1, 6 do
			select(i, GuildFinderRequestMembershipFrameInputFrame:GetRegions()):Hide()
		end
		LookingForGuildFrameTabardBackground:Hide()
		LookingForGuildFrameTabardEmblem:Hide()
		LookingForGuildFrameTabardBorder:Hide()
		LookingForGuildFramePortraitFrame:Hide()
		LookingForGuildFrameTopBorder:Hide()
		LookingForGuildFrameTopRightCorner:Hide()

		F.Reskin(LookingForGuildBrowseButton)
		F.Reskin(GuildFinderRequestMembershipFrameAcceptButton)
		F.Reskin(GuildFinderRequestMembershipFrameCancelButton)
		F.ReskinClose(LookingForGuildFrameCloseButton)
		F.ReskinCheck(LookingForGuildQuestButton)
		F.ReskinCheck(LookingForGuildDungeonButton)
		F.ReskinCheck(LookingForGuildRaidButton)
		F.ReskinCheck(LookingForGuildPvPButton)
		F.ReskinCheck(LookingForGuildRPButton)
		F.ReskinCheck(LookingForGuildWeekdaysButton)
		F.ReskinCheck(LookingForGuildWeekendsButton)
		F.ReskinInput(GuildFinderRequestMembershipFrameInputFrame)

		-- [[ Browse frame ]]

		F.Reskin(LookingForGuildRequestButton)
		F.ReskinScroll(LookingForGuildBrowseFrameContainerScrollBar)

		for i = 1, 5 do
			local bu = _G["LookingForGuildBrowseFrameContainerButton"..i]

			bu:SetBackdrop(nil)
			bu:SetHighlightTexture("")

			-- my client crashes if I put this in a var? :x
			bu:GetRegions():SetTexture(C.media.backdrop)
			bu:GetRegions():SetVertexColor(r, g, b, .2)
			bu:GetRegions():SetPoint("TOPLEFT", 1, -1)
			bu:GetRegions():SetPoint("BOTTOMRIGHT", -1, 2)

			local bg = F.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
		end

		-- [[ Role buttons ]]

		for _, roleButton in pairs({LookingForGuildTankButton, LookingForGuildHealerButton, LookingForGuildDamagerButton}) do
			roleButton.cover:SetTexture(C.media.roleIcons)
			roleButton:SetNormalTexture(C.media.roleIcons)
			local bg = F.CreateBDFrame(roleButton, 1)
			bg:SetPoint("TOPLEFT", roleButton, 5, -3)
			bg:SetPoint("BOTTOMRIGHT", roleButton, -5, 6)

			roleButton.checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)
			F.ReskinCheck(roleButton.checkButton)
		end

		styled = true
	end)
end