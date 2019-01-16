local F, C = unpack(select(2, ...))

C.themes["Blizzard_ArtifactUI"] = function()
	F.StripTextures(ArtifactFrame)
	F.SetBD(ArtifactFrame)
	F.ReskinTab(ArtifactFrameTab1)
	F.ReskinTab(ArtifactFrameTab2)
	ArtifactFrameTab1:ClearAllPoints()
	ArtifactFrameTab1:SetPoint("TOPLEFT", ArtifactFrame, "BOTTOMLEFT", 10, 0)
	F.ReskinClose(ArtifactFrame.CloseButton)
	ArtifactFrame.Background:Hide()
	ArtifactFrame.PerksTab.BackgroundBack:Hide()
	ArtifactFrame.PerksTab.Model.BackgroundBackShadow:Hide()
	ArtifactFrame.PerksTab.HeaderBackground:Hide()
	ArtifactFrame.PerksTab.TitleContainer.Background:SetAlpha(0)
	ArtifactFrame.PerksTab.Model:SetAlpha(.5)
	ArtifactFrame.PerksTab.Model.BackgroundFront:Hide()
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:SetAlpha(0)
	ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackgroundBlack:SetAlpha(0)
	ArtifactFrame.ForgeBadgeFrame.ItemIcon:Hide()
	ArtifactFrame.AppearancesTab.Background:Hide()

	-- Appearance

	for i = 1, 6 do
		local set = ArtifactFrame.AppearancesTab.appearanceSetPool:Acquire()
		set.Background:Hide()
		local bg = F.CreateGradient(set)
		bg:SetPoint("TOPLEFT", 10, -5)
		bg:SetPoint("BOTTOMRIGHT", -10, 5)
		for j = 1, 4 do
			local slot = ArtifactFrame.AppearancesTab.appearanceSlotPool:Acquire()
			slot.Border:SetAlpha(0)
			F.CreateBDFrame(slot)

			slot.Background:Hide()
			slot.SwatchTexture:SetTexCoord(.2, .8, .2, .8)
			slot.SwatchTexture:SetAllPoints()
			slot.HighlightTexture:SetColorTexture(1, 1, 1, .25)
			slot.HighlightTexture:SetAllPoints()

			slot.Selected:SetDrawLayer("BACKGROUND")
			slot.Selected:SetTexture(C.media.backdrop)
			slot.Selected:SetVertexColor(1, 1, 0)
			slot.Selected:SetPoint("TOPLEFT", -C.mult, C.mult)
			slot.Selected:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
		end
	end
end