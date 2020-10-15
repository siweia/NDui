local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:RegisterModule("GUI")

local tonumber, tostring, pairs, ipairs, next, select, type = tonumber, tostring, pairs, ipairs, next, select, type
local tinsert, strsplit, strfind = table.insert, string.split, string.find
local cr, cg, cb = DB.r, DB.g, DB.b
local guiTab, guiPage, f, dataFrame = {}, {}

-- Default Settings
G.DefaultSettings = {
	BFA = false,
	Mover = {},
	InternalCD = {},
	AuraWatchMover = {},
	RaidClickSets = {},
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
		ItemSetFilter = false,
		DeleteButton = true,
		FavouriteItems = {},
		GatherEmpty = false,
		ShowNewItem = true,
		SplitCount = 1,
		SpecialBagsColor = false,
		iLvlToShow = 1,

		FilterJunk = true,
		FilterConsumable = true,
		FilterAzerite = true,
		FilterEquipment = true,
		FilterLegendary = true,
		FilterMount = true,
		FilterFavourite = true,
		FilterGoods = false,
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
		Coord = true,
		Clock = false,
		CombatPulse = true,
		MapScale = 1,
		MinimapScale = 1.4,
		ShowRecycleBin = true,
		WhoPings = true,
		MapReveal = true,
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
		--Distance = 42,
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
		NameplateClassPower = false,
		NameTextSize = 14,
		HealthTextSize = 16,
		MinScale = 1,
		MinAlpha = 1,
		ColorBorder = false,
		QuestIndicator = true,
		NameOnlyMode = false,
		PPGCDTicker = true,
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
		AzeriteArmor = false,
		OnlyArmorIcons = false,
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
		HideBanner = true,
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
	CornerBuffs = {},
	TexStyle = 2,
	KeystoneInfo = {},
	AutoBubbles = false,
	DisableInfobars = false,
	PartyWatcherSpells = {},
	ContactList = {},
	CustomJunkList = {},
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
	if not NDuiDB["BFA"] then
		NDuiDB = {}
		NDuiDB["BFA"] = true
	end

	InitialSettings(G.DefaultSettings, NDuiDB, true)
	InitialSettings(G.AccountSettings, NDuiADB)
	B:SetupUIScale(true)
	if not G.TextureList[NDuiADB["TexStyle"]] then
		NDuiADB["TexStyle"] = 2 -- reset value if not exists
	end
	DB.normTex = G.TextureList[NDuiADB["TexStyle"]].texture

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

local function setupAuraWatch()
	f:Hide()
	SlashCmdList["NDUI_AWCONFIG"]()
end

local function updateBagSortOrder()
	SetSortBagsRightToLeft(NDuiDB["Bags"]["BagSortMode"] == 1)
end

local function updateBagStatus()
	B:GetModule("Bags"):UpdateAllBags()

	local label = BAG_FILTER_EQUIPMENT
	if NDuiDB["Bags"]["ItemSetFilter"] then
		label = L["Equipement Set"]
	end
	_G.NDui_BackpackEquipment.label:SetText(label)
	_G.NDui_BackpackBankEquipment.label:SetText(label)
end

local function updateActionbarScale()
	B:GetModule("Actionbar"):UpdateAllScale()
end

local function updateCustomBar()
	B:GetModule("Actionbar"):UpdateCustomBar()
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
	if not NDuiDB["Auras"]["Totems"] then return end
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

local function updatePlateRange()
	B:GetModule("UnitFrames"):UpdatePlateRange()
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
	B:SetSmoothingAmount(NDuiDB["UFs"]["SmoothAmount"])
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
		frame:SetBackdropColor(0, 0, 0, NDuiDB["Skins"]["SkinAlpha"])
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
G.TabList = {
	L["Actionbar"],
	L["Bags"],
	L["Unitframes"],
	L["RaidFrame"],
	L["Nameplate"],
	L["PlayerPlate"],
	L["Auras"],
	L["Raid Tools"],
	L["ChatFrame"],
	L["Maps"],
	L["Skins"],
	L["Tooltip"],
	L["Misc"],
	L["UI Settings"],
}

G.OptionList = { -- type, key, value, name, horizon, doubleline
	[1] = {
		{1, "Actionbar", "Enable", "|cff00cc4c"..L["Enable Actionbar"]},
		{},--blank
		{1, "Actionbar", "MicroMenu", L["Micromenu"]},
		{1, "Actionbar", "ShowStance", L["ShowStanceBar"], true},
		{1, "Actionbar", "Bar4Fade", L["Bar4 Fade"]},
		{1, "Actionbar", "Bar5Fade", L["Bar5 Fade"], true},
		{4, "Actionbar", "Style", L["Actionbar Style"], false, {L["BarStyle1"], L["BarStyle2"], L["BarStyle3"], L["BarStyle4"], L["BarStyle5"]}},
		{3, "Actionbar", "Scale", L["Actionbar Scale"].."*", true, {.8, 1.5, .01}, updateActionbarScale},
		{},--blank
		{1, "Actionbar", "CustomBar", "|cff00cc4c"..L["Enable CustomBar"], nil, nil, nil, L["CustomBarTip"]},
		{1, "Actionbar", "CustomBarFader", L["CustomBarFader"]},
		{3, "Actionbar", "CustomBarButtonSize", L["CustomBarButtonSize"].."*", true, {24, 60, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumButtons", L["CustomBarNumButtons"].."*", nil, {1, 12, 1}, updateCustomBar},
		{3, "Actionbar", "CustomBarNumPerRow", L["CustomBarNumPerRow"].."*", true, {1, 12, 1}, updateCustomBar},
		{},--blank
		{1, "Actionbar", "Cooldown", "|cff00cc4c"..L["Show Cooldown"]},
		{1, "Actionbar", "DecimalCD", L["Decimal Cooldown"].."*"},
		{1, "Actionbar", "OverrideWA", L["HideCooldownOnWA"].."*", true},
		{},--blank
		{1, "Actionbar", "Hotkeys", L["Actionbar Hotkey"]},
		{1, "Actionbar", "Macro", L["Actionbar Macro"], true},
		{1, "Actionbar", "Count", L["Actionbar Item Counts"]},
		{1, "Actionbar", "Classcolor", L["ClassColor BG"], true},
	},
	[2] = {
		{1, "Bags", "Enable", "|cff00cc4c"..L["Enable Bags"]},
		{},--blank
		{1, "Bags", "ItemFilter", L["Bags ItemFilter"].."*", nil, setupBagFilter, updateBagStatus},
		{1, "Bags", "ItemSetFilter", L["Use ItemSetFilter"].."*", true, nil, updateBagStatus, L["ItemSetFilterTips"]},
		{1, "Bags", "GatherEmpty", L["Bags GatherEmpty"].."*", nil, nil, updateBagStatus},
		{1, "Bags", "SpecialBagsColor", L["SpecialBagsColor"].."*", true, nil, updateBagStatus, L["SpecialBagsColorTip"]},
		{1, "Bags", "ShowNewItem", L["Bags ShowNewItem"]},
		{1, "Bags", "DeleteButton", L["Bags DeleteButton"], true},
		{1, "Bags", "BagsiLvl", L["Bags Itemlevel"].."*", nil, nil, updateBagStatus},
		{3, "Bags", "iLvlToShow", L["iLvlToShow"].."*", nil, {1, 500, 1}, updateBagStatus, L["iLvlToShowTip"]},
		{4, "Bags", "BagSortMode", L["BagSortMode"].."*", true, {L["Forward"], L["Backward"], DISABLE}, updateBagSortOrder},
		{},--blank
		{3, "Bags", "BagsScale", L["Bags Scale"], false, {.5, 1.5, .1}},
		{3, "Bags", "IconSize", L["Bags IconSize"], true, {30, 42, 1}},
		{3, "Bags", "BagsWidth", L["Bags Width"], false, {12, 40, 1}},
		{3, "Bags", "BankWidth", L["Bank Width"], true, {12, 40, 1}},
	},
	[3] = {
		{1, "UFs", "Enable", "|cff00cc4c"..L["Enable UFs"], nil, setupUnitFrame, nil, L["HideUFWarning"]},
		{},--blank
		{1, "UFs", "Castbars", "|cff00cc4c"..L["UFs Castbar"], nil, setupCastbar},
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
		{4, "UFs", "HealthColor", L["HealthColor"], nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}},
		{3, "UFs", "TargetAurasPerRow", L["TargetAurasPerRow"].."*", true, {5, 10, 1}, updateTargetFrameAuras},
		{3, "UFs", "UFTextScale", L["UFTextScale"].."*", nil, {.8, 1.5, .05}, updateUFTextScale},
		{3, "UFs", "SmoothAmount", "|cff00cc4c"..L["SmoothAmount"].."*", true, {.15, .6, .05}, updateSmoothingAmount, L["SmoothAmountTip"]},
		{},--blank
		{1, "UFs", "CombatText", "|cff00cc4c"..L["UFs CombatText"]},
		{1, "UFs", "AutoAttack", L["CombatText AutoAttack"]},
		{1, "UFs", "PetCombatText", L["CombatText ShowPets"], true},
		{1, "UFs", "HotsDots", L["CombatText HotsDots"]},
		{1, "UFs", "FCTOverHealing", L["CombatText OverHealing"], true},
	},
	[4] = {
		{1, "UFs", "RaidFrame", "|cff00cc4c"..L["UFs RaidFrame"], nil, setupRaidFrame, nil, L["RaidFrameTip"]},
		{},--blank
		{1, "UFs", "PartyFrame", "|cff00cc4c"..L["UFs PartyFrame"]},
		{1, "UFs", "PartyPetFrame", "|cff00cc4c"..L["UFs PartyPetFrame"], true},
		{1, "UFs", "HorizonParty", L["Horizon PartyFrame"]},
		{1, "UFs", "PartyAltPower", L["UFs PartyAltPower"], true, nil, nil, L["PartyAltPowerTip"]},
		{1, "UFs", "PartyWatcher", "|cff00cc4c"..L["UFs PartyWatcher"], nil, setupPartyWatcher, nil, L["PartyWatcherTip"]},
		{1, "UFs", "PWOnRight", L["PartyWatcherOnRight"], true},
		{1, "UFs", "PartyWatcherSync", L["PartyWatcherSync"], nil, nil, nil, L["PartyWatcherSyncTip"]},
		{},--blank
		{1, "UFs", "RaidBuffIndicator", "|cff00cc4c"..L["RaidBuffIndicator"], nil, setupBuffIndicator, nil, L["RaidBuffIndicatorTip"]},
		{4, "UFs", "BuffIndicatorType", L["BuffIndicatorType"].."*", nil, {L["BI_Blocks"], L["BI_Icons"], L["BI_Numbers"]}, refreshRaidFrameIcons},
		{3, "UFs", "BuffIndicatorScale", L["BuffIndicatorScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{1, "UFs", "RaidClickSets", "|cff00cc4c"..L["Enable ClickSets"], nil, setupClickCast},
		{1, "UFs", "InstanceAuras", "|cff00cc4c"..L["Instance Auras"], nil, setupRaidDebuffs},
		{3, "UFs", "RaidDebuffScale", L["RaidDebuffScale"].."*", true, {.8, 2, .1}, refreshRaidFrameIcons},
		{1, "UFs", "AurasClickThrough", L["RaidAuras ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{1, "UFs", "AutoRes", L["UFs AutoRes"], true},
		{},--blank
		{1, "UFs", "ShowSolo", L["ShowSolo"], nil, nil, nil, L["ShowSoloTip"]},
		{1, "UFs", "SpecRaidPos", L["Spec RaidPos"], true},
		{1, "UFs", "ShowTeamIndex", L["RaidFrame TeamIndex"]},
		{1, "UFs", "FrequentHealth", "|cff00cc4c"..L["FrequentHealth"].."*", true, nil, updateRaidHealthMethod, L["FrequentHealthTip"]},
		{1, "UFs", "HorizonRaid", L["Horizon RaidFrame"]},
		{1, "UFs", "ReverseRaid", L["Reverse RaidFrame"]},
		{3, "UFs", "HealthFrequency", L["HealthFrequency"].."*", true, {.01, .2, .01}, updateRaidHealthMethod, L["HealthFrequencyTip"]},
		{3, "UFs", "NumGroups", L["Num Groups"], nil, {4, 8, 1}},
		{3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, updateRaidTextScale},
		{4, "UFs", "RaidHealthColor", L["HealthColor"], nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"]}},
		{4, "UFs", "RaidHPMode", L["RaidHPMode"].."*", true, {L["DisableRaidHP"], L["RaidHPPercent"], L["RaidHPCurrent"], L["RaidHPLost"]}, updateRaidNameText},
		{},--blank
		{1, "UFs", "SimpleMode", "|cff00cc4c"..L["SimpleRaidFrame"], nil, nil, nil, L["SimpleRaidFrameTip"]},
		{3, "UFs", "SMUnitsPerColumn", L["SimpleMode Column"], nil, {10, 40, 1}},
		{4, "UFs", "SMGroupByIndex", L["SimpleMode GroupBy"].."*", true, {GROUP, CLASS, ROLE}, updateSimpleModeGroupBy},
		{nil, true},-- FIXME: dirty fix for now
		{nil, true},
	},
	[5] = {
		{1, "Nameplate", "Enable", "|cff00cc4c"..L["Enable Nameplate"], nil, setupNameplateFilter},
		{1, "Nameplate", "NameOnlyMode", L["NameOnlyMode"].."*", true, nil, nil, L["NameOnlyModeTip"]},
		{},--blank
		{4, "Nameplate", "AuraFilter", L["NameplateAuraFilter"].."*", nil, {L["BlackNWhite"], L["PlayerOnly"], L["IncludeCrowdControl"]}, refreshNameplates},
		{4, "Nameplate", "TargetIndicator", L["TargetIndicator"].."*", true, {DISABLE, L["TopArrow"], L["RightArrow"], L["TargetGlow"], L["TopNGlow"], L["RightNGlow"]}, refreshNameplates},
		{1, "Nameplate", "FriendlyCC", L["Friendly CC"].."*"},
		{1, "Nameplate", "HostileCC", L["Hostile CC"].."*", true},
		{1, "Nameplate", "FullHealth", L["Show FullHealth"].."*", nil, nil, refreshNameplates},
		{1, "Nameplate", "ColorBorder", L["ColorBorder"].."*", true, nil, refreshNameplates},
		{1, "Nameplate", "InsideView", L["Nameplate InsideView"].."*", nil, nil, updatePlateInsideView},
		{1, "Nameplate", "ExplosivesScale", L["ExplosivesScale"], true},
		{1, "Nameplate", "QuestIndicator", L["QuestIndicator"]},
		{1, "Nameplate", "AKSProgress", L["AngryKeystones Progress"], true},
		{},--blank
		{1, "Nameplate", "CustomUnitColor", "|cff00cc4c"..L["CustomUnitColor"].."*", nil, nil, updateCustomUnitList, L["CustomUnitColorTip"]},
		{5, "Nameplate", "CustomColor", L["Custom Color"].."*", 2},
		{2, "Nameplate", "UnitList", L["UnitColor List"].."*", nil, nil, updateCustomUnitList, L["CustomUnitTips"]},
		{2, "Nameplate", "ShowPowerList", L["ShowPowerList"].."*", true, nil, updatePowerUnitList, L["CustomUnitTips"]},
		{1, "Nameplate", "TankMode", "|cff00cc4c"..L["Tank Mode"].."*", nil, nil, nil, L["TankModeTip"]},
		{1, "Nameplate", "DPSRevertThreat", L["DPS Revert Threat"].."*", true},
		{5, "Nameplate", "SecureColor", L["Secure Color"].."*"},
		{5, "Nameplate", "TransColor", L["Trans Color"].."*", 1},
		{5, "Nameplate", "InsecureColor", L["Insecure Color"].."*", 2},
		{5, "Nameplate", "OffTankColor", L["OffTank Color"].."*", 3},
		{},--blank
		{3, "Nameplate", "VerticalSpacing", L["NP VerticalSpacing"].."*", false, {.5, 1.5, .1}, updatePlateSpacing},
		--{3, "Nameplate", "Distance", L["Nameplate Distance"].."*", true, {20, 100, 1}, updatePlateRange}, -- hide until blizz re-enable it
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
		{1, "Nameplate", "ShowPlayerPlate", "|cff00cc4c"..L["Enable PlayerPlate"]},
		{},--blank
		{1, "Auras", "ClassAuras", L["Enable ClassAuras"]},
		{1, "Nameplate", "PPFadeout", L["PlayerPlate Fadeout"].."*", true, nil, togglePlateVisibility},
		{1, "Nameplate", "NameplateClassPower", L["Nameplate ClassPower"], nil},
		{1, "Nameplate", "PPPowerText", L["PlayerPlate PowerText"].."*", nil, nil, togglePlatePower},
		{3, "Nameplate", "PPFadeoutAlpha", L["PlayerPlate FadeoutAlpha"].."*", true, {0, .5, .05}, togglePlateVisibility},
		{1, "Nameplate", "PPGCDTicker", L["PlayerPlate GCDTicker"].."*", nil, nil, toggleGCDTicker},
		{},--blank
		{3, "Nameplate", "PPWidth", L["PlayerPlate HPWidth"].."*", false, {150, 300, 1}, refreshNameplates},
		{3, "Nameplate", "PPBarHeight", L["PlayerPlate CPHeight"].."*", true, {5, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPHealthHeight", L["PlayerPlate HPHeight"].."*", false, {5, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPPowerHeight", L["PlayerPlate MPHeight"].."*", true, {5, 15, 1}, refreshNameplates},
	},
	[7] = {
		{1, "AuraWatch", "Enable", "|cff00cc4c"..L["Enable AuraWatch"], nil, setupAuraWatch},
		{1, "AuraWatch", "DeprecatedAuras", L["DeprecatedAuras"], true},
		{1, "AuraWatch", "QuakeRing", L["QuakeRing"].."*"},
		{1, "AuraWatch", "ClickThrough", L["AuraWatch ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "AuraWatch", "IconScale", L["AuraWatch IconScale"], true, {.8, 2, .1}},
		{},--blank
		{1, "Auras", "Totems", "|cff00cc4c"..L["Enable Totembar"]},
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
		{1, "Misc", "RaidTool", "|cff00cc4c"..L["Raid Manger"]},
		{1, "Misc", "RMRune", L["Runes Check"].."*"},
		{1, "Misc", "EasyMarking", L["Easy Mark"].."*", true},
		{2, "Misc", "DBMCount", L["Countdown Sec"].."*"},
		{4, "Misc", "ShowMarkerBar", L["ShowMarkerBar"].."*", true, {L["Grids"], L["Horizontal"], L["Vertical"], DISABLE}, updateMarkerGrid},
		{},--blank
		{1, "Misc", "QuestNotification", "|cff00cc4c"..L["QuestNotification"].."*", nil, nil, updateQuestNotification},
		{1, "Misc", "QuestProgress", L["QuestProgress"].."*"},
		{1, "Misc", "OnlyCompleteRing", L["OnlyCompleteRing"].."*", true},
		{},--blank
		{1, "Misc", "Interrupt", "|cff00cc4c"..L["Interrupt Alert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "AlertInInstance", L["Alert In Instance"].."*", true},
		{1, "Misc", "OwnInterrupt", L["Own Interrupt"].."*"},
		{1, "Misc", "BrokenSpell", L["Broken Spell"].."*", true, nil, nil, L["BrokenSpellTip"]},
		{},--blank
		{1, "Misc", "ExplosiveCount", L["Explosive Alert"].."*", nil, nil, updateExplosiveAlert, L["ExplosiveAlertTip"]},
		{1, "Misc", "PlacedItemAlert", L["Placed Item Alert"].."*", true},
		{1, "Misc", "SoloInfo", L["SoloInfo"].."*", nil, nil, updateSoloInfo},
		{1, "Misc", "NzothVision", "|cff00cc4c"..L["NzothVision"], true},
		{},--blank
		{1, "Misc", "RareAlerter", "|cff00cc4c"..L["Rare Alert"].."*", nil, nil, updateRareAlert},
		{1, "Misc", "AlertinChat", L["Alert In Chat"].."*"},
		{1, "Misc", "RareAlertInWild", L["RareAlertInWild"].."*", true},
	},
	[9] = {
		{1, "Chat", "Lock", "|cff00cc4c"..L["Lock Chat"]},
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
		{1, "Chat", "EnableFilter", "|cff00cc4c"..L["Enable Chatfilter"]},
		{1, "Chat", "BlockAddonAlert", L["Block Addon Alert"], true},
		{1, "Chat", "AllowFriends", L["AllowFriendsSpam"].."*", nil, nil, nil, L["AllowFriendsSpamTip"]},
		{1, "Chat", "BlockStranger", "|cffff0000"..L["BlockStranger"].."*", nil, nil, nil, L["BlockStrangerTip"]},
		{2, "ACCOUNT", "ChatFilterWhiteList", "|cff00cc4c"..L["ChatFilterWhiteList"].."*", true, nil, updateFilterWhiteList, L["ChatFilterWhiteListTip"]},
		{3, "Chat", "Matches", L["Keyword Match"].."*", false, {1, 3, 1}},
		{2, "ACCOUNT", "ChatFilterList", L["Filter List"].."*", true, nil, updateFilterList, L["FilterListTip"]},
		{},--blank
		{1, "Chat", "Invite", "|cff00cc4c"..L["Whisper Invite"]},
		{1, "Chat", "GuildInvite", L["Guild Invite Only"].."*"},
		{2, "Chat", "Keyword", L["Whisper Keyword"].."*", true, nil, updateWhisperList},
	},
	[10] = {
		{1, "Map", "Coord", L["Map Coords"]},
		{},--blank
		{1, "Map", "Calendar", L["MinimapCalendar"].."*", nil, nil, showCalendar, L["MinimapCalendarTip"]},
		{1, "Map", "Clock", L["Minimap Clock"].."*", true, nil, showMinimapClock},
		{1, "Map", "CombatPulse", L["Minimap Pulse"]},
		{1, "Map", "WhoPings", L["Show WhoPings"], true},
		{1, "Map", "ShowRecycleBin", L["Show RecycleBin"]},
		{1, "Misc", "ExpRep", L["Show Expbar"], true},
		{},--blank
		{3, "Map", "MapScale", L["Map Scale"], false, {1, 2, .1}},
		{3, "Map", "MinimapScale", L["Minimap Scale"].."*", true, {1, 2, .1}, updateMinimapScale},
	},
	[11] = {
		{1, "Skins", "BlizzardSkins", "|cff00cc4c"..L["BlizzardSkins"], nil, nil, nil, L["BlizzardSkinsTips"]},
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
		{},--blank
		{1, "Tooltip", "AzeriteArmor", "|cff00cc4c"..L["Show AzeriteArmor"]},
		{1, "Tooltip", "OnlyArmorIcons", L["Armor icons only"].."*", true},
	},
	[13] = {
		{1, "Misc", "ItemLevel", "|cff00cc4c"..L["Show ItemLevel"]},
		{1, "Misc", "GemNEnchant", L["Show GemNEnchant"].."*"},
		{1, "Misc", "AzeriteTraits", L["Show AzeriteTraits"].."*", true},
		{},--blank
		{1, "Misc", "HideTalking", L["No Talking"]},
		{1, "ACCOUNT", "AutoBubbles", L["AutoBubbles"], true},
		{1, "Misc", "HideBossEmote", L["HideBossEmote"].."*", nil, nil, toggleBossEmote},
		{1, "Misc", "HideBanner", L["Hide Bossbanner"].."*", true, nil, toggleBossBanner},
		{1, "Misc", "InstantDelete", L["InstantDelete"].."*"},
		{1, "Misc", "FasterLoot", L["Faster Loot"].."*", true, nil, updateFasterLoot},
		{},--blank
		{1, "Misc", "MissingStats", L["Show MissingStats"]},
		{1, "Misc", "ParagonRep", L["ParagonRep"], true},
		{1, "Misc", "Mail", L["Mail Tool"]},
		{1, "Misc", "TradeTabs", L["TradeTabs"], true},
		{1, "Misc", "PetFilter", L["Show PetFilter"]},
		{1, "Misc", "Screenshot", L["Auto ScreenShot"].."*", true, nil, updateScreenShot},
		{1, "Misc", "Focuser", L["Easy Focus"]},
		{1, "Misc", "BlockInvite", "|cffff0000"..L["BlockInvite"].."*", true},
	},
	[14] = {
		{1, "ACCOUNT", "VersionCheck", L["Version Check"]},
		{1, "ACCOUNT", "DisableInfobars", L["DisableInfobars"], true},
		{},--blank
		{3, "ACCOUNT", "UIScale", L["Setup UIScale"], false, {.4, 1.15, .01}},
		{1, "ACCOUNT", "LockUIScale", "|cff00cc4c"..L["Lock UIScale"], true},
		{},--blank
		{4, "ACCOUNT", "TexStyle", L["Texture Style"], false, {}},
		{4, "ACCOUNT", "NumberFormat", L["Numberize"], true, {L["Number Type1"], L["Number Type2"], L["Number Type3"]}},
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
			NDuiDB[key][value] = newValue
		else
			return NDuiDB[key][value]
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
			eb.title = L["Tips"]
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			B.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info")

			B.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
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
		-- Colorswatch
		elseif optType == 5 then
			local f = B.CreateColorSwatch(parent, name, NDUI_VARIABLE(key, value))
			local width = 25 + (horizon or 0)*155
			if horizon then
				f:SetPoint("TOPLEFT", width, -offset + 30)
			else
				f:SetPoint("TOPLEFT", width, -offset - 5)
				offset = offset + 35
			end
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

local bloodlustFilter = {
	[57723] = true,
	[57724] = true,
	[80354] = true,
	[264689] = true
}

function G:ExportGUIData()
	local text = "NDuiSettings:"..DB.Version..":"..DB.MyName..":"..DB.MyClass
	for KEY, VALUE in pairs(NDuiDB) do
		if type(VALUE) == "table" then
			for key, value in pairs(VALUE) do
				if type(value) == "table" then
					if value.r then
						for k, v in pairs(value) do
							text = text..";"..KEY..":"..key..":"..k..":"..v
						end
					elseif key == "ExplosiveCache" then
						text = text..";"..KEY..":"..key..":EMPTYTABLE"
					elseif KEY == "AuraWatchList" then
						if key == "Switcher" then
							for k, v in pairs(value) do
								text = text..";"..KEY..":"..key..":"..k..":"..tostring(v)
							end
						else
							for spellID, k in pairs(value) do
								text = text..";"..KEY..":"..key..":"..spellID
								if k[5] == nil then k[5] = false end
								for _, v in ipairs(k) do
									text = text..":"..tostring(v)
								end
							end
						end
					elseif KEY == "Mover" or KEY == "RaidClickSets" or KEY == "InternalCD" or KEY == "AuraWatchMover" then
						text = text..";"..KEY..":"..key
						for _, v in ipairs(value) do
							text = text..":"..tostring(v)
						end
					elseif key == "FavouriteItems" then
						text = text..";"..KEY..":"..key
						for itemID in pairs(value) do
							text = text..":"..tostring(itemID)
						end
					end
				else
					if NDuiDB[KEY][key] ~= G.DefaultSettings[KEY][key] then -- don't export default settings
						text = text..";"..KEY..":"..key..":"..tostring(value)
					end
				end
			end
		end
	end

	for KEY, VALUE in pairs(NDuiADB) do
		if KEY == "RaidAuraWatch" or KEY == "CustomJunkList" then
			text = text..";ACCOUNT:"..KEY
			for spellID in pairs(VALUE) do
				text = text..":"..spellID
			end
		elseif KEY == "RaidDebuffs" then
			for instName, value in pairs(VALUE) do
				for spellID, prio in pairs(value) do
					text = text..";ACCOUNT:"..KEY..":"..instName..":"..spellID..":"..prio
				end
			end
		elseif KEY == "NameplateFilter" then
			for index, value in pairs(VALUE) do
				text = text..";ACCOUNT:"..KEY..":"..index
				for spellID in pairs(value) do
					text = text..":"..spellID
				end
			end
		elseif KEY == "CornerBuffs" then
			for class, value in pairs(VALUE) do
				for spellID, data in pairs(value) do
					if not bloodlustFilter[spellID] and class == DB.MyClass then
						local anchor, color, filter = unpack(data)
						text = text..";ACCOUNT:"..KEY..":"..class..":"..spellID..":"..anchor..":"..color[1]..":"..color[2]..":"..color[3]..":"..tostring(filter or false)
					end
				end
			end
		elseif KEY == "PartyWatcherSpells" then
			text = text..";ACCOUNT:"..KEY
			for spellID, duration in pairs(VALUE) do
				local name = GetSpellInfo(spellID)
				if name then
					text = text..":"..spellID..":"..duration
				end
			end
		elseif KEY == "ContactList" then
			for name, color in pairs(VALUE) do
				text = text..";ACCOUNT:"..KEY..":"..name..":"..color
			end
		end
	end

	dataFrame.editBox:SetText(B:Encode(text))
	dataFrame.editBox:HighlightText()
end

local function toBoolean(value)
	if value == "true" then
		return true
	elseif value == "false" then
		return false
	end
end

local function reloadDefaultSettings()
	for i, j in pairs(G.DefaultSettings) do
		if type(j) == "table" then
			if not NDuiDB[i] then NDuiDB[i] = {} end
			for k, v in pairs(j) do
				NDuiDB[i][k] = v
			end
		else
			NDuiDB[i] = j
		end
	end
	NDuiDB["BFA"] = true -- don't empty data on next loading
end

function G:ImportGUIData()
	local profile = dataFrame.editBox:GetText()
	if B:IsBase64(profile) then profile = B:Decode(profile) end
	local options = {strsplit(";", profile)}
	local title, _, _, class = strsplit(":", options[1])
	if title ~= "NDuiSettings" then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Import data error"])
		return
	end

	-- we don't export default settings, so need to reload it
	reloadDefaultSettings()

	for i = 2, #options do
		local option = options[i]
		local key, value, arg1 = strsplit(":", option)
		if arg1 == "true" or arg1 == "false" then
			NDuiDB[key][value] = toBoolean(arg1)
		elseif arg1 == "EMPTYTABLE" then
			NDuiDB[key][value] = {}
		elseif strfind(value, "Color") and (arg1 == "r" or arg1 == "g" or arg1 == "b") then
			local color = select(4, strsplit(":", option))
			if NDuiDB[key][value] then
				NDuiDB[key][value][arg1] = tonumber(color)
			end
		elseif key == "AuraWatchList" then
			if value == "Switcher" then
				local index, state = select(3, strsplit(":", option))
				NDuiDB[key][value][tonumber(index)] = toBoolean(state)
			else
				local idType, spellID, unit, caster, stack, amount, timeless, combat, text, flash = select(4, strsplit(":", option))
				value = tonumber(value)
				arg1 = tonumber(arg1)
				spellID = tonumber(spellID)
				stack = tonumber(stack)
				amount = toBoolean(amount)
				timeless = toBoolean(timeless)
				combat = toBoolean(combat)
				flash = toBoolean(flash)
				if not NDuiDB[key][value] then NDuiDB[key][value] = {} end
				NDuiDB[key][value][arg1] = {idType, spellID, unit, caster, stack, amount, timeless, combat, text, flash}
			end
		elseif value == "FavouriteItems" then
			local items = {select(3, strsplit(":", option))}
			for _, itemID in next, items do
				NDuiDB[key][value][tonumber(itemID)] = true
			end
		elseif key == "Mover" or key == "AuraWatchMover" then
			local relFrom, parent, relTo, x, y = select(3, strsplit(":", option))
			value = tonumber(value) or value
			x = tonumber(x)
			y = tonumber(y)
			NDuiDB[key][value] = {relFrom, parent, relTo, x, y}
		elseif key == "RaidClickSets" then
			if DB.MyClass == class then
				NDuiDB[key][value] = {select(3, strsplit(":", option))}
			end
		elseif key == "InternalCD" then
			local spellID, duration, indicator, unit, itemID = select(3, strsplit(":", option))
			spellID = tonumber(spellID)
			duration = tonumber(duration)
			itemID = tonumber(itemID)
			NDuiDB[key][spellID] = {spellID, duration, indicator, unit, itemID}
		elseif key == "ACCOUNT" then
			if value == "RaidAuraWatch" or value == "CustomJunkList" then
				local spells = {select(3, strsplit(":", option))}
				for _, spellID in next, spells do
					NDuiADB[value][tonumber(spellID)] = true
				end
			elseif value == "RaidDebuffs" then
				local instName, spellID, priority = select(3, strsplit(":", option))
				if not NDuiADB[value][instName] then NDuiADB[value][instName] = {} end
				NDuiADB[value][instName][tonumber(spellID)] = tonumber(priority)
			elseif value == "NameplateFilter" then
				local spells = {select(4, strsplit(":", option))}
				for _, spellID in next, spells do
					NDuiADB[value][tonumber(arg1)][tonumber(spellID)] = true
				end
			elseif value == "CornerBuffs" then
				local class, spellID, anchor, r, g, b, filter = select(3, strsplit(":", option))
				spellID = tonumber(spellID)
				r = tonumber(r)
				g = tonumber(g)
				b = tonumber(b)
				filter = toBoolean(filter)
				if not NDuiADB[value][class] then NDuiADB[value][class] = {} end
				NDuiADB[value][class][spellID] = {anchor, {r, g, b}, filter}
			elseif value == "PartyWatcherSpells" then
				local options = {strsplit(":", option)}
				local index = 3
				local spellID = options[index]
				while spellID do
					local duration = options[index+1]
					NDuiADB[value][tonumber(spellID)] = tonumber(duration) or 0
					index = index + 2
					spellID = options[index]
				end
			elseif value == "ContactList" then
				local name, r, g, b = select(3, strsplit(":", option))
				NDuiADB["ContactList"][name] = r..":"..g..":"..b
			end
		elseif tonumber(arg1) then
			if value == "DBMCount" then
				NDuiDB[key][value] = arg1
			else
				NDuiDB[key][value] = tonumber(arg1)
			end
		end
	end
end

local function updateTooltip()
	local profile = dataFrame.editBox:GetText()
	if B:IsBase64(profile) then profile = B:Decode(profile) end
	local option = strsplit(";", profile)
	local title, version, name, class = strsplit(":", option)
	if title == "NDuiSettings" then
		dataFrame.version = version
		dataFrame.name = name
		dataFrame.class = class
	else
		dataFrame.version = nil
	end
end

local function createDataFrame()
	if dataFrame then dataFrame:Show() return end

	dataFrame = CreateFrame("Frame", nil, UIParent)
	dataFrame:SetPoint("CENTER")
	dataFrame:SetSize(500, 500)
	dataFrame:SetFrameStrata("DIALOG")
	B.CreateMF(dataFrame)
	B.SetBD(dataFrame)
	dataFrame.Header = B.CreateFS(dataFrame, 16, L["Export Header"], true, "TOP", 0, -5)

	local scrollArea = CreateFrame("ScrollFrame", nil, dataFrame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 40)
	B.CreateBDFrame(scrollArea, .25)
	B.ReskinScroll(scrollArea.ScrollBar)

	local editBox = CreateFrame("EditBox", nil, dataFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(true)
	editBox:SetFont(DB.Font[1], 14)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() dataFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	dataFrame.editBox = editBox

	StaticPopupDialogs["NDUI_IMPORT_DATA"] = {
		text = L["Import data warning"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			G:ImportGUIData()
			ReloadUI()
		end,
		whileDead = 1,
	}
	local accept = B.CreateButton(dataFrame, 100, 20, OKAY)
	accept:SetPoint("BOTTOM", 0, 10)
	accept:SetScript("OnClick", function(self)
		if self.text:GetText() ~= OKAY and dataFrame.editBox:GetText() ~= "" then
			StaticPopup_Show("NDUI_IMPORT_DATA")
		end
		dataFrame:Hide()
	end)
	accept:HookScript("OnEnter", function(self)
		if dataFrame.editBox:GetText() == "" then return end
		updateTooltip()

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
		GameTooltip:ClearLines()
		if dataFrame.version then
			GameTooltip:AddLine(L["Data Info"])
			GameTooltip:AddDoubleLine(L["Version"], dataFrame.version, .6,.8,1, 1,1,1)
			GameTooltip:AddDoubleLine(L["Character"], dataFrame.name, .6,.8,1, B.ClassColor(dataFrame.class))
		else
			GameTooltip:AddLine(L["Data Exception"], 1,0,0)
		end
		GameTooltip:Show()
	end)
	accept:HookScript("OnLeave", B.HideTooltip)
	dataFrame.text = accept.text
end

local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*35)
end

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

	local close = B.CreateButton(f, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() f:Hide() end)

	local ok = B.CreateButton(f, 80, 20, OKAY)
	ok:SetPoint("RIGHT", close, "LEFT", -10, 0)
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

	local reset = B.CreateButton(f, 120, 20, L["NDui Reset"])
	reset:SetPoint("BOTTOMLEFT", 25, 15)
	StaticPopupDialogs["RESET_NDUI"] = {
		text = L["Reset NDui Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiDB = {}
			NDuiADB = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI")
	end)

	local import = B.CreateButton(f, 59, 20, L["Import"])
	import:SetPoint("BOTTOMLEFT", reset, "TOPLEFT", 0, 2)
	import:SetScript("OnClick", function()
		f:Hide()
		createDataFrame()
		dataFrame.Header:SetText(L["Import Header"])
		dataFrame.text:SetText(L["Import"])
		dataFrame.editBox:SetText("")
	end)

	local export = B.CreateButton(f, 59, 20, L["Export"])
	export:SetPoint("BOTTOMRIGHT", reset, "TOPRIGHT", 0, 2)
	export:SetScript("OnClick", function()
		f:Hide()
		createDataFrame()
		dataFrame.Header:SetText(L["Export Header"])
		dataFrame.text:SetText(OKAY)
		G:ExportGUIData()
	end)

	local helpInfo = B.CreateHelpInfo(f, L["Option* Tips"])
	helpInfo:SetPoint("TOPLEFT", 20, -5)

	local credit = CreateFrame("Button", nil, f)
	credit:SetPoint("TOPRIGHT", -20, -5)
	credit:SetSize(40, 40)
	credit.Icon = credit:CreateTexture(nil, "ARTWORK")
	credit.Icon:SetAllPoints()
	credit.Icon:SetTexture(DB.creditTex)
	credit:SetHighlightTexture(DB.creditTex)
	credit:SetScript("OnEnter", function()
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(credit, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:AddLine("Credits:")
		GameTooltip:AddLine(GetAddOnMetadata("NDui", "X-Credits"), .6,.8,1, 1)
		GameTooltip:Show()
	end)
	credit:SetScript("OnLeave", B.HideTooltip)

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

	if NDuiDB["Skins"]["BlizzardSkins"] then B.Reskin(gui) end
end