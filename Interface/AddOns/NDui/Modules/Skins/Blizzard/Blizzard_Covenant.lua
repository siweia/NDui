local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Blizzard_CovenantPreviewUI

C.themes["Blizzard_CovenantPreviewUI"] = function()
	local CovenantPreviewFrame = CovenantPreviewFrame
	B.Reskin(CovenantPreviewFrame.SelectButton)

	local infoPanel = CovenantPreviewFrame.InfoPanel
	infoPanel.Name:SetTextColor(1, .8, 0)
	infoPanel.Location:SetTextColor(1, 1, 1)
	infoPanel.Description:SetTextColor(1, 1, 1)
	infoPanel.AbilitiesFrame.AbilitiesLabel:SetTextColor(1, .8, 0)
	infoPanel.SoulbindsFrame.SoulbindsLabel:SetTextColor(1, .8, 0)
	infoPanel.CovenantFeatureFrame.Label:SetTextColor(1, .8, 0)

	hooksecurefunc(CovenantPreviewFrame, "TryShow", function(self)
		if not self.bg then
			self.Background:SetAlpha(0)
			self.BorderFrame:SetAlpha(0)
			self.Title:DisableDrawLayer("BACKGROUND")
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title.Text:SetFontObject(SystemFont_Huge1)
			self.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)
			B.CreateBDFrame(self.Title, .25)
			B.ReskinClose(self.CloseButton)
			self.bg = B.SetBD(self)
		end
		self.CloseButton:SetPoint("TOPRIGHT", -6, -6)
	end)
end

-- Blizzard_CovenantSanctum

local function reskinTalentsList(self)
	for frame in self.talentPool:EnumerateActive() do
		if not frame.bg then
			frame.Border:SetAlpha(0)
			frame.IconBorder:SetAlpha(0)
			frame.TierBorder:SetAlpha(0)
			frame.Background:SetAlpha(0)
			frame.bg = B.CreateBDFrame(frame, .25)
			frame.bg:SetInside()
			frame.Highlight:SetColorTexture(1, 1, 1, .25)
			frame.Highlight:SetInside(frame.bg)
			B.ReskinIcon(frame.Icon)
			frame.Icon:SetPoint("TOPLEFT", 7, -7)

			B.ReplaceIconString(frame.InfoText)
			hooksecurefunc(frame.InfoText, "SetText", B.ReplaceIconString)
		end
	end
end

local function replaceCurrencies(displayGroup)
	for frame in displayGroup.currencyFramePool:EnumerateActive() do
		if not frame.styled then
			B.ReplaceIconString(frame.Text)
			hooksecurefunc(frame.Text, "SetText", B.ReplaceIconString)

			frame.styled = true
		end
	end
end

C.themes["Blizzard_CovenantSanctum"] = function()
	local CovenantSanctumFrame = CovenantSanctumFrame

	CovenantSanctumFrame:HookScript("OnShow", function(self)
		if not self.bg then
			self.bg = B.SetBD(self)
			self.NineSlice:SetAlpha(0)
			self.LevelFrame.Background:SetAlpha(0)
			B.ReskinClose(self.CloseButton)
		end
	end)

	local upgradesTab = CovenantSanctumFrame.UpgradesTab
	upgradesTab.Background:SetAlpha(0)
	B.CreateBDFrame(upgradesTab.Background, .25)
	B.Reskin(upgradesTab.DepositButton)
	for _, frame in ipairs(upgradesTab.Upgrades) do
		if frame.TierBorder then
			frame.TierBorder:SetAlpha(0)
		end
	end
	upgradesTab.CurrencyBackground:SetAlpha(0)
	replaceCurrencies(upgradesTab.CurrencyDisplayGroup)

	local talentsList = upgradesTab.TalentsList
	talentsList.Divider:SetAlpha(0)
	B.CreateBDFrame(talentsList, .25)
	talentsList.BackgroundTile:SetAlpha(0)
	talentsList.IntroBox.Background:Hide()
	B.Reskin(talentsList.UpgradeButton)
	hooksecurefunc(talentsList, "Refresh", reskinTalentsList)
end

-- Covenant renown
C.themes["Blizzard_CovenantRenown"] = function()
	hooksecurefunc(CovenantRenownFrame, "SetUpCovenantData", function(self)
		B.StripTextures(self)

		if not self.styled then
			B.SetBD(self)
			B.ReskinClose(self.CloseButton)

			self.styled = true
		end
	end)
end