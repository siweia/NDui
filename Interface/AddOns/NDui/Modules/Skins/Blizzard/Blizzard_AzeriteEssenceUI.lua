local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AzeriteEssenceUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(AzeriteEssenceUI)
	B.StripTextures(AzeriteEssenceUI.PowerLevelBadgeFrame)
	B.ReskinScroll(AzeriteEssenceUI.EssenceList.ScrollBar)

	local headerButton = AzeriteEssenceUI.EssenceList.HeaderButton
	headerButton:DisableDrawLayer("BORDER")
	headerButton:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(headerButton)
	bg:SetPoint("TOPLEFT", headerButton.ExpandedIcon, -4, 6)
	bg:SetPoint("BOTTOMRIGHT", headerButton.ExpandedIcon, 4, -6)
	B.CreateGradient(bg)
	headerButton:SetScript("OnEnter", function()
		bg:SetBackdropColor(r, g, b, .25)
	end)
	headerButton:SetScript("OnLeave", function()
		bg:SetBackdropColor(0, 0, 0, 0)
	end)

	for _, milestoneFrame in pairs(AzeriteEssenceUI.Milestones) do
		if milestoneFrame.LockedState then
			milestoneFrame.LockedState.UnlockLevelText:SetTextColor(.6, .8, 1)
		end
	end

	hooksecurefunc(AzeriteEssenceUI.EssenceList, "Refresh", function(self)
		for _, button in ipairs(self.buttons) do
			if not button.bg then
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 1, 0)
				bg:SetPoint("BOTTOMRIGHT", 0, 2)

				B.ReskinIcon(button.Icon)
				button.PendingGlow:SetTexture("")
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .25)
				hl:SetAllPoints(bg)

				button.bg = bg
			end
			button.Background:SetTexture("")

			if button:IsShown() then
				if button.PendingGlow:IsShown() then
					button.bg:SetBackdropBorderColor(1, .8, 0)
				else
					button.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end