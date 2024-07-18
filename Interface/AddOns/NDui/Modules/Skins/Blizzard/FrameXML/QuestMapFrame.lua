local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinQuestHeader(header, isCalling)
	if header.styled then return end

	if header.Background then header.Background:SetAlpha(.7) end
	if header.Divider then header.Divider:Hide() end
	if header.TopFiligree then header.TopFiligree:Hide() end

	if not DB.isWW then
		local collapseButton = isCalling and header or header.CollapseButton
		if collapseButton then
			collapseButton:GetPushedTexture():SetAlpha(0)
			collapseButton:GetHighlightTexture():SetAlpha(0)
			B.ReskinCollapse(collapseButton, true)
			collapseButton.bg:SetFrameLevel(6)
		end
	end

	header.styled = true
end

local function ReskinSessionDialog(_, dialog)
	if not dialog.styled then
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.Reskin(dialog.ButtonContainer.Confirm)
		B.Reskin(dialog.ButtonContainer.Decline)
		if dialog.MinimizeButton then
			B.ReskinArrow(dialog.MinimizeButton, "down")
		end

		dialog.styled = true
	end
end

local function ReskinAWQHeader()
	if C_AddOns.IsAddOnLoaded("AngrierWorldQuests") then
		local button = _G["AngrierWorldQuestsHeader"]
		if button and not button.styled then
			B.ReskinCollapse(button, true)
			button:GetPushedTexture():SetAlpha(0)
			button:GetHighlightTexture():SetAlpha(0)

			button.styled = true
		end
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Quest frame

	local QuestMapFrame = QuestMapFrame
	QuestMapFrame.VerticalSeparator:SetAlpha(0)

	local QuestScrollFrame = QuestScrollFrame
	QuestScrollFrame.Contents.Separator:SetAlpha(0)
	ReskinQuestHeader(QuestScrollFrame.Contents.StoryHeader)

	if DB.isWW then
		QuestScrollFrame.Background:SetAlpha(0)
		B.StripTextures(QuestScrollFrame.BorderFrame)
		B.StripTextures(QuestMapFrame.DetailsFrame.BackFrame)
	else
		QuestMapFrame.Background:SetAlpha(0)
		QuestScrollFrame.DetailFrame.TopDetail:SetAlpha(0)
		QuestScrollFrame.DetailFrame.BottomDetail:SetAlpha(0)
	end

	local campaignOverview = QuestMapFrame.CampaignOverview
	campaignOverview.BG:SetAlpha(0)
	ReskinQuestHeader(campaignOverview.Header)

	QuestScrollFrame.Edge:Hide()
	B.ReskinTrimScroll(QuestScrollFrame.ScrollBar)
	B.ReskinTrimScroll(campaignOverview.ScrollFrame.ScrollBar)
	if DB.isWW then
		B.ReskinEditBox(QuestScrollFrame.SearchBox)
	end

	-- Quest details

	local DetailsFrame = QuestMapFrame.DetailsFrame
	local CompleteQuestFrame = DetailsFrame.CompleteQuestFrame

	B.StripTextures(DetailsFrame)
	B.StripTextures(DetailsFrame.ShareButton)
	DetailsFrame.Bg:SetAlpha(0)
	DetailsFrame.SealMaterialBG:SetAlpha(0)

	B.Reskin(DetailsFrame.AbandonButton)
	B.Reskin(DetailsFrame.ShareButton)
	B.Reskin(DetailsFrame.TrackButton)
	B.ReskinTrimScroll(QuestMapDetailsScrollFrame.ScrollBar)

	if DB.isWW then
		B.Reskin(DetailsFrame.BackFrame.BackButton)
		B.StripTextures(DetailsFrame.RewardsFrameContainer.RewardsFrame)
	else
		B.StripTextures(DetailsFrame.RewardsFrame)
		B.Reskin(DetailsFrame.BackButton)
	end

	DetailsFrame.AbandonButton:ClearAllPoints()
	DetailsFrame.AbandonButton:SetPoint("BOTTOMLEFT", DetailsFrame, -1, 0)
	DetailsFrame.AbandonButton:SetWidth(95)

	DetailsFrame.ShareButton:ClearAllPoints()
	DetailsFrame.ShareButton:SetPoint("LEFT", DetailsFrame.AbandonButton, "RIGHT", 1, 0)
	DetailsFrame.ShareButton:SetWidth(94)

	DetailsFrame.TrackButton:ClearAllPoints()
	DetailsFrame.TrackButton:SetPoint("LEFT", DetailsFrame.ShareButton, "RIGHT", 1, 0)
	DetailsFrame.TrackButton:SetWidth(96)

	-- Scroll frame

	hooksecurefunc("QuestLogQuests_Update", function()
		for button in QuestScrollFrame.headerFramePool:EnumerateActive() do
			if button.ButtonText then
				if not button.styled then
					if DB.isWW then
						B.StripTextures(button)
						B.CreateBDFrame(button, .25)
						button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					else
						B.ReskinCollapse(button, true)
						button:GetPushedTexture():SetAlpha(0)
						button:GetHighlightTexture():SetAlpha(0)
					end

					button.styled = true
				end
			end
		end

		for button in QuestScrollFrame.titleFramePool:EnumerateActive() do
			if not button.styled then
				if button.Checkbox then
					B.StripTextures(button.Checkbox, 2)
					B.CreateBDFrame(button.Checkbox, 0, true)
				end
				if button.Check then -- isWW removed?
					button.Check:SetAtlas("checkmark-minimal")
				end
				button.styled = true
			end
		end

		for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
			ReskinQuestHeader(header)
		end

		for header in QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
			if DB.isWW then
				if header.CollapseButton and not header.styled then
					B.StripTextures(header)
					B.CreateBDFrame(header.Background, .25)
					header.Highlight:SetColorTexture(1, 1, 1, .25)
					header.styled = true
				end
			else
				ReskinQuestHeader(header)
			end
		end

		for header in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
			ReskinQuestHeader(header, true)
		end

		ReskinAWQHeader()
	end)

	-- Complete quest frame
	if not DB.isWW then
		B.StripTextures(CompleteQuestFrame)
		B.StripTextures(CompleteQuestFrame.CompleteButton)
		B.Reskin(CompleteQuestFrame.CompleteButton)
	end

	-- Map legend
	local mapLegend = QuestMapFrame.MapLegend
	if mapLegend then
		B.StripTextures(mapLegend.BorderFrame)
		B.Reskin(mapLegend.BackButton)
		B.ReskinTrimScroll(mapLegend.ScrollFrame.ScrollBar)
		B.StripTextures(mapLegend.ScrollFrame)
		B.CreateBDFrame(mapLegend.ScrollFrame, .25)
	end

	-- [[ Quest log popup detail frame ]]

	local QuestLogPopupDetailFrame = QuestLogPopupDetailFrame

	B.ReskinPortraitFrame(QuestLogPopupDetailFrame)
	B.Reskin(QuestLogPopupDetailFrame.AbandonButton)
	B.Reskin(QuestLogPopupDetailFrame.TrackButton)
	B.Reskin(QuestLogPopupDetailFrame.ShareButton)
	QuestLogPopupDetailFrame.SealMaterialBG:SetAlpha(0)
	B.ReskinTrimScroll(QuestLogPopupDetailFrameScrollFrame.ScrollBar)

	-- Show map button

	local ShowMapButton = QuestLogPopupDetailFrame.ShowMapButton

	ShowMapButton.Texture:SetAlpha(0)
	ShowMapButton.Highlight:SetTexture("")
	ShowMapButton.Highlight:SetTexture("")

	ShowMapButton:SetSize(ShowMapButton.Text:GetStringWidth() + 14, 22)
	ShowMapButton.Text:ClearAllPoints()
	ShowMapButton.Text:SetPoint("CENTER", 1, 0)

	ShowMapButton:ClearAllPoints()
	ShowMapButton:SetPoint("TOPRIGHT", QuestLogPopupDetailFrame, -30, -25)

	B.Reskin(ShowMapButton)

	ShowMapButton:HookScript("OnEnter", function(self)
		self.Text:SetTextColor(1, 1, 1)
	end)

	ShowMapButton:HookScript("OnLeave", function(self)
		self.Text:SetTextColor(1, .8, 0)
	end)

	-- Bottom buttons

	QuestLogPopupDetailFrame.ShareButton:ClearAllPoints()
	QuestLogPopupDetailFrame.ShareButton:SetPoint("LEFT", QuestLogPopupDetailFrame.AbandonButton, "RIGHT", 1, 0)
	QuestLogPopupDetailFrame.ShareButton:SetPoint("RIGHT", QuestLogPopupDetailFrame.TrackButton, "LEFT", -1, 0)

	-- Party Sync button

	local sessionManagement = QuestMapFrame.QuestSessionManagement
	sessionManagement.BG:Hide()
	B.CreateBDFrame(sessionManagement, .25)

	hooksecurefunc(QuestSessionManager, "NotifyDialogShow", ReskinSessionDialog)

	local executeSessionCommand = sessionManagement.ExecuteSessionCommand
	B.Reskin(executeSessionCommand)

	local icon = executeSessionCommand:CreateTexture(nil, "ARTWORK")
	icon:SetInside()
	executeSessionCommand.normalIcon = icon

	local sessionCommandToButtonAtlas = {
		[_G.Enum.QuestSessionCommand.Start] = "QuestSharing-DialogIcon",
		[_G.Enum.QuestSessionCommand.Stop] = "QuestSharing-Stop-DialogIcon"
	}

	hooksecurefunc(QuestMapFrame.QuestSessionManagement, "UpdateExecuteCommandAtlases", function(self, command)
		self.ExecuteSessionCommand:SetNormalTexture(0)
		self.ExecuteSessionCommand:SetPushedTexture(0)
		self.ExecuteSessionCommand:SetDisabledTexture(0)

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			self.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)
end)