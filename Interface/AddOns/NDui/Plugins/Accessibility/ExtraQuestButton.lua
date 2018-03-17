local B, C, L, DB = unpack(select(2, ...))
--------------------------------
-- ExtraQuestButton, by p3lim
-- NDui MOD
--------------------------------
-- Quests with incorrect or missing quest area blobs
local questAreas = {
	-- Global
	[24629] = true,

	-- Icecrown
	[14108] = 541,

	-- Northern Barrens
	[13998] = 11,

	-- Un'Goro Crater
	[24735] = 201,

	-- Darkmoon Island
	[29506] = 823,
	[29510] = 823,

	-- Mulgore
	[24440] = 9,
	[14491] = 9,
	[24456] = 9,
	[24524] = 9,

	-- Mount Hyjal
	[25577] = 606,
}

-- Quests items with incorrect or missing quest area blobs
local itemAreas = {
	-- Global
	[34862] = true,
	[34833] = true,
	[39700] = true,

	-- Deepholm
	[58167] = 640,
	[60490] = 640,

	-- Ashenvale
	[35237] = 43,

	-- Thousand Needles
	[56011] = 61,

	-- Tanaris
	[52715] = 161,

	-- The Jade Forest
	[84157] = 806,
	[89769] = 806,

	-- Hellfire Peninsula
	[28038] = 465,
	[28132] = 465,

	-- Borean Tundra
	[35352] = 486,
	[34772] = 486,
	[34711] = 486,
	[35288] = 486,
	[34782] = 486,

	-- Zul'Drak
	[41161] = 496,
	[39157] = 496,
	[39206] = 496,
	[39238] = 496,
	[39664] = 496,
	[38699] = 496,
	[41390] = 496,

	-- Dalaran (Broken Isles)
	[129047] = 1014,

	-- Stormheim
	[128287] = 1017,
	[129161] = 1017,

	-- Azsuna
	[118330] = 1015,

	-- Suramar
	[133882] = 1033,
}

local ExtraQuestButton = CreateFrame("Button", "ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
ExtraQuestButton:SetMovable(true)
ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
ExtraQuestButton:SetScript("OnEvent", function(self, event, ...)
	if(self[event]) then
		self[event](self, event, ...)
	elseif(self:IsEnabled()) then
		self:Update()
	end
end)

local visibilityState = "[extrabar][petbattle] hide; show"
local onAttributeChanged = [[
	if(name == "item") then
		if(value and not self:IsShown() and not HasExtraActionBar()) then
			self:Show()
		elseif(not value) then
			self:Hide()
			self:ClearBindings()
		end
	elseif(name == "state-visible") then
		if(value == "show") then
			self:CallMethod("Update")
		else
			self:Hide()
			self:ClearBindings()
		end
	end

	if(self:IsShown() and (name == "item" or name == "binding")) then
		self:ClearBindings()

		local key = GetBindingKey("EXTRAACTIONBUTTON1")
		if(key) then
			self:SetBindingClick(1, key, self, "LeftButton")
		end
	end
]]

function ExtraQuestButton:BAG_UPDATE_COOLDOWN()
	if(self:IsShown() and self:IsEnabled()) then
		local start, duration = GetItemCooldown(self.itemID)
		if(duration > 0) then
			self.Cooldown:SetCooldown(start, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function ExtraQuestButton:BAG_UPDATE_DELAYED()
	self:Update()

	if(self:IsShown() and self:IsEnabled()) then
		local count = GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or "")
	end
end

function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
	self:SetAttribute("item", self.attribute)
	self:UnregisterEvent(event)
	self:BAG_UPDATE_COOLDOWN()
end

function ExtraQuestButton:UPDATE_BINDINGS()
	if(self:IsShown() and self:IsEnabled()) then
		self:SetItem()
		self:SetAttribute("binding", GetTime())
	end
end

function ExtraQuestButton:PLAYER_LOGIN()
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:SetAttribute("type", "item")

	if(not self:GetPoint()) then
		self:SetPoint("CENTER", ExtraActionButton1)
	end

	self:SetSize(ExtraActionButton1:GetSize())
	self:SetScale(ExtraActionButton1:GetScale())
	self:SetPushedTexture(DB.textures.pushed)
	self:GetPushedTexture():SetBlendMode("ADD")
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetClampedToScreen(true)
	self:SetToplevel(true)

	self.updateTimer = 0
	self.rangeTimer = 0
	self:Hide()

	local Icon = self:CreateTexture("$parentIcon", "ARTWORK")
	Icon:SetAllPoints()
	Icon:SetTexCoord(unpack(DB.TexCoord))
	B.CreateSD(self, 3, 3)
	self.Shadow:SetFrameLevel(self:GetFrameLevel())
	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetColorTexture(1, 1, 1, .3)
	self.HL:SetAllPoints(Icon)
	self.Icon = Icon

	local HotKey = self:CreateFontString("$parentHotKey", nil, "NumberFontNormal")
	HotKey:SetPoint("TOP", 0, -5)
	self.HotKey = HotKey

	local Count = self:CreateFontString("$parentCount", nil, "NumberFontNormal")
	Count:SetPoint("TOPLEFT", 7, -7)
	self.Count = Count

	local Cooldown = CreateFrame("Cooldown", "$parentCooldown", self, "CooldownFrameTemplate")
	Cooldown:ClearAllPoints()
	Cooldown:SetPoint("TOPRIGHT", -1, -1)
	Cooldown:SetPoint("BOTTOMLEFT", 1, 1)
	Cooldown:SetReverse(false)
	Cooldown:Hide()
	self.Cooldown = Cooldown

	local Artwork = self:CreateTexture("$parentArtwork", "BACKGROUND")
	Artwork:SetPoint("CENTER", -2, 0)
	Artwork:SetSize(240, 120)
	Artwork:SetTexture([[Interface\ExtraButton\Smash]])
	self.Artwork = Artwork

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("WORLD_MAP_UPDATE")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_POI_UPDATE")
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	self:RegisterEvent("QUEST_ACCEPTED")

	if(not WorldMapFrame:IsShown()) then
		SetMapToCurrentZone()
	end
end

local worldQuests = {}
function ExtraQuestButton:QUEST_REMOVED(_, questID)
	if(worldQuests[questID]) then
		worldQuests[questID] = nil

		self:Update()
	end
end

function ExtraQuestButton:QUEST_ACCEPTED(_, questLogIndex, questID)
	if(questID and not IsQuestBounty(questID) and IsQuestTask(questID)) then
		local _, _, worldQuestType = GetQuestTagInfo(questID)
		if(worldQuestType and not worldQuests[questID]) then
			worldQuests[questID] = questLogIndex

			self:Update()
		end
	end
end

ExtraQuestButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self.itemLink)
end)

ExtraQuestButton:SetScript("OnUpdate", function(self, elapsed)
	if(not self:IsEnabled()) then
		return
	end

	if(self.rangeTimer > TOOLTIP_UPDATE_TIME) then
		local HotKey = self.HotKey

		-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
		local inRange = IsItemInRange(self.itemLink, "target")
		if(HotKey:GetText() == RANGE_INDICATOR) then
			if(inRange == false) then
				HotKey:SetTextColor(1, .1, .1)
				HotKey:Show()
			elseif(inRange) then
				HotKey:SetTextColor(.6, .6, .6)
				HotKey:Show()
			else
				HotKey:Hide()
			end
		else
			if(inRange == false) then
				HotKey:SetTextColor(1, .1, .1)
			else
				HotKey:SetTextColor(.6, .6, .6)
			end
		end

		self.rangeTimer = 0
	else
		self.rangeTimer = self.rangeTimer + elapsed
	end

	if(self.updateTimer > 5) then
		self:Update()
		self.updateTimer = 0
	else
		self.updateTimer = self.updateTimer + elapsed
	end
end)

ExtraQuestButton:SetScript("OnEnable", function(self)
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self.Artwork:SetTexture([[Interface\ExtraButton\Smash]])
	self:Update()
	self:SetItem()
end)

ExtraQuestButton:SetScript("OnDisable", function(self)
	if(not self:IsMovable()) then
		self:SetMovable(true)
	end

	RegisterStateDriver(self, "visible", "show")
	self:SetAttribute("_onattributechanged", nil)
	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.Artwork:SetTexture([[Interface\ExtraButton\Ultraxion]])
	self.HotKey:Hide()
end)

-- Sometimes blizzard does actually do what I want
local blacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

function ExtraQuestButton:SetItem(itemLink, texture)
	if(HasExtraActionBar()) then
		return
	end

	if(itemLink) then
		self.Icon:SetTexture(texture)

		if(itemLink == self.itemLink and self:IsShown()) then
			return
		end

		local itemID, itemName = string.match(itemLink, "|Hitem:(.-):.-|h%[(.+)%]|h")
		self.itemID = tonumber(itemID)
		self.itemName = itemName
		self.itemLink = itemLink

		if(blacklist[itemID]) then
			return
		end
	end

	local HotKey = self.HotKey
	local key = GetBindingKey("EXTRAACTIONBUTTON1")
	if(key) then
		HotKey:SetText(GetBindingText(key, 1))
		HotKey:Show()
	elseif(ItemHasRange(itemLink)) then
		HotKey:SetText(RANGE_INDICATOR)
		HotKey:Show()
	else
		HotKey:Hide()
	end
	if NDuiDB["Actionbar"]["Enable"] then NDui.UpdateHotkey(self) end

	if(InCombatLockdown()) then
		self.attribute = self.itemName
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:SetAttribute("item", self.itemName)
		self:BAG_UPDATE_COOLDOWN()
	end
end

function ExtraQuestButton:RemoveItem()
	if(InCombatLockdown()) then
		self.attribute = nil
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:SetAttribute("item", nil)
	end
end

local function GetClosestQuestItem()
	-- Basically a copy of QuestSuperTracking_ChooseClosestQuest from Blizzard_ObjectiveTracker
	local closestQuestLink, closestQuestTexture
	local shortestDistanceSq = 62500 -- 250 yards²
	local numItems = 0

	-- XXX: temporary solution for the above
	for questID, questLogIndex in next, worldQuests do
		local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
		if(itemLink) then
			local areaID = questAreas[questID]
			if(not areaID) then
				areaID = itemAreas[tonumber(string.match(itemLink, "item:(%d+)"))]
			end

			local _, _, _, _, _, isComplete = GetQuestLogTitle(questLogIndex)
			if(areaID and (type(areaID) == "boolean" or areaID == GetCurrentMapAreaID())) then
				closestQuestLink = itemLink
				closestQuestTexture = texture
			elseif(not isComplete or (isComplete and showCompleted)) then
				local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
				if(onContinent and distanceSq <= shortestDistanceSq) then
					shortestDistanceSq = distanceSq
					closestQuestLink = itemLink
					closestQuestTexture = texture
				end
			end

			numItems = numItems + 1
		end
	end

	if(not closestQuestLink) then
		for index = 1, GetNumQuestWatches() do
			local questID, _, questLogIndex, _, _, isComplete = GetQuestWatchInfo(index)
			if(questID and QuestHasPOIInfo(questID)) then
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if(itemLink) then
					local areaID = questAreas[questID]
					if(not areaID) then
						areaID = itemAreas[tonumber(string.match(itemLink, "item:(%d+)"))]
					end

					if(areaID and (type(areaID) == "boolean" or areaID == GetCurrentMapAreaID())) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif(not isComplete or (isComplete and showCompleted)) then
						local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
						if(onContinent and distanceSq <= shortestDistanceSq) then
							shortestDistanceSq = distanceSq
							closestQuestLink = itemLink
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end
	end

	if(not closestQuestLink) then
		for questLogIndex = 1, GetNumQuestLogEntries() do
			local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questLogIndex)
			if(not isHeader and QuestHasPOIInfo(questID)) then
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if(itemLink) then
					local areaID = questAreas[questID]
					if(not areaID) then
						areaID = itemAreas[tonumber(string.match(itemLink, "item:(%d+)"))]
					end

					if(areaID and (type(areaID) == "boolean" or areaID == GetCurrentMapAreaID())) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif(not isComplete or (isComplete and showCompleted)) then
						local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
						if(onContinent and distanceSq <= shortestDistanceSq) then
							shortestDistanceSq = distanceSq
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
function ExtraQuestButton:Update()
	if(not self:IsEnabled() or self.locked) then
		return
	end

	local itemLink, texture, numItems = GetClosestQuestItem()
	if(itemLink) then
		self:SetItem(itemLink, texture)
	elseif(self:IsShown()) then
		self:RemoveItem()
	end

	if(numItems > 0 and not ticker) then
		ticker = C_Timer.NewTicker(30, function() -- might want to lower this
			ExtraQuestButton:Update()
		end)
	elseif(numItems == 0 and ticker) then
		ticker:Cancel()
		ticker = nil
	end
end