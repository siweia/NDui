local F, C = unpack(select(2, ...))

C.themes["Blizzard_TrainerUI"] = function()
	local r, g, b = C.r, C.g, C.b

	ClassTrainerFrameBottomInset:DisableDrawLayer("BORDER")
	ClassTrainerFrame.BG:Hide()
	ClassTrainerFrameBottomInsetBg:Hide()
	ClassTrainerFrameMoneyBg:SetAlpha(0)

	ClassTrainerStatusBarSkillRank:ClearAllPoints()
	ClassTrainerStatusBarSkillRank:SetPoint("CENTER", ClassTrainerStatusBar, "CENTER", 0, 0)

	local bg = F.CreateBDFrame(ClassTrainerFrameSkillStepButton, .25)
	bg:SetPoint("TOPLEFT", 42, -2)
	bg:SetPoint("BOTTOMRIGHT", 0, 2)

	ClassTrainerFrameSkillStepButton:SetNormalTexture("")
	ClassTrainerFrameSkillStepButton:SetHighlightTexture("")
	ClassTrainerFrameSkillStepButton.disabledBG:SetTexture("")

	ClassTrainerFrameSkillStepButton.selectedTex:SetPoint("TOPLEFT", 43, -3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetPoint("BOTTOMRIGHT", -1, 3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetTexture(C.media.backdrop)
	ClassTrainerFrameSkillStepButton.selectedTex:SetVertexColor(r, g, b, .2)

	local icbg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
	icbg:SetPoint("TOPLEFT", ClassTrainerFrameSkillStepButtonIcon, -1, 1)
	icbg:SetPoint("BOTTOMRIGHT", ClassTrainerFrameSkillStepButtonIcon, 1, -1)
	F.CreateBD(icbg, 0)

	ClassTrainerFrameSkillStepButtonIcon:SetTexCoord(.08, .92, .08, .92)

	hooksecurefunc("ClassTrainerFrame_Update", function()
		for _, bu in next, ClassTrainerFrame.scrollFrame.buttons do
			if not bu.styled then
				local bg = F.CreateBDFrame(bu, .25)
				bg:SetPoint("TOPLEFT", 42, -6)
				bg:SetPoint("BOTTOMRIGHT", 0, 6)

				bu.name:SetParent(bg)
				bu.name:SetPoint("TOPLEFT", bu.icon, "TOPRIGHT", 6, -2)
				bu.subText:SetParent(bg)
				bu.money:SetParent(bg)
				bu.money:SetPoint("TOPRIGHT", bu, "TOPRIGHT", 5, -8)
				bu:SetNormalTexture("")
				bu:SetHighlightTexture("")
				bu.disabledBG:Hide()
				bu.disabledBG.Show = F.dummy

				bu.selectedTex:SetPoint("TOPLEFT", 43, -6)
				bu.selectedTex:SetPoint("BOTTOMRIGHT", -1, 7)
				bu.selectedTex:SetTexture(C.media.backdrop)
				bu.selectedTex:SetVertexColor(r, g, b, .2)

				bu.icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(bu.icon)

				bu.styled = true
			end
		end
	end)

	ClassTrainerStatusBarLeft:Hide()
	ClassTrainerStatusBarMiddle:Hide()
	ClassTrainerStatusBarRight:Hide()
	ClassTrainerStatusBarBackground:Hide()
	ClassTrainerStatusBar:SetPoint("TOPLEFT", ClassTrainerFrame, "TOPLEFT", 64, -35)
	ClassTrainerStatusBar:SetStatusBarTexture(C.media.backdrop)
	ClassTrainerStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	F.CreateBDFrame(ClassTrainerStatusBar, .25)

	F.ReskinPortraitFrame(ClassTrainerFrame, true)
	F.Reskin(ClassTrainerTrainButton)
	F.ReskinScroll(ClassTrainerScrollFrameScrollBar)
	F.ReskinDropDown(ClassTrainerFrameFilterDropDown)
end