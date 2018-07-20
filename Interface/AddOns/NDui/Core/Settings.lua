local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Settings")

-- Addon Info
print("|cff0080ff< NDui >|cff70C0F5----------------")
print("|cff00ff00  "..DB.Support.."|c00ffff00 "..DB.Version.." |c0000ff00"..L["Version Info1"])
print("|c0000ff00  "..L["Version Info2"].."|c00ffff00 /ndui |c0000ff00"..L["Version Info3"])
print("|cff70C0F5------------------------")

-- Tuitorial
local function ForceDefaultSettings()
	SetCVar("ActionButtonUseKeyDown", 1)
	--SetCVar("SpellQueueWindow", 250)
	SetCVar("autoLootDefault", 1)
	SetCVar("alwaysCompareItems", 0)
	SetCVar("useCompactPartyFrames", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateMotion", 1)
	SetCVar("nameplateShowFriendlyNPCs", 0)
	SetCVar("screenshotQuality", 10)
	SetCVar("showTutorials", 0)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("lockActionBars", 1)
	SetActionBarToggles(1, 1, 1, 1)
	SetCVar("enableFloatingCombatText", 1)
	SetCVar("floatingCombatTextCombatState", 1)
	SetCVar("floatingCombatTextCombatDamage", 1)
	SetCVar("floatingCombatTextCombatHealing", 1)
	SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0)
	SetCVar("floatingCombatTextFloatMode", 1)
	SetCVar("ffxGlow", 0)
	SetCVar("autoQuestWatch", 1)
	--SetCVar("overrideArchive", 0)
	SetCVar("WorldTextScale", 1.5)
end

local function ForceRaidFrame()
	if not CompactUnitFrameProfiles.selectedProfile then return end
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
	CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_UpdateCurrentPanel()
end

local function ForceUIScale()
	B.HideOption(Advanced_UseUIScale)
	B.HideOption(Advanced_UIScaleSlider)

	local scale = NDuiDB["Settings"]["UIScale"]
	if NDuiDB["Settings"]["LockUIScale"] then
		scale = 768/DB.ScreenHeight * .8
		local minScale = .64
		if DB.ScreenHeight > 1080 then minScale = .5 end
		if scale < minScale then scale = minScale end
		NDuiDB["Settings"]["UIScale"] = scale
	end

	SetCVar("useUiScale", 1)
	if scale < .64 then
		UIParent:SetScale(scale)
	else
		SetCVar("uiScale", scale)
	end

	-- Restore from Auto-scaling
	local function RestoreUIScale(scale)
		UIParent:SetScale(scale)
		if NDuiDB["Chat"]["Lock"] then
			ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 28)
		end
	end

	B:RegisterEvent("UI_SCALE_CHANGED", function()
		if scale < .64 then RestoreUIScale(scale) end

		C_Timer.After(1, function()
			if scale < .64 and UIParent:GetScale() ~= scale then
				RestoreUIScale(scale)
			end
		end)
	end)
end

local function ForceChatSettings()
	FCF_SetLocked(ChatFrame1, nil)
	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 28)
	ChatFrame1:SetWidth(380)
	ChatFrame1:SetHeight(190)
    ChatFrame1:SetUserPlaced(true)
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		ChatFrame_RemoveMessageGroup(cf, "CHANNEL")
	end
	FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, true)

	NDuiDB["Chat"]["Lock"] = true
end

StaticPopupDialogs["RELOAD_NDUI"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
}

-- DBM bars	
local function ForceDBMOptions()
	if not IsAddOnLoaded("DBM-Core") then return end
	if DBT_AllPersistentOptions then table.wipe(DBT_AllPersistentOptions) end
	DBT_AllPersistentOptions = {
		["Default"] = {
			["DBM"] = {
				["Scale"] = 1,
				["HugeScale"] = 1,
				["ExpandUpwards"] = true,
				["ExpandUpwardsLarge"] = true,
				["BarXOffset"] = 0,
				["BarYOffset"] = 15,
				["TimerPoint"] = "LEFT",
				["TimerX"] = 118,
				["TimerY"] = -105,
				["Width"] = 175,
				["Heigh"] = 20,
				["HugeWidth"] = 210,
				["HugeBarXOffset"] = 0,
				["HugeBarYOffset"] = 15,
				["HugeTimerPoint"] = "CENTER",
				["HugeTimerX"] = 330,
				["HugeTimerY"] = -42,
				["FontSize"] = 10,
				["StartColorR"] = 1,
				["StartColorG"] = .7,
				["StartColorB"] = 0,
				["EndColorR"] = 1,
				["EndColorG"] = 0,
				["EndColorB"] = 0,
				["Texture"] = DB.normTex,
			},
		},
	}

	if not DBM_AllSavedOptions["Default"] then DBM_AllSavedOptions["Default"] = {} end
	DBM_AllSavedOptions["Default"]["WarningY"] = -170
	DBM_AllSavedOptions["Default"]["WarningX"] = 0
	DBM_AllSavedOptions["Default"]["WarningFontStyle"] = "OUTLINE"
	DBM_AllSavedOptions["Default"]["SpecialWarningX"] = 0
	DBM_AllSavedOptions["Default"]["SpecialWarningY"] = -260
	DBM_AllSavedOptions["Default"]["SpecialWarningFontStyle"] = "OUTLINE"
	DBM_AllSavedOptions["Default"]["HideObjectivesFrame"] = false
	DBM_AllSavedOptions["Default"]["WarningFontSize"] = 18
	DBM_AllSavedOptions["Default"]["SpecialWarningFontSize2"] = 24

	NDuiDB["Settings"]["DBMRequest"] = false
end

-- Skada
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then return end
	if SkadaDB then table.wipe(SkadaDB) end
	SkadaDB = {
		["hasUpgraded"] = true,
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{
						["barheight"] = 18,
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 24,
						["x"] = -3,
						["title"] = {
							["color"] = {
								["a"] = 0.3,
								["b"] = 0,
								["g"] = 0,
								["r"] = 0,
							},
							["font"] = "",
							["borderthickness"] = 0,
							["fontflags"] = "OUTLINE",
							["fontsize"] = 14,
							["texture"] = "normTex",
						},
						["barfontflags"] = "OUTLINE",
						["point"] = "BOTTOMRIGHT",
						["mode"] = "",
						["barwidth"] = 300,
						["barbgcolor"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["barfontsize"] = 15,
						["background"] = {
							["height"] = 180,
							["texture"] = "None",
							["bordercolor"] = {
								["a"] = 0,
							},
						},
						["bartexture"] = "normTex",
					}, -- [1]
				},
				["tooltiprows"] = 10,
				["setstokeep"] = 30,
				["tooltippos"] = "topleft",
				["reset"] = {
					["instance"] = 3,
					["join"] = 1,
				},
			},
		},
	}
	NDuiDB["Settings"]["SkadaRequest"] = false
end

-- BigWigs
local function ForceBigwigs()
	if not IsAddOnLoaded("BigWigs") then return end
	if BigWigs3DB then table.wipe(BigWigs3DB) end
	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["Default"] = {
						["outline"] = "OUTLINE",
						["fontSize"] = 12,
						["BigWigsAnchor_y"] = 336,
						["BigWigsAnchor_x"] = 16,
						["BigWigsAnchor_width"] = 175,
						["growup"] = true, 
						["interceptMouse"] = false,
						["barStyle"] = "NDui",
						["LeftButton"] = {
							["emphasize"] = false,
						},
						["font"] = DB.Font[1],
						["onlyInterceptOnKeypress"] = true,
						["emphasizeScale"] = 1,
						["BigWigsEmphasizeAnchor_x"] = 810,
						["BigWigsEmphasizeAnchor_y"] = 350,
						["BigWigsEmphasizeAnchor_width"] = 220,
						["emphasizeGrowup"] = true,
					},
				},
			},
			["BigWigs_Plugins_Super Emphasize"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 28,
						["font"] = DB.Font[1],
					},
				},
			},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = DB.Font[1],
						["BWEmphasizeCountdownMessageAnchor_x"] = 665,
						["BWMessageAnchor_x"] = 616,
						["BWEmphasizeCountdownMessageAnchor_y"] = 530,
						["BWMessageAnchor_y"] = 305,
					},
				},
			},
			["BigWigs_Plugins_Proximity"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = DB.Font[1],
						["posy"] = 346,
						["width"] = 140,
						["posx"] = 1024,
						["height"] = 120,
					},
				},
			},
			["BigWigs_Plugins_Alt Power"] = {
				["profiles"] = {
					["Default"] = {
						["posx"] = 1002,
						["fontSize"] = 14,
						["font"] = DB.Font[1],
						["fontOutline"] = "OUTLINE",
						["posy"] = 490,
					},
				},
			},
		},
		["profiles"] = {
			["Default"] = {
				["fakeDBMVersion"] = true,
			},
		},
	}
	NDuiDB["Settings"]["BWRequest"] = false
end

local function ForceAddonSkins()
	if NDuiDB["Settings"]["DBMRequest"] then ForceDBMOptions() end
	if NDuiDB["Settings"]["SkadaRequest"] then ForceSkadaOptions() end
	if NDuiDB["Settings"]["BWRequest"] then ForceBigwigs() end
end

-- Tutorial
local tutor
local function YesTutor()
	if tutor then tutor:Show() return end
	tutor = CreateFrame("Frame", nil, UIParent)
	tutor:SetPoint("CENTER")
	tutor:SetSize(400, 250)
	tutor:SetFrameStrata("HIGH")
	tutor:SetScale(1.2)
	B.CreateMF(tutor)
	B.CreateBD(tutor)
	B.CreateTex(tutor)
	B.CreateFS(tutor, 30, "NDui", true, "TOPLEFT", 10, 25)
	local ll = CreateFrame("Frame", nil, tutor)
	ll:SetPoint("TOP", -40, -32)
	B.CreateGF(ll, 80, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, tutor)
	lr:SetPoint("TOP", 40, -32)
	B.CreateGF(lr, 80, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")

	local title = B.CreateFS(tutor, 12, "", true, "TOP", 0, -10)
	local body = B.CreateFS(tutor, 12, "", false, "TOPLEFT", 20, -50)
	body:SetPoint("BOTTOMRIGHT", -20, 50)
	body:SetJustifyV("TOP")
	body:SetJustifyH("LEFT")
	body:SetWordWrap(true)
	local foot = B.CreateFS(tutor, 12, "", false, "BOTTOM", 0, 10)

	local pass = B.CreateButton(tutor, 50, 20, L["Skip"])
	pass:SetPoint("BOTTOMLEFT", 10, 10)
	local apply = B.CreateButton(tutor, 50, 20, APPLY)
	apply:SetPoint("BOTTOMRIGHT", -10, 10)

	local titles = {L["Default Settings"], UI_SCALE, L["ChatFrame"], L["Skins"], L["Tips"]}
	local function RefreshText(page)
		title:SetText(titles[page])
		body:SetText(L["Tutorial Page"..page])
		foot:SetText(page.."/5")
	end
	RefreshText(1)

	local currentPage = 1
	pass:SetScript("OnClick", function()
		if currentPage > 3 then pass:Hide() end
		currentPage = currentPage + 1
		RefreshText(currentPage)
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
	end)
	apply:SetScript("OnClick", function()
		pass:Show()
		if currentPage == 1 then
			ForceDefaultSettings()
			ForceRaidFrame()
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Default Settings Check"])
		elseif currentPage == 2 then
			NDuiDB["Settings"]["LockUIScale"] = true
			ForceUIScale()
			NDuiDB["Settings"]["LockUIScale"] = false
			UIErrorsFrame:AddMessage(DB.InfoColor..L["UIScale Check"])
		elseif currentPage == 3 then
			ForceChatSettings()
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Chat Settings Check"])
		elseif currentPage == 4 then
			NDuiDB["Settings"]["DBMRequest"] = true
			NDuiDB["Settings"]["SkadaRequest"] = true
			NDuiDB["Settings"]["BWRequest"] = true
			ForceAddonSkins()
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Tutorial Complete"])
			pass:Hide()
		elseif currentPage == 5 then
			tutor:Hide()
			StaticPopup_Show("RELOAD_NDUI")
			currentPage = 0
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
	end)
end

local welcome
local function HelloWorld()
	if welcome then welcome:Show() return end
	welcome = CreateFrame("Frame", "HelloWorld", UIParent)
	welcome:SetPoint("CENTER")
	welcome:SetSize(350, 400)
	welcome:SetScale(1.2)
	welcome:SetFrameStrata("HIGH")
	B.CreateMF(welcome)
	B.CreateBD(welcome)
	B.CreateTex(welcome)
	B.CreateFS(welcome, 30, "NDui", true, "TOPLEFT", 10, 25)
	B.CreateFS(welcome, 14, DB.Version, true, "TOPLEFT", 90, 12)
	B.CreateFS(welcome, 16, L["Help Title"], true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	B.CreateFS(welcome, 12, L["Help Info1"], false, "TOPLEFT", 20, -50)
	B.CreateFS(welcome, 12, L["Help Info2"], false, "TOPLEFT", 20, -70)

	local c1, c2 = "|c00FFFF00", "|c0000FF00"
	local lines = {
		c1.." /ww "..c2..L["Help Info12"],
		c1.." /hb "..c2..L["Help Info5"],
		c1.." /mm "..c2..L["Help Info6"],
		c1.." /rl "..c2..L["Help Info7"],
		c1.." /kro "..c2..L["Help Info13"],
		c1.." /ncl "..c2..L["Help Info9"],
	}
	for index, line in pairs(lines) do
		B.CreateFS(welcome, 12, line, false, "TOPLEFT", 20, -100-index*20)
	end

	B.CreateFS(welcome, 12, L["Help Info10"], false, "TOPLEFT", 20, -310)
	B.CreateFS(welcome, 12, L["Help Info11"], false, "TOPLEFT", 20, -330)

	local close = B.CreateButton(welcome, 20, 20, "X")
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() welcome:Hide() end)

	local goTutor = B.CreateButton(welcome, 100, 20, L["Tutorial"])
	goTutor:SetPoint("BOTTOM", 0, 10)
	goTutor:SetScript("OnClick", function() welcome:Hide() YesTutor() end)
end
SlashCmdList["NDUI"] = function() HelloWorld() end
SLASH_NDUI1 = "/ndui"

function module:OnLogin()
	if not NDuiDB["Tutorial"]["Complete"] then
		HelloWorld()
		NDuiDB["Tutorial"]["Complete"] = true
	end

	ForceUIScale()
	ForceAddonSkins()
	if NDuiDB["Chat"]["Lock"] then ForceChatSettings() end

	if tonumber(GetCVar("cameraDistanceMaxZoomFactor")) ~= 2.6 then
		SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	end
end