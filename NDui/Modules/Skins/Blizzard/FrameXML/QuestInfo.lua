local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function clearHighlight()
	for _, button in pairs(QuestInfoRewardsFrame.RewardButtons) do
		button.textBg:SetBackdropColor(0, 0, 0, .25)
	end
end

local function setHighlight(self)
	clearHighlight()

	local _, point = self:GetPoint()
	if point then
		point.textBg:SetBackdropColor(r, g, b, .25)
	end
end

local function colourObjectivesText()
	if not QuestInfoFrame.questLog then return end

	local objectivesTable = QuestInfoObjectivesFrame.Objectives
	local numVisibleObjectives = 0

	for i = 1, GetNumQuestLeaderBoards() do
		local _, type, finished = GetQuestLogLeaderBoard(i)

		if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
			numVisibleObjectives = numVisibleObjectives + 1
			local objective = objectivesTable[numVisibleObjectives]

			if objective then
				if finished then
					objective:SetTextColor(.9, .9, .9)
				else
					objective:SetTextColor(1, 1, 1)
				end
			end
		end
	end
end

local function restyleSpellButton(bu)
	local name = bu:GetName()
	local icon = bu.Icon

	_G[name.."NameFrame"]:Hide()

	icon:SetPoint("TOPLEFT", 3, -2)
	B.ReskinIcon(icon)

	local bg = B.CreateBDFrame(bu, .25)
	bg:SetPoint("TOPLEFT", 2, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 14)
end

local function ReskinRewardButton(bu)
	if bu.NameFrame then bu.NameFrame:SetAlpha(0) end
	if bu.IconBorder then bu.IconBorder:SetAlpha(0) end
	bu.bg = B.ReskinIcon(bu.Icon)

	local bg = B.CreateBDFrame(bu, .25)
	bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 2, 0)
	bg:SetPoint("BOTTOMRIGHT", bu.bg, 100, 0)
	bu.textBg = bg
end

local function ReskinRewardButtonWithSize(bu, isMapQuestInfo)
	ReskinRewardButton(bu)

	if isMapQuestInfo then
		bu.Icon:SetSize(29, 29)
	else
		bu.Icon:SetSize(34, 34)
	end
end

local function HookTextColor_Yellow(self, r, g, b)
	if r ~= 1 or g ~= .8 or b ~= 0 then
		self:SetTextColor(1, .8, 0)
	end
end

local function SetTextColor_Yellow(font)
	font:SetShadowColor(0, 0, 0, 0)
	font:SetTextColor(1, .8, 0)
	hooksecurefunc(font, "SetTextColor", HookTextColor_Yellow)
end

local function HookTextColor_White(self, r, g, b)
	if r ~= 1 or g ~= 1 or b ~= 1 then
		self:SetTextColor(1, 1, 1)
	end
end

local function SetTextColor_White(font)
	font:SetShadowColor(0, 0, 0)
	font:SetTextColor(1, 1, 1)
	hooksecurefunc(font, "SetTextColor", HookTextColor_White)
end

tinsert(C.defaultThemes, function()
	-- Item reward highlight
	QuestInfoItemHighlight:GetRegions():Hide()
	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", setHighlight)
	QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

	-- Reskin rewards
	restyleSpellButton(QuestInfoSpellObjectiveFrame) -- needs review

	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local bu = rewardsFrame.RewardButtons[index]
		if not bu.restyled then
			ReskinRewardButtonWithSize(bu, rewardsFrame == MapQuestInfoRewardsFrame)
			B.ReskinIconBorder(bu.IconBorder)

			bu.restyled = true
		end
	end)

	MapQuestInfoRewardsFrame.XPFrame.Name:SetShadowOffset(0, 0)
	for _, name in next, {"HonorFrame", "MoneyFrame", "SkillPointFrame", "XPFrame", "ArtifactXPFrame", "TitleFrame"} do
		ReskinRewardButtonWithSize(MapQuestInfoRewardsFrame[name], true)
	end

	--for _, name in next, {"HonorFrame", "SkillPointFrame", "ArtifactXPFrame"} do
	for _, name in next, {"SkillPointFrame", "ArtifactXPFrame"} do -- don't handle honor frame, needs review
		ReskinRewardButtonWithSize(QuestInfoRewardsFrame[name])
	end

	-- Title Reward, needs review
	do
		local frame = QuestInfoPlayerTitleFrame
		for i = 2, 4 do
			select(i, frame:GetRegions()):Hide()
		end

		local icon = frame.Icon or QuestInfoPlayerTitleFrameIconTexture
		if icon then
			B.ReskinIcon(icon)
			local bg = B.CreateBDFrame(frame, .25)
			bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 2)
			bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 220, -1)
		end
	end

	-- Others
	hooksecurefunc("QuestInfo_Display", function()
		colourObjectivesText()

        local rewardsFrame = QuestInfoFrame.rewardsFrame
        local isQuestLog = QuestInfoFrame.questLog ~= nil
		local questID = QuestInfoFrame.questLog and GetQuestLogSelectedID() or GetQuestID()
		local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}

		if #spellRewards > 0 then
			-- Spell Headers
			for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
				spellHeader:SetVertexColor(1, 1, 1)
			end
			-- Spell Rewards
			for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
				if not spellReward.styled then
					ReskinRewardButton(spellReward)

					spellReward.styled = true
				end
			end
		end
	end)

	-- Change text colors
	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", function(self, r)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	local yellowish = {
		QuestInfoTitleHeader,
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader,
		QuestInfoRewardsFrame.Header,
	}
	for _, font in pairs(yellowish) do
		SetTextColor_Yellow(font)
	end

	local whitish = {
		QuestInfoDescriptionText,
		QuestInfoObjectivesText,
		QuestInfoGroupSize,
		QuestInfoRewardText,
		QuestInfoSpellObjectiveLearnLabel,
		QuestInfoRewardsFrame.ItemChooseText,
		QuestInfoRewardsFrame.ItemReceiveText,
		QuestInfoRewardsFrame.PlayerTitleText,
		QuestInfoRewardsFrame.XPFrame.ReceiveText,
		QuestInfoTalentFrame.ReceiveText,
	}
	for _, font in pairs(whitish) do
		SetTextColor_White(font)
	end
end)