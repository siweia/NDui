local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.isPatch10_1 then return end -- ui removed in 10.1

C.themes["Blizzard_LookingForGuildUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	local styled
	hooksecurefunc("LookingForGuildFrame_CreateUIElements", function()
		if styled then return end

		B.ReskinPortraitFrame(LookingForGuildFrame)
		B.CreateBDFrame(LookingForGuildInterestFrame, .25)
		LookingForGuildInterestFrameBg:Hide()
		B.CreateBDFrame(LookingForGuildAvailabilityFrame, .25)
		LookingForGuildAvailabilityFrameBg:Hide()
		B.CreateBDFrame(LookingForGuildRolesFrame, .25)
		LookingForGuildRolesFrameBg:Hide()
		B.CreateBDFrame(LookingForGuildCommentFrame, .25)
		LookingForGuildCommentFrameBg:Hide()
		B.StripTextures(LookingForGuildCommentInputFrame)
		B.CreateBDFrame(LookingForGuildCommentInputFrame, .12)
		B.SetBD(GuildFinderRequestMembershipFrame)
		for i = 1, 3 do
			B.StripTextures(_G["LookingForGuildFrameTab"..i])
		end
		LookingForGuildFrameTabardBackground:Hide()
		LookingForGuildFrameTabardEmblem:Hide()
		LookingForGuildFrameTabardBorder:Hide()

		B.Reskin(LookingForGuildBrowseButton)
		B.Reskin(GuildFinderRequestMembershipFrameAcceptButton)
		B.Reskin(GuildFinderRequestMembershipFrameCancelButton)
		B.ReskinCheck(LookingForGuildQuestButton)
		B.ReskinCheck(LookingForGuildDungeonButton)
		B.ReskinCheck(LookingForGuildRaidButton)
		B.ReskinCheck(LookingForGuildPvPButton)
		B.ReskinCheck(LookingForGuildRPButton)
		B.ReskinCheck(LookingForGuildWeekdaysButton)
		B.ReskinCheck(LookingForGuildWeekendsButton)
		B.StripTextures(GuildFinderRequestMembershipFrameInputFrame)
		B.ReskinInput(GuildFinderRequestMembershipFrameInputFrame)

		-- [[ Browse frame ]]

		B.Reskin(LookingForGuildRequestButton)
		B.ReskinScroll(LookingForGuildBrowseFrameContainerScrollBar)

		for i = 1, 5 do
			local bu = _G["LookingForGuildBrowseFrameContainerButton"..i]
			bu:HideBackdrop()
			bu:SetHighlightTexture(0)

			-- my client crashes if I put this in a var? :x
			bu:GetRegions():SetTexture(DB.bdTex)
			bu:GetRegions():SetVertexColor(r, g, b, .2)
			bu:GetRegions():SetInside()

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
		end

		-- [[ Role buttons ]]
		B.ReskinRole(LookingForGuildTankButton, "TANK")
		B.ReskinRole(LookingForGuildHealerButton, "HEALER")
		B.ReskinRole(LookingForGuildDamagerButton, "DPS")

		styled = true
	end)
end