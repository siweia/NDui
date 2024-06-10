local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_TrainerUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.ReskinPortraitFrame(ClassTrainerFrame)
	ClassTrainerStatusBarSkillRank:ClearAllPoints()
	ClassTrainerStatusBarSkillRank:SetPoint("CENTER", ClassTrainerStatusBar, "CENTER", 0, 0)

	local icbg = B.ReskinIcon(ClassTrainerFrameSkillStepButtonIcon)
	local bg = B.CreateBDFrame(ClassTrainerFrameSkillStepButton, .25)
	bg:SetPoint("TOPLEFT", icbg, "TOPRIGHT", 1, 0)
	bg:SetPoint("BOTTOMRIGHT", icbg, "BOTTOMRIGHT", 270, 0)

	ClassTrainerFrameSkillStepButton:SetNormalTexture(0)
	ClassTrainerFrameSkillStepButton:SetHighlightTexture(0)
	ClassTrainerFrameSkillStepButton.disabledBG:SetTexture(0)
	ClassTrainerFrameSkillStepButton.selectedTex:SetInside(bg)
	ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(r, g, b, .25)

	B.StripTextures(ClassTrainerStatusBar)
	ClassTrainerStatusBar:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 64, -35)
	ClassTrainerStatusBar:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(ClassTrainerStatusBar, .25)

	ClassTrainerStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(.1, .3, .9, 1), CreateColor(.2, .4, 1, 1))
	B.ReskinTrimScroll(ClassTrainerFrame.ScrollBar)

	hooksecurefunc(ClassTrainerFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.styled then
				local icbg = B.ReskinIcon(button.icon)
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", icbg, "TOPRIGHT", 1, 0)
				bg:SetPoint("BOTTOMRIGHT", icbg, "BOTTOMRIGHT", 253, 0)

				button.name:SetParent(bg)
				button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 6, -2)
				button.subText:SetParent(bg)
				button.money:SetParent(bg)
				button.money:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, -8)
				button:SetNormalTexture(0)
				button:SetHighlightTexture(0)
				button.disabledBG:SetTexture(0)
				button.selectedTex:SetInside(bg)
				button.selectedTex:SetColorTexture(r, g, b, .25)

				button.styled = true
			end
		end
	end)

	B.Reskin(ClassTrainerTrainButton)
	if DB.isWW then
		B.ReskinFilterButton(ClassTrainerFrame.FilterDropdown)
	else
		B.ReskinDropDown(ClassTrainerFrameFilterDropDown)
	end
end