local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

--[[
	一个工具条用来替代系统的经验条、声望条、神器经验等等
]]
local format, pairs, select = string.format, pairs, select
local min, mod, floor = math.min, mod, math.floor
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local REPUTATION_PROGRESS_FORMAT = REPUTATION_PROGRESS_FORMAT
local HONOR, LEVEL, TUTORIAL_TITLE26, SPELLBOOK_AVAILABLE_AT = HONOR, LEVEL, TUTORIAL_TITLE26, SPELLBOOK_AVAILABLE_AT
local ARTIFACT_POWER, ARTIFACT_RETIRED = ARTIFACT_POWER, ARTIFACT_RETIRED

local UnitLevel, UnitXP, UnitXPMax, GetXPExhaustion, IsXPUserDisabled = UnitLevel, UnitXP, UnitXPMax, GetXPExhaustion, IsXPUserDisabled
local BreakUpLargeNumbers, GetNumFactions, GetFactionInfo = BreakUpLargeNumbers, GetNumFactions, GetFactionInfo
local HasArtifactEquipped, ArtifactBarGetNumArtifactTraitsPurchasableFromXP = HasArtifactEquipped, ArtifactBarGetNumArtifactTraitsPurchasableFromXP
local IsWatchingHonorAsXP, UnitHonor, UnitHonorMax, UnitHonorLevel = IsWatchingHonorAsXP, UnitHonor, UnitHonorMax, UnitHonorLevel
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local C_GossipInfo_GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks

function M:ExpBar_Update()
	local rest = self.restBar
	if rest then rest:Hide() end

	local factionData = C_Reputation.GetWatchedFactionData()

	if not IsPlayerAtEffectiveMaxLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self:SetStatusBarColor(0, .7, 1)
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:Show()
		if rxp then
			rest:SetMinMaxValues(0, mxp)
			rest:SetValue(min(xp + rxp, mxp))
			rest:Show()
		end
		if IsXPUserDisabled() then self:SetStatusBarColor(.7, 0, 0) end
	elseif factionData then
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		if C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			currentValue = mod(currentValue, threshold)
			barMin, barMax, value = 0, threshold, currentValue
		elseif factionID and C_Reputation_IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
			if isMaxRenown then
				barMin, barMax, value = 0, 1, 1
			else
				value = majorFactionData.renownReputationEarned or 0
				barMin, barMax = 0, majorFactionData.renownLevelThreshold
			end
		else
			local repInfo = C_GossipInfo_GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			if friendID and friendID ~= 0 then
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMin, barMax, value = 0, 1, 1
				end
				standing = 5
			else
				if standing == MAX_REPUTATION_REACTION then barMin, barMax, value = 0, 1, 1 end
			end
		end
		local color = FACTION_BAR_COLORS[standing] or FACTION_BAR_COLORS[5]
		self:SetStatusBarColor(color.r, color.g, color.b, .85)
		self:SetMinMaxValues(barMin, barMax)
		self:SetValue(value)
		self:Show()
	else
		self:Hide()
	end
end

function M:ExpBar_UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)

	if not IsPlayerAtEffectiveMaxLevel() then
		GameTooltip:AddLine(" ")
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddDoubleLine(XP..":", BreakUpLargeNumbers(xp).." / "..BreakUpLargeNumbers(mxp).." ("..format("%.1f%%)", xp/mxp*100), .6,.8,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", "+"..BreakUpLargeNumbers(rxp).." ("..format("%.1f%%)", rxp/mxp*100), .6,.8,1, 1,1,1)
		end
		if IsXPUserDisabled() then GameTooltip:AddLine("|cffff0000"..XP..LOCKED) end
	end

	local factionData = C_Reputation.GetWatchedFactionData()
	if factionData then
		local name = factionData.name
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		local standingtext
		if factionID and C_Reputation_IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			name = majorFactionData.name
			standingtext = format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

			local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
			if isMaxRenown then
				barMin, barMax, value = 0, 1, 1
			else
				value = majorFactionData.renownReputationEarned or 0
				barMin, barMax = 0, majorFactionData.renownLevelThreshold
			end
		else
			local repInfo = C_GossipInfo_GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			local repRankInfo = C_GossipInfo_GetFriendshipReputationRanks(factionID)
			local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
			if friendID and friendID ~= 0 then
				if maxRank > 0 then
					name = name.." ("..currentRank.." / "..maxRank..")"
				end
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = repInfo.reaction
			else
				if standing == MAX_REPUTATION_REACTION then
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,.6,1)
		GameTooltip:AddDoubleLine(standingtext, value - barMin.." / "..barMax - barMin.." ("..floor((value - barMin)/(barMax - barMin)*100).."%)", .6,.8,1, 1,1,1)

		if C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			local paraCount = floor(currentValue/threshold)
			currentValue = mod(currentValue, threshold)
			GameTooltip:AddDoubleLine(L["Paragon"]..paraCount, currentValue.." / "..threshold.." ("..floor(currentValue/threshold*100).."%)", .6,.8,1, 1,1,1)
		end
	end
	GameTooltip:Show()
end

function M:SetupScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"PLAYER_EQUIPMENT_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
	}
	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end
	bar:SetScript("OnEvent", M.ExpBar_Update)
	bar:SetScript("OnEnter", M.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", B.HideTooltip)
	bar:SetScript("OnMouseUp", function(_, btn)
		if not HasArtifactEquipped() or btn ~= "LeftButton" then return end
		if not ArtifactFrame or not ArtifactFrame:IsShown() then
			SocketInventoryItem(16)
		else
			B:TogglePanel(ArtifactFrame)
		end
	end)
	hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
		M.ExpBar_Update(bar)
	end)

	-- Housing, fixme: unable to toggle on without reload
	M.houseLevelFavor = nil
	B:RegisterEvent("TRACKED_HOUSE_CHANGED", function()
		M.ExpBar_Update(bar)
	end)
	B:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED", function(_, houseLevelFavor)
		if houseLevelFavor.houseGUID == C_Housing.GetTrackedHouseGuid() then
			M.houseLevelFavor = houseLevelFavor
			M.ExpBar_Update(bar)
		end
	end)
	if C_Housing.GetTrackedHouseGuid() then
		C_Housing.GetCurrentHouseLevelFavor(C_Housing.GetTrackedHouseGuid())
	end
end

function M:Expbar()
	if C.db["Map"]["DisableMinimap"] then return end
	if not C.db["Misc"]["ExpRep"] then return end

	local bar = CreateFrame("StatusBar", "NDuiExpRepBar", MinimapCluster)
	bar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 5, -5)
	bar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -5, -5)
	bar:SetHeight(5)
	bar:SetHitRectInsets(0, 0, 0, -10)
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	M:SetupScript(bar)
end
M:RegisterMisc("ExpRep", M.Expbar)

-- Paragon reputation info
function M:ParagonReputationSetup()
	if not C.db["Misc"]["ParagonRep"] then return end

	hooksecurefunc("ReputationFrame_InitReputationRow", function(factionRow, elementData)
		local factionID = factionRow.factionID
		local factionContainer = factionRow.Container
		local factionBar = factionContainer.ReputationBar
		local factionStanding = factionBar.FactionStanding

		if factionContainer.Paragon:IsShown() then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue then
				local barValue = mod(currentValue, threshold)
				local factionStandingtext = L["Paragon"]..floor(currentValue/threshold)

				factionBar:SetMinMaxValues(0, threshold)
				factionBar:SetValue(barValue)
				factionStanding:SetText(factionStandingtext)
				factionRow.standingText = factionStandingtext
				factionRow.rolloverText = format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(threshold))
			end
		end
	end)
end
--M:RegisterMisc("ParagonRep", M.ParagonReputationSetup)