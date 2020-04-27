local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local QuestMapFrame = QuestMapFrame

	-- [[ Quest scroll frame ]]

	local QuestScrollFrame = QuestScrollFrame
	local campaignHeader = QuestScrollFrame.Contents.WarCampaignHeader
	local StoryHeader = QuestScrollFrame.Contents.StoryHeader

	QuestMapFrame.VerticalSeparator:SetAlpha(0)
	QuestScrollFrame.Background:SetAlpha(0)
	QuestScrollFrame.DetailFrame.TopDetail:SetAlpha(0)
	QuestScrollFrame.DetailFrame.BottomDetail:SetAlpha(0)
	QuestScrollFrame.Contents.Separator:SetAlpha(0)

	B.ReskinScroll(QuestScrollFrame.ScrollBar)

	for _, header in next, {campaignHeader, StoryHeader} do
		header.Background:SetAlpha(0)
		header.HighlightTexture:Hide()
		header.Text:SetPoint("TOPLEFT", 15, -20)

		local bg = B.CreateBDFrame(header, .25)
		bg:SetPoint("TOPLEFT", 0, -14)
		bg:SetPoint("BOTTOMRIGHT", -4, 5)
		if header == campaignHeader then
			local newTex = bg:CreateTexture(nil, "OVERLAY")
			newTex:SetPoint("TOPRIGHT", -25, 3)
			newTex:SetSize(50, 50)
			newTex:SetBlendMode("ADD")
			newTex:SetAlpha(0)
			header.newTex = newTex
		end

		header:HookScript("OnEnter", function()
			bg:SetBackdropColor(r, g, b, .25)
		end)
		header:HookScript("OnLeave", function()
			bg:SetBackdropColor(0, 0, 0, .25)
		end)
	end

	local idToTexture = {
		[261] = "Interface\\Timer\\Alliance-Logo",
		[262] = "Interface\\Timer\\Horde-Logo",
	}
	local function UpdateCampaignHeader()
		campaignHeader.newTex:SetAlpha(0)
		if campaignHeader:IsShown() then
			local campaignID = C_CampaignInfo.GetCurrentCampaignID()
			if campaignID then
				local warCampaignInfo = C_CampaignInfo.GetCampaignInfo(campaignID)
				local textureID = warCampaignInfo.uiTextureKitID
				if textureID and idToTexture[textureID] then
					campaignHeader.newTex:SetTexture(idToTexture[textureID])
					campaignHeader.newTex:SetAlpha(.7)
				end
			end
		end
	end

	-- [[ Quest details ]]

	local DetailsFrame = QuestMapFrame.DetailsFrame
	local RewardsFrame = DetailsFrame.RewardsFrame
	local CompleteQuestFrame = DetailsFrame.CompleteQuestFrame

	B.StripTextures(DetailsFrame)
	select(6, DetailsFrame.ShareButton:GetRegions()):SetAlpha(0)
	select(7, DetailsFrame.ShareButton:GetRegions()):SetAlpha(0)
	DetailsFrame.SealMaterialBG:SetAlpha(0)

	B.Reskin(DetailsFrame.BackButton)
	B.Reskin(DetailsFrame.AbandonButton)
	B.Reskin(DetailsFrame.ShareButton)
	B.Reskin(DetailsFrame.TrackButton)
	B.ReskinScroll(QuestMapDetailsScrollFrameScrollBar)

	DetailsFrame.AbandonButton:ClearAllPoints()
	DetailsFrame.AbandonButton:SetPoint("BOTTOMLEFT", DetailsFrame, -1, 0)
	DetailsFrame.AbandonButton:SetWidth(95)

	DetailsFrame.ShareButton:ClearAllPoints()
	DetailsFrame.ShareButton:SetPoint("LEFT", DetailsFrame.AbandonButton, "RIGHT", 1, 0)
	DetailsFrame.ShareButton:SetWidth(94)

	DetailsFrame.TrackButton:ClearAllPoints()
	DetailsFrame.TrackButton:SetPoint("LEFT", DetailsFrame.ShareButton, "RIGHT", 1, 0)
	DetailsFrame.TrackButton:SetWidth(96)

	-- Rewards frame

	RewardsFrame.Background:SetAlpha(0)
	select(2, RewardsFrame:GetRegions()):SetAlpha(0)

	-- Scroll frame

	hooksecurefunc("QuestLogQuests_Update", function()
		UpdateCampaignHeader()

		for i = 6, QuestMapFrame.QuestsFrame.Contents:GetNumChildren() do
			local child = select(i, QuestMapFrame.QuestsFrame.Contents:GetChildren())
			if child.ButtonText then
				if not child.styled then
					B.ReskinExpandOrCollapse(child)
					child.styled = true
				end
				child:SetHighlightTexture("")
			end
		end
	end)

	-- Complete quest frame
	CompleteQuestFrame:GetRegions():SetAlpha(0)
	select(2, CompleteQuestFrame:GetRegions()):SetAlpha(0)
	select(6, CompleteQuestFrame.CompleteButton:GetRegions()):SetAlpha(0)
	select(7, CompleteQuestFrame.CompleteButton:GetRegions()):SetAlpha(0)

	B.Reskin(CompleteQuestFrame.CompleteButton)

	-- [[ Quest log popup detail frame ]]

	local QuestLogPopupDetailFrame = QuestLogPopupDetailFrame

	B.ReskinPortraitFrame(QuestLogPopupDetailFrame)
	B.ReskinScroll(QuestLogPopupDetailFrameScrollFrameScrollBar)
	B.Reskin(QuestLogPopupDetailFrame.AbandonButton)
	B.Reskin(QuestLogPopupDetailFrame.TrackButton)
	B.Reskin(QuestLogPopupDetailFrame.ShareButton)

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
		self.Text:SetTextColor(GameFontHighlight:GetTextColor())
	end)

	ShowMapButton:HookScript("OnLeave", function(self)
		self.Text:SetTextColor(GameFontNormal:GetTextColor())
	end)

	-- Bottom buttons

	QuestLogPopupDetailFrame.ShareButton:ClearAllPoints()
	QuestLogPopupDetailFrame.ShareButton:SetPoint("LEFT", QuestLogPopupDetailFrame.AbandonButton, "RIGHT", 1, 0)
	QuestLogPopupDetailFrame.ShareButton:SetPoint("RIGHT", QuestLogPopupDetailFrame.TrackButton, "LEFT", -1, 0)

	-- Party Sync button

	local sessionManagement = QuestMapFrame.QuestSessionManagement
	sessionManagement.BG:Hide()
	B.CreateBDFrame(sessionManagement, .25)

	local function reskinSessionDialog(_, dialog)
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
	hooksecurefunc(QuestSessionManager, "NotifyDialogShow", reskinSessionDialog)

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
		self.ExecuteSessionCommand:SetNormalTexture("")
		self.ExecuteSessionCommand:SetPushedTexture("")
		self.ExecuteSessionCommand:SetDisabledTexture("")

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			self.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)
end)