local F, C = unpack(select(2, ...))

C.themes["Blizzard_GuildRecruitmentUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.StripTextures(CommunitiesGuildRecruitmentFrame)
	F.SetBD(CommunitiesGuildRecruitmentFrame)
	F.StripTextures(CommunitiesGuildRecruitmentFrameTab1)
	F.StripTextures(CommunitiesGuildRecruitmentFrameTab2)
	F.ReskinClose(CommunitiesGuildRecruitmentFrameCloseButton)
	F.Reskin(CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton)
	F.StripTextures(CommunitiesGuildRecruitmentFrame)
	CommunitiesGuildRecruitmentFrameInset:Hide()

	for _, name in next, {"InterestFrame", "AvailabilityFrame", "RolesFrame", "LevelFrame", "CommentFrame"} do
		local frame = CommunitiesGuildRecruitmentFrameRecruitment[name]
		frame:GetRegions():Hide()
	end

	for _, name in next, {"QuestButton", "DungeonButton", "RaidButton", "PvPButton", "RPButton"} do
		local button = CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame[name]
		F.ReskinCheck(button)
	end

	local rolesFrame = CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame
	for _, button in next, {rolesFrame.TankButton, rolesFrame.HealerButton, rolesFrame.DamagerButton} do
		button:SetNormalTexture(C.media.roleIcons)
		F.ReskinCheck(button.checkButton)
		local bg = F.CreateBDFrame(button, 1)
		bg:SetPoint("TOPLEFT", 4, -3)
		bg:SetPoint("BOTTOMRIGHT", -4, 5)
	end

	F.ReskinCheck(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekdaysButton)
	F.ReskinCheck(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekendsButton)
	F.ReskinRadio(CommunitiesGuildRecruitmentFrameRecruitment.LevelFrame.LevelAnyButton)
	F.ReskinRadio(CommunitiesGuildRecruitmentFrameRecruitment.LevelFrame.LevelMaxButton)
	F.StripTextures(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)
	F.CreateBDFrame(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame, .25)
	F.ReskinScroll(CommunitiesGuildRecruitmentFrameRecruitmentScrollFrameScrollBar)

	F.ReskinScroll(CommunitiesGuildRecruitmentFrameApplicantsContainer.scrollBar)
	F.Reskin(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	F.Reskin(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	F.Reskin(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	hooksecurefunc("CommunitiesGuildRecruitmentFrameApplicants_Update", function(self)
		local buttons = self.Container.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				for i = 1, 9 do
					select(i, button:GetRegions()):Hide()
				end
				button.selectedTex:SetTexture("")
				button:SetHighlightTexture("")
				button.bg = F.CreateBDFrame(button, .25)
				button.bg:SetPoint("TOPLEFT", 3, -3)
				button.bg:SetPoint("BOTTOMRIGHT", -3, 3)
			end

			if button.selectedTex:IsShown() then
				button.bg:SetBackdropColor(r, g, b, .25)
			else
				button.bg:SetBackdropColor(0, 0, 0, .25)
			end
		end
	end)
end