local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GuildRecruitmentUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.StripTextures(CommunitiesGuildRecruitmentFrame)
	B.SetBD(CommunitiesGuildRecruitmentFrame)
	B.StripTextures(CommunitiesGuildRecruitmentFrameTab1)
	B.StripTextures(CommunitiesGuildRecruitmentFrameTab2)
	B.ReskinClose(CommunitiesGuildRecruitmentFrameCloseButton)
	B.Reskin(CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton)
	B.StripTextures(CommunitiesGuildRecruitmentFrame)
	CommunitiesGuildRecruitmentFrameInset:Hide()

	for _, name in next, {"InterestFrame", "AvailabilityFrame", "RolesFrame", "LevelFrame", "CommentFrame"} do
		local frame = CommunitiesGuildRecruitmentFrameRecruitment[name]
		frame:GetRegions():Hide()
	end

	for _, name in next, {"QuestButton", "DungeonButton", "RaidButton", "PvPButton", "RPButton"} do
		local button = CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame[name]
		B.ReskinCheck(button)
	end

	local rolesFrame = CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame
	B.ReskinRole(rolesFrame.TankButton, "TANK")
	B.ReskinRole(rolesFrame.HealerButton, "HEALER")
	B.ReskinRole(rolesFrame.DamagerButton, "DPS")

	B.ReskinCheck(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekdaysButton)
	B.ReskinCheck(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekendsButton)
	B.ReskinRadio(CommunitiesGuildRecruitmentFrameRecruitment.LevelFrame.LevelAnyButton)
	B.ReskinRadio(CommunitiesGuildRecruitmentFrameRecruitment.LevelFrame.LevelMaxButton)
	B.StripTextures(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)
	B.CreateBDFrame(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame, .25)
	B.ReskinScroll(CommunitiesGuildRecruitmentFrameRecruitmentScrollFrameScrollBar)

	B.ReskinScroll(CommunitiesGuildRecruitmentFrameApplicantsContainer.scrollBar)
	B.Reskin(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	B.Reskin(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	B.Reskin(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	hooksecurefunc("CommunitiesGuildRecruitmentFrameApplicants_Update", function(self)
		local buttons = self.Container.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.bg then
				for i = 1, 9 do
					select(i, button:GetRegions()):Hide()
				end
				button.selectedTex:SetTexture("")
				button:SetHighlightTexture(0)
				button.bg = B.CreateBDFrame(button, .25)
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