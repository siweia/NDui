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

local function QuestInfo_GetQuestID()
	if QuestInfoFrame.questLog then
		return C_QuestLog.GetSelectedQuest()
	else
		return GetQuestID()
	end
end

local defaultColor = GetMaterialTextColors("Default")
local completedColor = QUEST_OBJECTIVE_COMPLETED_FONT_COLOR:GetRGB()

local function ReplaceTextColor(object, r)
	if r == 0 or r == defaultColor[1] then
		object:SetTextColor(1, 1, 1)
	elseif r == completedColor then
		object:SetTextColor(.7, .7, .7)
	end
end

local function restyleSpellButton(bu)
	local name = bu:GetName()
	local icon = bu.Icon

	_G[name.."NameFrame"]:Hide()
	_G[name.."SpellBorder"]:Hide()

	icon:SetPoint("TOPLEFT", 3, -2)
	B.ReskinIcon(icon)

	local bg = B.CreateBDFrame(bu, .25)
	bg:SetPoint("TOPLEFT", 2, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 14)
end

local function ReskinRewardButton(bu)
	bu.NameFrame:Hide()
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
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Item reward highlight
	QuestInfoItemHighlight:GetRegions():Hide()
	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", setHighlight)
	QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

	-- Reskin rewards
	restyleSpellButton(QuestInfoSpellObjectiveFrame)

	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local bu = rewardsFrame.RewardButtons[index]
		if not bu.styled then
			ReskinRewardButtonWithSize(bu, rewardsFrame == MapQuestInfoRewardsFrame)
			B.ReskinIconBorder(bu.IconBorder)

			bu.styled = true
		end
	end)

	MapQuestInfoRewardsFrame.XPFrame.Name:SetShadowOffset(0, 0)
	for _, name in next, {"HonorFrame", "MoneyFrame", "SkillPointFrame", "XPFrame", "ArtifactXPFrame", "TitleFrame", "WarModeBonusFrame"} do
		ReskinRewardButtonWithSize(MapQuestInfoRewardsFrame[name], true)
	end

	for _, name in next, {"HonorFrame", "SkillPointFrame", "ArtifactXPFrame", "WarModeBonusFrame"} do
		ReskinRewardButtonWithSize(QuestInfoRewardsFrame[name])
	end

	-- Title Reward
	do
		local frame = QuestInfoPlayerTitleFrame
		local icon = frame.Icon

		B.ReskinIcon(icon)
		for i = 2, 4 do
			select(i, frame:GetRegions()):Hide()
		end
		local bg = B.CreateBDFrame(frame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 2)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 220, -1)
	end

	-- Others
	hooksecurefunc("QuestInfo_Display", function()
		local objectivesTable = QuestInfoObjectivesFrame.Objectives
		for i = #objectivesTable, 1, -1 do
			local object = objectivesTable[i]
			if object.hooked then break end
			object:SetTextColor(1, 1, 1)
			hooksecurefunc(object, "SetTextColor", ReplaceTextColor)

			object.hooked = true
		end

		local rewardsFrame = QuestInfoFrame.rewardsFrame
		local isQuestLog = QuestInfoFrame.questLog ~= nil
		local questID = isQuestLog and C_QuestLog.GetSelectedQuest() or GetQuestID()
		local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}

		if #spellRewards > 0 then
			-- Spell Headers
			for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
				spellHeader:SetVertexColor(1, 1, 1)
			end
			-- Follower Rewards
			for reward in rewardsFrame.followerRewardPool:EnumerateActive() do
				local portrait = reward.PortraitFrame
				if not reward.textBg then
					B.ReskinGarrisonPortrait(portrait)
					reward.BG:Hide()
					reward.textBg = B.CreateBDFrame(reward, .25)
				end

				if isQuestLog then
					portrait:SetPoint("TOPLEFT", 2, 0)
					reward.textBg:SetPoint("TOPLEFT", 0, 1)
					reward.textBg:SetPoint("BOTTOMRIGHT", 2, -3)
				else
					portrait:SetPoint("TOPLEFT", 2, -5)
					reward.textBg:SetPoint("TOPLEFT", 0, -3)
					reward.textBg:SetPoint("BOTTOMRIGHT", 2, 7)
				end

				if portrait then
					local color = DB.QualityColors[portrait.quality or 1]
					portrait.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end
			-- Spell Rewards
			for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
				if not spellReward.styled then
					ReskinRewardButton(spellReward)

					spellReward.styled = true
				end
			end
		end

		-- Reputation Rewards
		for repReward in rewardsFrame.reputationRewardPool:EnumerateActive() do
			if not repReward.styled then
				ReskinRewardButton(repReward)

				repReward.styled = true
			end
		end
	end)

	hooksecurefunc(QuestInfoQuestType, "SetTextColor", function(text, r, g, b)
		if not (r == 1 and g == 1 and b == 1) then
			text:SetTextColor(1, 1, 1)
		end
	end)

	-- Change text colors
	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", ReplaceTextColor)
	hooksecurefunc(QuestInfoSpellObjectiveLearnLabel, "SetTextColor", ReplaceTextColor)

	local yellowish = {
		QuestInfoTitleHeader,
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader,
		QuestInfoRewardsFrame.Header,
		QuestInfoAccountCompletedNotice,
	}
	for _, font in pairs(yellowish) do
		SetTextColor_Yellow(font)
	end

	local whitish = {
		QuestInfoDescriptionText,
		QuestInfoObjectivesText,
		QuestInfoGroupSize,
		QuestInfoRewardText,
		QuestInfoTimerText,
		QuestInfoRewardsFrame.ItemChooseText,
		QuestInfoRewardsFrame.ItemReceiveText,
		QuestInfoRewardsFrame.PlayerTitleText,
		QuestInfoRewardsFrame.XPFrame.ReceiveText,
	}
	for _, font in pairs(whitish) do
		SetTextColor_White(font)
	end

	-- Replace seal signature string
	local replacedSealColor = {
		["480404"] = "c20606",
		["042c54"] = "1c86ee",
	}
	hooksecurefunc(QuestInfoSealFrame.Text, "SetText", function(self, text)
		if text and text ~= "" then
			local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
			if colorStr and rawText then
				colorStr = replacedSealColor[colorStr] or "99ccff"
				self:SetFormattedText("|cff%s%s|r", colorStr, rawText)
			end
		end
	end)
end)