local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Blizzard_CovenantPreviewUI

C.themes["Blizzard_CovenantPreviewUI"] = function()
	B.Reskin(CovenantPreviewFrame.SelectButton)
	CovenantPreviewFrame.InfoPanel.Description:SetTextColor(1, 1, 1)
	CovenantPreviewFrame.InfoPanel.AbilitiesLabel:SetTextColor(1, .8, 0)

	hooksecurefunc(CovenantPreviewFrame, "TryShow", function(self)
		if not self.bg then
			self.Background:SetAlpha(0)
			self.BorderFrame:SetAlpha(0)
			self.Title:DisableDrawLayer("BACKGROUND")
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title.Text:SetFontObject(SystemFont_Huge2)
			self.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)
			B.CreateBDFrame(self.Title, .25)
			B.ReskinClose(self.CloseButton)
			self.bg = B.SetBD(self)
		end
	end)

	hooksecurefunc(CovenantPreviewFrame, "SetupTextureKits", function(_, button)
		if button.IconBorder and not button.bg then
			button.IconBorder:SetAlpha(0)
			button.CircleMask:Hide()
			button.Background:SetAlpha(0)
			button.bg = B.ReskinIcon(button.Icon)
		end
	end)
end

-- Blizzard_CovenantSanctum

local function ReskinTalentsList(self)
	for frame in self.talentPool:EnumerateActive() do
		if not frame.bg then
			frame.Border:SetAlpha(0)
			frame.Background:SetAlpha(0)
			frame.bg = B.CreateBDFrame(frame, .25)
			frame.bg:SetInside()
			frame.Highlight:SetColorTexture(1, 1, 1, .25)
			frame.Highlight:SetInside(frame.bg)
			B.ReskinIcon(frame.Icon)
			frame.Icon:SetPoint("TOPLEFT", 7, -7)
		end
	end
end

local function HideRenownLevelBorder(frame)
	if not frame.styled then
		frame.Divider:SetAlpha(0)
		frame.BackgroundTile:SetAlpha(0)
		B.CreateBDFrame(frame.Background, .25)

		frame.styled = true
	end

	for button in frame.milestonesPool:EnumerateActive() do
		if not button.styled then
			button.LevelBorder:SetAlpha(0)

			button.styled = true
		end
	end
end

C.themes["Blizzard_CovenantSanctum"] = function()
	B.ReskinTab(CovenantSanctumFrameTab1)
	B.ReskinTab(CovenantSanctumFrameTab2)
	CovenantSanctumFrameTab1:SetPoint("TOPLEFT", CovenantSanctumFrame, "BOTTOMLEFT", 23, 1)

	CovenantSanctumFrame:HookScript("OnShow", function(self)
		if not self.bg then
			self.bg = B.SetBD(self)
			self.NineSlice:SetAlpha(0)
			self.LevelFrame.Background:SetAlpha(0)
			B.ReskinClose(self.CloseButton)
			self.CloseButton.Border:SetAlpha(0)

			local upgradesTab = self.UpgradesTab
			upgradesTab.Background:SetAlpha(0)
			B.CreateBDFrame(upgradesTab.Background, .25)
			B.Reskin(upgradesTab.DepositButton)
			for _, frame in ipairs(upgradesTab.Upgrades) do
				frame.RankBorder:SetAlpha(0)
			end

			local talentsList = upgradesTab.TalentsList
			talentsList.Divider:SetAlpha(0)
			B.CreateBDFrame(talentsList, .25)
			talentsList.BackgroundTile:SetAlpha(0)
			B.Reskin(talentsList.UpgradeButton)
			hooksecurefunc(talentsList, "Refresh", ReskinTalentsList)

			hooksecurefunc(self.RenownTab, "Refresh", HideRenownLevelBorder)
		end
	end)
end