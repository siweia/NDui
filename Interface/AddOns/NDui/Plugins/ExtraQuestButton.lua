--------------------------------
-- ExtraQuestButton, by p3lim
-- NDui MOD
--------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)

local _G = _G
local next, type, sqrt, GetTime, format = next, type, sqrt, GetTime, format
local RegisterStateDriver, InCombatLockdown = RegisterStateDriver, InCombatLockdown
local IsItemInRange, ItemHasRange, HasExtraActionBar = IsItemInRange, ItemHasRange, HasExtraActionBar
local GetItemCooldown, GetItemCount, GetItemIcon, GetItemInfoFromHyperlink = GetItemCooldown, GetItemCount, GetItemIcon, GetItemInfoFromHyperlink
local GetBindingKey, GetBindingText, GetQuestLogSpecialItemInfo, QuestHasPOIInfo = GetBindingKey, GetBindingText, GetQuestLogSpecialItemInfo, QuestHasPOIInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_IsOnMap = C_QuestLog.IsOnMap
local C_QuestLog_IsComplete = C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local C_QuestLog_GetDistanceSqToQuest = C_QuestLog.GetDistanceSqToQuest
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumWorldQuestWatches = C_QuestLog.GetNumWorldQuestWatches
local C_QuestLog_GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex
local C_QuestLog_GetQuestIDForWorldQuestWatchIndex = C_QuestLog.GetQuestIDForWorldQuestWatchIndex
local MAX_DISTANCE_YARDS = 1e4 -- needs review
local onlyCurrentZone = true

-- Warlords of Draenor intro quest items which inspired this addon
local blacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

-- quests that doesn't have a defined area on the map (questID = bool/mapID/{mapID,...})
-- these have low priority during collision
local inaccurateQuestAreas = {
	[11731] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11921] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11922] = {18, 85, 88, 110}, -- horde capitals
	[11926] = {18, 85, 88, 110}, -- horde capitals
	[12779] = 124, -- Scarlet Enclave (Death Knight starting zone)
	[13998] = 11, -- Northern Barrens
	[14246] = 66, -- Desolace
	[24440] = 7, -- Mulgore
	[24456] = 7, -- Mulgore
	[24524] = 7, -- Mulgore
	[24629] = {84, 85, 87, 88, 103, 110}, -- major capitals (missing Darnassus & Undercity)
	[25577] = 198, -- Mount Hyjal
	[29506] = 407, -- Darkmoon Island
	[29510] = 407, -- Darkmoon Island
	[29515] = 407, -- Darkmoon Island
	[29516] = 407, -- Darkmoon Island
	[29517] = 407, -- Darkmoon Island
	[49813] = true, -- anywhere
	[49846] = true, -- anywhere
	[49860] = true, -- anywhere
	[49864] = true, -- anywhere
	[25798] = 64, -- Thousand Needles
	[25799] = 64, -- Thousand Needles
	[34461] = 590, -- Horde Garrison
	[59809] = true,
	[60004] = 118, -- 前夕任务：英勇之举
	[63971] = 1543, -- 法夜突袭，蜗牛践踏
}

-- items that should be used for a quest but aren't (questID = itemID)
-- these have low priority during collision
local questItems = {
	[10129] = 28038, -- Hellfire Peninsula
	[10146] = 28038, -- Hellfire Peninsula
	[10162] = 28132, -- Hellfire Peninsula
	[10163] = 28132, -- Hellfire Peninsula
	[10346] = 28132, -- Hellfire Peninsula
	[10347] = 28132, -- Hellfire Peninsula
	[11617] = 34772, -- Borean Tundra
	[11633] = 34782, -- Borean Tundra
	[11894] = 35288, -- Borean Tundra
	[11982] = 35734, -- Grizzly Hills
	[11986] = 35739, -- Grizzly Hills
	[11989] = 38083, -- Grizzly Hills
	[12026] = 35739, -- Grizzly Hills
	[12415] = 37716, -- Grizzly Hills
	[12007] = 35797, -- Grizzly Hills
	[12456] = 37881, -- Dragonblight
	[12470] = 37923, -- Dragonblight
	[12484] = 38149, -- Grizzly Hills
	[12661] = 41390, -- Zul'Drak
	[12713] = 38699, -- Zul'Drak
	[12861] = 41161, -- Zul'Drak
	[13343] = 44450, -- Dragonblight
	[29821] = 84157, -- Jade Forest
	[31112] = 84157, -- Jade Forest
	[31769] = 89769, -- Jade Forest
	[35237] = 11891, -- Ashenvale
	[36848] = 36851, -- Grizzly Hills
	[37565] = 118330, -- Azsuna
	[39385] = 128287, -- Stormheim
	[39847] = 129047, -- Dalaran (Broken Isles)
	[40003] = 129161, -- Stormheim
	[40965] = 133882, -- Suramar
	[43827] = 129161, -- Stormheim
	[49402] = 154878, -- Tiragarde Sound
	[50164] = 154878, -- Tiragarde Sound
	[51646] = 154878, -- Tiragarde Sound
	[58586] = 174465, -- Venthyr Covenant
	[59063] = 175137, -- Night Fae Covenant
	[59809] = 177904, -- Night Fae Covenant
	[60188] = 178464, -- Night Fae Covenant
	[60649] = 180170, -- Ardenweald
	[60609] = 180008, -- Ardenweald
}

-- items that need to be shown, but not. (itemID = bool/mapID)
local completeShownItems = {
	[35797] = 116, -- Grizzly Hills
	[60273] = 50, -- Northern Stranglethorn Vale
	[52853] = true, -- Mount Hyjal
	[41058] = 120, -- Storm Peaks
	[177904] = true,
}

-- items that need to be hidden, but not. (itemID = bool/mapID)
local completeHiddenItems = {
	[180899] = true, -- Riding Hook
	[184876] = true, -- Cohesion Crystal
	[186199] = true, -- Lady Moonberry's Wand
	[187012] = true, -- Unbalanced Riftstone
	[187516] = true, -- 菲历姆的锻炉阀门
	[112681] = true, -- 古怪的水晶碎片，questID 34938
}

local ExtraQuestButton = CreateFrame("Button", "ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
ExtraQuestButton:SetMovable(true)
ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
ExtraQuestButton:RegisterForClicks("AnyDown")
ExtraQuestButton:Hide()
ExtraQuestButton:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...)
	else
		self:Update()
	end
end)

local visibilityState = "[extrabar][petbattle] hide; show"
local onAttributeChanged = [[
	if name == "item" then
		if value and not self:IsShown() and not HasExtraActionBar() then
			self:Show()
		elseif not value then
			self:Hide()
			self:ClearBindings()
		end
	elseif name == "state-visible" then
		if value == "show" then
			self:Show()
			self:CallMethod("Update")
		else
			self:Hide()
			self:ClearBindings()
		end
	end

	if self:IsShown() then
		self:ClearBindings()

		local key1, key2 = GetBindingKey("EXTRAACTIONBUTTON1")
		if key1 then
			self:SetBindingClick(1, key1, self, "LeftButton")
		end
		if key2 then
			self:SetBindingClick(2, key2, self, "LeftButton")
		end
	end
]]

function ExtraQuestButton:BAG_UPDATE_COOLDOWN()
	if self:IsShown() and self.itemID then
		local start, duration = GetItemCooldown(self.itemID)
		if duration > 0 then
			self.Cooldown:SetCooldown(start, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function ExtraQuestButton:UpdateCount()
	if self:IsShown() then
		local count = GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or "")
	end
end

function ExtraQuestButton:BAG_UPDATE_DELAYED()
	self:Update()
	self:UpdateCount()
end

function ExtraQuestButton:UpdateAttributes()
	if InCombatLockdown() then
		if not self.itemID and self:IsShown() then
			self:SetAlpha(0)
		end
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	else
		self:SetAlpha(1)
	end

	if self.itemID then
		self:SetAttribute("item", "item:"..self.itemID)
		self:BAG_UPDATE_COOLDOWN()
	else
		self:SetAttribute("item", nil)
	end
end

function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
	self:UpdateAttributes()
	self:UnregisterEvent(event)
end

function ExtraQuestButton:UPDATE_BINDINGS()
	if self:IsShown() then
		self:SetItem()
		self:SetAttribute("binding", GetTime())
	end
end

function ExtraQuestButton:PLAYER_LOGIN()
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:SetAttribute("type", "item")

	self:SetSize(ExtraActionButton1:GetSize())
	self:SetScale(ExtraActionButton1:GetScale())
	self:SetScript("OnLeave", B.HideTooltip)
	self:SetClampedToScreen(true)
	self:SetToplevel(true)

	if not self:GetPoint() then
		if _G.NDui_ActionBarExtra then
			self:SetPoint("CENTER", _G.NDui_ActionBarExtra)
		else
			B.Mover(self, L["ExtraQuestButton"], "Extrabar", {"BOTTOM", UIParent, "BOTTOM", 250, 100})
		end
	end

	self.updateTimer = 0
	self.rangeTimer = 0

	self:SetPushedTexture(DB.pushedTex)
	local push = self:GetPushedTexture()
	push:SetBlendMode("ADD")
	push:SetInside()

	local Icon = self:CreateTexture("$parentIcon", "ARTWORK")
	Icon:SetInside()
	B.ReskinIcon(Icon, true)
	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetColorTexture(1, 1, 1, .25)
	self.HL:SetAllPoints(Icon)
	self.Icon = Icon

	local HotKey = self:CreateFontString("$parentHotKey", nil, "NumberFontNormal")
	HotKey:SetPoint("TOP", 0, -5)
	self.HotKey = HotKey

	local Count = self:CreateFontString("$parentCount", nil, "NumberFont_Shadow_Med")
	Count:SetPoint("BOTTOMRIGHT", -3, 3)
	self.Count = Count

	local Cooldown = CreateFrame("Cooldown", "$parentCooldown", self, "CooldownFrameTemplate")
	Cooldown:SetInside()
	Cooldown:SetReverse(false)
	Cooldown:Hide()
	self.Cooldown = Cooldown

	local Artwork = self:CreateTexture("$parentArtwork", "OVERLAY")
	Artwork:SetPoint("BOTTOMLEFT", -1, -3)
	Artwork:SetSize(20, 20)
	Artwork:SetAtlas(DB.questTex)
	self.Artwork = Artwork

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_POI_UPDATE")
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

ExtraQuestButton:SetScript("OnEnter", function(self)
	if not self.itemLink then return end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self.itemLink)
end)

ExtraQuestButton:SetScript("OnUpdate", function(self, elapsed)
	if self.updateRange then
		if (self.rangeTimer or 0) > TOOLTIP_UPDATE_TIME then
			local HotKey = self.HotKey
			local Icon = self.Icon

			-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
			local inRange = IsItemInRange(self.itemLink, "target")
			if HotKey:GetText() == RANGE_INDICATOR then
				if inRange == false then
					HotKey:SetTextColor(1, .1, .1)
					HotKey:Show()
					Icon:SetVertexColor(1, .1, .1)
				elseif inRange then
					HotKey:SetTextColor(.6, .6, .6)
					HotKey:Show()
					Icon:SetVertexColor(1, 1, 1)
				else
					HotKey:Hide()
				end
			else
				if inRange == false then
					HotKey:SetTextColor(1, .1, .1)
					Icon:SetVertexColor(1, .1, .1)
				else
					HotKey:SetTextColor(.6, .6, .6)
					Icon:SetVertexColor(1, 1, 1)
				end
			end

			self.rangeTimer = 0
		else
			self.rangeTimer = (self.rangeTimer or 0) + elapsed
		end
	end

	if (self.updateTimer or 0) > 5 then
		self:Update()
		self.updateTimer = 0
	else
		self.updateTimer = (self.updateTimer or 0) + elapsed
	end
end)

ExtraQuestButton:SetScript("OnEnable", function(self)
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:Update()
	self:SetItem()
end)

ExtraQuestButton:SetScript("OnDisable", function(self)
	if not self:IsMovable() then
		self:SetMovable(true)
	end

	RegisterStateDriver(self, "visible", "show")
	self:SetAttribute("_onattributechanged", nil)
	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.HotKey:Hide()
end)

function ExtraQuestButton:SetItem(itemLink)
	if HasExtraActionBar() then return end

	if itemLink then
		self.Icon:SetTexture(GetItemIcon(itemLink))
		local itemID = GetItemInfoFromHyperlink(itemLink)
		self.itemID = itemID
		self.itemLink = itemLink

		if blacklist[itemID] then return end
	end

	if self.itemID then
		local HotKey = self.HotKey
		local key = GetBindingKey("EXTRAACTIONBUTTON1")
		local hasRange = ItemHasRange(itemLink)
		if key then
			HotKey:SetText(GetBindingText(key, 1))
			HotKey:Show()
		elseif hasRange then
			HotKey:SetText(RANGE_INDICATOR)
			HotKey:Show()
		else
			HotKey:Hide()
		end
		B:GetModule("Actionbar").UpdateHotKey(HotKey)

		self:UpdateAttributes()
		self:UpdateCount()
		self.updateRange = hasRange
	end
end

function ExtraQuestButton:RemoveItem()
	self.itemID = nil
	self.itemLink = nil
	self:UpdateAttributes()
end

local function IsQuestOnMap(questID)
	return not onlyCurrentZone or C_QuestLog_IsOnMap(questID)
end

local function GetQuestDistanceWithItem(questID)
	local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
	if not questLogIndex then return end

	local itemLink, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
	if not itemLink then
		local fallbackItemID = questItems[questID]
		if fallbackItemID then
			itemLink = format("|Hitem:%d|h", fallbackItemID)
		end
	end
	if not itemLink then return end
	if GetItemCount(itemLink) == 0 then return end

	local itemID = GetItemInfoFromHyperlink(itemLink)
	if blacklist[itemID] then return end

	if C_QuestLog_IsComplete(questID) then
		if showWhenComplete and completeHiddenItems[itemID] then return end -- hide item when quest completed
		if not showWhenComplete and not completeShownItems[itemID] then return end -- show item even quest completed
	end

	local distanceSq = C_QuestLog_GetDistanceSqToQuest(questID)
	local distanceYd = distanceSq and sqrt(distanceSq)
	if IsQuestOnMap(questID) and distanceYd and distanceYd <= MAX_DISTANCE_YARDS then
		return distanceYd, itemLink
	end

	local questMapID = inaccurateQuestAreas[questID]
	if questMapID then
		local currentMapID = C_Map_GetBestMapForUnit("player")
		if type(questMapID) == "boolean" then
			return MAX_DISTANCE_YARDS-1, itemLink
		elseif type(questMapID) == "number" then
			if questMapID == currentMapID then
				return MAX_DISTANCE_YARDS-2, itemLink
			end
		elseif type(questMapID) == "table" then
			for _, mapID in next, questMapID do
				if mapID == currentMapID then
					return MAX_DISTANCE_YARDS-2, itemLink
				end
			end
		end
	end
end

local function GetClosestQuestItem()
	local closestQuestItemLink
	local closestDistance = MAX_DISTANCE_YARDS

	for index = 1, C_QuestLog_GetNumWorldQuestWatches() do
		-- this only tracks supertracked worldquests,
		-- e.g. stuff the player has shift-clicked on the map
		local questID = C_QuestLog_GetQuestIDForWorldQuestWatchIndex(index)
		if questID then
			local distance, itemLink = GetQuestDistanceWithItem(questID)
			if distance and distance <= closestDistance then
				closestDistance = distance
				closestQuestItemLink = itemLink
			end
		end
	end

	if not closestQuestItemLink then
		for index = 1, C_QuestLog_GetNumQuestWatches() do
			local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(index)
			if questID and QuestHasPOIInfo(questID) then
				local distance, itemLink = GetQuestDistanceWithItem(questID)
				if distance and distance <= closestDistance then
					closestDistance = distance
					closestQuestItemLink = itemLink
				end
			end
		end
	end

	if not closestQuestItemLink then
		for index = 1, C_QuestLog_GetNumQuestLogEntries() do
			local info = C_QuestLog_GetInfo(index)
			local questID = info and info.questID
			if questID and not info.isHeader and (not info.isHidden or C_QuestLog_IsWorldQuest(questID)) and QuestHasPOIInfo(questID) then
				local distance, itemLink = GetQuestDistanceWithItem(questID)
				if distance and distance <= closestDistance then
					closestDistance = distance
					closestQuestItemLink = itemLink
				end
			end
		end
	end

	return closestQuestItemLink
end

function ExtraQuestButton:Update()
	if HasExtraActionBar() or self.locked then return end

	local itemLink = GetClosestQuestItem()
	if itemLink then
		if itemLink ~= self.itemLink then
			self:SetItem(itemLink)
		end
	elseif self:IsShown() then
		self:RemoveItem()
	end
end