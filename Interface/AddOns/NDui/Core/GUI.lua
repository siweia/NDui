local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:RegisterModule("GUI")

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
		IgnoreSpells = {},
	},
	Actionbar = {
		Enable = true,
		Hotkeys = true,
		Macro = true,
		Count = true,
		Classcolor = false,
		Cooldown = true,
		DecimalCD = true,
		Style = 1,
		Bar4Fade = false,
		Bar5Fade = true,
		Scale = 1,
		BindType = 1,
		OverrideWA = false,
		MicroMenu = true,
		CustomBar = false,
		CustomBarFader = false,
		CustomBarButtonSize = 34,
		CustomBarNumButtons = 12,
		CustomBarNumPerRow = 12,
		ShowStance = true,
	},
	Bags = {
		Enable = true,
		BagsScale = 1,
		IconSize = 34,
		BagsWidth = 12,
		BankWidth = 14,
		BagsiLvl = true,
		BagSortMode = 1,
		ItemFilter = true,
		DeleteButton = true,
		FavouriteItems = {},
		GatherEmpty = false,
		ShowNewItem = true,
		SplitCount = 1,
		SpecialBagsColor = false,
		iLvlToShow = 1,
		AutoDeposit = false,

		FilterJunk = true,
		FilterConsumable = true,
		FilterAzerite = false,
		FilterEquipment = true,
		FilterLegendary = true,
		FilterCollection = true,
		FilterFavourite = true,
		FilterGoods = false,
		FilterQuest = false,
		FilterEquipSet = false,
	},
	Auras = {
		Reminder = true,
		Totems = true,
		VerticalTotems = true,
		TotemSize = 32,
		ClassAuras = true,
		ReverseBuffs = false,
		BuffSize = 30,
		BuffsPerRow = 16,
		ReverseDebuffs = false,
		DebuffSize = 30,
		DebuffsPerRow = 16,
	},
	AuraWatch = {
		Enable = true,
		ClickThrough = false,
		IconScale = 1,
		DeprecatedAuras = false,
		QuakeRing = false,
	},
	UFs = {
		Enable = true,
		Portrait = true,
		PlayerDebuff = false,
		ToTAuras = false,
		Arena = true,
		Castbars = true,
		SwingBar = false,
		SwingTimer = false,
		RaidFrame = true,
		AutoRes = true,
		NumGroups = 6,
		SimpleMode = false,
		SMUnitsPerColumn = 20,
		SMGroupByIndex = 1,
		InstanceAuras = true,
		RaidDebuffScale = 1,
		SpecRaidPos = false,
		RaidHealthColor = 1,
		HorizonRaid = false,
		HorizonParty = false,
		ReverseRaid = false,
		ShowSolo = false,
		SimpleRaidScale = 10,
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
		RaidClickSets = false,
		ShowTeamIndex = false,
		ClassPower = true,
		QuakeTimer = true,
		LagString = true,
		RuneTimer = true,
		RaidBuffIndicator = true,
		PartyFrame = true,
		PartyWatcher = true,
		PWOnRight = false,
		PartyWidth = 100,
		PartyHeight = 32,
		PartyPowerHeight = 2,
		PartyPetFrame = false,
		PartyPetWidth = 100,
		PartyPetHeight = 22,
		PartyPetPowerHeight = 2,
		HealthColor = 1,
		BuffIndicatorType = 1,
		BuffIndicatorScale = 1,
		UFTextScale = 1,
		PartyAltPower = true,
		PartyWatcherSync = true,
		SmoothAmount = .3,
		RaidTextScale = 1,
		FrequentHealth = false,
		HealthFrequency = .2,
		TargetAurasPerRow = 9,

		PlayerWidth = 245,
		PlayerHeight = 24,
		PlayerPowerHeight = 4,
		PlayerPowerOffset = 2,
		FocusWidth = 200,
		FocusHeight = 22,
		FocusPowerHeight = 3,
		FocusPowerOffset = 2,
		PetWidth = 120,
		PetHeight = 18,
		PetPowerHeight = 2,
		BossWidth = 150,
		BossHeight = 22,
		BossPowerHeight = 2,

		CastingColor = {r=.3, g=.7, b=1},
		NotInterruptColor = {r=1, g=.5, b=.5},
		PlayerCBWidth = 300,
		PlayerCBHeight = 20,
		TargetCBWidth = 280,
		TargetCBHeight = 20,
		FocusCBWidth = 320,
		FocusCBHeight = 20,
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
		AllowFriends = true,
		ChatBGType = 2,
	},
	Map = {
		DisableMap = false,
		Clock = false,
		CombatPulse = true,
		MapScale = 1,
		MaxMapScale = 1,
		MinimapScale = 1.4,
		ShowRecycleBin = true,
		WhoPings = true,
		MapReveal = true,
		MapRevealGlow = true,
		Calendar = false,
	},
	Nameplate = {
		Enable = true,
		maxAuras = 5,
		AuraSize = 28,
		AuraFilter = 3,
		FriendlyCC = false,
		HostileCC = true,
		TankMode = false,
		TargetIndicator = 5,
		InsideView = true,
		PlateWidth = 190,
		PlateHeight = 8,
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
		FullHealth = true,
		SecureColor = {r=1, g=0, b=1},
		TransColor = {r=1, g=.8, b=0},
		InsecureColor = {r=1, g=0, b=0},
		OffTankColor = {r=.2, g=.7, b=.5},
		DPSRevertThreat = false,
		ExplosivesScale = false,
		AKSProgress = false,
		PPFadeout = true,
		PPFadeoutAlpha = 0,
		PPOnFire = false,
		NameplateClassPower = false,
		NameTextSize = 14,
		HealthTextSize = 16,
		MinScale = 1,
		MinAlpha = 1,
		ColorBorder = false,
		QuestIndicator = true,
		NameOnlyMode = false,
		PPGCDTicker = true,
		ExecuteRatio = 0,
		ColoredTarget = false,
		TargetColor = {r=0, g=.6, b=1},
		ColoredFocus = false,
		FocusColor = {r=1, g=.8, b=0},
		CastbarGlow = true,
		CastTarget = false,
	},
	Skins = {
		DBM = true,
		Skada = true,
		Bigwigs = true,
		TMW = true,
		PetBattle = true,
		WeakAuras = true,
		InfobarLine = true,
		ChatbarLine = true,
		MenuLine = true,
		ClassLine = true,
		Details = true,
		PGFSkin = true,
		Rematch = true,
		ToggleDirection = 1,
		BlizzardSkins = true,
		SkinAlpha = .5,
		DefaultBags = true,
		FlatMode = false,
		AlertFrames = true,
		FontOutline = true,
		Loot = true,
		Shadow = true,
		FontScale = 1,
	},
	Tooltip = {
		CombatHide = false,
		Cursor = false,
		ClassColor = false,
		HideRank = false,
		FactionIcon = true,
		LFDRole = false,
		TargetBy = true,
		Scale = 1,
		SpecLevelByShift = false,
		HideRealm = false,
		HideTitle = false,
		HideJunkGuild = true,
		AzeriteArmor = true,
		OnlyArmorIcons = false,
		ConduitInfo = true,
		HideAllID = false,
	},
	Misc = {
		Mail = true,
		ItemLevel = true,
		GemNEnchant = true,
		AzeriteTraits = true,
		MissingStats = true,
		SoloInfo = true,
		RareAlerter = true,
		AlertinChat = false,
		Focuser = true,
		ExpRep = true,
		Screenshot = true,
		TradeTabs = true,
		Interrupt = false,
		OwnInterrupt = true,
		AlertInInstance = true,
		BrokenSpell = false,
		FasterLoot = true,
		AutoQuest = false,
		HideTalking = true,
		HideBossBanner = false,
		HideBossEmote = false,
		PetFilter = true,
		QuestNotification = false,
		QuestProgress = false,
		OnlyCompleteRing = false,
		ExplosiveCount = false,
		ExplosiveCache = {},
		PlacedItemAlert = false,
		RareAlertInWild = false,
		ParagonRep = true,
		InstantDelete = true,
		RaidTool = true,
		RMRune = false,
		DBMCount = "10",
		EasyMarking = true,
		ShowMarkerBar = 4,
		BlockInvite = false,
		NzothVision = true,
		SendActionCD = false,
		MawThreatBar = true,
		MDGuildBest = true,
		FasterSkip = false,
		EnhanceDressup = true,
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
	RepairType = 1,
	AutoSell = true,
	GuildSortBy = 1,
	GuildSortOrder = true,
	DetectVersion = DB.Version,
	ResetDetails = true,
	LockUIScale = false,
	UIScale = .71,
	NumberFormat = 1,
	VersionCheck = true,
	DBMRequest = false,
	SkadaRequest = false,
	BWRequest = false,
	RaidAuraWatch = {},
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
	PartySpells = {},
	CornerSpells = {},
	CustomTex = "",
	MajorSpells = {},
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
		if fullClean and type(j) == "table" then
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

local function setupRaidFrame()
	G:SetupRaidFrame(guiPage[4])
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

local function setupPartyWatcher()
	G:SetupPartyWatcher(guiPage[4])
end

local function setupNameplateFilter()
	G:SetupNameplateFilter(guiPage[5])
end

local function setupPlateCastbarGlow()
	G:PlateCastbarGlow(guiPage[5])
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

local function updateActionbarScale()
	B:GetModule("Actionbar"):UpdateAllScale()
end

local function updateCustomBar()
	B:GetModule("Actionbar"):UpdateCustomBar()
end

local function updateHotkeys()
	local Bar = B:GetModule("Actionbar")
	for _, button in pairs(Bar.buttons) do
		if button.UpdateHotkeys then
			button:UpdateHotkeys(button.buttonType)
		end
	end
end

local function updateBuffFrame()
	local A = B:GetModule("Auras")
	A:UpdateOptions()
	A:UpdateHeader(A.BuffFrame)
	A.BuffFrame.mover:SetSize(A.BuffFrame:GetSize())
end

local function updateDebuffFrame()
	local A = B:GetModule("Auras")
	A:UpdateOptions()
	A:UpdateHeader(A.DebuffFrame)
	A.DebuffFrame.mover:SetSize(A.DebuffFrame:GetSize())
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

local function updateToggleDirection()
	B:GetModule("Skins"):RefreshToggleDirection()
end

local function updatePlateInsideView()
	B:GetModule("UnitFrames"):PlateInsideView()
end

local function updatePlateSpacing()
	B:GetModule("UnitFrames"):UpdatePlateSpacing()
end

local function updateCustomUnitList()
	B:GetModule("UnitFrames"):CreateUnitTable()
end

local function updatePowerUnitList()
	B:GetModule("UnitFrames"):CreatePowerUnitTable()
end

local function refreshNameplates()
	B:GetModule("UnitFrames"):RefreshAllPlates()
end

local function togglePlatePower()
	B:GetModule("UnitFrames"):TogglePlatePower()
end

local function togglePlateVisibility()
	B:GetModule("UnitFrames"):TogglePlateVisibility()
end

local function toggleGCDTicker()
	B:GetModule("UnitFrames"):ToggleGCDTicker()
end

local function updatePlateScale()
	B:GetModule("UnitFrames"):UpdatePlateScale()
end

local function updatePlateAlpha()
	B:GetModule("UnitFrames"):UpdatePlateAlpha()
end

local function updateRaidNameText()
	B:GetModule("UnitFrames"):UpdateRaidNameText()
end

local function updateUFTextScale()
	B:GetModule("UnitFrames"):UpdateTextScale()
end

local function updateRaidTextScale()
	B:GetModule("UnitFrames"):UpdateRaidTextScale()
end

local function refreshRaidFrameIcons()
	B:GetModule("UnitFrames"):RefreshRaidFrameIcons()
end

local function updateTargetFrameAuras()
	B:GetModule("UnitFrames"):UpdateTargetAuras()
end

local function updateSimpleModeGroupBy()
	local UF = B:GetModule("UnitFrames")
	if UF.UpdateSimpleModeHeader then
		UF:UpdateSimpleModeHeader()
	end
end

local function updateRaidHealthMethod()
	B:GetModule("UnitFrames"):UpdateRaidHealthMethod()
end

local function updateSmoothingAmount()
	B:SetSmoothingAmount(C.db["UFs"]["SmoothAmount"])
end

local function updateMinimapScale()
	B:GetModule("Maps"):UpdateMinimapScale()
end

local function showMinimapClock()
	B:GetModule("Maps"):ShowMinimapClock()
end

local function showCalendar()
	B:GetModule("Maps"):ShowCalendar()
end

local function updateInterruptAlert()
	B:GetModule("Misc"):InterruptAlert()
end

local function updateExplosiveAlert()
	B:GetModule("Misc"):ExplosiveAlert()
end

local function updateRareAlert()
	B:GetModule("Misc"):RareAlert()
end

local function updateSoloInfo()
	B:GetModule("Misc"):SoloInfo()
end

local function updateQuestNotification()
	B:GetModule("Misc"):QuestNotification()
end

local function updateScreenShot()
	B:GetModule("Misc"):UpdateScreenShot()
end

local function updateFasterLoot()
	B:GetModule("Misc"):UpdateFasterLoot()
end

local function toggleBossBanner()
	B:GetModule("Misc"):ToggleBossBanner()
end

local function toggleBossEmote()
	B:GetModule("Misc"):ToggleBossEmote()
end

local function updateMarkerGrid()
	B:GetModule("Misc"):RaidTool_UpdateGrid()
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
		NDuiADB["ResetDetails"] = true
		ReloadUI()
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
local NewFeatureTag = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"

G.TabList = {
	L["Actionbar"],
	L["Bags"],
	L["Unitframes"],
	L["RaidFrame"],
	NewFeatureTag..L["Nameplate"],
	L["PlayerPlate"],
	L["Auras"],
	L["Raid Tools"],
	L["ChatFrame"],
	L["Maps"],
	L["Skins"],
	L["Tooltip"],
	NewFeatureTag..L["Misc"],
	NewFeatureTag..L["UI Settings"],
	L["Profile"],
}

G.OptionList = { -- type, key, value, name, horizon, doubleline
	[1] = {
		{1, "Actionbar", "Enable", HeaderTag..L["Enable Actionbar"]},
		{},--blank
		{1, "Actionbar", "MicroMenu", L["Micromenu"]},
		{1, "Actionbar", "ShowStance", L["ShowStanceBar"], true},
		{1, "Actionbar", "Bar4Fade", L["Bar4 Fade"]},
		{1, "Actionbar", "Bar5Fade", L["Bar5 Fade"], true},
		{4, "Actionbar", "Style", L["Actionbar Style"], false, {L["BarStyle1"], L["BarStyle2"], L["BarStyle3"], L["BarStyle4"], L["BarStyle5"]}},
		{3, "Actionbar", "Scale", L["Actionbar Scale"].."*", true, {.5, 1.5, .01}, updateActionbarScale},
		{},--blank
		{1, "Actionbar", "CustomBar", HeaderTag..L["Enable CustomBar"], nil, nil, nil, L["CustomBarTip"]},
		{1, "Actionbar", "CustomBarFader", L["CustomBarFader"]},
		{3, "Actionbar", "CustomBarButtonSize", L["CustomBarButtonSize"].."*", true, {24, 60, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumButtons", L["CustomBarNumButtons"].."*", nil, {1, 12, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumPerRow", L["CustomBarNumPerRow"].."*", true, {1, 12, 1}, updateCustomBar},
		{},--blank
		{1, "Actionbar", "Cooldown", HeaderTag..L["Show Cooldown"]},
		{1, "Actionbar", "OverrideWA", L["HideCooldownOnWA"].."*", true},
		{1, "Actionbar", "DecimalCD", L["Decimal Cooldown"].."*"},
		{1, "Misc", "SendActionCD", HeaderTag..L["SendActionCD"].."*", true, nil, nil, L["SendActionCDTip"]},
		{},--blank
		{1, "Actionbar", "Hotkeys", L["Actionbar Hotkey"].."*", nil, nil, updateHotkeys},
		{1, "Actionbar", "Macro", L["Actionbar Macro"], true},
		{1, "Actionbar", "Count", L["Actionbar Item Counts"]},
		{1, "Actionbar", "Classcolor", L["ClassColor BG"], true},
	},
	[2] = {
		{1, "Bags", "Enable", HeaderTag..L["Enable Bags"]},
		{},--blank
		{1, "Bags", "ItemFilter", L["Bags ItemFilter"].."*", nil, setupBagFilter, updateBagStatus},
		{1, "Bags", "GatherEmpty", L["Bags GatherEmpty"].."*", true, nil, updateBagStatus},
		{1, "Bags", "SpecialBagsColor", L["SpecialBagsColor"].."*", nil, nil, updateBagStatus, L["SpecialBagsColorTip"]},
		{1, "Bags", "DeleteButton", L["Bags DeleteButton"], true},
		{1, "Bags", "BagsiLvl", L["Bags Itemlevel"].."*", nil, nil, updateBagStatus},
		{1, "Bags", "ShowNewItem", L["Bags ShowNewItem"], true},
		{3, "Bags", "iLvlToShow", L["iLvlToShow"].."*", nil, {1, 500, 1}, nil, L["iLvlToShowTip"]},
		{4, "Bags", "BagSortMode", L["BagSortMode"].."*", true, {L["Forward"], L["Backward"], DISABLE}, updateBagSortOrder, L["BagSortTip"]},
		{},--blank
		{3, "Bags", "BagsScale", L["Bags Scale"], false, {.5, 1.5, .1}},
		{3, "Bags", "IconSize", L["Bags IconSize"], true, {30, 42, 1}},
		{3, "Bags", "BagsWidth", L["Bags Width"], false, {12, 40, 1}},
		{3, "Bags", "BankWidth", L["Bank Width"], true, {12, 40, 1}},
	},
	[3] = {
		{1, "UFs", "Enable", HeaderTag..L["Enable UFs"], nil, setupUnitFrame, nil, L["HideUFWarning"]},
		{},--blank
		{1, "UFs", "Castbars", HeaderTag..L["UFs Castbar"], nil, setupCastbar},
		{1, "UFs", "SwingBar", L["UFs SwingBar"]},
		{1, "UFs", "SwingTimer", L["UFs SwingTimer"], true, nil, nil, L["SwingTimer Tip"]},
		{1, "UFs", "LagString", L["Castbar LagString"]},
		{1, "UFs", "QuakeTimer", L["UFs QuakeTimer"], true},
		{},--blank
		{1, "UFs", "Arena", L["Arena Frame"]},
		{1, "UFs", "Portrait", L["UFs Portrait"], true},
		{1, "UFs", "ClassPower", L["UFs ClassPower"]},
		{1, "UFs", "RuneTimer", L["UFs RuneTimer"], true},
		{1, "UFs", "PlayerDebuff", L["Player Debuff"]},
		{1, "UFs", "ToTAuras", L["ToT Debuff"], true},
		{4, "UFs", "HealthColor", L["HealthColor"].."*", nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}, updateUFTextScale},
		{3, "UFs", "TargetAurasPerRow", L["TargetAurasPerRow"].."*", true, {5, 10, 1}, updateTargetFrameAuras},
		{3, "UFs", "UFTextScale", L["UFTextScale"].."*", nil, {.8, 1.5, .05}, updateUFTextScale},
		{3, "UFs", "SmoothAmount", HeaderTag..L["SmoothAmount"].."*", true, {.15, .6, .05}, updateSmoothingAmount, L["SmoothAmountTip"]},
		{},--blank
		{1, "UFs", "CombatText", HeaderTag..L["UFs CombatText"]},
		{1, "UFs", "AutoAttack", L["CombatText AutoAttack"].."*"},
		{1, "UFs", "PetCombatText", L["CombatText ShowPets"].."*", true},
		{1, "UFs", "HotsDots", L["CombatText HotsDots"].."*"},
		{1, "UFs", "FCTOverHealing", L["CombatText OverHealing"].."*"},
		{3, "UFs", "FCTFontSize", L["FCTFontSize"].."*", true, {12, 40, 1}},
	},
	[4] = {
		{1, "UFs", "RaidFrame", HeaderTag..L["UFs RaidFrame"], nil, setupRaidFrame, nil, L["RaidFrameTip"]},
		{},--blank
		{1, "UFs", "PartyFrame", HeaderTag..L["UFs PartyFrame"]},
		{1, "UFs", "PartyPetFrame", HeaderTag..L["UFs PartyPetFrame"], true},
		{1, "UFs", "HorizonParty", L["Horizon PartyFrame"]},
		{1, "UFs", "PartyAltPower", L["UFs PartyAltPower"], true, nil, nil, L["PartyAltPowerTip"]},
		{1, "UFs", "PartyWatcher", HeaderTag..L["UFs PartyWatcher"], nil, setupPartyWatcher, nil, L["PartyWatcherTip"]},
		{1, "UFs", "PWOnRight", L["PartyWatcherOnRight"], true},
		{1, "UFs", "PartyWatcherSync", L["PartyWatcherSync"], nil, nil, nil, L["PartyWatcherSyncTip"]},
		{},--blank
		{1, "UFs", "RaidClickSets", HeaderTag..L["Enable ClickSets"], nil, setupClickCast},
		{1, "UFs", "AutoRes", L["UFs AutoRes"], true},
		{1, "UFs", "RaidBuffIndicator", HeaderTag..L["RaidBuffIndicator"], nil, setupBuffIndicator, nil, L["RaidBuffIndicatorTip"]},
		{4, "UFs", "BuffIndicatorType", L["BuffIndicatorType"].."*", nil, {L["BI_Blocks"], L["BI_Icons"], L["BI_Numbers"]}, refreshRaidFrameIcons},
		{3, "UFs", "BuffIndicatorScale", L["BuffIndicatorScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{1, "UFs", "InstanceAuras", HeaderTag..L["Instance Auras"], nil, setupRaidDebuffs, nil, L["InstanceAurasTip"]},
		{1, "UFs", "AurasClickThrough", L["RaidAuras ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "UFs", "RaidDebuffScale", L["RaidDebuffScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{},--blank
		{1, "UFs", "ShowSolo", L["ShowSolo"], nil, nil, nil, L["ShowSoloTip"]},
		{1, "UFs", "SpecRaidPos", L["Spec RaidPos"], true, nil, nil, L["SpecRaidPosTip"]},
		{1, "UFs", "ShowTeamIndex", L["RaidFrame TeamIndex"]},
		{1, "UFs", "FrequentHealth", HeaderTag..L["FrequentHealth"].."*", true, nil, updateRaidHealthMethod, L["FrequentHealthTip"]},
		{1, "UFs", "HorizonRaid", L["Horizon RaidFrame"]},
		{1, "UFs", "ReverseRaid", L["Reverse RaidFrame"]},
		{3, "UFs", "HealthFrequency", L["HealthFrequency"].."*", true, {.02, .2, .01}, updateRaidHealthMethod, L["HealthFrequencyTip"]},
		{3, "UFs", "NumGroups", L["Num Groups"], nil, {4, 8, 1}},
		{3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, updateRaidTextScale},
		{4, "UFs", "RaidHealthColor", L["HealthColor"].."*", nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}, updateRaidTextScale},
		{4, "UFs", "RaidHPMode", L["RaidHPMode"].."*", true, {L["DisableRaidHP"], L["RaidHPPercent"], L["RaidHPCurrent"], L["RaidHPLost"]}, updateRaidNameText},
		{},--blank
		{1, "UFs", "SimpleMode", HeaderTag..L["SimpleRaidFrame"], nil, nil, nil, L["SimpleRaidFrameTip"]},
		{3, "UFs", "SMUnitsPerColumn", L["SimpleMode Column"], nil, {10, 40, 1}},
		{4, "UFs", "SMGroupByIndex", L["SimpleMode GroupBy"].."*", true, {GROUP, CLASS, ROLE}, updateSimpleModeGroupBy},
		{nil, true},-- FIXME: dirty fix for now
		{nil, true},
	},
	[5] = {
		{1, "Nameplate", "Enable", HeaderTag..L["Enable Nameplate"], nil, setupNameplateFilter},
		{1, "Nameplate", "NameOnlyMode", L["NameOnlyMode"].."*", true, nil, nil, L["NameOnlyModeTip"]},
		{},--blank
		{4, "Nameplate", "TargetIndicator", L["TargetIndicator"].."*", nil, {DISABLE, L["TopArrow"], L["RightArrow"], L["TargetGlow"], L["TopNGlow"], L["RightNGlow"]}, refreshNameplates},
		{4, "Nameplate", "AuraFilter", L["NameplateAuraFilter"].."*", true, {L["BlackNWhite"], L["PlayerOnly"], L["IncludeCrowdControl"]}, refreshNameplates},
		{1, "Nameplate", "FriendlyCC", L["Friendly CC"].."*"},
		{1, "Nameplate", "HostileCC", L["Hostile CC"].."*", true},
		{1, "Nameplate", "FullHealth", L["Show FullHealth"].."*", nil, nil, refreshNameplates},
		{1, "Nameplate", "ColorBorder", L["ColorBorder"].."*", true, nil, refreshNameplates},
		{1, "Nameplate", "InsideView", L["Nameplate InsideView"].."*", nil, nil, updatePlateInsideView},
		{1, "Nameplate", "ExplosivesScale", L["ExplosivesScale"], true, nil, nil, L["ExplosivesScaleTip"]},
		{1, "Nameplate", "QuestIndicator", L["QuestIndicator"]},
		{1, "Nameplate", "AKSProgress", L["AngryKeystones Progress"], true},
		{1, "Nameplate", "CastbarGlow", L["PlateCastbarGlow"].."*", nil, setupPlateCastbarGlow, nil, L["PlateCastbarGlowTip"]},
		{1, "Nameplate", "CastTarget", NewFeatureTag..L["PlateCastTarget"].."*", true, nil, nil, L["PlateCastTargetTip"]},
		{},--blank
		{1, "Nameplate", "ColoredTarget", HeaderTag..L["ColoredTarget"].."*", nil, nil, nil, L["ColoredTargetTip"]},
		{1, "Nameplate", "ColoredFocus", NewFeatureTag..HeaderTag..L["ColoredFocus"].."*", true, nil, nil, L["ColoredFocusTip"]},
		{5, "Nameplate", "TargetColor", L["TargetNP Color"].."*"},
		{5, "Nameplate", "FocusColor", L["FocusNP Color"].."*", 2},
		{},--blank
		{1, "Nameplate", "CustomUnitColor", HeaderTag..L["CustomUnitColor"].."*", nil, nil, updateCustomUnitList, L["CustomUnitColorTip"]},
		{5, "Nameplate", "CustomColor", L["Custom Color"].."*", 2},
		{2, "Nameplate", "UnitList", L["UnitColor List"].."*", nil, nil, updateCustomUnitList, L["CustomUnitTips"]},
		{2, "Nameplate", "ShowPowerList", L["ShowPowerList"].."*", true, nil, updatePowerUnitList, L["CustomUnitTips"]},
		{},--blank
		{1, "Nameplate", "TankMode", HeaderTag..L["Tank Mode"].."*", nil, nil, nil, L["TankModeTip"]},
		{1, "Nameplate", "DPSRevertThreat", L["DPS Revert Threat"].."*", true, nil, nil, L["RevertThreatTip"]},
		{5, "Nameplate", "SecureColor", L["Secure Color"].."*"},
		{5, "Nameplate", "TransColor", L["Trans Color"].."*", 1},
		{5, "Nameplate", "InsecureColor", L["Insecure Color"].."*", 2},
		{5, "Nameplate", "OffTankColor", L["OffTank Color"].."*", 3},
		{},--blank
		{3, "Nameplate", "ExecuteRatio", "|cffff0000"..L["ExecuteRatio"].."*", nil, {0, 90, 1}, nil, L["ExecuteRatioTip"]},
		{3, "Nameplate", "VerticalSpacing", L["NP VerticalSpacing"].."*", true, {.5, 1.5, .1}, updatePlateSpacing},
		{3, "Nameplate", "MinScale", L["Nameplate MinScale"].."*", false, {.5, 1, .1}, updatePlateScale},
		{3, "Nameplate", "MinAlpha", L["Nameplate MinAlpha"].."*", true, {.5, 1, .1}, updatePlateAlpha},
		{3, "Nameplate", "PlateWidth", L["NP Width"].."*", false, {50, 250, 1}, refreshNameplates},
		{3, "Nameplate", "PlateHeight", L["NP Height"].."*", true, {5, 30, 1}, refreshNameplates},
		{3, "Nameplate", "NameTextSize", L["NameTextSize"].."*", false, {10, 30, 1}, refreshNameplates},
		{3, "Nameplate", "HealthTextSize", L["HealthTextSize"].."*", true, {10, 30, 1}, refreshNameplates},
		{3, "Nameplate", "maxAuras", L["Max Auras"].."*", false, {0, 10, 1}, refreshNameplates},
		{3, "Nameplate", "AuraSize", L["Auras Size"].."*", true, {18, 40, 1}, refreshNameplates},
	},
	[6] = {
		{1, "Nameplate", "ShowPlayerPlate", HeaderTag..L["Enable PlayerPlate"]},
		{},--blank
		{1, "Auras", "ClassAuras", L["Enable ClassAuras"]},
		{1, "Nameplate", "PPOnFire", L["PlayerPlate OnFire"], true, nil, nil, L["PPOnFireTip"]},
		{1, "Nameplate", "NameplateClassPower", L["Nameplate ClassPower"], nil},
		{1, "Nameplate", "PPFadeout", L["PlayerPlate Fadeout"].."*", true, nil, togglePlateVisibility},
		{1, "Nameplate", "PPPowerText", L["PlayerPlate PowerText"].."*", nil, nil, togglePlatePower},
		{1, "Nameplate", "PPGCDTicker", L["PlayerPlate GCDTicker"].."*", nil, nil, toggleGCDTicker},
		{3, "Nameplate", "PPFadeoutAlpha", L["PlayerPlate FadeoutAlpha"].."*", true, {0, .5, .05}, togglePlateVisibility},
		{},--blank
		{3, "Nameplate", "PPWidth", L["PlayerPlate HPWidth"].."*", false, {150, 300, 1}, refreshNameplates},
		{3, "Nameplate", "PPBarHeight", L["PlayerPlate CPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPHealthHeight", L["PlayerPlate HPHeight"].."*", false, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPPowerHeight", L["PlayerPlate MPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
	},
	[7] = {
		{1, "AuraWatch", "Enable", HeaderTag..L["Enable AuraWatch"], nil, setupAuraWatch},
		{1, "AuraWatch", "DeprecatedAuras", L["DeprecatedAuras"], true},
		{1, "AuraWatch", "QuakeRing", L["QuakeRing"].."*"},
		{1, "AuraWatch", "ClickThrough", L["AuraWatch ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "AuraWatch", "IconScale", L["AuraWatch IconScale"], true, {.8, 2, .1}},
		{},--blank
		{1, "Auras", "Totems", HeaderTag..L["Enable Totembar"]},
		{1, "Auras", "VerticalTotems", L["VerticalTotems"].."*", nil, nil, refreshTotemBar},
		{3, "Auras", "TotemSize", L["TotemSize"].."*", true, {24, 60, 1}, refreshTotemBar},
		{},--blank
		{1, "Auras", "Reminder", L["Enable Reminder"].."*", nil, nil, updateReminder, L["ReminderTip"]},
		{},--blank
		{1, "Auras", "ReverseBuffs", L["ReverseBuffs"].."*", nil, nil, updateBuffFrame},
		{1, "Auras", "ReverseDebuffs", L["ReverseDebuffs"].."*", true, nil, updateDebuffFrame},
		{3, "Auras", "BuffSize", L["BuffSize"].."*", nil, {24, 50, 1}, updateBuffFrame},
		{3, "Auras", "DebuffSize", L["DebuffSize"].."*", true, {24, 50, 1}, updateDebuffFrame},
		{3, "Auras", "BuffsPerRow", L["BuffsPerRow"].."*", nil, {10, 20, 1}, updateBuffFrame},
		{3, "Auras", "DebuffsPerRow", L["DebuffsPerRow"].."*", true, {10, 16, 1}, updateDebuffFrame},
	},
	[8] = {
		{1, "Misc", "RaidTool", HeaderTag..L["Raid Manger"]},
		{1, "Misc", "RMRune", L["Runes Check"].."*"},
		{1, "Misc", "EasyMarking", L["Easy Mark"].."*", true},
		{2, "Misc", "DBMCount", L["DBMCount"].."*", nil, nil, nil, L["DBMCountTip"]},
		{4, "Misc", "ShowMarkerBar", L["ShowMarkerBar"].."*", true, {L["Grids"], L["Horizontal"], L["Vertical"], DISABLE}, updateMarkerGrid},
		{},--blank
		{1, "Misc", "QuestNotification", HeaderTag..L["QuestNotification"].."*", nil, nil, updateQuestNotification},
		{1, "Misc", "QuestProgress", L["QuestProgress"].."*"},
		{1, "Misc", "OnlyCompleteRing", L["OnlyCompleteRing"].."*", true},
		{},--blank
		{1, "Misc", "Interrupt", HeaderTag..L["Interrupt Alert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "AlertInInstance", L["Alert In Instance"].."*", true},
		{1, "Misc", "OwnInterrupt", L["Own Interrupt"].."*"},
		{1, "Misc", "BrokenSpell", L["Broken Spell"].."*", true, nil, nil, L["BrokenSpellTip"]},
		{},--blank
		{1, "Misc", "ExplosiveCount", L["Explosive Alert"].."*", nil, nil, updateExplosiveAlert, L["ExplosiveAlertTip"]},
		{1, "Misc", "PlacedItemAlert", L["Placed Item Alert"].."*", true},
		{1, "Misc", "SoloInfo", L["SoloInfo"].."*", nil, nil, updateSoloInfo},
		{1, "Misc", "NzothVision", L["NzothVision"], true},
		{},--blank
		{1, "Misc", "RareAlerter", HeaderTag..L["Rare Alert"].."*", nil, nil, updateRareAlert},
		{1, "Misc", "AlertinChat", L["Alert In Chat"].."*"},
		{1, "Misc", "RareAlertInWild", L["RareAlertInWild"].."*", true},
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
		{1, "Chat", "Freedom", L["Language Filter"], true},
		{4, "ACCOUNT", "TimestampFormat", L["TimestampFormat"].."*", nil, {DISABLE, "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}},
		{4, "Chat", "ChatBGType", L["ChatBGType"].."*", true, {DISABLE, L["Default Dark"], L["Gradient"]}, toggleChatBackground},
		{},--blank
		{1, "Chat", "EnableFilter", HeaderTag..L["Enable Chatfilter"]},
		{1, "Chat", "BlockAddonAlert", L["Block Addon Alert"], true},
		{1, "Chat", "AllowFriends", L["AllowFriendsSpam"].."*", nil, nil, nil, L["AllowFriendsSpamTip"]},
		{1, "Chat", "BlockStranger", "|cffff0000"..L["BlockStranger"].."*", nil, nil, nil, L["BlockStrangerTip"]},
		{2, "ACCOUNT", "ChatFilterWhiteList", HeaderTag..L["ChatFilterWhiteList"].."*", true, nil, updateFilterWhiteList, L["ChatFilterWhiteListTip"]},
		{3, "Chat", "Matches", L["Keyword Match"].."*", false, {1, 3, 1}},
		{2, "ACCOUNT", "ChatFilterList", L["Filter List"].."*", true, nil, updateFilterList, L["FilterListTip"]},
		{},--blank
		{1, "Chat", "Invite", HeaderTag..L["Whisper Invite"]},
		{1, "Chat", "GuildInvite", L["Guild Invite Only"].."*"},
		{2, "Chat", "Keyword", L["Whisper Keyword"].."*", true, nil, updateWhisperList, L["WhisperKeywordTip"]},
	},
	[10] = {
		{1, "Map", "DisableMap", "|cffff0000"..L["DisableMap"], nil, nil, nil, L["DisableMapTip"]},
		{1, "Map", "MapRevealGlow", L["MapRevealGlow"].."*", true, nil, nil, L["MapRevealGlowTip"]},
		{3, "Map", "MapScale", L["Map Scale"].."*", false, {.8, 2, .1}},
		{3, "Map", "MaxMapScale", L["Maximize Map Scale"].."*", true, {.5, 1, .1}},
		{},--blank
		{1, "Map", "Calendar", L["MinimapCalendar"].."*", nil, nil, showCalendar, L["MinimapCalendarTip"]},
		{1, "Map", "Clock", L["Minimap Clock"].."*", true, nil, showMinimapClock},
		{1, "Map", "CombatPulse", L["Minimap Pulse"]},
		{1, "Map", "WhoPings", L["Show WhoPings"], true},
		{1, "Map", "ShowRecycleBin", L["Show RecycleBin"]},
		{1, "Misc", "ExpRep", L["Show Expbar"]},
		{3, "Map", "MinimapScale", L["Minimap Scale"].."*", true, {1, 2, .1}, updateMinimapScale},
	},
	[11] = {
		{1, "Skins", "BlizzardSkins", HeaderTag..L["BlizzardSkins"], nil, nil, nil, L["BlizzardSkinsTips"]},
		{1, "Skins", "AlertFrames", L["ReskinAlertFrames"], true},
		{1, "Skins", "DefaultBags", L["DefaultBags"], nil, nil, nil, L["DefaultBagsTips"]},
		{1, "Skins", "Loot", L["Loot"], true},
		{1, "Skins", "PetBattle", L["PetBattle Skin"]},
		{1, "Skins", "FlatMode", L["FlatMode"], true},
		{1, "Skins", "Shadow", L["Shadow"]},
		{1, "Skins", "FontOutline", L["FontOutline"], true},
		{3, "Skins", "SkinAlpha", L["SkinAlpha"].."*", nil, {0, 1, .05}, updateSkinAlpha},
		{3, "Skins", "FontScale", L["GlobalFontScale"], true, {.5, 1.5, .05}},
		{},--blank
		{1, "Skins", "ClassLine", L["ClassColor Line"]},
		{1, "Skins", "InfobarLine", L["Infobar Line"], true},
		{1, "Skins", "ChatbarLine", L["Chat Line"]},
		{1, "Skins", "MenuLine", L["Menu Line"], true},
		{},--blank
		{1, "Skins", "Skada", L["Skada Skin"]},
		{1, "Skins", "Details", L["Details Skin"], nil, resetDetails},
		{4, "Skins", "ToggleDirection", L["ToggleDirection"].."*", true, {L["LEFT"], L["RIGHT"], L["TOP"], L["BOTTOM"]}, updateToggleDirection},
		{1, "Skins", "DBM", L["DBM Skin"]},
		{1, "Skins", "Bigwigs", L["Bigwigs Skin"], true},
		{1, "Skins", "TMW", L["TMW Skin"]},
		{1, "Skins", "WeakAuras", L["WeakAuras Skin"], true},
		{1, "Skins", "PGFSkin", L["PGF Skin"]},
		{1, "Skins", "Rematch", L["Rematch Skin"], true},
	},
	[12] = {
		{1, "Tooltip", "CombatHide", L["Hide Tooltip"].."*"},
		{1, "Tooltip", "Cursor", L["Follow Cursor"].."*"},
		{1, "Tooltip", "ClassColor", L["Classcolor Border"].."*"},
		{3, "Tooltip", "Scale", L["Tooltip Scale"].."*", true, {.5, 1.5, .1}},
		{},--blank
		{1, "Tooltip", "HideTitle", L["Hide Title"].."*"},
		{1, "Tooltip", "HideRank", L["Hide Rank"].."*", true},
		{1, "Tooltip", "FactionIcon", L["FactionIcon"].."*"},
		{1, "Tooltip", "HideJunkGuild", L["HideJunkGuild"].."*", true},
		{1, "Tooltip", "HideRealm", L["Hide Realm"].."*"},
		{1, "Tooltip", "SpecLevelByShift", L["Show SpecLevelByShift"].."*", true},
		{1, "Tooltip", "LFDRole", L["Group Roles"].."*"},
		{1, "Tooltip", "TargetBy", L["Show TargetedBy"].."*", true},
		{1, "Tooltip", "HideAllID", "|cffff0000"..L["HideAllID"]},
		{},--blank
		{1, "Tooltip", "AzeriteArmor", HeaderTag..L["Show AzeriteArmor"]},
		{1, "Tooltip", "OnlyArmorIcons", L["Armor icons only"].."*", true},
		{1, "Tooltip", "ConduitInfo", HeaderTag..L["Show ConduitInfo"]},
	},
	[13] = {
		{1, "Misc", "ItemLevel", HeaderTag..L["Show ItemLevel"], nil, nil, nil, L["ItemLevelTip"]},
		{1, "Misc", "GemNEnchant", L["Show GemNEnchant"].."*"},
		{1, "Misc", "AzeriteTraits", L["Show AzeriteTraits"].."*", true},
		{},--blank
		{1, "Misc", "HideTalking", L["No Talking"]},
		{1, "ACCOUNT", "AutoBubbles", L["AutoBubbles"], true},
		{1, "Misc", "HideBossEmote", L["HideBossEmote"].."*", nil, nil, toggleBossEmote},
		{1, "Misc", "HideBossBanner", L["Hide Bossbanner"].."*", true, nil, toggleBossBanner},
		{1, "Misc", "InstantDelete", L["InstantDelete"].."*"},
		{1, "Misc", "FasterLoot", L["Faster Loot"].."*", true, nil, updateFasterLoot},
		{1, "Misc", "BlockInvite", "|cffff0000"..L["BlockInvite"].."*", nil, nil, nil, L["BlockInviteTip"]},
		{1, "Misc", "FasterSkip", NewFeatureTag..L["FasterMovieSkip"], true, nil, nil, L["FasterMovieSkipTip"]},
		{},--blank
		{1, "Misc", "MissingStats", L["Show MissingStats"]},
		{1, "Misc", "ParagonRep", L["ParagonRep"], true},
		{1, "Misc", "Mail", L["Mail Tool"]},
		{1, "Misc", "TradeTabs", L["TradeTabs"], true},
		{1, "Misc", "PetFilter", L["Show PetFilter"]},
		{1, "Misc", "Screenshot", L["Auto ScreenShot"].."*", true, nil, updateScreenShot},
		{1, "Misc", "Focuser", L["Easy Focus"]},
		{1, "Misc", "MDGuildBest", L["MDGuildBest"], true, nil, nil, L["MDGuildBestTip"]},
		{1, "Misc", "MawThreatBar", L["MawThreatBar"], nil, nil, nil, L["MawThreatBarTip"]},
		{1, "Misc", "EnhanceDressup", NewFeatureTag..L["EnhanceDressup"], true, nil, nil, L["EnhanceDressupTip"]},
	},
	[14] = {
		{1, "ACCOUNT", "VersionCheck", L["Version Check"]},
		{1, "ACCOUNT", "DisableInfobars", L["DisableInfobars"], true},
		{},--blank
		{3, "ACCOUNT", "UIScale", L["Setup UIScale"], false, {.4, 1.15, .01}},
		{1, "ACCOUNT", "LockUIScale", HeaderTag..L["Lock UIScale"], true},
		{},--blank
		{4, "ACCOUNT", "TexStyle", L["Texture Style"], false, {}},
		{4, "ACCOUNT", "NumberFormat", L["Numberize"], true, {L["Number Type1"], L["Number Type2"], L["Number Type3"]}},
		{2, "ACCOUNT", "CustomTex", NewFeatureTag..L["CustomTex"], nil, nil, nil, L["CustomTexTip"]},
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

local function NDUI_VARIABLE(key, value, newValue)
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
			cb.name = B.CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			cb:SetChecked(NDUI_VARIABLE(key, value))
			cb:SetScript("OnClick", function()
				NDUI_VARIABLE(key, value, cb:GetChecked())
				if callback then callback() end
			end)
			if data and type(data) == "function" then
				local bu = B.CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
			if tooltip then
				cb.title = L["Tips"]
				B.AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info")
			end
		-- Editbox
		elseif optType == 2 then
			local eb = B.CreateEditBox(parent, 200, 28)
			eb:SetMaxLetters(999)
			if horizon then
				eb:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				eb:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			eb:SetText(NDUI_VARIABLE(key, value))
			eb:HookScript("OnEscapePressed", function()
				eb:SetText(NDUI_VARIABLE(key, value))
			end)
			eb:HookScript("OnEnterPressed", function()
				NDUI_VARIABLE(key, value, eb:GetText())
				if callback then callback() end
			end)

			B.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
			eb.title = L["Tips"]
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			B.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info")
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
			s.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			s:SetValue(NDUI_VARIABLE(key, value))
			s:SetScript("OnValueChanged", function(_, v)
				local current = B:Round(tonumber(v), 2)
				NDUI_VARIABLE(key, value, current)
				s.value:SetText(current)
				if callback then callback() end
			end)
			s.value:SetText(B:Round(NDUI_VARIABLE(key, value), 2))
			if tooltip then
				s.title = L["Tips"]
				B.AddTooltip(s, "ANCHOR_RIGHT", tooltip, "info")
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
			dd.Text:SetText(data[NDUI_VARIABLE(key, value)])

			local opt = dd.options
			dd.button:HookScript("OnClick", function()
				for num = 1, #data do
					if num == NDUI_VARIABLE(key, value) then
						opt[num]:SetBackdropColor(1, .8, 0, .3)
						opt[num].selected = true
					else
						opt[num]:SetBackdropColor(0, 0, 0, .3)
						opt[num].selected = false
					end
				end
			end)
			for i in pairs(data) do
				opt[i]:HookScript("OnClick", function()
					NDUI_VARIABLE(key, value, i)
					if callback then callback() end
				end)
				if value == "TexStyle" then
					AddTextureToOption(opt, i) -- texture preview
				end
			end

			B.CreateFS(dd, 14, name, "system", "CENTER", 0, 25)
			if tooltip then
				dd.title = L["Tips"]
				B.AddTooltip(dd, "ANCHOR_RIGHT", tooltip, "info")
			end
		-- Colorswatch
		elseif optType == 5 then
			local swatch = B.CreateColorSwatch(parent, name, NDUI_VARIABLE(key, value))
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
	["afdian"] = "33578473, normanvon, y368413, EK, msylgj, 夜丨灬清寒, akakai, reisen410, 其实你很帥, 萨菲尔, Antares, RyanZ, fldqw, Mario, 时光旧予, 食铁骑兵, 爱蕾丝的基总, 施然, 命运镇魂曲, 不可语上, Leo, 忘川, 刘翰承, 悟空海外党, cncj, 暗月, 汪某人, 黑手, iraq120, 嗜血未冷, 我又不是妖怪，养乐多，无人知晓，秋末旷夜，以及部分未备注名字的用户。",
	["Patreon"] = "Quentin, Julian Neigefind, silenkin, imba Villain, Zeyu Zhu.",
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

	CreateContactBox(frame, "NGA.CN", "https://bbs.nga.cn/read.php?tid=5483616", 1)
	CreateContactBox(frame, "GitHub", "https://github.com/siweia/NDui", 2)
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
		B.CreateBDFrame(guiPage[i], .25)
		guiPage[i]:Hide()
		guiPage[i].child = CreateFrame("Frame", nil, guiPage[i])
		guiPage[i].child:SetSize(610, 1)
		guiPage[i]:SetScrollChild(guiPage[i].child)
		B.ReskinScroll(guiPage[i].ScrollBar)
		guiPage[i]:SetScript("OnMouseWheel", scrollBarHook)

		CreateOption(i)
	end

	G:CreateProfileGUI(guiPage[15]) -- profile GUI

	local helpInfo = B.CreateHelpInfo(f, L["Option* Tips"])
	helpInfo:SetPoint("TOPLEFT", 20, -5)
	local guiHelpInfo = {
		text = L["GUIPanelHelp"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "GUIPanel",
	}
	if not NDuiADB["Help"]["GUIPanel"] then
		HelpTip:Show(helpInfo, guiHelpInfo)
	end

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