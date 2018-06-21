local F, C = unpack(select(2, ...))

C.themes["Blizzard_OrderHallUI"] = function()
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
	OrderHallTalentFrame.CurrencyIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(OrderHallTalentFrame.CurrencyIcon)

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
end