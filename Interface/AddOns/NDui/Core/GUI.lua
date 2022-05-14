local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:RegisterModule("GUI")

local unpack, strfind, gsub = unpack, strfind, gsub
local tonumber, pairs, ipairs, next, type, tinsert = tonumber, pairs, ipairs, next, type, tinsert
local cr, cg, cb = DB.r, DB.g, DB.b
local guiTab, guiPage, f = {}, {}

-- Default Settings
G.DefaultSettings = {
	BFA = false,
	Mover = {},
	InternalCD = {},
	AuraWatchMover = {},
	TempAnchor = {},
	AuraWatchList = {
		Switcher = {},
	},
	Actionbar = {
		Enable = true,
		Hotkeys = true,
		Macro = true,
		Count = true,
		Classcolor = false,
		Cooldown = true,
		MmssTH = 60,
		TenthTH = 3,
		Bar4Fader = false,
		Bar5Fader = true,
		BindType = 1,
		OverrideWA = false,
		MicroMenu = true,
		CustomBar = false,
		BarXFader = false,
		CustomBarButtonSize = 34,
		CustomBarNumButtons = 12,
		CustomBarNumPerRow = 12,
		ShowStance = true,
		EquipColor = false,
		AspectBar = true,
		AspectSize = 25,
		VerticleAspect = true,
		VehButtonSize = 34,

		Bar1Size = 34,
		Bar1Font = 12,
		Bar1Num = 12,
		Bar1PerRow = 12,
		Bar2Size = 34,
		Bar2Font = 12,
		Bar2Num = 12,
		Bar2PerRow = 12,
		Bar3Size = 32,
		Bar3Font = 12,
		Bar3Num = 0,
		Bar3PerRow = 12,
		Bar4Size = 32,
		Bar4Font = 12,
		Bar4Num = 12,
		Bar4PerRow = 1,
		Bar5Size = 32,
		Bar5Font = 12,
		Bar5Num = 12,
		Bar5PerRow = 1,
		BarPetSize = 26,
		BarPetFont = 12,
		BarPetNum = 10,
		BarPetPerRow = 10,
		BarStanceSize = 30,
		BarStanceFont = 12,
		BarStancePerRow = 10,
	},
	Bags = {
		Enable = true,
		IconSize = 34,
		FontSize = 12,
		BagsWidth = 12,
		BankWidth = 14,
		BagsiLvl = true,
		BagSortMode = 1,
		ItemFilter = true,
		CustomItems = {},
		CustomNames = {},
		GatherEmpty = false,
		ShowNewItem = true,
		SplitCount = 1,
		SpecialBagsColor = false,
		iLvlToShow = 1,
		BagsPerRow = 6,
		BankPerRow = 10,
		HideWidgets = true,

		FilterJunk = true,
		FilterAmmo = true,
		FilterConsumable = true,
		FilterEquipment = true,
		FilterLegendary = true,
		FilterFavourite = true,
		FilterGoods = false,
		FilterQuest = false,
	},
	Auras = {
		Reminder = true,
		Totems = true,
		VerticalTotems = true,
		TotemSize = 32,
		ClassAuras = false,
		BuffFrame = true,
		HideBlizBuff = false,
		ReverseBuff = false,
		BuffSize = 30,
		BuffsPerRow = 16,
		ReverseDebuff = false,
		DebuffSize = 30,
		DebuffsPerRow = 16,
	},
	AuraWatch = {
		Enable = true,
		ClickThrough = false,
		IconScale = 1,
		WatchSpellRank = true,
	},
	UFs = {
		Enable = true,
		Portrait = true,
		ShowAuras = true,
		Arena = true,
		Castbars = true,
		SwingBar = false,
		SwingWidth = 275,
		SwingHeight = 3,
		SwingTimer = false,
		OffOnTop = false,
		RaidFrame = true,
		NumGroups = 8,
		RaidDirec = 1,
		RaidRows = 1,
		SimpleMode = false,
		SMRScale = 10,
		SMRPerCol = 20,
		SMRGroupBy = 1,
		SMRGroups = 6,
		SMRDirec = 1,
		InstanceAuras = true,
		DispellOnly = false,
		RaidDebuffScale = 1,
		RaidHealthColor = 1,
		ShowSolo = false,
		RaidWidth = 80,
		RaidHeight = 32,
		RaidPowerHeight = 2,
		RaidHPMode = 1,
		AurasClickThrough = false,
		CombatText = true,
		HotsDots = true,
		AutoAttack = true,
		FCTOverHealing = false,
		FCTFontSize = 18,
		PetCombatText = true,
		ScrollingCT = false,
		RaidClickSets = false,
		TeamIndex = false,
		ClassPower = true,
		CPWidth = 150,
		CPHeight = 5,
		CPxOffset = 12,
		CPyOffset = -2,
		LagString = true,
		RaidBuffIndicator = true,
		PartyFrame = true,
		PartyDirec = 2,
		PWOnRight = false,
		PartyWidth = 100,
		PartyHeight = 32,
		PartyPowerHeight = 2,
		PartyPetFrame = false,
		PartyPetWidth = 100,
		PartyPetHeight = 22,
		PartyPetPowerHeight = 2,
		PartyPetPerCol = 5,
		PartyPetMaxCol = 1,
		PartyPetVsby = 1,
		PetDirec = 1,
		HealthColor = 1,
		BuffIndicatorType = 1,
		BuffIndicatorScale = 1,
		EnergyTicker = false,
		UFTextScale = 1,
		ToToT = false,
		RaidTextScale = 1,
		FrequentHealth = false,
		HealthFrequency = .2,
		ShowRaidBuff = false,
		RaidBuffSize = 12,
		BuffClickThru = true,
		ShowRaidDebuff = true,
		RaidDebuffSize = 12,
		DebuffClickThru = true,
		SmartRaid = false,
		Desaturate = true,
		DebuffColor = false,
		CCName = true,
		RCCName = true,
		HideTip = false,

		PlayerWidth = 245,
		PlayerHeight = 24,
		PlayerPowerHeight = 4,
		PlayerPowerOffset = 2,
		PlayerHPTag = 2,
		PlayerMPTag = 4,
		FocusWidth = 200,
		FocusHeight = 22,
		FocusPowerHeight = 3,
		FocusPowerOffset = 2,
		FocusHPTag = 2,
		FocusMPTag = 4,
		PetWidth = 120,
		PetHeight = 18,
		PetPowerHeight = 2,
		PetHPTag = 4,
		BossWidth = 150,
		BossHeight = 22,
		BossPowerHeight = 2,
		BossHPTag = 5,
		BossMPTag = 5,

		CastingColor = {r=.3, g=.7, b=1},
		--NotInterruptColor = {r=1, g=.5, b=.5},
		PlayerCB = true,
		PlayerCBWidth = 300,
		PlayerCBHeight = 20,
		TargetCB = true,
		TargetCBWidth = 280,
		TargetCBHeight = 20,
		FocusCB = true,
		FocusCBWidth = 320,
		FocusCBHeight = 20,

		PlayerNumBuff = 20,
		PlayerNumDebuff = 20,
		PlayerBuffType = 1,
		PlayerDebuffType = 1,
		PlayerAurasPerRow = 9,
		TargetNumBuff = 20,
		TargetNumDebuff = 20,
		TargetBuffType = 2,
		TargetDebuffType = 2,
		TargetAurasPerRow = 9,
		FocusNumBuff = 20,
		FocusNumDebuff = 20,
		FocusBuffType = 3,
		FocusDebuffType = 2,
		FocusAurasPerRow = 8,
		ToTNumBuff = 6,
		ToTNumDebuff = 6,
		ToTBuffType = 1,
		ToTDebuffType = 1,
		ToTAurasPerRow = 5,
		PetNumBuff = 6,
		PetNumDebuff = 6,
		PetBuffType = 1,
		PetDebuffType = 1,
		PetAurasPerRow = 5,
		BossNumBuff = 6,
		BossNumDebuff = 6,
		BossBuffType = 2,
		BossDebuffType = 3,
		BossBuffPerRow = 6,
		BossDebuffPerRow = 6,
	},
	Chat = {
		Sticky = false,
		Lock = true,
		Invite = true,
		Freedom = true,
		Keyword = "raid",
		Oldname = false,
		GuildInvite = true,
		EnableFilter = true,
		Matches = 1,
		BlockAddonAlert = true,
		ChatMenu = true,
		WhisperColor = true,
		ChatItemLevel = true,
		Chatbar = true,
		ChatWidth = 380,
		ChatHeight = 190,
		BlockStranger = false,
		BlockSpammer = false,
		ChatBGType = 2,
		WhisperSound = true,
		BottomBox = false,
		SysFont = false,
	},
	Map = {
		DisableMap = false,
		Clock = false,
		CombatPulse = true,
		MapScale = .7,
		MinimapScale = 1.4,
		MinimapSize = 140,
		ShowRecycleBin = true,
		WhoPings = true,
		MapReveal = true,
		MapRevealGlow = true,
		MapFader = true,
		DiffFlag = true,
		EasyVolume = true,
	},
	Nameplate = {
		Enable = true,
		maxAuras = 5,
		PlateAuras = true,
		AuraSize = 28,
		AuraFilter = 3,
		FriendlyCC = false,
		HostileCC = true,
		TankMode = false,
		TargetIndicator = 5,
		CustomUnitColor = true,
		CustomColor = {r=0, g=.8, b=.3},
		UnitList = "",
		ShowPowerList = "",
		VerticalSpacing = .7,
		ShowPlayerPlate = false,
		PPWidth = 175,
		PPBarHeight = 5,
		PPHealthHeight = 5,
		PPPowerHeight = 5,
		PPPowerText = false,
		EnergyTicker = true,
		NameType = 5,
		HealthType = 2,
		SecureColor = {r=1, g=0, b=1},
		TransColor = {r=1, g=.8, b=0},
		InsecureColor = {r=1, g=0, b=0},
		--OffTankColor = {r=.2, g=.7, b=.5},
		--DPSRevertThreat = false,
		PPFadeout = true,
		PPFadeoutAlpha = 0,
		TargetPower = false,
		MinScale = 1,
		MinAlpha = 1,
		Desaturate = true,
		DebuffColor = false,
		QuestIndicator = true,
		NameOnlyMode = false,
		ExecuteRatio = 0,
		ColoredTarget = false,
		TargetColor = {r=0, g=.6, b=1},
		ColoredFocus = false,
		FocusColor = {r=1, g=.8, b=0},
		CastbarGlow = true,
		CastTarget = false,
		Interruptor = true,
		PlateRange = 41,
		ClampTarget = true,
		FriendPlate = false,
		EnemyThru = false,
		FriendlyThru = false,
		BlockDBM = true,
		Dispellable = true,
		UnitTargeted = false,
		ColorByDot = false,
		ColorDots = "",
		DotColor = {r=1, g=.5, b=.2},

		PlateWidth = 190,
		PlateHeight = 8,
		PlateCBHeight = 8,
		PlateCBOffset = -1,
		CBTextSize = 14,
		NameTextSize = 14,
		HealthTextSize = 16,
		HealthTextOffset = 5,
		FriendPlateWidth = 190,
		FriendPlateHeight = 8,
		FriendPlateCBHeight = 8,
		FriendPlateCBOffset = -1,
		FriendCBTextSize = 14,
		FriendNameSize = 14,
		FriendHealthSize = 16,
		FriendHealthOffset = 5,
		NameOnlyTextSize = 14,
		NameOnlyTitleSize = 12,
		NameOnlyTitle = true,
		NameOnlyGuild = false,
		CVarOnlyNames = false,
		CVarShowNPCs = false,
	},
	Skins = {
		DBM = true,
		Skada = true,
		Bigwigs = true,
		TMW = true,
		WeakAuras = true,
		InfobarLine = true,
		ChatbarLine = true,
		MenuLine = true,
		ClassLine = true,
		Details = true,
		QuestTracker = true,
		Recount = true,
		ResetRecount = true,
		ToggleDirection = 1,
		TradeSkills = true,
		BlizzardSkins = true,
		SkinAlpha = .5,
		DefaultBags = false,
		FlatMode = false,
		FontOutline = true,
		Loot = true,
		Shadow = true,
		BgTex = true,
		GreyBD = false,
		FontScale = 1,
	},
	Tooltip = {
		CombatHide = false,
		CursorMode = 1,
		ItemQuality = false,
		TipAnchor = 4,
		HideRank = false,
		FactionIcon = true,
		TargetBy = true,
		Scale = 1,
		HideRealm = false,
		HideTitle = false,
		HideJunkGuild = true,
		HideAllID = false,
	},
	Misc = {
		Mail = true,
		MailSaver = false,
		MailTarget = "",
		ItemLevel = true,
		GemNEnchant = true,
		ShowItemLevel = true,
		HideErrors = true,
		Focuser = true,
		ExpRep = true,
		InterruptAlert = false,
		OwnInterrupt = true,
		DispellAlert = false,
		OwnDispell = true,
		InstAlertOnly = true,
		BrokenAlert = false,
		LoCAlert = false,
		FasterLoot = true,
		AutoQuest = false,
		IgnoreQuestNPC = {},
		QuestNotification = false,
		QuestProgress = false,
		OnlyCompleteRing = false,
		ExplosiveCache = {},
		PlacedItemAlert = false,
		MenuButton = true,
		AutoDismount = true,
		TradeTabs = true,
		InstantDelete = true,
		RaidTool = true,
		--RMRune = false,
		DBMCount = "10",
		EasyMarkKey = 1,
		EasyMarking = true,
		BlockInvite = false,
		SendActionCD = false,
		StatOrder = "12345",
		StatExpand = true,
		PetHappiness = true,
		InfoStrLeft = "[guild][friend][ping][fps][zone]",
		InfoStrRight = "[spec][dura][gold][time]",
		InfoSize = 13,
		MaxAddOns = 12,
		MaxZoom = 2.6,
	},
	Tutorial = {
		Complete = false,
	},
}

G.AccountSettings = {
	ChatFilterList = "%*",
	ChatFilterWhiteList = "",
	TimestampFormat = 4,
	NameplateFilter = {[1]={}, [2]={}},
	RaidDebuffs = {},
	Changelog = {},
	totalGold = {},
	ShowSlots = false,
	RepairType = 1,
	AutoSell = false,
	GuildSortBy = 1,
	GuildSortOrder = true,
	DetectVersion = DB.Version,
	LockUIScale = false,
	UIScale = .71,
	NumberFormat = 1,
	VersionCheck = true,
	DBMRequest = false,
	SkadaRequest = false,
	BWRequest = false,
	RaidAuraWatch = {},
	CornerSpells = {},
	RaidClickSets = {},
	TexStyle = 2,
	KeystoneInfo = {},
	AutoBubbles = false,
	DisableInfobars = false,
	ContactList = {},
	CustomJunkList = {},
	ProfileIndex = {},
	ProfileNames = {},
	Help = {},
	CustomTex = "",
	MajorSpells = {},
	SmoothAmount = .25,
	AutoRecycle = false,
	IgnoredButtons = "",
}

-- Initial settings
G.TextureList = {
	[1] = {texture = DB.normTex, name = L["Highlight"]},
	[2] = {texture = DB.gradTex, name = L["Gradient"]},
	[3] = {texture = DB.flatTex, name = L["Flat"]},
}

local function InitialSettings(source, target, fullClean)
	for i, j in pairs(source) do
		if type(j) == "table" then
			if target[i] == nil then target[i] = {} end
			for k, v in pairs(j) do
				if target[i][k] == nil then
					target[i][k] = v
				end
			end
		else
			if target[i] == nil then target[i] = j end
		end
	end

	for i, j in pairs(target) do
		if source[i] == nil then target[i] = nil end
		if type(j) == "table" and fullClean then
			for k, v in pairs(j) do
				if type(v) ~= "table" and source[i] and source[i][k] == nil then
					target[i][k] = nil
				end
			end
		end
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "NDui" then return end

	InitialSettings(G.AccountSettings, NDuiADB)
	if not next(NDuiPDB) then
		for i = 1, 5 do NDuiPDB[i] = {} end
	end

	if not NDuiADB["ProfileIndex"][DB.MyFullName] then
		NDuiADB["ProfileIndex"][DB.MyFullName] = 1
	end

	if NDuiADB["ProfileIndex"][DB.MyFullName] == 1 then
		C.db = NDuiDB
		if not C.db["BFA"] then
			wipe(C.db)
			C.db["BFA"] = true
		end
	else
		C.db = NDuiPDB[NDuiADB["ProfileIndex"][DB.MyFullName] - 1]
	end
	-- Transfer favourite items START
	if C.db["Bags"] and C.db["Bags"]["FavouriteItems"] and next(C.db["Bags"]["FavouriteItems"]) then
		for itemID in pairs(C.db["Bags"]["FavouriteItems"]) do
			if not C.db["Bags"]["CustomItems"] then
				C.db["Bags"]["CustomItems"] = {}
			end
			C.db["Bags"]["CustomItems"][itemID] = 1
		end
		C.db["Bags"]["FavouriteItems"] = nil
	end
	-- Transfer favourite items END
	InitialSettings(G.DefaultSettings, C.db, true)

	B:SetupUIScale(true)
	if NDuiADB["CustomTex"] ~= "" then
		DB.normTex = "Interface\\"..NDuiADB["CustomTex"]
	else
		if not G.TextureList[NDuiADB["TexStyle"]] then
			NDuiADB["TexStyle"] = 2 -- reset value if not exists
		end
		DB.normTex = G.TextureList[NDuiADB["TexStyle"]].texture
	end

	self:UnregisterAllEvents()
end)

-- Callbacks
local function setupBagFilter()
	G:SetupBagFilter(guiPage[2])
end

local function setupUnitFrame()
	G:SetupUnitFrame(guiPage[3])
end

local function setupCastbar()
	G:SetupCastbar(guiPage[3])
end

local function setupClassPower()
	G:SetupUFClassPower(guiPage[3])
end

local function setupUFAuras()
	G:SetupUFAuras(guiPage[3])
end

local function setupSwingBars()
	G:SetupSwingBars(guiPage[3])
end

local function setupRaidFrame()
	G:SetupRaidFrame(guiPage[4])
end

local function setupSimpleRaidFrame()
	G:SetupSimpleRaidFrame(guiPage[4])
end

local function setupPartyFrame()
	G:SetupPartyFrame(guiPage[4])
end

local function setupPartyPetFrame()
	G:SetupPartyPetFrame(guiPage[4])
end

local function setupRaidDebuffs()
	G:SetupRaidDebuffs(guiPage[4])
end

local function setupClickCast()
	G:SetupClickCast(guiPage[4])
end

local function setupBuffIndicator()
	G:SetupBuffIndicator(guiPage[4])
end

local function setupNameplateFilter()
	G:SetupNameplateFilter(guiPage[5])
end

local function setupNameplateSize()
	G:SetupNameplateSize(guiPage[5])
end

local function setupNameOnlySize()
	G:SetupNameOnlySize(guiPage[5])
end

local function setupPlateCastbarGlow()
	G:PlateCastbarGlow(guiPage[5])
end

local function setupBuffFrame()
	G:SetupBuffFrame(guiPage[7])
end

local function setupAuraWatch()
	f:Hide()
	SlashCmdList["NDUI_AWCONFIG"]()
end

local function updateBagSortOrder()
	SetSortBagsRightToLeft(C.db["Bags"]["BagSortMode"] == 1)
end

local function updateBagStatus()
	B:GetModule("Bags"):UpdateAllBags()
end

local function updateBagAnchor()
	B:GetModule("Bags"):UpdateAllAnchors()
end

local function updateBagSize()
	B:GetModule("Bags"):UpdateBagSize()
end

local function setupActionBar()
	G:SetupActionBar(guiPage[1])
end

local function setupStanceBar()
	G:SetupStanceBar(guiPage[1])
end

local function updateCustomBar()
	B:GetModule("Actionbar"):UpdateCustomBar()
end

local function updateHotkeys()
	local Bar = B:GetModule("Actionbar")
	for _, button in pairs(Bar.buttons) do
		ActionButton_UpdateHotkeys(button, button.buttonType)
	end
end

local function updateEquipColor()
	local Bar = B:GetModule("Actionbar")
	for _, button in pairs(Bar.buttons) do
		if button.Border and button.action then
			Bar.UpdateEquipItemColor(button)
		end
	end
end

local function updateAspectStatus()
	B:GetModule("Actionbar"):UpdateAspectStatus()
end

local function toggleAspectBar()
	B:GetModule("Actionbar"):ToggleAspectBar()
end

local function toggleBarFader(self)
	local name = gsub(self.__value, "Fader", "")
	B:GetModule("Actionbar"):ToggleBarFader(name)
end

local function updateReminder()
	B:GetModule("Auras"):InitReminder()
end

local function refreshTotemBar()
	if not C.db["Auras"]["Totems"] then return end
	B:GetModule("Auras"):TotemBar_Init()
end

local function updateChatSticky()
	B:GetModule("Chat"):ChatWhisperSticky()
end

local function updateWhisperList()
	B:GetModule("Chat"):UpdateWhisperList()
end

local function updateFilterList()
	B:GetModule("Chat"):UpdateFilterList()
end

local function updateFilterWhiteList()
	B:GetModule("Chat"):UpdateFilterWhiteList()
end

local function updateChatSize()
	B:GetModule("Chat"):UpdateChatSize()
end

local function toggleChatBackground()
	B:GetModule("Chat"):ToggleChatBackground()
end

local function toggleLanguageFilter()
	B:GetModule("Chat"):ToggleLanguageFilter()
end

local function toggleEditBoxAnchor()
	B:GetModule("Chat"):ToggleEditBoxAnchor()
end

local function updateToggleDirection()
	B:GetModule("Skins"):RefreshToggleDirection()
end

local function updatePlateCVars()
	B:GetModule("UnitFrames"):UpdatePlateCVars()
end

local function updateCustomUnitList()
	B:GetModule("UnitFrames"):CreateUnitTable()
end

local function updatePowerUnitList()
	B:GetModule("UnitFrames"):CreatePowerUnitTable()
end

local function refreshColorDots()
	B:GetModule("UnitFrames"):RefreshColorDots()
end

local function refreshNameplates()
	B:GetModule("UnitFrames"):RefreshAllPlates()
end

local function updateClickThru()
	B:GetModule("UnitFrames"):UpdatePlateClickThru()
end

local function togglePlateVisibility()
	B:GetModule("UnitFrames"):TogglePlateVisibility()
end

local function togglePlayerPlate()
	refreshNameplates()
	B:GetModule("UnitFrames"):TogglePlayerPlate()
end

local function toggleTargetClassPower()
	refreshNameplates()
	B:GetModule("UnitFrames"):ToggleTargetClassPower()
end

local function updateUFTextScale()
	B:GetModule("UnitFrames"):UpdateTextScale()
end

local function toggleUFClassPower()
	B:GetModule("UnitFrames"):ToggleUFClassPower()
end

local function toggleAllAuras()
	B:GetModule("UnitFrames"):ToggleAllAuras()
end

local function updateRaidTextScale()
	B:GetModule("UnitFrames"):UpdateRaidTextScale()
end

local function refreshRaidFrameIcons()
	B:GetModule("UnitFrames"):RefreshRaidFrameIcons()
end

local function updateRaidAuras()
	B:GetModule("UnitFrames"):UpdateRaidAuras()
end

local function updateRaidHealthMethod()
	B:GetModule("UnitFrames"):UpdateRaidHealthMethod()
end

local function toggleCastBarLatency()
	B:GetModule("UnitFrames"):ToggleCastBarLatency()
end

local function toggleSwingBars()
	B:GetModule("UnitFrames"):ToggleSwingBars()
end

local function updateSmoothingAmount()
	B:SetSmoothingAmount(NDuiADB["SmoothAmount"])
end

local function updateAllHeaders()
	B:GetModule("UnitFrames"):UpdateAllHeaders()
end

local function updateTeamIndex()
	local UF = B:GetModule("UnitFrames")
	if UF.CreateAndUpdateRaidHeader then
		UF:CreateAndUpdateRaidHeader()
		UF:UpdateRaidTeamIndex()
	end
	updateRaidTextScale()
end

local function updateMapFader()
	B:GetModule("Maps"):MapFader()
end

local function refreshPlateByEvents()
	B:GetModule("UnitFrames"):RefreshPlateByEvents()
end

local function updateScrollingFont()
	B:GetModule("UnitFrames"):UpdateScrollingFont()
end

local function updateMinimapScale()
	B:GetModule("Maps"):UpdateMinimapScale()
end

local function showMinimapClock()
	B:GetModule("Maps"):ShowMinimapClock()
end

local function updateInterruptAlert()
	B:GetModule("Misc"):InterruptAlert()
end

local function updateQuestNotification()
	B:GetModule("Misc"):QuestNotification()
end

local function updateFasterLoot()
	B:GetModule("Misc"):UpdateFasterLoot()
end

local function updateErrorBlocker()
	B:GetModule("Misc"):UpdateErrorBlocker()
end

local function togglePetHappiness()
	B:GetModule("Misc"):TogglePetHappiness()
end

local function updateMaxZoomLevel()
	B:GetModule("Misc"):UpdateMaxZoomLevel()
end

local function updateInfobarAnchor(self)
	if self:GetText() == "" then
		self:SetText(self.__default)
		C.db[self.__key][self.__value] = self:GetText()
	end

	if not NDuiADB["DisableInfobars"] then
		B:GetModule("Infobar"):Infobar_UpdateAnchor()
	end
end

local function updateInfobarSize()
	B:GetModule("Infobar"):UpdateInfobarSize()
end

local function updateSkinAlpha()
	for _, frame in pairs(C.frames) do
		frame:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
	end
end

StaticPopupDialogs["RESET_DETAILS"] = {
	text = L["Reset Details check"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		B:GetModule("Skins"):ResetDetailsAnchor(true)
	end,
	whileDead = 1,
}
local function resetDetails()
	StaticPopup_Show("RESET_DETAILS")
end

local function AddTextureToOption(parent, index)
	local tex = parent[index]:CreateTexture()
	tex:SetInside(nil, 4, 4)
	tex:SetTexture(G.TextureList[index].texture)
	tex:SetVertexColor(cr, cg, cb)
end

-- Config
local HeaderTag = "|cff00cc4c"
local NewTag = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"
G.HealthValues = {DISABLE, L["ShowHealthDefault"], L["ShowHealthCurMax"], L["ShowHealthCurrent"], L["ShowHealthPercent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"]}

G.TabList = {
	L["Actionbar"],
	L["Bags"],
	NewTag..L["Unitframes"],
	L["RaidFrame"],
	NewTag..L["Nameplate"],
	L["PlayerPlate"],
	L["Auras"],
	L["Raid Tools"],
	NewTag..L["ChatFrame"],
	NewTag..L["Maps"],
	L["Skins"],
	L["Tooltip"],
	L["Misc"],
	L["UI Settings"],
	L["Profile"],
}

G.OptionList = { -- type, key, value, name, horizon, doubleline
	[1] = {
		{1, "Actionbar", "Enable", HeaderTag..L["Enable Actionbar"], nil, setupActionBar},
		{},--blank
		{1, "Actionbar", "MicroMenu", L["Micromenu"], nil, nil, nil, L["MicroMenuTip"]},
		{1, "Actionbar", "ShowStance", L["ShowStanceBar"], true, setupStanceBar},
		{1, "Actionbar", "Bar4Fader", L["Bar4 Fade"].."*", nil, nil, toggleBarFader},
		{1, "Actionbar", "Bar5Fader", L["Bar5 Fade"].."*", true, nil, toggleBarFader},
		{},--blank
		{1, "Actionbar", "CustomBar", HeaderTag..L["Enable CustomBar"], nil, nil, nil, L["CustomBarTip"]},
		{1, "Actionbar", "BarXFader", L["CustomBarFader"].."*", nil, nil, toggleBarFader},
		{3, "Actionbar", "CustomBarButtonSize", L["ButtonSize"].."*", true, {20, 80, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumButtons", L["MaxButtons"].."*", nil, {1, 12, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumPerRow", L["ButtonsPerRow"].."*", true, {1, 12, 1}, updateCustomBar},
		{},--blank
		{1, "Actionbar", "Cooldown", HeaderTag..L["Show Cooldown"]},
		{1, "Actionbar", "OverrideWA", L["HideCooldownOnWA"].."*", true},
		{3, "Actionbar", "MmssTH", L["MmssThreshold"].."*", nil, {60, 600, 1}, nil, L["MmssThresholdTip"]},
		{3, "Actionbar", "TenthTH", L["TenthThreshold"].."*", true, {0, 60, 1}, nil, L["TenthThresholdTip"]},
		{},--blank
		{1, "Actionbar", "Hotkeys", L["Actionbar Hotkey"].."*", nil, nil, updateHotkeys},
		{1, "Actionbar", "Macro", L["Actionbar Macro"], true},
		{1, "Actionbar", "Count", L["Actionbar Item Counts"]},
		{1, "Actionbar", "Classcolor", L["ClassColor BG"], true},
		{1, "Actionbar", "EquipColor", L["EquipColor"].."*", nil, nil, updateEquipColor},
		{1, "Misc", "SendActionCD", HeaderTag..L["SendActionCD"].."*", true, nil, nil, L["SendActionCDTip"]},
		{},--blank
		{1, "Actionbar", "AspectBar", HeaderTag..L["AspectBar"].."*", nil, nil, toggleAspectBar},
		{1, "Actionbar", "VerticleAspect", L["VerticleAspect"].."*", nil, nil, updateAspectStatus},
		{3, "Actionbar", "AspectSize", L["AspectSize"].."*", true, {24, 60, 1}, updateAspectStatus},
	},
	[2] = {
		{1, "Bags", "Enable", HeaderTag..L["Enable Bags"]},
		{},--blank
		{1, "Bags", "GatherEmpty", L["Bags GatherEmpty"].."*", nil, nil, updateBagStatus},
		{1, "Bags", "ItemFilter", L["Bags ItemFilter"].."*", true, setupBagFilter, updateBagStatus},
		{1, "Bags", "SpecialBagsColor", L["SpecialBagsColor"].."*", nil, nil, updateBagStatus, L["SpecialBagsColorTip"]},
		{1, "Bags", "ShowNewItem", L["Bags ShowNewItem"], true},
		{1, "Bags", "BagsiLvl", L["Bags Itemlevel"].."*", nil, nil, updateBagStatus},
		{3, "Bags", "iLvlToShow", L["iLvlToShow"].."*", nil, {1, 500, 1}, nil, L["iLvlToShowTip"]},
		{4, "Bags", "BagSortMode", L["BagSortMode"].."*", true, {L["Forward"], L["Backward"], DISABLE}, updateBagSortOrder, L["BagSortTip"]},
		{},--blank
		{3, "Bags", "BagsPerRow", L["BagsPerRow"].."*", nil, {1, 20, 1}, updateBagAnchor, L["BagsPerRowTip"]},
		{3, "Bags", "BankPerRow", L["BankPerRow"].."*", true, {1, 20, 1}, updateBagAnchor, L["BankPerRowTip"]},
		{3, "Bags", "IconSize", L["Bags IconSize"].."*", nil, {20, 50, 1}, updateBagSize},
		{3, "Bags", "FontSize", L["Bags FontSize"].."*", true, {10, 50, 1}, updateBagSize},
		{3, "Bags", "BagsWidth", L["Bags Width"].."*", false, {10, 40, 1}, updateBagSize},
		{3, "Bags", "BankWidth", L["Bank Width"].."*", true, {10, 40, 1}, updateBagSize},
	},
	[3] = {
		{1, "UFs", "Enable", HeaderTag..L["Enable UFs"], nil, setupUnitFrame, nil, L["HideUFWarning"]},
		{1, "UFs", "Arena", L["Arena Frame"], true},
		{1, "UFs", "ToToT", L["TototUF"]},
		{1, "UFs", "EnergyTicker", L["EnergyTicker"].."*", true, nil, toggleUFClassPower},
		{1, "UFs", "ShowAuras", L["ShowAuras"].."*", nil, setupUFAuras, toggleAllAuras},
		{1, "UFs", "ClassPower", L["UFs ClassPower"].."*", true, setupClassPower, toggleUFClassPower},
		{1, "UFs", "Portrait", L["UFs Portrait"]},
		{1, "UFs", "CCName", L["ClassColor Name"].."*", true, nil, updateUFTextScale},
		{3, "UFs", "UFTextScale", L["UFTextScale"].."*", nil, {.8, 1.5, .05}, updateUFTextScale},
		{4, "UFs", "HealthColor", L["HealthColor"].."*", true, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}, updateUFTextScale},
		{},--blank
		{1, "UFs", "Castbars", HeaderTag..L["UFs Castbar"], nil, setupCastbar},
		{1, "UFs", "LagString", L["Castbar LagString"].."*", true, nil, toggleCastBarLatency},
		{1, "UFs", "SwingBar", L["UFs SwingBar"].."*", nil, setupSwingBars, toggleSwingBars},
		{},--blank
		{1, "UFs", "CombatText", HeaderTag..L["UFs CombatText"]},
		{1, "UFs", "ScrollingCT", NewTag..L["ScrollingCT"].."*", true},
		{1, "UFs", "AutoAttack", L["CombatText AutoAttack"].."*"},
		{1, "UFs", "PetCombatText", L["CombatText ShowPets"].."*", true},
		{1, "UFs", "HotsDots", L["CombatText HotsDots"].."*"},
		{1, "UFs", "FCTOverHealing", L["CombatText OverHealing"].."*"},
		{3, "UFs", "FCTFontSize", L["FCTFontSize"].."*", true, {12, 40, 1}, updateScrollingFont},
	},
	[4] = {
		{1, "UFs", "RaidFrame", HeaderTag..L["UFs RaidFrame"], nil, setupRaidFrame, nil, L["RaidFrameTip"]},
		{1, "UFs", "SimpleMode", L["SimpleRaidFrame"], true, setupSimpleRaidFrame, nil, L["SimpleRaidFrameTip"]},
		{},--blank
		{1, "UFs", "PartyFrame", L["PartyFrame"], nil, setupPartyFrame, nil, L["PartyFrameTip"]},
		{1, "UFs", "PartyPetFrame", L["PartyPetFrame"], true, setupPartyPetFrame, nil, L["PartyPetTip"]},
		{},--blank
		{1, "UFs", "ShowRaidDebuff", L["ShowRaidDebuff"].."*", nil, nil, updateRaidAuras, L["ShowRaidDebuffTip"]},
		{1, "UFs", "ShowRaidBuff", L["ShowRaidBuff"].."*", true, nil, updateRaidAuras, L["ShowRaidBuffTip"]},
		{1, "UFs", "DebuffClickThru", L["DebuffClickThru"].."*", nil, nil, updateRaidAuras, L["ClickThroughTip"]},
		{1, "UFs", "BuffClickThru", L["BuffClickThru"].."*", true, nil, updateRaidAuras, L["ClickThroughTip"]},
		{3, "UFs", "RaidDebuffSize", L["RaidDebuffSize"].."*", nil, {5, 30, 1}, updateRaidAuras},
		{3, "UFs", "RaidBuffSize", L["RaidBuffSize"].."*", true, {5, 30, 1}, updateRaidAuras},
		{},--blank
		{1, "UFs", "RaidBuffIndicator", HeaderTag..L["RaidBuffIndicator"], nil, setupBuffIndicator, nil, L["RaidBuffIndicatorTip"]},
		{4, "UFs", "BuffIndicatorType", L["BuffIndicatorType"].."*", nil, {L["BI_Blocks"], L["BI_Icons"], L["BI_Numbers"]}, refreshRaidFrameIcons},
		{3, "UFs", "BuffIndicatorScale", L["BuffIndicatorScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{},--blank
		{1, "UFs", "InstanceAuras", HeaderTag..L["Instance Auras"], nil, setupRaidDebuffs, nil, L["InstanceAurasTip"]},
		{1, "UFs", "DispellOnly", L["DispellableOnly"].."*", nil, nil, nil, L["DispellableOnlyTip"]},
		{1, "UFs", "AurasClickThrough", L["RaidAuras ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "UFs", "RaidDebuffScale", L["RaidDebuffScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{},--blank
		{1, "UFs", "RaidClickSets", HeaderTag..L["Enable ClickSets"], nil, setupClickCast},
		{},--blank
		{4, "UFs", "RaidHealthColor", L["HealthColor"].."*", nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}, updateRaidTextScale},
		{4, "UFs", "RaidHPMode", L["HealthValueType"].."*", true, {DISABLE, L["ShowHealthPercent"], L["ShowHealthCurrent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"]}, updateRaidTextScale, L["100PercentTip"]},
		{1, "UFs", "ShowSolo", L["ShowSolo"].."*", nil, nil, updateAllHeaders, L["ShowSoloTip"]},
		{1, "UFs", "SmartRaid", HeaderTag..L["SmartRaid"].."*", nil, nil, updateAllHeaders, L["SmartRaidTip"]},
		{3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, updateRaidTextScale},
		{1, "UFs", "TeamIndex", L["RaidFrame TeamIndex"].."*", nil, nil, updateTeamIndex},
		{1, "UFs", "FrequentHealth", HeaderTag..L["FrequentHealth"].."*", true, nil, updateRaidHealthMethod, L["FrequentHealthTip"]},
		{1, "UFs", "HideTip", L["HideTooltip"].."*", nil, nil, updateRaidTextScale, L["HideTooltipTip"]},
		{1, "UFs", "RCCName", L["ClassColor Name"].."*", nil, nil, updateRaidTextScale},
		{3, "UFs", "HealthFrequency", L["HealthFrequency"].."*", true, {.1, .5, .05}, updateRaidHealthMethod, L["HealthFrequencyTip"]},
	},
	[5] = {
		{1, "Nameplate", "Enable", HeaderTag..L["Enable Nameplate"], nil, setupNameplateSize, refreshNameplates},
		{1, "Nameplate", "FriendPlate", L["FriendPlate"].."*", nil, nil, refreshNameplates, L["FriendPlateTip"]},
		{1, "Nameplate", "NameOnlyMode", L["NameOnlyMode"].."*", true, setupNameOnlySize, nil, L["NameOnlyModeTip"]},
		{4, "Nameplate", "NameType", L["NameTextType"].."*", nil, {DISABLE, L["Tag:name"], L["Tag:levelname"], L["Tag:rarename"], L["Tag:rarelevelname"]}, refreshNameplates, L["PlateLevelTagTip"]},
		{4, "Nameplate", "HealthType", L["HealthValueType"].."*", true, G.HealthValues, refreshNameplates, L["100PercentTip"]},
		{},--blank
		{1, "Nameplate", "PlateAuras", HeaderTag..L["PlateAuras"].."*", nil, setupNameplateFilter, refreshNameplates},
		{1, "Nameplate", "Dispellable", L["Dispellable"].."*", true, nil, refreshNameplates, L["DispellableTip"]},
		{1, "Nameplate", "Desaturate", L["DesaturateIcon"].."*", nil, nil, refreshNameplates, L["DesaturateIconTip"]},
		{1, "Nameplate", "DebuffColor", L["DebuffColor"].."*", nil, nil, refreshNameplates, L["DebuffColorTip"]},
		{4, "Nameplate", "AuraFilter", L["NameplateAuraFilter"].."*", true, {L["BlackNWhite"], L["PlayerOnly"], L["IncludeCrowdControl"]}, refreshNameplates},
		{3, "Nameplate", "maxAuras", L["Max Auras"].."*", false, {1, 20, 1}, refreshNameplates},
		{3, "Nameplate", "AuraSize", L["Auras Size"].."*", true, {18, 40, 1}, refreshNameplates},
		{},--blank
		{4, "Nameplate", "TargetIndicator", L["TargetIndicator"].."*", nil, {DISABLE, L["TopArrow"], L["RightArrow"], L["TargetGlow"], L["TopNGlow"], L["RightNGlow"]}, refreshNameplates},
		{3, "Nameplate", "ExecuteRatio", L["ExecuteRatio"].."*", true, {0, 90, 1}, nil, L["ExecuteRatioTip"]},
		{1, "Nameplate", "FriendlyCC", L["Friendly CC"].."*"},
		{1, "Nameplate", "HostileCC", L["Hostile CC"].."*", true},
		{1, "Nameplate", "FriendlyThru", "|cffff0000"..L["Friendly ClickThru"].."*", nil, nil, updateClickThru, L["PlateClickThruTip"]},
		{1, "Nameplate", "EnemyThru", "|cffff0000"..L["Enemy ClickThru"].."*", true, nil, updateClickThru, L["PlateClickThruTip"]},
		{1, "Nameplate", "CastbarGlow", L["PlateCastbarGlow"].."*", nil, setupPlateCastbarGlow, nil, L["PlateCastbarGlowTip"]},
		{1, "Nameplate", "CastTarget", L["PlateCastTarget"].."*", true, nil, nil, L["PlateCastTargetTip"]},
		{1, "Nameplate", "ClampTarget", L["ClampTargetPlate"].."*", nil, nil, updatePlateCVars, L["ClampTargetPlateTip"]},
		{1, "Nameplate", "QuestIndicator", L["QuestIndicator"], true, nil, nil, L["QuestIndicatorAddOns"]},
		{1, "Nameplate", "BlockDBM", L["BlockDBM"], nil, nil, nil, L["BlockDBMTip"]},
		{1, "Nameplate", "Interruptor", L["ShowInterruptor"].."*", true},
		{1, "Nameplate", "UnitTargeted", L["Show TargetedBy"].."*", nil, nil, refreshPlateByEvents, L["TargetedByTip"]},
		{},--blank
		{1, "Nameplate", "ColoredTarget", HeaderTag..L["ColoredTarget"].."*", nil, nil, nil, L["ColoredTargetTip"]},
		{1, "Nameplate", "ColoredFocus", HeaderTag..L["ColoredFocus"].."*", true, nil, nil, L["ColoredFocusTip"]},
		{5, "Nameplate", "TargetColor", L["TargetNP Color"].."*"},
		{5, "Nameplate", "FocusColor", L["FocusNP Color"].."*", 2},
		{1, "Nameplate", "ColorByDot", NewTag..HeaderTag..L["ColorByDot"].."*", nil, nil, nil, L["ColorByDotTip"]},
		{5, "Nameplate", "DotColor", NewTag..L["DotColor"].."*"},
		{2, "Nameplate", "ColorDots", NewTag..L["ColorDots"].."*", true, nil, refreshColorDots, L["ColorDotsTip"]},
		{},--blank
		{1, "Nameplate", "CustomUnitColor", HeaderTag..L["CustomUnitColor"].."*", nil, nil, updateCustomUnitList, L["CustomUnitColorTip"]},
		{5, "Nameplate", "CustomColor", L["Custom Color"].."*", 2},
		{2, "Nameplate", "UnitList", L["UnitColor List"].."*", nil, nil, updateCustomUnitList, L["CustomUnitTips"]},
		{2, "Nameplate", "ShowPowerList", L["ShowPowerList"].."*", true, nil, updatePowerUnitList, L["CustomUnitTips"]},
		{},--blank
		{1, "Nameplate", "TankMode", HeaderTag..L["Tank Mode"].."*", nil, nil, nil, L["TankModeTip"]},
		{5, "Nameplate", "SecureColor", L["Secure Color"].."*"},
		{5, "Nameplate", "TransColor", L["Trans Color"].."*", 1},
		{5, "Nameplate", "InsecureColor", L["Insecure Color"].."*", 2},
		--{1, "Nameplate", "DPSRevertThreat", L["DPS Revert Threat"].."*", true},
		--{5, "Nameplate", "OffTankColor", L["OffTank Color"].."*", 3},
		{},--blank
		{1, "Nameplate", "CVarOnlyNames", L["CVarOnlyNames"], nil, nil, updatePlateCVars, L["CVarOnlyNamesTip"]},
		{1, "Nameplate", "CVarShowNPCs", L["CVarShowNPCs"].."*", true, nil, updatePlateCVars, L["CVarShowNPCsTip"]},
		{3, "Nameplate", "PlateRange", L["PlateRange"].."*", nil, {0, 41, 1}, updatePlateCVars},
		{3, "Nameplate", "VerticalSpacing", L["NP VerticalSpacing"].."*", true, {.5, 1.5, .1}, updatePlateCVars},
		{3, "Nameplate", "MinScale", L["Nameplate MinScale"].."*", false, {.5, 1, .1}, updatePlateCVars},
		{3, "Nameplate", "MinAlpha", L["Nameplate MinAlpha"].."*", true, {.3, 1, .1}, updatePlateCVars},
	},
	[6] = {
		{1, "Nameplate", "ShowPlayerPlate", HeaderTag..L["Enable PlayerPlate"].."*", nil, nil, togglePlayerPlate},
		{1, "Nameplate", "TargetPower", HeaderTag..L["TargetClassPower"].."*", true, nil, toggleTargetClassPower},
		{},--blank
		--{1, "Auras", "ClassAuras", L["Enable ClassAuras"], true},
		{1, "Nameplate", "PPFadeout", L["PlayerPlate Fadeout"].."*", nil, nil, togglePlateVisibility},
		{1, "Nameplate", "PPPowerText", L["PlayerPlate PowerText"].."*", nil, nil, togglePlayerPlate},
		{3, "Nameplate", "PPFadeoutAlpha", L["PlayerPlate FadeoutAlpha"].."*", true, {0, .5, .05}, togglePlateVisibility},
		{1, "Nameplate", "EnergyTicker", L["EnergyTicker"].."*", nil, nil, togglePlayerPlate},
		{},--blank
		{3, "Nameplate", "PPWidth", L["Width"].."*", false, {150, 300, 1}, refreshNameplates},
		{3, "Nameplate", "PPBarHeight", L["PlayerPlate CPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPHealthHeight", L["PlayerPlate HPHeight"].."*", false, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPPowerHeight", L["PlayerPlate MPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
	},
	[7] = {
		{1, "Auras", "BuffFrame", HeaderTag..L["BuffFrame"], nil, setupBuffFrame, nil, L["BuffFrameTip"]},
		{1, "Auras", "HideBlizBuff", L["HideBlizUI"], true, nil, nil, L["HideBlizBuffTip"]},
		{},--blank
		{1, "AuraWatch", "Enable", HeaderTag..L["Enable AuraWatch"], nil, setupAuraWatch},
		{1, "AuraWatch", "WatchSpellRank", L["AuraWatch WatchSpellRank"], nil, nil, nil, L["WatchSpellRankTip"]},
		{1, "AuraWatch", "ClickThrough", L["AuraWatch ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "AuraWatch", "IconScale", L["AuraWatch IconScale"], true, {.8, 2, .1}},
		{},--blank
		{1, "Auras", "Totems", HeaderTag..L["Enable Totembar"]},
		{1, "Auras", "VerticalTotems", L["VerticalTotems"].."*", nil, nil, refreshTotemBar},
		{3, "Auras", "TotemSize", L["TotemSize"].."*", true, {24, 60, 1}, refreshTotemBar},
		{},--blank
		{1, "Auras", "Reminder", L["Enable Reminder"].."*", nil, nil, updateReminder, L["ReminderTip"]},
	},
	[8] = {
		{1, "Misc", "RaidTool", HeaderTag..L["Raid Manger"]},
		--{1, "Misc", "RMRune", L["Runes Check"].."*", true},
		{4, "Misc", "EasyMarkKey", L["EasyMark"].."*", nil, {"CTRL", "ALT", "SHIFT", DISABLE}, nil, L["EasyMarkTip"]},
		{2, "Misc", "DBMCount", L["DBMCount"].."*", true, nil, nil, L["DBMCountTip"]},
		{},--blank
		{1, "Misc", "QuestNotification", HeaderTag..L["QuestNotification"].."*", nil, nil, updateQuestNotification},
		{1, "Misc", "QuestProgress", L["QuestProgress"].."*"},
		{1, "Misc", "OnlyCompleteRing", L["OnlyCompleteRing"].."*", true, nil, nil, L["OnlyCompleteRingTip"]},
		{},--blank
		{1, "Misc", "InterruptAlert", HeaderTag..L["InterruptAlert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "OwnInterrupt", L["OwnInterrupt"].."*", true},
		{1, "Misc", "DispellAlert", HeaderTag..L["DispellAlert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "OwnDispell", L["OwnDispell"].."*", true},
		{1, "Misc", "BrokenAlert", HeaderTag..L["BrokenAlert"].."*", nil, nil, updateInterruptAlert, L["BrokenAlertTip"]},
		{1, "Misc", "LoCAlert", HeaderTag..L["LoCAlert"].."*", true, nil, updateInterruptAlert, L["LoCAlertTip"]},
		{1, "Misc", "InstAlertOnly", L["InstAlertOnly"].."*", nil, nil, updateInterruptAlert, L["InstAlertOnlyTip"]},
		--{},--blank
		--{1, "Misc", "PlacedItemAlert", L["Placed Item Alert"].."*"}, -- fix me: need more data
	},
	[9] = {
		{1, "Chat", "Lock", HeaderTag..L["Lock Chat"]},
		{3, "Chat", "ChatWidth", L["LockChatWidth"].."*", nil, {200, 600, 1}, updateChatSize},
		{3, "Chat", "ChatHeight", L["LockChatHeight"].."*", true, {100, 500, 1}, updateChatSize},
		{},--blank
		{1, "Chat", "Oldname", L["Default Channel"]},
		{1, "Chat", "Sticky", L["Chat Sticky"].."*", true, nil, updateChatSticky},
		{1, "Chat", "Chatbar", L["ShowChatbar"]},
		{1, "Chat", "WhisperColor", L["Differ WhisperColor"].."*", true},
		{1, "Chat", "ChatItemLevel", L["ShowChatItemLevel"]},
		{1, "Chat", "Freedom", L["Language Filter"].."*", true, nil, toggleLanguageFilter},
		{1, "Chat", "WhisperSound", L["WhisperSound"].."*", nil, nil, nil, L["WhisperSoundTip"]},
		{1, "Chat", "BottomBox", L["BottomBox"].."*", true, nil, toggleEditBoxAnchor},
		{1, "Chat", "SysFont", NewTag..L["SysFont"], nil, nil, nil, L["SysFontTip"]},
		{4, "ACCOUNT", "TimestampFormat", L["TimestampFormat"].."*", nil, {DISABLE, "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}},
		{4, "Chat", "ChatBGType", L["ChatBGType"].."*", true, {DISABLE, L["Default Dark"], L["Gradient"]}, toggleChatBackground},
		{},--blank
		{1, "Chat", "EnableFilter", HeaderTag..L["Enable Chatfilter"]},
		{1, "Chat", "BlockAddonAlert", L["Block Addon Alert"], true},
		{1, "Chat", "BlockSpammer", L["BlockSpammer"].."*", nil, nil, nil, L["BlockSpammerTip"]},
		{1, "Chat", "BlockStranger", "|cffff0000"..L["BlockStranger"].."*", nil, nil, nil, L["BlockStrangerTip"]},
		{2, "ACCOUNT", "ChatFilterWhiteList", HeaderTag..L["ChatFilterWhiteList"].."*", true, nil, updateFilterWhiteList, L["ChatFilterWhiteListTip"]},
		{3, "Chat", "Matches", L["Keyword Match"].."*", nil, {1, 3, 1}},
		{2, "ACCOUNT", "ChatFilterList", L["Filter List"].."*", true, nil, updateFilterList, L["FilterListTip"]},
		{},--blank
		{1, "Chat", "Invite", HeaderTag..L["Whisper Invite"]},
		{1, "Chat", "GuildInvite", L["Guild Invite Only"].."*"},
		{2, "Chat", "Keyword", L["Whisper Keyword"].."*", true, nil, updateWhisperList, L["WhisperKeywordTip"]},
	},
	[10] = {
		{1, "Map", "DisableMap", "|cffff0000"..L["DisableMap"], nil, nil, nil, L["DisableMapTip"]},
		{1, "Map", "MapRevealGlow", L["MapRevealGlow"].."*", nil, nil, nil, L["MapRevealGlowTip"]},
		{1, "Map", "MapFader", L["MapFader"].."*", nil, nil, updateMapFader},
		{3, "Map", "MapScale", L["Map Scale"], true, {.5, 1, .1}},
		{},--blank
		{3, "Map", "MinimapScale", L["Minimap Scale"].."*", nil, {.5, 3, .1}, updateMinimapScale},
		{3, "Map", "MinimapSize", L["Minimap Size"].."*", true, {100, 500, 1}, updateMinimapScale},
		{1, "Map", "Clock", L["Minimap Clock"].."*", nil, nil, showMinimapClock},
		{1, "Map", "DiffFlag", L["Minimap DiffFlag"], true, nil, nil, L["DiffFlagTip"]},
		{1, "Map", "CombatPulse", L["Minimap Pulse"]},
		{1, "Map", "WhoPings", L["Show WhoPings"], true},
		{1, "Map", "EasyVolume", NewTag..L["EasyVolume"], nil, nil, nil, L["EasyVolumeTip"]},
		{1, "Misc", "ExpRep", L["Show Expbar"], true},
		{1, "Map", "ShowRecycleBin", L["Show RecycleBin"]},
		{2, "ACCOUNT", "IgnoredButtons", L["IgnoredButtons"], nil, nil, nil, L["IgnoredButtonsTip"]},
	},
	[11] = {
		{1, "Skins", "BlizzardSkins", HeaderTag..L["BlizzardSkins"], nil, nil, nil, L["BlizzardSkinsTips"]},
		{1, "Skins", "FlatMode", L["FlatMode"], true},
		{1, "Skins", "DefaultBags", L["DefaultBags"], nil, nil, nil, L["DefaultBagsTips"]},
		{1, "Skins", "Loot", L["Loot"], true},
		{1, "Skins", "Shadow", L["Shadow"]},
		{1, "Skins", "FontOutline", L["FontOutline"], true},
		{1, "Skins", "BgTex", L["BgTex"]},
		{1, "Skins", "GreyBD", L["GreyBackdrop"], true, nil, nil, L["GreyBackdropTip"]},
		{3, "Skins", "SkinAlpha", L["SkinAlpha"].."*", nil, {0, 1, .05}, updateSkinAlpha},
		{3, "Skins", "FontScale", L["GlobalFontScale"], true, {.5, 1.5, .05}},
		{},--blank
		{1, "Skins", "ClassLine", L["ClassColor Line"]},
		{1, "Skins", "InfobarLine", L["Infobar Line"], true},
		{1, "Skins", "ChatbarLine", L["Chat Line"]},
		{1, "Skins", "MenuLine", L["Menu Line"], true},
		{},--blank
		{1, "Skins", "TradeSkills", L["EnhancedTradeSkills"]},
		{1, "Skins", "QuestTracker", L["EnhancedQuestLog"], true, nil, nil, L["EnhancedQuestLogTips"]},
		{},--blank
		{1, "Skins", "Skada", L["Skada Skin"]},
		{1, "Skins", "Details", L["Details Skin"], nil, resetDetails},
		{4, "Skins", "ToggleDirection", L["ToggleDirection"].."*", true, {L["LEFT"], L["RIGHT"], L["TOP"], L["BOTTOM"], DISABLE}, updateToggleDirection},
		{1, "Skins", "Recount", L["Recount Skin"]},
		{},--blank
		{1, "Skins", "DBM", L["DBM Skin"]},
		{1, "Skins", "Bigwigs", L["Bigwigs Skin"], true},
		{1, "Skins", "TMW", L["TMW Skin"]},
		{1, "Skins", "WeakAuras", L["WeakAuras Skin"], true},
	},
	[12] = {
		{3, "Tooltip", "Scale", L["Tooltip Scale"].."*", nil, {.5, 1.5, .1}},
		{4, "Tooltip", "TipAnchor", L["TipAnchor"].."*", true, {L["TOPLEFT"], L["TOPRIGHT"], L["BOTTOMLEFT"], L["BOTTOMRIGHT"]}, nil, L["TipAnchorTip"]},
		{1, "Tooltip", "CombatHide", L["Hide Tooltip"].."*"},
		{1, "Tooltip", "ItemQuality", L["ShowItemQuality"].."*"},
		{4, "Tooltip", "CursorMode", L["Follow Cursor"].."*", true, {DISABLE, L["LEFT"], L["TOP"], L["RIGHT"]}},
		{1, "Tooltip", "HideTitle", L["Hide Title"].."*"},
		{1, "Tooltip", "HideRank", L["Hide Rank"].."*", true},
		{1, "Tooltip", "FactionIcon", L["FactionIcon"].."*"},
		{1, "Tooltip", "HideJunkGuild", L["HideJunkGuild"].."*", true},
		{1, "Tooltip", "HideRealm", L["Hide Realm"].."*"},
		{1, "Tooltip", "TargetBy", L["Show TargetedBy"].."*", true},
		{1, "Tooltip", "HideAllID", "|cffff0000"..L["HideAllID"]},
	},
	[13] = {
		{1, "Misc", "ItemLevel", HeaderTag..L["Show ItemQuality"]},
		{1, "Misc", "ShowItemLevel", L["Show ItemLevel"].."*"},
		{1, "Misc", "GemNEnchant", L["Show GemNEnchant"].."*", true},
		{},--blank
		{1, "Misc", "FasterLoot", L["Faster Loot"].."*", nil, nil, updateFasterLoot},
		{1, "Misc", "HideErrors", L["Hide Error"].."*", true, nil, updateErrorBlocker},
		{1, "Misc", "Mail", L["Mail Tool"]},
		{1, "ACCOUNT", "AutoBubbles", L["AutoBubbles"], true},
		{1, "Misc", "TradeTabs", L["TradeTabs"], nil, nil, nil, L["TradeTabsTips"]},
		{1, "Misc", "InstantDelete", L["InstantDelete"].."*", true},
		{1, "Misc", "Focuser", L["Easy Focus"]},
		{1, "Misc", "PetHappiness", L["PetHappiness"].."*", true, nil, togglePetHappiness},
		{1, "Misc", "MenuButton", L["MenuButton"], nil, nil, nil, L["MenuButtonTip"]},
		{1, "Misc", "AutoDismount", L["AutoDismount"].."*", nil, nil, nil, L["AutoDismountTip"]},
		{3, "Misc", "MaxZoom", L["MaxZoom"].."*", true, {1, 3.4, .1}, updateMaxZoomLevel},
		{1, "Misc", "BlockInvite", "|cffff0000"..L["BlockInvite"].."*", nil, nil, nil, L["BlockInviteTip"]},
	},
	[14] = {
		{1, "ACCOUNT", "VersionCheck", L["Version Check"]},
		{1, "ACCOUNT", "LockUIScale", L["Lock UIScale"]},
		{3, "ACCOUNT", "UIScale", L["Setup UIScale"], true, {.4, 1.15, .01}, nil, L["UIScaleTip"]},
		{},--blank
		{1, "ACCOUNT", "DisableInfobars", "|cffff0000"..L["DisableInfobars"]},
		{3, "Misc", "MaxAddOns", L["SysMaxAddOns"].."*", nil,  {1, 50, 1}, nil, L["SysMaxAddOnsTip"]},
		{3, "Misc", "InfoSize", L["InfobarFontSize"].."*", true,  {10, 50, 1}, updateInfobarSize},
		{2, "Misc", "InfoStrLeft", L["LeftInfobar"].."*", nil, nil, updateInfobarAnchor, L["InfobarStrTip"]},
		{2, "Misc", "InfoStrRight", L["RightInfobar"].."*", true, nil, updateInfobarAnchor, L["InfobarStrTip"]},
		{},--blank
		{4, "ACCOUNT", "TexStyle", L["Texture Style"], false, {}},
		{4, "ACCOUNT", "NumberFormat", L["Numberize"], true, {L["Number Type1"], L["Number Type2"], L["Number Type3"]}},
		{2, "ACCOUNT", "CustomTex", L["CustomTex"], nil, nil, nil, L["CustomTexTip"]},
		{3, "ACCOUNT", "SmoothAmount", L["SmoothAmount"].."*", true, {.1, 1, .05}, updateSmoothingAmount, L["SmoothAmountTip"]},
	},
	[15] = {
	},
}

local function SelectTab(i)
	for num = 1, #G.TabList do
		if num == i then
			guiTab[num]:SetBackdropColor(cr, cg, cb, .3)
			guiTab[num].checked = true
			guiPage[num]:Show()
		else
			guiTab[num]:SetBackdropColor(0, 0, 0, .3)
			guiTab[num].checked = false
			guiPage[num]:Hide()
		end
	end
end

local function tabOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	SelectTab(self.index)
end
local function tabOnEnter(self)
	if self.checked then return end
	self:SetBackdropColor(cr, cg, cb, .3)
end
local function tabOnLeave(self)
	if self.checked then return end
	self:SetBackdropColor(0, 0, 0, .3)
end

local function CreateTab(parent, i, name)
	local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
	tab:SetPoint("TOPLEFT", 20, -30*i - 20 + C.mult)
	tab:SetSize(130, 28)
	B.CreateBD(tab, .3)
	B.CreateFS(tab, 15, name, "system", "LEFT", 10, 0)
	tab.index = i

	tab:SetScript("OnClick", tabOnClick)
	tab:SetScript("OnEnter", tabOnEnter)
	tab:SetScript("OnLeave", tabOnLeave)

	return tab
end

local function CheckUIOption(key, value, newValue)
	if key == "ACCOUNT" then
		if newValue ~= nil then
			NDuiADB[value] = newValue
		else
			return NDuiADB[value]
		end
	else
		if newValue ~= nil then
			C.db[key][value] = newValue
		else
			return C.db[key][value]
		end
	end
end

G.needUIReload = nil

local function CheckUIReload(name)
	if not strfind(name, "%*") then
		G.needUIReload = true
	end
end

local function onCheckboxClick(self)
	CheckUIOption(self.__key, self.__value, self:GetChecked())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function restoreEditbox(self)
	self:SetText(CheckUIOption(self.__key, self.__value))
end
local function acceptEditbox(self)
	CheckUIOption(self.__key, self.__value, self:GetText())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function onSliderChanged(self, v)
	local current = B:Round(tonumber(v), 2)
	CheckUIOption(self.__key, self.__value, current)
	CheckUIReload(self.__name)
	self.value:SetText(current)
	if self.__callback then self:__callback() end
end

local function updateDropdownSelection(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == CheckUIOption(dd.__key, dd.__value) then
			option:SetBackdropColor(1, .8, 0, .3)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .3)
			option.selected = false
		end
	end
end
local function updateDropdownClick(self)
	local dd = self.__owner
	CheckUIOption(dd.__key, dd.__value, self.index)
	CheckUIReload(dd.__name)
	if dd.__callback then dd:__callback() end
end

local function CreateOption(i)
	local parent, offset = guiPage[i].child, 20

	for _, option in pairs(G.OptionList[i]) do
		local optType, key, value, name, horizon, data, callback, tooltip = unpack(option)
		-- Checkboxes
		if optType == 1 then
			local cb = B.CreateCheckBox(parent)
			cb:SetHitRectInsets(-5, -5, -5, -5)
			if horizon then
				cb:SetPoint("TOPLEFT", 330, -offset + 35)
			else
				cb:SetPoint("TOPLEFT", 20, -offset)
				offset = offset + 35
			end
			cb.__key = key
			cb.__value = value
			cb.__name = name
			cb.__callback = callback
			cb.name = B.CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			cb:SetChecked(CheckUIOption(key, value))
			cb:SetScript("OnClick", onCheckboxClick)
			if data and type(data) == "function" then
				local bu = B.CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
			if tooltip then
				B.AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Editbox
		elseif optType == 2 then
			local eb = B.CreateEditBox(parent, 200, 28)
			eb:SetMaxLetters(999)
			eb.__key = key
			eb.__value = value
			eb.__name = name
			eb.__callback = callback
			eb.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			if horizon then
				eb:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				eb:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			eb:SetText(CheckUIOption(key, value))
			eb:HookScript("OnEscapePressed", restoreEditbox)
			eb:HookScript("OnEnterPressed", acceptEditbox)

			B.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			B.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info", true)
		-- Slider
		elseif optType == 3 then
			local min, max, step = unpack(data)
			local x, y
			if horizon then
				x, y = 350, -offset + 40
			else
				x, y = 40, -offset - 30
				offset = offset + 70
			end
			local s = B.CreateSlider(parent, name, min, max, step, x, y)
			s.__key = key
			s.__value = value
			s.__name = name
			s.__callback = callback
			s.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			s:SetValue(CheckUIOption(key, value))
			s:SetScript("OnValueChanged", onSliderChanged)
			s.value:SetText(B:Round(CheckUIOption(key, value), 2))
			if tooltip then
				B.AddTooltip(s, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Dropdown
		elseif optType == 4 then
			if value == "TexStyle" then
				for _, v in ipairs(G.TextureList) do
					tinsert(data, v.name)
				end
			end

			local dd = B.CreateDropDown(parent, 200, 28, data)
			if horizon then
				dd:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				dd:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			dd.Text:SetText(data[CheckUIOption(key, value)])
			dd.__key = key
			dd.__value = value
			dd.__name = name
			dd.__options = data
			dd.__callback = callback
			dd.button.__owner = dd
			dd.button:HookScript("OnClick", updateDropdownSelection)

			for i = 1, #data do
				dd.options[i]:HookScript("OnClick", updateDropdownClick)
				if value == "TexStyle" then
					AddTextureToOption(dd.options, i) -- texture preview
				end
			end

			B.CreateFS(dd, 14, name, "system", "CENTER", 0, 25)
			if tooltip then
				B.AddTooltip(dd, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Colorswatch
		elseif optType == 5 then
			local swatch = B.CreateColorSwatch(parent, name, CheckUIOption(key, value))
			local width = 25 + (horizon or 0)*155
			if horizon then
				swatch:SetPoint("TOPLEFT", width, -offset + 30)
			else
				swatch:SetPoint("TOPLEFT", width, -offset - 5)
				offset = offset + 35
			end
			swatch.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
		-- Blank, no optType
		else
			if not key then
				local line = B.SetGradient(parent, "H", 1, 1, 1, .25, .25, 560, C.mult)
				line:SetPoint("TOPLEFT", 25, -offset - 12)
			end
			offset = offset + 35
		end
	end

	local footer = CreateFrame("Frame", nil, parent)
	footer:SetSize(20, 20)
	footer:SetPoint("TOPLEFT", 25, -offset)
end

local function resetUrlBox(self)
	self:SetText(self.url)
	self:HighlightText()
end

local function CreateContactBox(parent, text, url, index)
	B.CreateFS(parent, 14, text, "system", "TOP", 0, -50 - (index-1) * 60)
	local box = B.CreateEditBox(parent, 250, 24)
	box:SetPoint("TOP", 0, -70 - (index-1) * 60)
	box.url = url
	resetUrlBox(box)
	box:SetScript("OnTextChanged", resetUrlBox)
	box:SetScript("OnCursorChanged", resetUrlBox)
end

local donationList = {
	["afdian"] = "33578473, normanvon, y368413, EK, msylgj, 夜丨灬清寒, akakai, reisen410, 其实你很帥, 萨菲尔, Antares, RyanZ, fldqw, Mario, 时光旧予, 食铁骑兵, 爱蕾丝的基总, 施然, 命运镇魂曲, 不可语上, Leo (En-布鲁), 忘川, 刘翰承, 悟空海外党, cncj, 暗月, 汪某人, 黑手, iraq120, 嗜血未冷, 我又不是妖怪, 养乐多, 无人知晓, 秋末旷夜-迪瑟洛克, Teo, 莉拉斯塔萨, 音尘绝, 刺王杀驾, 醉跌-凤凰之神, 灬麦加灬-阿古斯, 漂舟不系, 朵小熙, 山岸逢花, 乄阿财-帕奇维克, 乌鸦岭守墓饼-罗宁, 自在独踽踽-霜之哀伤, 御行宇航-碧玉矿洞, 末日伯爵-奥罗, 阿玛忆-白银之手, 零氪-罗宁, 粉色刘老头-黑曜石之锋, shadowlezi, 風雲再起-帕奇维克, congfeng, 东叫兽, solor, DC_Doraemon, 不明飞行物以及部分未备注名字的用户。",
	["Patreon"] = "Quentin, Julian Neigefind, silenkin, imba Villain, Zeyu Zhu, Kon Floros.",
}
local function CreateDonationIcon(parent, texture, name, xOffset)
	local button = B.CreateButton(parent, 30, 30, true, texture)
	button:SetPoint("BOTTOM", xOffset, 45)
	button.title = format(L["Donation"], name)
	B.AddTooltip(button, "ANCHOR_TOP", "|n"..donationList[name], "info")
end

function G:AddContactFrame()
	if G.ContactFrame then G.ContactFrame:Show() return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(300, 300)
	frame:SetPoint("CENTER")
	B.SetBD(frame)
	B.CreateWatermark(frame)

	B.CreateFS(frame, 16, L["Contact"], true, "TOP", 0, -10)
	local ll = B.SetGradient(frame, "H", .7, .7, .7, 0, .5, 80, C.mult)
	ll:SetPoint("TOP", -40, -32)
	local lr = B.SetGradient(frame, "H", .7, .7, .7, .5, 0, 80, C.mult)
	lr:SetPoint("TOP", 40, -32)

	CreateContactBox(frame, "NGA.CN", "https://bbs.nga.cn/read.php?tid=18321155", 1)
	CreateContactBox(frame, "GitHub", "https://github.com/siweia/NDuiClassic", 2)
	CreateContactBox(frame, "Discord", "https://discord.gg/WXgrfBm", 3)

	CreateDonationIcon(frame, DB.afdianTex, "afdian", -20)
	CreateDonationIcon(frame, DB.patreonTex, "Patreon", 20)

	local back = B.CreateButton(frame, 120, 20, OKAY)
	back:SetPoint("BOTTOM", 0, 15)
	back:SetScript("OnClick", function() frame:Hide() end)

	G.ContactFrame = frame
end

local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*35)
end

StaticPopupDialogs["RELOAD_NDUI"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
}

local function OpenGUI()
	if f then f:Show() return end

	-- Main Frame
	f = CreateFrame("Frame", "NDuiGUI", UIParent)
	tinsert(UISpecialFrames, "NDuiGUI")
	f:SetSize(800, 600)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(10)
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, L["NDui Console"], true, "TOP", 0, -10)
	B.CreateFS(f, 16, DB.Version.." ("..DB.Support..")", false, "TOP", 0, -30)

	local contact = B.CreateButton(f, 130, 20, L["Contact"])
	contact:SetPoint("BOTTOMLEFT", 20, 15)
	contact:SetScript("OnClick", function()
		f:Hide()
		G:AddContactFrame()
	end)

	local unlock = B.CreateButton(f, 130, 20, L["UnlockUI"])
	unlock:SetPoint("BOTTOM", contact, "TOP", 0, 2)
	unlock:SetScript("OnClick", function()
		f:Hide()
		SlashCmdList["NDUI_MOVER"]()
	end)

	local close = B.CreateButton(f, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() f:Hide() end)

	local ok = B.CreateButton(f, 80, 20, OKAY)
	ok:SetPoint("RIGHT", close, "LEFT", -5, 0)
	ok:SetScript("OnClick", function()
		B:SetupUIScale()
		f:Hide()
		StaticPopup_Show("RELOAD_NDUI")
	end)

	for i, name in pairs(G.TabList) do
		guiTab[i] = CreateTab(f, i, name)

		guiPage[i] = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
		guiPage[i]:SetPoint("TOPLEFT", 160, -50)
		guiPage[i]:SetSize(610, 500)
		B.CreateBDFrame(guiPage[i], .3)
		guiPage[i]:Hide()
		guiPage[i].child = CreateFrame("Frame", nil, guiPage[i])
		guiPage[i].child:SetSize(610, 1)
		guiPage[i]:SetScrollChild(guiPage[i].child)
		B.ReskinScroll(guiPage[i].ScrollBar)
		guiPage[i]:SetScript("OnMouseWheel", scrollBarHook)

		CreateOption(i)
	end

	G:CreateProfileGUI(guiPage[15]) -- profile GUI
	G:SetupActionbarStyle(guiPage[1])

	local helpInfo = B.CreateHelpInfo(f, L["Option* Tips"])
	helpInfo:SetPoint("TOPLEFT", 20, -5)

	local credit = CreateFrame("Button", nil, f)
	credit:SetPoint("TOPRIGHT", -20, -5)
	credit:SetSize(40, 40)
	credit.Icon = credit:CreateTexture(nil, "ARTWORK")
	credit.Icon:SetAllPoints()
	credit.Icon:SetTexture(DB.creditTex)
	credit:SetHighlightTexture(DB.creditTex)
	credit.title = "Credits"
	B.AddTooltip(credit, "ANCHOR_BOTTOMLEFT", "|n"..GetAddOnMetadata("NDui", "X-Credits"), "info")

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				B:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			f:Show()
			B:UnregisterEvent(event, showLater)
		end
	end
	B:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)

	SelectTab(1)
end

function G:OnLogin()
	local gui = CreateFrame("Button", "GameMenuFrameNDui", GameMenuFrame, "GameMenuButtonTemplate, BackdropTemplate")
	gui:SetText(L["NDui Console"])
	gui:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -21)
	GameMenuFrame:HookScript("OnShow", function(self)
		GameMenuButtonLogout:SetPoint("TOP", gui, "BOTTOM", 0, -21)
		self:SetHeight(self:GetHeight() + gui:GetHeight() + 22)
	end)

	gui:SetScript("OnClick", function()
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
		OpenGUI()
		HideUIPanel(GameMenuFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end)

	if C.db["Skins"]["BlizzardSkins"] then B.Reskin(gui) end
end