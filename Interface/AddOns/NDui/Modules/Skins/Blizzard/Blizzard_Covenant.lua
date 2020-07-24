local _, ns = ...
local B, C, L, DB = unpack(ns)

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

	hooksecurefunc(CovenantPreviewFrame, "SetupTextureKits", function(self, button)
		if button.IconBorder and not button.bg then
			button.IconBorder:SetAlpha(0)
			button.CircleMask:Hide()
			button.Background:SetAlpha(0)
			button.bg = B.ReskinIcon(button.Icon)
		end
	end)
end

C.themes["Blizzard_CovenantSanctum"] = function()
	CovenantSanctumFrame:HookScript("OnShow", function(self)
		if not self.bg then
			self.bg = B.SetBD(self)
			self.NineSlice:SetAlpha(0)
			CovenantSanctumFrame.UpgradesTab.Background:SetAlpha(0)
			B.CreateBDFrame(CovenantSanctumFrame.UpgradesTab.Background, .25)
			CovenantSanctumFrame.UpgradesTab.TalentsList.Divider:SetAlpha(0)
			B.CreateBDFrame(CovenantSanctumFrame.UpgradesTab.TalentsList, .25)
			CovenantSanctumFrame.UpgradesTab.TalentsList.BackgroundTile:SetAlpha(0)
			B.Reskin(CovenantSanctumFrame.UpgradesTab.DepositButton)
			B.Reskin(CovenantSanctumFrame.UpgradesTab.TalentsList.UpgradeButton)
		end
	end)
	B.ReskinClose(CovenantSanctumFrameCloseButton)
	B.ReskinTab(CovenantSanctumFrameTab1)
	B.ReskinTab(CovenantSanctumFrameTab2)
	CovenantSanctumFrameTab1:SetPoint("TOPLEFT", CovenantSanctumFrame, "BOTTOMLEFT", 23, 1)
end