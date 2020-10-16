--------------------------------
-- ExtraQuestButton, by p3lim
-- NDui MOD
--------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)

local _G = _G
local next, type, sqrt, GetTime = next, type, sqrt, GetTime
local RegisterStateDriver, InCombatLockdown = RegisterStateDriver, InCombatLockdown
local GetItemCooldown, GetItemCount, GetItemInfoFromHyperlink = GetItemCooldown, GetItemCount, GetItemInfoFromHyperlink
local IsItemInRange, ItemHasRange, HasExtraActionBar = IsItemInRange, ItemHasRange, HasExtraActionBar
local GetBindingKey, GetBindingText, GetQuestLogSpecialItemInfo, QuestHasPOIInfo = GetBindingKey, GetBindingText, GetQuestLogSpecialItemInfo, QuestHasPOIInfo
local C_Timer_NewTicker = C_Timer.NewTicker
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_IsComplete = C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local C_QuestLog_GetDistanceSqToQuest = C_QuestLog.GetDistanceSqToQuest
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex

-- Warlords of Draenor intro quest items which inspired this addon
local blacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

-- Quests with incorrect or missing quest area blobs
local questAreas = {
	-- Global
	[24629] = true,
	-- Icecrown
	[14108] = 170,
	-- Northern Barrens
	[13998] = 11,
	-- Un'Goro Crater
	[24735] = 78,
	-- Darkmoon Island
	[29506] = 407,
	[29510] = 407,
	[29515] = 407,
	[29516] = 407,
	[29517] = 407,
	-- Mulgore
	[24440] = 7,
	[14491] = 7,
	[24456] = 7,
	[24524] = 7,
	-- Mount Hyjal
	[25577] = 198,
}

-- Quests items with incorrect or missing quest area blobs
local itemAreas = {
	-- Global
	[34862] = true,
	[34833] = true,
	[39700] = true,
	[155915] = true,
	[156474] = true,
	[156477] = true,
	[155918] = true,
	-- Deepholm
	[58167] = 207,
	[60490] = 207,
	-- Ashenvale
	[35237] = 63,
	-- Thousand Needles
	[56011] = 64,
	-- Tanaris
	[52715] = 71,
	-- The Jade Forest
	[84157] = 371,
	[89769] = 371,
	-- Hellfire Peninsula
	[28038] = 100,
	[28132] = 100,
	-- Borean Tundra
	[35352] = 114,
	[34772] = 114,
	[34711] = 114,
	[35288] = 114,
	[34782] = 114,
	-- Dragonblight
	[37881] = 115,
	[37923] = 115,
	[44450] = 115,
	[37887] = 115,
	-- Zul'Drak
	[41161] = 121,
	[39157] = 121,
	[39206] = 121,
	[39238] = 121,
	[39664] = 121,
	[38699] = 121,
	[41390] = 121,
	-- Grizzly Hills
	[38083] = 116,
	[35797] = 116,
	[37716] = 116,
	[35739] = 116,
	[36851] = 116,
	-- Icecrown
	[41265] = 170,
	-- Dalaran (Broken Isles)
	[129047] = 625,
	-- Stormheim
	[128287] = 634,
	[129161] = 634,
	-- Azsuna
	[118330] = 630,
	-- Suramar
	[133882] = 680,
	-- Tiragarde Sound
	[154878] = 895,
	-- Mechagon
	[168813] = 1462,
}

local ExtraQuestButton = CreateFrame("Button", "ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
ExtraQuestButton:SetMovable(true)
ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
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
			self:CallMethod("Update")
		else
			self:Hide()
			self:ClearBindings()
		end
	end

	if self:IsShown() and (name == "item" or name == "binding") then
		self:ClearBindings()

		local key1, key2 = GetBindingKey("EXTRAACTIONBUTTON1")
		if key1 then
			self:SetBindingClick(1, key1, self, 'LeftButton')
		end
		if key2 then
			self:SetBindingClick(2, key2, self, 'LeftButton')
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

function ExtraQuestButton:BAG_UPDATE_DELAYED()
	self:Update()

	if self:IsShown() then
		local count = GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or "")
	end
end

function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
	if self.itemID then
		self:SetAttribute("item", "item:" .. self.itemID)
		self:UnregisterEvent(event)
		self:BAG_UPDATE_COOLDOWN()
	end
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
	self:Hide()

	self:SetPushedTexture(DB.textures.pushed)
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
	self:RegisterEvent("QUEST_TURNED_IN")
end

local activeWorldQuests = {}

hooksecurefunc("QuestObjectiveSetupBlockButton_Item", function(block, questLogIndex, isQuestComplete)
	if not block.itemButton then return end

	local questID = C_QuestLog_GetQuestIDForLogIndex(questLogIndex)
	if questID and activeWorldQuests[questID] then return end

	if C_QuestLog_IsWorldQuest(questID) and not isQuestComplete then
		activeWorldQuests[questID] = true
		ExtraQuestButton:Update()
	end
end)

function ExtraQuestButton:QUEST_TURNED_IN(_, questID)
	if activeWorldQuests[questID] then
		activeWorldQuests[questID] = nil
		self:Update()
	end
end

ExtraQuestButton:SetScript("OnEnter", function(self)
	if not self.itemLink then
		if DB.isDeveloper then print("ExtraQuestButton: invalid item link.") end
		return
	end
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

function ExtraQuestButton:SetItem(itemLink, texture)
	if HasExtraActionBar() then return end

	if itemLink then
		self.Icon:SetTexture(texture)
		if itemLink == self.itemLink and self:IsShown() then return end

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
		B:GetModule("Actionbar").UpdateHotKey(self)

		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:SetAttribute("item", "item:" .. self.itemID)
			self:BAG_UPDATE_COOLDOWN()
		end
		self.updateRange = hasRange
	end
end

function ExtraQuestButton:RemoveItem()
	if InCombatLockdown() then
		self.itemID = nil
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:SetAttribute("item", nil)
	end
end

local function GetQuestDistance(questID, isWorldQuest)
	local distanceSq, onContinent = C_QuestLog_GetDistanceSqToQuest(questID)
	if isWorldQuest or onContinent then
		return sqrt(distanceSq)
	end
end

local function GetClosestQuestItem()
	local closestQuestLink, closestQuestTexture
	local closestDistance = 1e5
	local numItems = 0
	local currentMapID = C_Map_GetBestMapForUnit("player")

	-- XXX: temporary solution for the above
	for questID in next, activeWorldQuests do
		local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
		if questLogIndex then
			local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
			if itemLink then
				local areaID = questAreas[questID]
				if not areaID then
					areaID = itemAreas[GetItemInfoFromHyperlink(itemLink)]
				end

				local isComplete = C_QuestLog_IsComplete(questID)
				if areaID and (type(areaID) == "boolean" or areaID == currentMapID) then
					closestQuestLink = itemLink
					closestQuestTexture = texture
				elseif not isComplete or showCompleted then
					local distance = GetQuestDistance(questID, true)
					if distance and distance <= closestDistance then
						closestDistance = distance
						closestQuestLink = itemLink
						closestQuestTexture = texture
					end
				end

				numItems = numItems + 1
			end
		end
	end

	if not closestQuestLink then
		for index = 1, C_QuestLog_GetNumQuestWatches() do
			local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(index)
			if questID and QuestHasPOIInfo(questID) then
				local isComplete = C_QuestLog_IsComplete(questID)
				local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if itemLink then
					local areaID = questAreas[questID]
					if not areaID then
						areaID = itemAreas[GetItemInfoFromHyperlink(itemLink)]
					end

					if areaID and (type(areaID) == "boolean" or areaID == currentMapID) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif not isComplete or showCompleted then
						local distance = GetQuestDistance(questID)
						if distance and distance <= closestDistance then
							closestDistance = distance
							closestQuestLink = itemLink
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end
	end

	if not closestQuestLink then
		for questLogIndex = 1, C_QuestLog_GetNumQuestLogEntries() do
			local info = C_QuestLog_GetInfo(questLogIndex)
			local questID = info.questID
			local isHeader = info.isHeader
			local isComplete = C_QuestLog_IsComplete(questID)
			if info and not isHeader and QuestHasPOIInfo(questID) then
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if itemLink then
					local areaID = questAreas[questID]
					if not areaID then
						areaID = itemAreas[GetItemInfoFromHyperlink(itemLink)]
					end

					if areaID and (type(areaID) == "boolean" or areaID == currentMapID) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif not isComplete or showCompleted then
						local distance = GetQuestDistance(questID)
						if distance and distance <= closestDistance then
							closestDistance = distance
							closestQuestLink = itemLink
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end
	end

	return closestQuestLink, closestQuestTexture, numItems
end

local ticker
local function updateTicker()
	ExtraQuestButton:Update()
end

function ExtraQuestButton:Update()
	if HasExtraActionBar() or self.locked then return end

	local itemLink, texture, numItems = GetClosestQuestItem()
	if itemLink then
		self:SetItem(itemLink, texture)
	elseif self:IsShown() then
		self:RemoveItem()
	end

	if numItems > 0 and not ticker then
		ticker = C_Timer_NewTicker(30, updateTicker) -- might want to lower this
	elseif numItems == 0 and ticker then
		ticker:Cancel()
		ticker = nil
	end
end