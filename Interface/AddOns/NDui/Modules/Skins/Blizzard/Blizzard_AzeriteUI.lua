local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AzeriteUI"] = function()
	B.ReskinPortraitFrame(AzeriteEmpoweredItemUI)
	AzeriteEmpoweredItemUIBg:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
end

C.themes["Blizzard_AzeriteEssenceUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(AzeriteEssenceUI)
	B.StripTextures(AzeriteEssenceUI.PowerLevelBadgeFrame)
	if DB.isPatch10_1 then
		B.ReskinTrimScroll(AzeriteEssenceUI.EssenceList.ScrollBar)
	else
		B.ReskinScroll(AzeriteEssenceUI.EssenceList.ScrollBar)
	end

	local headerButton = AzeriteEssenceUI.EssenceList.HeaderButton
	if headerButton then -- todo: removed in 10.1
		headerButton:DisableDrawLayer("BORDER")
		headerButton:DisableDrawLayer("BACKGROUND")
		local bg = B.CreateBDFrame(headerButton, 0, true)
		bg:SetPoint("TOPLEFT", headerButton.ExpandedIcon, -4, 6)
		bg:SetPoint("BOTTOMRIGHT", headerButton.ExpandedIcon, 4, -6)
		headerButton:SetScript("OnEnter", function()
			bg:SetBackdropColor(r, g, b, .25)
		end)
		headerButton:SetScript("OnLeave", function()
			bg:SetBackdropColor(0, 0, 0, 0)
		end)
	end

	for _, milestoneFrame in pairs(AzeriteEssenceUI.Milestones) do
		if milestoneFrame.LockedState then
			milestoneFrame.LockedState.UnlockLevelText:SetTextColor(.6, .8, 1)
			milestoneFrame.LockedState.UnlockLevelText.SetTextColor = B.Dummy
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
				hl:SetInside(bg)

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

local function reskinReforgeUI(frame, index)
	B.StripTextures(frame, index)
	B.CreateBDFrame(frame.Background)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinIcon(frame.ItemSlot.Icon)

	local buttonFrame = frame.ButtonFrame
	B.StripTextures(buttonFrame)
	buttonFrame.MoneyFrameEdge:SetAlpha(0)
	local bg = B.CreateBDFrame(buttonFrame, .25)
	bg:SetPoint("TOPLEFT", buttonFrame.MoneyFrameEdge, 3, 0)
	bg:SetPoint("BOTTOMRIGHT", buttonFrame.MoneyFrameEdge, 0, 2)
	if buttonFrame.AzeriteRespecButton then B.Reskin(buttonFrame.AzeriteRespecButton) end
	if buttonFrame.ActionButton then B.Reskin(buttonFrame.ActionButton) end
	if buttonFrame.Currency then B.ReskinIcon(buttonFrame.Currency.Icon) end

	if frame.DescriptionCurrencies then
		hooksecurefunc(frame.DescriptionCurrencies, "SetCurrencies", B.SetCurrenciesHook)
	end
end

C.themes["Blizzard_AzeriteRespecUI"] = function()
	reskinReforgeUI(AzeriteRespecFrame, 15)
end

C.themes["Blizzard_ItemInteractionUI"] = function()
	reskinReforgeUI(ItemInteractionFrame)
end