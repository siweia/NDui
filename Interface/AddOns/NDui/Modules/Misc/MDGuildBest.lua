local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local format, strsplit, tonumber, pairs, wipe = format, strsplit, tonumber, pairs, wipe
local Ambiguate = Ambiguate
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_ChallengeMode_GetGuildLeaders = C_ChallengeMode.GetGuildLeaders
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_WeeklyRewards_GetActivities = C_WeeklyRewards.GetActivities
local C_WeeklyRewards_GetExampleRewardItemHyperlinks = C_WeeklyRewards.GetExampleRewardItemHyperlinks
local CHALLENGE_MODE_POWER_LEVEL = CHALLENGE_MODE_POWER_LEVEL
local CHALLENGE_MODE_GUILD_BEST_LINE = CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local WEEKLY_REWARDS_MYTHIC, GREAT_VAULT_REWARDS, UNKNOWN = WEEKLY_REWARDS_MYTHIC, GREAT_VAULT_REWARDS, UNKNOWN
local WEEKLY_TYPE_RAID = Enum.WeeklyRewardChestThresholdType.Raid
local WEEKLY_TYPE_RANKED_PVP = Enum.WeeklyRewardChestThresholdType.RankedPvP
local WEEKLY_TYPE_MYTHIC_PLUS = Enum.WeeklyRewardChestThresholdType.MythicPlus

local hasAngryKeystones
local frame

function M:GuildBest_UpdateTooltip()
	local leaderInfo = self.leaderInfo
	if not leaderInfo then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
	for i = 1, #leaderInfo.members do
		local classColorStr = DB.ClassColors[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr,leaderInfo.members[i].name));
	end
	GameTooltip:Show()
end

function M:GuildBest_Create()
	frame = CreateFrame("Frame", nil, ChallengesFrame, "BackdropTemplate")
	frame:SetPoint("BOTTOMRIGHT", -8, 75)
	frame:SetSize(170, 105)
	B.CreateBD(frame, .25)
	B.CreateFS(frame, 16, GUILD, "system", "TOPLEFT", 16, -6)

	frame.entries = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame)
		entry:SetPoint("LEFT", 10, 0)
		entry:SetPoint("RIGHT", -10, 0)
		entry:SetHeight(18)
		entry.CharacterName = B.CreateFS(entry, 14, "", false, "LEFT", 6, 0)
		entry.CharacterName:SetPoint("RIGHT", -30, 0)
		entry.CharacterName:SetJustifyH("LEFT")
		entry.Level = B.CreateFS(entry, 14, "", "system")
		entry.Level:SetJustifyH("LEFT")
		entry.Level:ClearAllPoints()
		entry.Level:SetPoint("LEFT", entry, "RIGHT", -22, 0)
		entry:SetScript("OnEnter", self.GuildBest_UpdateTooltip)
		entry:SetScript("OnLeave", B.HideTooltip)
		if i == 1 then
			entry:SetPoint("TOP", frame, 0, -26)
		else
			entry:SetPoint("TOP", frame.entries[i-1], "BOTTOM")
		end

		frame.entries[i] = entry
	end

	if not hasAngryKeystones then
		ChallengesFrame.WeeklyInfo.Child.Description:SetPoint("CENTER", 0, 20)
	end
end

function M:GuildBest_SetUp(leaderInfo)
	self.leaderInfo = leaderInfo
	local str = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = DB.ClassColors[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
function M:GuildBest_Update()
	if not frame then M:GuildBest_Create() end
	if self.leadersAvailable then
		local leaders = C_ChallengeMode_GetGuildLeaders()
		if leaders and #leaders > 0 then
			for i = 1, #leaders do
				M.GuildBest_SetUp(frame.entries[i], leaders[i])
			end
			frame:Show()
		else
			frame:Hide()
		end
	end

	if not resize and hasAngryKeystones then
		local schedule = AngryKeystones.Modules.Schedule.AffixFrame
		frame:SetWidth(246)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", schedule, "TOPLEFT", 0, 10)

		self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -135, -25)
		local affix = self.WeeklyInfo.Child.Affixes[1]
		if affix then
			affix:ClearAllPoints()
			affix:SetPoint("TOPLEFT", 20, -55)
		end

		resize = true
	end
end

function M.GuildBest_OnLoad(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hooksecurefunc("ChallengesFrame_Update", M.GuildBest_Update)
		M:KeystoneInfo_Create()
		M:WeeklyInfo_Create()

		B:UnregisterEvent(event, M.GuildBest_OnLoad)
	end
end

-- Keystone Info
local rewardOrder = {
	[1] = 4,
	[2] = 5,
	[3] = 6,
	[4] = 7,
	[5] = 8,
	[6] = 9,
	[7] = 1,
	[8] = 2,
	[9] = 3,
}
local indexToTitle = {
	[1] = PVP,
	[4] = RAIDS,
	[7] = MYTHIC_DUNGEONS,
}

function M:GetWeeklyRewardName(info)
	local rewardName
	if info.type == WEEKLY_TYPE_RANKED_PVP then
		rewardName = PVPUtil.GetTierName(info.level)
	elseif info.type == WEEKLY_TYPE_MYTHIC_PLUS then
		rewardName = format(WEEKLY_REWARDS_MYTHIC, info.level)
	elseif info.type == WEEKLY_TYPE_RAID then
		rewardName = DifficultyUtil.GetDifficultyName(info.level)
	end
	local itemLink = C_WeeklyRewards_GetExampleRewardItemHyperlinks(info.id)
	local itemLevel = itemLink and GetDetailedItemLevelInfo(itemLink) or UNKNOWN
	return rewardName, itemLevel
end

function M:WeeklyInfo_Create()
	local texture = "Interface\\Icons\\Inv_legion_chest_Valajar"
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 36, 67)
	button:SetSize(32, 32)
	B.PixelIcon(button, texture, true)
	button.bg:SetBackdropBorderColor(1, .8, 0)
	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(GREAT_VAULT_REWARDS)
	
		local activities = C_WeeklyRewards_GetActivities()
		for index, newIndex in ipairs(rewardOrder) do
			local info = activities[newIndex]
			if info then
				if index % 3 == 1 then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(indexToTitle[index], .6,.8,1)
				end
	
				if info.progress < info.threshold then
					GameTooltip:AddDoubleLine("R"..info.index..": "..info.progress.."/"..info.threshold, INCOMPLETE, 1,1,1, 1,0,0)
				else
					local rewardName, itemLevel = M:GetWeeklyRewardName(info)
					if rewardName then
						GameTooltip:AddDoubleLine("R"..info.index..": "..rewardName, itemLevel, 1,1,1, 0,1,0)
					end
				end
			end
		end

		GameTooltip:AddDoubleLine(" ", DB.LineString)
		GameTooltip:AddDoubleLine(" ", DB.LeftButton..RATED_PVP_WEEKLY_VAULT.." ", 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			if not WeeklyRewardsFrame then WeeklyRewards_LoadUI() end
			B:TogglePanel(WeeklyRewardsFrame)
		end
	end)
end

function M:KeystoneInfo_Create()
	local texture = select(10, GetItemInfo(158923)) or 525134
	local iconColor = DB.QualityColors[LE_ITEM_QUALITY_EPIC or 4]
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 2, 67)
	button:SetSize(32, 32)
	B.PixelIcon(button, texture, true)
	button.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Account Keystones"])
		for fullName, info in pairs(NDuiADB["KeystoneInfo"]) do
			local name = Ambiguate(fullName, "none")
			local mapID, level, class, faction = strsplit(":", info)
			local color = B.HexRGB(B.ClassColor(class))
			local factionColor = faction == "Horde" and "|cffff5040" or "|cff00adf0"
			local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))
			GameTooltip:AddDoubleLine(format(color.."%s:|r", name), format("%s%s(%s)|r", factionColor, dungeon, level))
		end
		GameTooltip:AddDoubleLine(" ", DB.LineString)
		GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Reset Gold"].." ", 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", B.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			wipe(NDuiADB["KeystoneInfo"])
		end
	end)
end

function M:KeystoneInfo_UpdateBag()
	local keystoneMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	if keystoneMapID then
		return keystoneMapID, C_MythicPlus_GetOwnedKeystoneLevel()
	end
end

function M:KeystoneInfo_Update()
	local mapID, keystoneLevel = M:KeystoneInfo_UpdateBag()
	if mapID then
		NDuiADB["KeystoneInfo"][DB.MyFullName] = mapID..":"..keystoneLevel..":"..DB.MyClass..":"..DB.MyFaction
	else
		NDuiADB["KeystoneInfo"][DB.MyFullName] = nil
	end
end

function M:GuildBest()
	hasAngryKeystones = IsAddOnLoaded("AngryKeystones")
	B:RegisterEvent("ADDON_LOADED", M.GuildBest_OnLoad)

	M:KeystoneInfo_Update()
	B:RegisterEvent("BAG_UPDATE", M.KeystoneInfo_Update)
end
M:RegisterMisc("GuildBest", M.GuildBest)