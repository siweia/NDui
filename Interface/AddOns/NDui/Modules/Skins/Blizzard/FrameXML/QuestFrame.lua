local _, ns = ...
local B, C, L, DB = unpack(ns)

local function UpdateProgressItemQuality(self)
	local button = self.__owner
	local index = button:GetID()
	local buttonType = button.type
	local objectType = button.objectType

	local quality
	if objectType == "item" then
		quality = select(4, GetQuestItemInfo(buttonType, index))
	elseif objectType == "currency" then
		quality = select(4, GetQuestCurrencyInfo(buttonType, index))
	end

	local color = DB.QualityColors[quality or 1]
	button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function UpdateQuestItemQuality(self)
	local button = self.__owner
	local index = button:GetID()
	local itemName, _, _, quality = GetQuestLogRewardInfo(index)
	if not itemName then
		itemName, _, _, quality = GetQuestLogChoiceInfo(index)
	end
	if not itemName then
		itemName = GetQuestLogRewardSpell(index)
		quality = 1
	end
	if itemName and quality then
		local color = DB.QualityColors[quality]
		button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

local function ReskinQuestItem(button)
	button.NameFrame:Hide()
	local icon = button.Icon
	icon.__owner = button
	button.bg = B.ReskinIcon(icon)

	local bg = B.CreateBDFrame(button, .25)
	bg:SetPoint("TOPLEFT", button.bg, "TOPRIGHT", 2, 0)
	bg:SetPoint("BOTTOMRIGHT", button.bg, 100, 0)
end

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(QuestFrame, 15, -15, -30, 65)

	B.StripTextures(QuestFrameDetailPanel)
	B.StripTextures(QuestFrameRewardPanel)
	B.StripTextures(QuestFrameProgressPanel)
	B.StripTextures(QuestFrameGreetingPanel)
	B.StripTextures(EmptyQuestLogFrame)

	hooksecurefunc("QuestFrame_SetMaterial", function(frame)
		_G[frame:GetName().."MaterialTopLeft"]:Hide()
		_G[frame:GetName().."MaterialTopRight"]:Hide()
		_G[frame:GetName().."MaterialBotLeft"]:Hide()
		_G[frame:GetName().."MaterialBotRight"]:Hide()
	end)

	local line = QuestFrameGreetingPanel:CreateTexture()
	line:SetColorTexture(1, 1, 1, .25)
	line:SetSize(256, C.mult)
	line:SetPoint("CENTER", QuestGreetingFrameHorizontalBreak)
	QuestGreetingFrameHorizontalBreak:SetTexture("")
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		line:SetShown(QuestGreetingFrameHorizontalBreak:IsShown())
	end)

	for i = 1, MAX_REQUIRED_ITEMS do
		local button = _G["QuestProgressItem"..i]
		ReskinQuestItem(button)
		hooksecurefunc(button.Icon, "SetTexture", UpdateProgressItemQuality)
	end

	QuestDetailScrollFrame:SetWidth(302) -- else these buttons get cut off

	hooksecurefunc(QuestProgressRequiredMoneyText, "SetTextColor", function(self, r)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	B.Reskin(QuestFrameAcceptButton)
	B.Reskin(QuestFrameDeclineButton)
	B.Reskin(QuestFrameCompleteQuestButton)
	B.Reskin(QuestFrameCancelButton)
	B.Reskin(QuestFrameCompleteButton)
	B.Reskin(QuestFrameGoodbyeButton)
	B.Reskin(QuestFrameGreetingGoodbyeButton)

	B.ReskinScroll(QuestProgressScrollFrameScrollBar)
	B.ReskinScroll(QuestRewardScrollFrameScrollBar)
	B.ReskinScroll(QuestDetailScrollFrameScrollBar)
	B.ReskinScroll(QuestGreetingScrollFrameScrollBar)

	-- Text colour stuff

	QuestProgressRequiredItemsText:SetTextColor(1, .8, 0)
	QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText:SetTextColor(1, .8, 0)
	QuestProgressTitleText:SetShadowColor(0, 0, 0)
	QuestProgressTitleText.SetTextColor = B.Dummy
	QuestProgressText:SetTextColor(1, 1, 1)
	QuestProgressText.SetTextColor = B.Dummy
	GreetingText:SetTextColor(1, 1, 1)
	GreetingText.SetTextColor = B.Dummy
	AvailableQuestsText:SetTextColor(1, .8, 0)
	AvailableQuestsText.SetTextColor = B.Dummy
	AvailableQuestsText:SetShadowColor(0, 0, 0)
	CurrentQuestsText:SetTextColor(1, .8, 0)
	CurrentQuestsText.SetTextColor = B.Dummy
	CurrentQuestsText:SetShadowColor(0, 0, 0)

	-- Quest NPC model

	B.StripTextures(QuestNPCModel)
	B.SetBD(QuestNPCModel)
	B.StripTextures(QuestNPCModelTextFrame)
	B.SetBD(QuestNPCModelTextFrame)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, _, x, y)
		x = x + 6
		QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y)
	end)

	B.ReskinScroll(QuestNPCModelTextScrollFrameScrollBar)

	-- QuestLogFrame

	QuestLogQuestTitle:SetTextColor(1, .8, 0)
	QuestLogDescriptionTitle:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText:SetTextColor(1, .8, 0)
	QuestLogRewardTitleText.SetTextColor = B.Dummy
	QuestLogItemReceiveText:SetTextColor(1, 1, 1)
	QuestLogItemReceiveText.SetTextColor = B.Dummy
	QuestLogItemChooseText:SetTextColor(1, 1, 1)
	QuestLogItemChooseText.SetTextColor = B.Dummy
	QuestLogTimerText:SetTextColor(1, .8, 0)
	QuestLogTimerText.SetTextColor = B.Dummy
	for i = 1, 10 do
		local text = _G["QuestLogObjective"..i]
		text:SetTextColor(1, 1, 1)
		text.SetTextColor = B.Dummy
	end

	B.ReskinPortraitFrame(QuestLogFrame, 10, -10, -30, 45)
	B.Reskin(QuestLogFrameAbandonButton)
	B.Reskin(QuestFramePushQuestButton)
	B.Reskin(QuestFrameExitButton)
	B.ReskinScroll(QuestLogDetailScrollFrameScrollBar)
	B.ReskinScroll(QuestLogListScrollFrameScrollBar)

	B.ReskinCollapse(QuestLogCollapseAllButton)
	QuestLogCollapseAllButton:DisableDrawLayer("BACKGROUND")

	B.StripTextures(QuestLogTrack)
	QuestLogTrack:SetSize(8, 8)
	QuestLogTrackTitle:SetPoint("LEFT", QuestLogTrack, "RIGHT", 3, 0)
	QuestLogTrackTracking:SetTexture(DB.bdTex)
	B.CreateBDFrame(QuestLogTrackTracking)

	hooksecurefunc("QuestLog_Update", function()
		for i = 1, QUESTS_DISPLAYED, 1 do
			local bu = _G["QuestLogTitle"..i]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu.styled = true
			end
		end
	end)

	for i = 1, 10 do
		local button = _G["QuestLogItem"..i]
		ReskinQuestItem(button)
		hooksecurefunc(button.Icon, "SetTexture", UpdateQuestItemQuality)
	end

	C_Timer.After(3, function()
		if CodexQuestShow then
			B.Reskin(CodexQuestShow)
			B.Reskin(CodexQuestHide)
			B.Reskin(CodexQuestReset)
		end

		-- Check all buttons
		for i = 1, QuestLogDetailScrollChildFrame:GetNumChildren() do
			local child = select(i, QuestLogDetailScrollChildFrame:GetChildren())
			if child:IsObjectType("Button") and child.Text and not child.__bg then
				B.Reskin(child)
			end
		end
	end)

	-- QuestTimerFrame

	B.StripTextures(QuestTimerFrame)
	B.SetBD(QuestTimerFrame)
end)