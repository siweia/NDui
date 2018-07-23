local _, ns = ...
local B, C, L, DB = unpack(ns)
--------------------------
-- QuickQuest, by P3lim
-- NDui MOD
--------------------------
local mono = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
mono:SetPoint("TOPRIGHT", -140, 0)
mono:SetSize(26, 26)
B.CreateCB(mono, .25)
mono.text = B.CreateFS(mono, 14, L["Auto Quest"], false, "LEFT", 25, 0)
mono:RegisterEvent("PLAYER_LOGIN")
mono:SetScript("OnEvent", function(self)
	self:SetChecked(NDuiDB["Misc"].AutoQuest)
end)
mono:SetScript("OnClick", function(self)
	NDuiDB["Misc"].AutoQuest = self:GetChecked()
end)

-- Function
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...) self[event](...) end)

local quests, choiceQueue = {}

function QuickQuest:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if NDuiDB["Misc"].AutoQuest then
			if(not IsShiftKeyDown()) then
				func(...)
			end
		else
			if(IsShiftKeyDown()) then
				func(...)
			end
		end
	end
end

local function GetNPCID()
	return tonumber(string.match(UnitGUID("npc") or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

local function IsTrackingHidden()
	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == (MINIMAP_TRACKING_TRIVIAL_QUESTS or MINIMAP_TRACKING_HIDDEN_QUESTS)) then
			return active
		end
	end
end

local ignoreQuestNPC = {
	[88570] = true,		-- Fate-Twister Tiklal
	[87391] = true,		-- Fate-Twister Seress
	[111243] = true,	-- Archmage Lan'dalock
	[108868] = true,	-- Hunter's order hall
	[101462] = true,	-- Reaves
	[43929] = true,		-- 4000
	[14847] = true,		-- DarkMoon
	[119388] = true,	-- 酋长哈顿
	[114719] = true,	-- 商人塞林
	[121263] = true,	-- 大技师罗姆尔
	[126954] = true,	-- 图拉扬
	[124312] = true,	-- 图拉扬
	[103792] = true,	-- 格里伏塔
	[101880] = true,	-- 泰克泰克
	[141584] = true,	-- 祖尔温
}

local function GetQuestLogQuests(onlyComplete)
	wipe(quests)

	for index = 1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
		if(not isHeader) then
			if(onlyComplete and isComplete or not onlyComplete) then
				quests[title] = questID
			end
		end
	end

	return quests
end

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumActiveQuests()
	if(active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, complete = GetActiveTitle(index)
			if(complete) then
				local questID = logQuests[name]
				if(not questID) then
					SelectActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if(not worldQuest) then
						SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			local isTrivial, _, _, _, isIgnored = GetAvailableQuestInfo(index)
			if((not isTrivial and not isIgnored) or IsTrackingHidden()) then
				SelectAvailableQuest(index)
			end
		end
	end
end)

-- This should be part of the API, really
local function GetAvailableGossipQuestInfo(index)
	local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(((index * 7) - 7) + 1, GetGossipAvailableQuests())
	return name, level, isTrivial, isIgnored, isRepeatable, frequency == 2, frequency == 3, isLegendary
end

local function GetActiveGossipQuestInfo(index)
	local name, level, isTrivial, isComplete, isLegendary, isIgnored = select(((index * 6) - 6) + 1, GetGossipActiveQuests())
	return name, level, isTrivial, isIgnored, isComplete, isLegendary
end

local ignoreGossipNPC = {
	-- Bodyguards
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86933] = true, -- Vivianne (Horde)
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86934] = true, -- Defender Illona (Alliance)
	[86682] = true, -- Tormmok
	[86964] = true, -- Leorajh
	[86946] = true, -- Talonpriest Ishaal

	-- Sassy Imps
	[95139] = true,
	[95141] = true,
	[95142] = true,
	[95143] = true,
	[95144] = true,
	[95145] = true,
	[95146] = true,
	[95200] = true,
	[95201] = true,

	-- Misc NPCs
	[79740] = true, -- Warmaster Zog (Horde)
	[79953] = true, -- Lieutenant Thorn (Alliance)
	[84268] = true, -- Lieutenant Thorn (Alliance)
	[84511] = true, -- Lieutenant Thorn (Alliance)
	[84684] = true, -- Lieutenant Thorn (Alliance)
	[117871] = true, -- War Councilor Victoria (Class Challenges @ Broken Shore)
}

local rogueClassHallInsignia = {
	[97004] = true, -- "Red" Jack Findle
	[96782] = true, -- Lucian Trias
	[93188] = true, -- Mongar
}

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if(ignoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if(active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, complete = GetActiveGossipQuestInfo(index)
			if(complete) then
				local questID = logQuests[name]
				if(not questID) then
					SelectGossipActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if(not worldQuest) then
						SelectGossipActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if(available > 0) then
		for index = 1, available do
			local _, _, trivial, ignored = GetAvailableGossipQuestInfo(index)
			if((not trivial and not ignored) or IsTrackingHidden()) then
				SelectGossipAvailableQuest(index)
			elseif(trivial and npcID == 64337) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if(rogueClassHallInsignia[npcID]) then
		return SelectGossipOption(1)
	end

	if(available == 0 and active == 0 and GetNumGossipOptions() == 1) then
		if(npcID == 57850) then
			return SelectGossipOption(1)
		end

		local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
		if(instance ~= "raid" and not ignoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626)) then
			local _, type = GetGossipOptions()
			if(type == "gossip") then
				SelectGossipOption(1)
				return
			end
		end
	end
end)

local darkmoonNPC = {
	[57850] = true, -- Teleportologist Fozlebub
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
}

QuickQuest:Register("GOSSIP_CONFIRM", function(index)
	local npcID = GetNPCID()
	if(npcID and darkmoonNPC[npcID]) then
		SelectGossipOption(index, "", true)
		StaticPopup_Hide("GOSSIP_CONFIRM")
	end
end)

QuickQuest:Register("QUEST_DETAIL", function()
	if(not QuestGetAutoAccept()) then
		AcceptQuest()
	end
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	if(QuestFrame:IsShown() and QuestGetAutoAccept()) then
		CloseQuest()
	end
end)

QuickQuest:Register("QUEST_ITEM_UPDATE", function()
	if(choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end)

local itemBlacklist = {
	-- Inscription weapons
	[31690] = 79343, -- Inscribed Tiger Staff
	[31691] = 79340, -- Inscribed Crane Staff
	[31692] = 79341, -- Inscribed Serpent Staff

	-- Darkmoon Faire artifacts
	[29443] = 71635, -- Imbued Crystal
	[29444] = 71636, -- Monstrous Egg
	[29445] = 71637, -- Mysterious Grimoire
	[29446] = 71638, -- Ornate Weapon
	[29451] = 71715, -- A Treatise on Strategy
	[29456] = 71951, -- Banner of the Fallen
	[29457] = 71952, -- Captured Insignia
	[29458] = 71953, -- Fallen Adventurer's Journal
	[29464] = 71716, -- Soothsayer's Runes

	-- Tiller Gifts
	["progress_79264"] = 79264, -- Ruby Shard
	["progress_79265"] = 79265, -- Blue Feather
	["progress_79266"] = 79266, -- Jade Cat
	["progress_79267"] = 79267, -- Lovely Apple
	["progress_79268"] = 79268, -- Marsh Lily

	-- Garrison scouting missives
	["38180"] = 122424, -- Scouting Missive: Broken Precipice
	["38193"] = 122423, -- Scouting Missive: Broken Precipice
	["38182"] = 122418, -- Scouting Missive: Darktide Roost
	["38196"] = 122417, -- Scouting Missive: Darktide Roost
	["38179"] = 122400, -- Scouting Missive: Everbloom Wilds
	["38192"] = 122404, -- Scouting Missive: Everbloom Wilds
	["38194"] = 122420, -- Scouting Missive: Gorian Proving Grounds
	["38202"] = 122419, -- Scouting Missive: Gorian Proving Grounds
	["38178"] = 122402, -- Scouting Missive: Iron Siegeworks
	["38191"] = 122406, -- Scouting Missive: Iron Siegeworks
	["38184"] = 122413, -- Scouting Missive: Lost Veil Anzu
	["38198"] = 122414, -- Scouting Missive: Lost Veil Anzu
	["38177"] = 122403, -- Scouting Missive: Magnarok
	["38190"] = 122399, -- Scouting Missive: Magnarok
	["38181"] = 122421, -- Scouting Missive: Mok'gol Watchpost
	["38195"] = 122422, -- Scouting Missive: Mok'gol Watchpost
	["38185"] = 122411, -- Scouting Missive: Pillars of Fate
	["38199"] = 122409, -- Scouting Missive: Pillars of Fate
	["38187"] = 122412, -- Scouting Missive: Shattrath Harbor
	["38201"] = 122410, -- Scouting Missive: Shattrath Harbor
	["38186"] = 122408, -- Scouting Missive: Skettis
	["38200"] = 122407, -- Scouting Missive: Skettis
	["38183"] = 122416, -- Scouting Missive: Socrethar's Rise
	["38197"] = 122415, -- Scouting Missive: Socrethar's Rise
	["38176"] = 122405, -- Scouting Missive: Stonefury Cliffs
	["38189"] = 122401, -- Scouting Missive: Stonefury Cliffs

	-- Misc
	[31664] = 88604, -- Nat's Fishing Journal
}

QuickQuest:Register("QUEST_PROGRESS", function()
	if(IsQuestCompletable()) then
		local id, _, worldQuest = GetQuestTagInfo(GetQuestID())
		if id == 153 or worldQuest then return end
		-- 阿古斯的随从兑换
		if GetNPCID() == 119388 or GetNPCID() == 127037 or GetNPCID() == 126954 or GetNPCID() == 124312 then return end

		local requiredItems = GetNumQuestItems()
		if(requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if(link) then
					local id = tonumber(string.match(link, "item:(%d+)"))
					for _, itemID in next, itemBlacklist do
						if(itemID == id) then
							return
						end
					end
				else
					choiceQueue = "QUEST_PROGRESS"
					return
				end
			end
		end

		CompleteQuest()
	end
end)

local cashRewards = {
	[45724] = 1e5, -- Champion's Purse
	[64491] = 2e6, -- Royal Reward

	-- Items from the Sixtrigger brothers quest chain in Stormheim
	[138127] = 15, -- Mysterious Coin, 15 copper
	[138129] = 11, -- Swatch of Priceless Silk, 11 copper
	[138131] = 24, -- Magical Sprouting Beans, 24 copper
	[138123] = 15, -- Shiny Gold Nugget, 15 copper
	[138125] = 16, -- Crystal Clear Gemstone, 16 copper
	[138133] = 27, -- Elixir of Endless Wonder, 27 copper
}

QuickQuest:Register("QUEST_COMPLETE", function()
	-- Blingtron 6000 only!
	local npcID = GetNPCID()
	if npcID == 43929 or npcID == 77789 then return end

	local choices = GetNumQuestChoices()
	if(choices <= 1) then
		GetQuestReward(1)
	elseif(choices > 1) then
		local bestValue, bestIndex = 0

		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if(link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = cashRewards[tonumber(string.match(link, "item:(%d+):"))] or value

				if(value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		if(bestIndex) then
			QuestInfoItem_OnClick(QuestInfoRewardsFrame.RewardButtons[bestIndex])
		end
	end
end)

local function AttemptAutoComplete(event)
	if(GetNumAutoQuestPopUps() > 0) then
		if(UnitIsDeadOrGhost("player")) then
			QuickQuest:Register("PLAYER_REGEN_ENABLED", AttemptAutoComplete)
			return
		end

		local questID, popUpType = GetAutoQuestPopUp(1)
		local _, _, worldQuest = GetQuestTagInfo(questID)
		if not worldQuest then
			if(popUpType == "OFFER") then
				ShowQuestOffer(GetQuestLogIndexByID(questID))
			else
				ShowQuestComplete(GetQuestLogIndexByID(questID))
			end
		end
	else
		C_Timer.After(1, AttemptAutoComplete)
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		QuickQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end
QuickQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
QuickQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)