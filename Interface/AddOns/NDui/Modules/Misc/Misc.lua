local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:RegisterModule("Misc")

local _G = getfenv(0)
local select, unpack, tonumber, gsub = select, unpack, tonumber, gsub
local InCombatLockdown, IsModifiedClick, IsAltKeyDown = InCombatLockdown, IsModifiedClick, IsAltKeyDown
local GetNumArchaeologyRaces = GetNumArchaeologyRaces
local GetNumArtifactsByRace = GetNumArtifactsByRace
local GetArtifactInfoByRace = GetArtifactInfoByRace
local GetArchaeologyRaceInfo = GetArchaeologyRaceInfo
local EquipmentManager_UnequipItemInSlot = EquipmentManager_UnequipItemInSlot
local EquipmentManager_RunAction = EquipmentManager_RunAction
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemInfo = GetItemInfo
local BuyMerchantItem = BuyMerchantItem
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetItemQualityColor = GetItemQualityColor
local Screenshot = Screenshot
local GetTime, GetCVarBool, SetCVar = GetTime, GetCVarBool, SetCVar
local GetNumLootItems, LootSlot = GetNumLootItems, LootSlot
local GetNumSavedInstances = GetNumSavedInstances
local GetInstanceInfo = GetInstanceInfo
local GetSavedInstanceInfo = GetSavedInstanceInfo
local SetSavedInstanceExtend = SetSavedInstanceExtend
local RequestRaidInfo, RaidInfoFrame_Update = RequestRaidInfo, RaidInfoFrame_Update
local IsGuildMember, C_BattleNet_GetGameAccountInfoByGUID, C_FriendList_IsFriend = IsGuildMember, C_BattleNet.GetGameAccountInfoByGUID, C_FriendList.IsFriend
local C_Map_GetMapInfo, C_Map_GetBestMapForUnit = C_Map.GetMapInfo, C_Map.GetBestMapForUnit
local UnitIsPlayer, GuildInvite, C_FriendList_AddFriend = UnitIsPlayer, GuildInvite, C_FriendList.AddFriend

--[[
	Miscellaneous 各种有用没用的小玩意儿
]]
local MISC_LIST = {}

function M:RegisterMisc(name, func)
	if not MISC_LIST[name] then
		MISC_LIST[name] = func
	end
end

function M:OnLogin()
	for name, func in next, MISC_LIST do
		if name and type(func) == "function" then
			func()
		end
	end

	-- Init
	M:NakedIcon()
	M:ExtendInstance()
	M:VehicleSeatMover()
	M:UIWidgetFrameMover()
	M:MoveMawBuffsFrame()
	M:MoveDurabilityFrame()
	M:MoveTicketStatusFrame()
	M:UpdateScreenShot()
	M:UpdateFasterLoot()
	M:TradeTargetInfo()
	M:MoveQuestTracker()
	M:BlockStrangerInvite()
	M:ToggleBossBanner()
	M:ToggleBossEmote()
	M:FasterMovieSkip()
	M:EnhanceDressup()
	M:FuckTrainSound()
	M:JerryWay()
	M:QuickMenuButton()
	M:BaudErrorFrameHelpTip()
	M:EnhancedPicker()
	M:UpdateMaxZoomLevel()

	-- Unregister talent event
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end

	-- Auto chatBubbles
	if NDuiADB["AutoBubbles"] then
		local function updateBubble()
			local name, instType = GetInstanceInfo()
			if name and instType == "raid" then
				SetCVar("chatBubbles", 1)
			else
				SetCVar("chatBubbles", 0)
			end
		end
		B:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end

	-- Readycheck sound on master channel
	B:RegisterEvent("READY_CHECK", function()
		PlaySound(SOUNDKIT.READY_CHECK, "master")
	end)

	-- Instant delete
	local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if deleteDialog.OnShow then
		hooksecurefunc(deleteDialog, "OnShow", function(self)
			if C.db["Misc"]["InstantDelete"] then
				self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end
		end)
	end

	-- Fix blizz bug in addon list
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if not owner then return end
		if owner:GetID() < 1 then return end
		_AddonTooltip_Update(owner)
	end
end

-- Hide boss banner
function M:ToggleBossBanner()
	if C.db["Misc"]["HideBossBanner"] then
		BossBanner:UnregisterAllEvents()
	else
		BossBanner:RegisterEvent("BOSS_KILL")
		BossBanner:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	end
end

-- Hide boss emote
function M:ToggleBossEmote()
	if C.db["Misc"]["HideBossEmote"] then
		RaidBossEmoteFrame:UnregisterAllEvents()
	else
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

-- Get Naked
function M:NakedIcon()
	local bu = CreateFrame("Button", nil, CharacterFrameInsetRight)
	bu:SetSize(31, 34)
	bu:SetPoint("RIGHT", PaperDollSidebarTab1, "LEFT", -4, -3)
	B.PixelIcon(bu, "Interface\\ICONS\\SPELL_SHADOW_TWISTEDFAITH", true)
	B.AddTooltip(bu, "ANCHOR_RIGHT", L["Get Naked"])

	local function UnequipItemInSlot(i)
		local action = EquipmentManager_UnequipItemInSlot(i)
		EquipmentManager_RunAction(action)
	end

	bu:SetScript("OnDoubleClick", function()
		for i = 1, 17 do
			local texture = GetInventoryItemTexture("player", i)
			if texture then
				UnequipItemInSlot(i)
			end
		end
	end)
end

-- Extend Instance
function M:ExtendInstance()
	local bu = CreateFrame("Button", nil, RaidInfoFrame)
	bu:SetPoint("TOPRIGHT", -35, -5)
	bu:SetSize(25, 25)
	B.PixelIcon(bu, GetSpellTexture(80353), true)
	bu.title = L["Extend Instance"]
	local tipStr = format(L["Extend Instance Tip"], DB.LeftButton, DB.RightButton)
	B.AddTooltip(bu, "ANCHOR_RIGHT", tipStr, "system")

	bu:SetScript("OnMouseUp", function(_, btn)
		for i = 1, GetNumSavedInstances() do
			local _, _, _, _, _, extended, _, isRaid = GetSavedInstanceInfo(i)
			if isRaid then
				if btn == "LeftButton" then
					if not extended then
						SetSavedInstanceExtend(i, true)		-- extend
					end
				else
					if extended then
						SetSavedInstanceExtend(i, false)	-- cancel
					end
				end
			end
		end
		RequestRaidInfo()
		RaidInfoFrame_Update()
	end)
end

-- Reanchor Vehicle
function M:VehicleSeatMover()
	local frame = CreateFrame("Frame", "NDuiVehicleSeatMover", UIParent)
	frame:SetSize(125, 125)
	B.Mover(frame, L["VehicleSeat"], "VehicleSeat", {"BOTTOMRIGHT", UIParent, -400, 30})

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame)
		end
	end)
end

-- Reanchor UIWidgetBelowMinimapContainerFrame
function M:UIWidgetFrameMover()
	local frame = CreateFrame("Frame", "NDuiUIWidgetMover", UIParent)
	frame:SetSize(200, 50)
	B.Mover(frame, L["UIWidgetFrame"], "UIWidgetFrame", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -20})

	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)
end

-- Reanchor MawBuffsBelowMinimapFrame
function M:MoveMawBuffsFrame()
	local frame = CreateFrame("Frame", "NDuiMawBuffsMover", UIParent)
	frame:SetSize(235, 28)
	local mover = B.Mover(frame, MAW_POWER_DESCRIPTION, "MawBuffs", {"TOPRIGHT", UIParent, -90, -225})
	frame:SetPoint("TOPLEFT", mover, 4, 12)

	hooksecurefunc(MawBuffsBelowMinimapFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)
end

-- Reanchor DurabilityFrame
function M:MoveDurabilityFrame()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -30)
		end
	end)
end

-- Reanchor TicketStatusFrame
function M:MoveTicketStatusFrame()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Reanchor ObjectiveTracker
function M:MoveQuestTracker()
	local frame = CreateFrame("Frame", "NDuiQuestMover", UIParent)
	frame:SetSize(240, 50)
	B.Mover(frame, L["QuestTracker"], "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -70, -55})

	local tracker = ObjectiveTrackerFrame
	tracker:ClearAllPoints()
	tracker:SetPoint("TOPRIGHT", frame)
	tracker:SetHeight(GetScreenHeight()*.65)
	tracker:SetClampedToScreen(false)
	tracker:SetMovable(true)
	if tracker:IsMovable() then tracker:SetUserPlaced(true) end
end

-- Achievement screenshot
function M:ScreenShotOnEvent()
	M.ScreenShotFrame.delay = 1
	M.ScreenShotFrame:Show()
end

function M:UpdateScreenShot()
	if not M.ScreenShotFrame then
		M.ScreenShotFrame = CreateFrame("Frame")
		M.ScreenShotFrame:Hide()
		M.ScreenShotFrame:SetScript("OnUpdate", function(self, elapsed)
			self.delay = self.delay - elapsed
			if self.delay < 0 then
				Screenshot()
				self:Hide()
			end
		end)
	end

	if C.db["Misc"]["Screenshot"] then
		B:RegisterEvent("ACHIEVEMENT_EARNED", M.ScreenShotOnEvent)
	else
		M.ScreenShotFrame:Hide()
		B:UnregisterEvent("ACHIEVEMENT_EARNED", M.ScreenShotOnEvent)
	end
end

-- Faster Looting
local lootDelay = 0
function M:DoFasterLoot()
	local thisTime = GetTime()
	if thisTime - lootDelay >= .3 then
		lootDelay = thisTime
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lootDelay = thisTime
		end
	end
end

function M:UpdateFasterLoot()
	if C.db["Misc"]["FasterLoot"] then
		B:RegisterEvent("LOOT_READY", M.DoFasterLoot)
	else
		B:UnregisterEvent("LOOT_READY", M.DoFasterLoot)
	end
end

-- TradeFrame hook
function M:TradeTargetInfo()
	local infoText = B.CreateFS(TradeFrame, 16, "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -5)

	local function updateColor()
		local r, g, b = B.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]
		if C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
			text = "|cffffff00"..FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00"..GUILD
		end
		infoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- Block invite from strangers
function M:BlockStrangerInvite()
	B:RegisterEvent("PARTY_INVITE_REQUEST", function(_, _, _, _, _, _, _, guid)
		if C.db["Misc"]["BlockInvite"] and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
			DeclineGroup()
			StaticPopup_Hide("PARTY_INVITE")
		end
	end)
end

-- Archaeology counts
do
	local function CalculateArches(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("|c0000FF00"..L["Arch Count"]..":")
		GameTooltip:AddLine(" ")
		local total = 0
		for i = 1, GetNumArchaeologyRaces() do
			local numArtifacts = GetNumArtifactsByRace(i)
			local count = 0
			for j = 1, numArtifacts do
				local completionCount = select(10, GetArtifactInfoByRace(i, j))
				count = count + completionCount
			end
			local name = GetArchaeologyRaceInfo(i)
			if numArtifacts > 1 then
				GameTooltip:AddDoubleLine(name..":", DB.InfoColor..count)
				total = total + count
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|c0000ff00"..TOTAL..":", "|cffff0000"..total)
		GameTooltip:Show()
	end

	local function AddCalculateIcon()
		local bu = CreateFrame("Button", nil, ArchaeologyFrameCompletedPage)
		bu:SetPoint("TOPRIGHT", -45, -45)
		bu:SetSize(35, 35)
		B.PixelIcon(bu, "Interface\\ICONS\\Ability_Iyyokuk_Calculate", true)
		bu:SetScript("OnEnter", CalculateArches)
		bu:SetScript("OnLeave", B.HideTooltip)
	end

	local function setupMisc(event, addon)
		if addon == "Blizzard_ArchaeologyUI" then
			AddCalculateIcon()
			-- Repoint Bar
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 150)
			B.CreateMF(ArcheologyDigsiteProgressBar)

			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)

	local newTitleString = ARCHAEOLOGY_DIGSITE_PROGRESS_BAR_TITLE.." %s/%s"
	local function updateArcTitle(_, ...)
		local numFindsCompleted, totalFinds = ...
		if ArcheologyDigsiteProgressBar then
			ArcheologyDigsiteProgressBar.BarTitle:SetFormattedText(newTitleString, numFindsCompleted, totalFinds)
		end
	end
	B:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST", updateArcTitle)
	B:RegisterEvent("ARCHAEOLOGY_FIND_COMPLETE", updateArcTitle)
end

-- Drag AltPowerbar
do
	local mover = CreateFrame("Frame", "NDuiAltBarMover", PlayerPowerBarAlt)
	mover:SetPoint("CENTER", UIParent, 0, -200)
	mover:SetSize(20, 20)
	B.CreateMF(PlayerPowerBarAlt, mover)

	hooksecurefunc(PlayerPowerBarAlt, "SetPoint", function(_, _, parent)
		if parent ~= mover then
			PlayerPowerBarAlt:ClearAllPoints()
			PlayerPowerBarAlt:SetPoint("CENTER", mover)
		end
	end)

	hooksecurefunc("UnitPowerBarAlt_SetUp", function(self)
		local statusFrame = self.statusFrame
		if statusFrame.enabled then
			statusFrame:Show()
			statusFrame.Hide = statusFrame.Show
		end
	end)

	local altPowerInfo = {
		text = L["Drag AltBar Tip"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "AltPower",
	}
	PlayerPowerBarAlt:HookScript("OnEnter", function(self)
		if not NDuiADB["Help"]["AltPower"] then
			HelpTip:Show(self, altPowerInfo)
		end
	end)
end

-- ALT+RightClick to buy a stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then return end
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Fix Drag Collections taint
do
	local done
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						B.CreateMF(CollectionsJournal)
					end
					done = true
				end
			end)
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			B.CreateMF(CollectionsJournal)
			B:UnregisterEvent(event, setupMisc)
		end
	end

	--B:RegisterEvent("ADDON_LOADED", setupMisc) -- FIXME: collections is not dragable atm
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				B:UnregisterEvent(event, setupMisc)
			end
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then return end

		local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_GuildNewsButton_OnEnter(self)
		end

		B:UnregisterEvent(event, fixGuildNews)
	end

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then return end

		local _CommunitiesGuildNewsButton_OnEnter = CommunitiesGuildNewsButton_OnEnter
		function CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_CommunitiesGuildNewsButton_OnEnter(self)
		end

		B:UnregisterEvent(event, fixCommunitiesNews)
	end

	B:RegisterEvent("ADDON_LOADED", fixGuildNews)
	B:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

local function skipOnKeyDown(self, key)
	if not C.db["Misc"]["FasterSkip"] then return end
	if key == "ESCAPE" then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog:Hide()
		end
	end
end

local function skipOnKeyUp(self, key)
	if not C.db["Misc"]["FasterSkip"] then return end
	if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog.confirmButton:Click()
		end
	end
end

function M:FasterMovieSkip()
	MovieFrame.closeDialog = MovieFrame.CloseDialog
	MovieFrame.closeDialog.confirmButton = MovieFrame.CloseDialog.ConfirmButton
	CinematicFrame.closeDialog.confirmButton = CinematicFrameCloseDialogConfirmButton

	MovieFrame:HookScript("OnKeyDown", skipOnKeyDown)
	MovieFrame:HookScript("OnKeyUp", skipOnKeyUp)
	CinematicFrame:HookScript("OnKeyDown", skipOnKeyDown)
	CinematicFrame:HookScript("OnKeyUp", skipOnKeyUp)
end

function M:EnhanceDressup()
	if not C.db["Misc"]["EnhanceDressup"] then return end

	local parent = _G.DressUpFrameResetButton
	local button = M:MailBox_CreatButton(parent, 80, 22, L["Undress"], {"RIGHT", parent, "LEFT", -1, 0})
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(_, btn)
		local actor = DressUpFrame.ModelScene:GetPlayerActor()
		if not actor then return end

		if btn == "LeftButton" then
			actor:Undress()
		else
			actor:UndressSlot(19)
		end
	end)

	B.AddTooltip(button, "ANCHOR_TOP", format(L["UndressButtonTip"], DB.LeftButton, DB.RightButton))

	DressUpFrame.LinkButton:SetWidth(80)
	DressUpFrame.LinkButton:SetText(SOCIAL_SHARE_TEXT)
end

function M:FuckTrainSound()
	local trainSounds = {
	--[[Blood Elf]]	"539219", "539203", "1313588", "1306531",
	--[[Draenei]]	"539516", "539730",
	--[[Dwarf]]		"539802", "539881",
	--[[Gnome]]		"540271", "540275",
	--[[Goblin]]	"541769", "542017",
	--[[Human]]		"540535", "540734",
	--[[Night Elf]]	"540870", "540947", "1316209", "1304872",
	--[[Orc]]		"541157", "541239",
	--[[Pandaren]]	"636621", "630296", "630298",
	--[[Tauren]]	"542818", "542896",
	--[[Troll]] 	"543085", "543093",
	--[[Undead]]	"542526", "542600",
	--[[Worgen]]	"542035", "542206", "541463", "541601",
	--[[Dark Iron]]	"1902030", "1902543",
	--[[Highmount]]	"1730534", "1730908",
	--[[Kul Tiran]]	"2531204", "2491898",
	--[[Lightforg]]	"1731282", "1731656",
	--[[MagharOrc]] "1951457", "1951458",
	--[[Mechagnom]] "3107651", "3107182",
	--[[Nightborn]]	"1732030", "1732405",
	--[[Void Elf]]	"1732785", "1733163",
	--[[Vulpera]] 	"3106252", "3106717",
	--[[Zandalari]]	"1903049", "1903522",
	}
	for _, soundID in pairs(trainSounds) do
		MuteSoundFile(soundID)
	end
end

function M:JerryWay()
	if IsAddOnLoaded("TomTom") then return end

	local pointString = DB.InfoColor.."|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s (%s, %s)%s]|h|r"

	local function GetCorrectCoord(x)
		x = tonumber(x)
		if x then
			if x > 100 then
				return 100
			elseif x < 0 then
				return 0
			end
			return x
		end
	end

	SlashCmdList["NDUI_JERRY_WAY"] = function(msg)
		msg = gsub(msg, "(%d)[%.,] (%d)", "%1 %2")
		local x, y, z = strmatch(msg, "(%S+)%s(%S+)(.*)")
		if x and y then
			local mapID = C_Map_GetBestMapForUnit("player")
			if mapID then
				local mapInfo = C_Map_GetMapInfo(mapID)
				local mapName = mapInfo and mapInfo.name
				if mapName then
					x = GetCorrectCoord(x)
					y = GetCorrectCoord(y)
					if x and y then
						print(format(pointString, mapID, x*100, y*100, mapName, x, y, z or ""))
					end
				end
			end
		end
	end
	SLASH_NDUI_JERRY_WAY1 = "/way"
end

function M:BaudErrorFrameHelpTip()
	if not IsAddOnLoaded("!BaudErrorFrame") then return end
	local button, count = _G.BaudErrorFrameMinimapButton, _G.BaudErrorFrameMinimapCount
	if not button then return end

	local errorInfo = {
		text = L["BaudErrorTip"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		alignment = HelpTip.Alignment.Right,
		offsetX = -15,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "BaudError",
	}
	hooksecurefunc(count, "SetText", function(_, text)
		if not NDuiADB["Help"]["BaudError"] then
			text = tonumber(text)
			if text and text > 0 then
				HelpTip:Show(button, errorInfo)
			end
		end
	end)
end

-- Buttons to enhance popup menu
function M:MenuButton_AddFriend()
	C_FriendList_AddFriend(M.MenuButtonName)
end

function M:MenuButton_CopyName()
	local editBox = ChatEdit_ChooseBoxForSend()
	local hasText = (editBox:GetText() ~= "")
	ChatEdit_ActivateChat(editBox)
	editBox:Insert(M.MenuButtonName)
	if not hasText then editBox:HighlightText() end
end

function M:MenuButton_GuildInvite()
	GuildInvite(M.MenuButtonName)
end

function M:QuickMenuButton()
	if not C.db["Misc"]["MenuButton"] then return end

	local menuList = {
		{text = ADD_FRIEND, func = M.MenuButton_AddFriend, color = {0, .6, 1}},
		{text = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, ""), func = M.MenuButton_GuildInvite, color = {0, .8, 0}},
		{text = COPY_NAME, func = M.MenuButton_CopyName, color = {1, 0, 0}},
	}

	local frame = CreateFrame("Frame", "NDuiMenuButtonFrame", DropDownList1)
	frame:SetSize(10, 10)
	frame:SetPoint("TOPLEFT")
	frame:Hide()
	for i = 1, 3 do
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(25, 10)
		button:SetPoint("TOPLEFT", frame, (i-1)*28 + 2, -2)
		B.PixelIcon(button, nil, true)
		button.Icon:SetColorTexture(unpack(menuList[i].color))
		button:SetScript("OnClick", menuList[i].func)
		B.AddTooltip(button, "ANCHOR_TOP", menuList[i].text)
	end

	hooksecurefunc("ToggleDropDownMenu", function(level, _, dropdownMenu)
		if level and level > 1 then return end

		local name = dropdownMenu.name
		local unit = dropdownMenu.unit
		local isPlayer = unit and UnitIsPlayer(unit)
		local isFriendMenu = dropdownMenu == FriendsDropDown -- menus on FriendsFrame
		if not name or (not isPlayer and not dropdownMenu.chatType and not isFriendMenu) then
			frame:Hide()
			return
		end

		local gameAccountInfo = dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo
		if gameAccountInfo and gameAccountInfo.characterName and gameAccountInfo.realmName then
			M.MenuButtonName = gameAccountInfo.characterName.."-"..gameAccountInfo.realmName
			frame:Show()
		else
			local server = dropdownMenu.server
			if not server or server == "" then
				server = DB.MyRealm
			end
			M.MenuButtonName = name.."-"..server
			frame:Show()
		end
	end)
end

-- Enhanced ColorPickerFrame
local function translateColor(r)
	if not r then r = "ff" end
	return tonumber(r, 16)/255
end

function M:EnhancedPicker_UpdateColor()
	local r, g, b = strmatch(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
end

local function GetBoxColor(box)
	local r = box:GetText()
	r = tonumber(r)
	if not r or r < 0 or r > 255 then r = 255 end
	return r
end

local function updateColorRGB(self)
	local r = GetBoxColor(_G.ColorPickerFrame.__boxR)
	local g = GetBoxColor(_G.ColorPickerFrame.__boxG)
	local b = GetBoxColor(_G.ColorPickerFrame.__boxB)
	self.colorStr = format("%02x%02x%02x", r, g, b)
	M.EnhancedPicker_UpdateColor(self)
end

local function updateColorStr(self)
	self.colorStr = self:GetText()
	M.EnhancedPicker_UpdateColor(self)
end

local function createCodeBox(width, index, text)
	local box = B.CreateEditBox(_G.ColorPickerFrame, width, 22)
	box:SetMaxLetters(index == 4 and 6 or 3)
	box:SetTextInsets(0, 0, 0, 0)
	box:SetPoint("TOPLEFT", _G.ColorSwatch, "BOTTOMLEFT", 0, -index*24 + 2)
	B.CreateFS(box, 14, text, "system", "LEFT", -15, 0)
	if index == 4 then
		box:HookScript("OnEnterPressed", updateColorStr)
	else
		box:HookScript("OnEnterPressed", updateColorRGB)
	end
	return box
end

function M:EnhancedPicker()
	local pickerFrame = _G.ColorPickerFrame
	pickerFrame:SetHeight(250)
	B.CreateMF(pickerFrame.Header, pickerFrame) -- movable by header
	_G.OpacitySliderFrame:SetPoint("TOPLEFT", _G.ColorSwatch, "TOPRIGHT", 50, 0)

	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 22)
	colorBar:SetPoint("BOTTOM", 0, 38)

	local count = 0
	for name, class in pairs(DB.ClassList) do
		local value = DB.ClassColors[class]
		if value then
			local bu = B.CreateButton(colorBar, 22, 22, true)
			bu.Icon:SetColorTexture(value.r, value.g, value.b)
			bu:SetPoint("LEFT", count*22, 0)
			bu.colorStr = value.colorStr
			bu:SetScript("OnClick", M.EnhancedPicker_UpdateColor)
			B.AddTooltip(bu, "ANCHOR_TOP", "|c"..value.colorStr..name)

			count = count + 1
		end
	end
	colorBar:SetWidth(count*22)

	pickerFrame.__boxR = createCodeBox(45, 1, "|cffff0000R")
	pickerFrame.__boxG = createCodeBox(45, 2, "|cff00ff00G")
	pickerFrame.__boxB = createCodeBox(45, 3, "|cff0000ffB")
	pickerFrame.__boxH = createCodeBox(70, 4, "#")

	pickerFrame:HookScript("OnColorSelect", function(self)
		local r, g, b = self:GetColorRGB()
		r = B:Round(r*255)
		g = B:Round(g*255)
		b = B:Round(b*255)

		self.__boxR:SetText(r)
		self.__boxG:SetText(g)
		self.__boxB:SetText(b)
		self.__boxH:SetText(format("%02x%02x%02x", r, g, b))
	end)
end

function M:UpdateMaxZoomLevel()
	SetCVar("cameraDistanceMaxZoomFactor", C.db["Misc"]["MaxZoom"])
end