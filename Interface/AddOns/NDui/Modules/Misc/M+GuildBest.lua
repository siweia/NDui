local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

function module:GuildBest()
	local frame

	local function UpdateTooltip(self)
		local leaderInfo = self.leaderInfo
		if not leaderInfo then return end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local name = C_ChallengeMode.GetMapUIInfo(leaderInfo.mapChallengeModeID)
		GameTooltip:SetText(name, 1, 1, 1)
		GameTooltip:AddLine(CHALLENGE_MODE_POWER_LEVEL:format(leaderInfo.keystoneLevel))
		for i = 1, #leaderInfo.members do
			local classColorStr = RAID_CLASS_COLORS[leaderInfo.members[i].classFileName].colorStr
			GameTooltip:AddLine(CHALLENGE_MODE_GUILD_BEST_LINE:format(classColorStr,leaderInfo.members[i].name));
		end
		GameTooltip:Show()
	end

	local function CreateBoard()
		frame = CreateFrame("Frame", nil, ChallengesFrame)
		frame:SetPoint("BOTTOMRIGHT", -6, 70)
		frame:SetSize(170, 110)
		B.CreateBD(frame, .3)
		B.CreateSD(frame)
		local header = B.CreateFS(frame, 14, CHALLENGE_MODE_THIS_WEEK , false, "TOPLEFT", 10, -9)
		header:SetTextColor(1, .8, 0)

		frame.entries = {}
		for i = 1, 4 do
			local entry = CreateFrame("Frame", nil, frame)
			entry:SetSize(150, 18)
			entry.CharacterName = B.CreateFS(entry, 14, "", false, "LEFT", 0, 0)
			entry.CharacterName:SetPoint("RIGHT", -30, 0)
			entry.CharacterName:SetJustifyH("LEFT")
			entry.Level = B.CreateFS(entry, 14, "", false, "RIGHT", 0, 0)
			entry.Level:SetTextColor(1, .8, 0)
			entry.Level:SetJustifyH("RIGHT")
			entry:SetScript("OnEnter", UpdateTooltip)
			entry:SetScript("OnLeave", GameTooltip_Hide)

			if i == 1 then
				entry:SetPoint("TOP", frame, 0, -32)
			else
				entry:SetPoint("TOP", frame.entries[i-1], "BOTTOM")
			end

			frame.entries[i] = entry
		end
	end

	local function SetUpRecord(self, leaderInfo)
		self.leaderInfo = leaderInfo
		local str = CHALLENGE_MODE_GUILD_BEST_LINE
		if leaderInfo.isYou then
			str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
		end

		local classColorStr = RAID_CLASS_COLORS[leaderInfo.classFileName].colorStr
		self.CharacterName:SetText(str:format(classColorStr, leaderInfo.name))
		self.Level:SetText(leaderInfo.keystoneLevel)
	end

	local function UpdateGuildBest(self)
		if not frame then CreateBoard() end
		if self.leadersAvailable then
			local leaders = C_ChallengeMode.GetGuildLeaders()
			if leaders and #leaders > 0 then
				for i = 1, #leaders do
					SetUpRecord(frame.entries[i], leaders[i])
				end
				frame:Show()
			else
				frame:Hide()
			end
		end
	end

	local function ChallengesOnLoad(event, addon)
		if addon == "Blizzard_ChallengesUI" then
			hooksecurefunc("ChallengesFrame_Update", UpdateGuildBest)

			B:UnregisterEvent(event)
		end
	end
	B:RegisterEvent("ADDON_LOADED", ChallengesOnLoad)
end