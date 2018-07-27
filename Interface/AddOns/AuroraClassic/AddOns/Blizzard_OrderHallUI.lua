local F, C = unpack(select(2, ...))

C.themes["Blizzard_OrderHallUI"] = function()
	-- Orderhall tooltips
	if AuroraConfig.tooltips then
		GarrisonFollowerAbilityWithoutCountersTooltip:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(GarrisonFollowerAbilityWithoutCountersTooltip)
		F.CreateSD(GarrisonFollowerAbilityWithoutCountersTooltip)
		GarrisonFollowerMissionAbilityWithoutCountersTooltip:DisableDrawLayer("BACKGROUND")
		F.CreateBDFrame(GarrisonFollowerMissionAbilityWithoutCountersTooltip)
		F.CreateSD(GarrisonFollowerMissionAbilityWithoutCountersTooltip)
	end

	-- Talent Frame
	for i = 1, 15 do
		if i ~= 8 then
			select(i, OrderHallTalentFrame:GetRegions()):SetAlpha(0)
		end
	end
	OrderHallTalentFrameBg:Hide()
	F.CreateBD(OrderHallTalentFrame)
	F.CreateSD(OrderHallTalentFrame)
	ClassHallTalentInset:SetAlpha(0)
	F.Reskin(OrderHallTalentFrame.BackButton)
	F.ReskinIcon(OrderHallTalentFrame.Currency.Icon)
	OrderHallTalentFrame.StyleFrame:SetAlpha(0)
	F.ReskinClose(OrderHallTalentFrameCloseButton)
	OrderHallTalentFrameCloseButton:ClearAllPoints()
	OrderHallTalentFrameCloseButton:SetPoint("TOPRIGHT", OrderHallTalentFrame)
	OrderHallTalentFrameCloseButton.SetPoint = F.dummy

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function()
		for i = 34, OrderHallTalentFrame:GetNumRegions() do
			select(i, OrderHallTalentFrame:GetRegions()):SetAlpha(0)
		end

		for i = 1, OrderHallTalentFrame:GetNumChildren() do
			local bu = select(i, OrderHallTalentFrame:GetChildren())
			if bu and bu.talent then
				if not bu.bg then
					bu.Icon:SetTexCoord(.08, .92, .08, .92)
					bu.Border:SetAlpha(0)
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.bg = F.CreateBDFrame(bu.Icon)
				end

				if bu.talent.selected then
					bu.bg:SetBackdropBorderColor(1, 1, 0)
				else
					bu.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end