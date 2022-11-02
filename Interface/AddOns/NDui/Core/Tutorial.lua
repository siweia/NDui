local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Settings")
local pairs, wipe = pairs, table.wipe

-- Addon Info
print("|cff0080ff< NDui >|cff70C0F5----------------")
print("|cff00ff00  "..DB.Support.."|c00ffff00 "..DB.Version.." |c0000ff00"..L["Version Info1"])
print("|c0000ff00  "..L["Version Info2"].."|c00ffff00 /ndui |c0000ff00"..L["Version Info3"])
print("|cff70C0F5------------------------")

-- Tuitorial
local function ForceDefaultSettings()
	SetCVar("autoLootDefault", 1)
	SetCVar("alwaysCompareItems", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("showTutorials", 0)
	SetCVar("ActionButtonUseKeyDown", 1)
	SetCVar("lockActionBars", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("overrideArchive", 0)
--	SetCVar("AutoPushSpellToActionBar", 0)
	SetCVar("floatingCombatTextFloatMode", 1)
	SetCVar("floatingCombatTextCombatDamage", 1)
	SetCVar("floatingCombatTextCombatHealing", 1)
	SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0)
	SetCVar("floatingCombatTextCombatDamageDirectionalOffset", 10)
	SetActionBarToggles(1, 1, 1, 1)
	if not InCombatLockdown() then
		SetCVar("nameplateMotion", 1)
		SetCVar("nameplateShowAll", 1)
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("alwaysShowActionBars", 1)
	end
	if DB.isDeveloper then
		SetCVar("ffxGlow", 0)
		SetCVar("WorldTextScale", 1.2)
		SetCVar("SpellQueueWindow", 100)
	end
end

local function ForceRaidFrame()
	if InCombatLockdown() then return end
	if not CompactUnitFrameProfiles then return end
	SetCVar("useCompactPartyFrames", 1)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
	CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_UpdateCurrentPanel()
end

-- DBM bars
local function ForceDBMOptions()
	if not IsAddOnLoaded("DBM-Core") then return end
	if DBT_AllPersistentOptions then wipe(DBT_AllPersistentOptions) end
	DBT_AllPersistentOptions = {
		["Default"] = {
			["DBM"] = {
				["Scale"] = 1,
				["HugeScale"] = 1,
				["ExpandUpwards"] = true,
				["ExpandUpwardsLarge"] = true,
				["BarXOffset"] = 0,
				["BarYOffset"] = 8,
				["TimerPoint"] = "LEFT",
				["TimerX"] = 118,
				["TimerY"] = -105,
				["Width"] = 175,
				["Heigh"] = 20,
				["HugeWidth"] = 210,
				["HugeBarXOffset"] = 0,
				["HugeBarYOffset"] = 8,
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
	DBM_AllSavedOptions["Default"]["WarningFontStyle"] = DB.Font[3]
	DBM_AllSavedOptions["Default"]["SpecialWarningX"] = 0
	DBM_AllSavedOptions["Default"]["SpecialWarningY"] = -260
	DBM_AllSavedOptions["Default"]["SpecialWarningFontStyle"] = DB.Font[3]
	DBM_AllSavedOptions["Default"]["HideQuestTooltips"] = false
	DBM_AllSavedOptions["Default"]["HideObjectivesFrame"] = false
	DBM_AllSavedOptions["Default"]["WarningFontSize"] = 18
	DBM_AllSavedOptions["Default"]["SpecialWarningFontSize2"] = 24

	NDuiADB["DBMRequest"] = false
end

-- Skada
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then return end
	if SkadaDB then wipe(SkadaDB) end
	SkadaDB = {
		["hasUpgraded"] = true,
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{	["barheight"] = 18,
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 28,
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
							["fontflags"] = DB.Font[3],
							["fontsize"] = 14,
							["texture"] = "normTex",
						},
						["barfontflags"] = DB.Font[3],
						["point"] = "BOTTOMRIGHT",
						["mode"] = "",
						["barwidth"] = 300,
						["barbgcolor"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["barfontsize"] = 14,
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
	NDuiADB["SkadaRequest"] = false
end

-- BigWigs
local function ForceBigwigs()
	if not IsAddOnLoaded("BigWigs") then return end
	if BigWigs3DB then wipe(BigWigs3DB) end
	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["Default"] = {
						["outline"] = DB.Font[3],
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
						["emphasizeMultiplier"] = 1,
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
						["fontOutline"] = DB.Font[3],
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
	NDuiADB["BWRequest"] = false
end

local function ForceAddonSkins()
	if NDuiADB["DBMRequest"] then ForceDBMOptions() end
	if NDuiADB["SkadaRequest"] then ForceSkadaOptions() end
	if NDuiADB["BWRequest"] then ForceBigwigs() end
end

-- Tutorial
local tutor
local function YesTutor()
	if tutor then tutor:Show() return end
	tutor = CreateFrame("Frame", nil, UIParent)
	tutor:SetPoint("CENTER")
	tutor:SetSize(480, 300)
	tutor:SetFrameStrata("HIGH")
	B.CreateMF(tutor)
	B.SetBD(tutor)
	B.CreateWatermark(tutor)

	local ll = B.SetGradient(tutor, "H", .7, .7, .7, 0, .5, 80, C.mult)
	ll:SetPoint("TOP", -40, -32)
	local lr = B.SetGradient(tutor, "H", .7, .7, .7, .5, 0, 80, C.mult)
	lr:SetPoint("TOP", 40, -32)

	local title = B.CreateFS(tutor, 16, "", true, "TOP", 0, -10)
	local body = B.CreateFS(tutor, 14, "", false, "TOPLEFT", 20, -50)
	body:SetPoint("BOTTOMRIGHT", -20, 50)
	body:SetJustifyV("TOP")
	body:SetJustifyH("LEFT")
	body:SetWordWrap(true)
	local foot = B.CreateFS(tutor, 14, "", false, "BOTTOM", 0, 10)

	local pass = B.CreateButton(tutor, 50, 20, L["Skip"])
	pass:SetPoint("BOTTOMLEFT", 10, 10)
	pass:Hide()
	local apply = B.CreateButton(tutor, 50, 20, APPLY)
	apply:SetPoint("BOTTOMRIGHT", -10, 10)

	local titles = {L["Default Settings"], L["Skins"], L["Tips"]}
	local function RefreshText(page)
		title:SetText(titles[page])
		body:SetText(L["Tutorial Page"..page])
		foot:SetText(page.."/3")
	end
	RefreshText(1)

	local currentPage = 1
	local function TurnNextPage()
		currentPage = currentPage + 1
		RefreshText(currentPage)
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
	end

	pass:SetScript("OnClick", function()
		pass:Hide()
		TurnNextPage()
	end)
	apply:SetScript("OnClick", function()
		if currentPage == 1 then
			ForceDefaultSettings()
			ForceRaidFrame()
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Default Settings Check"])
			pass:Show()
		elseif currentPage == 2 then
			NDuiADB["DBMRequest"] = true
			NDuiADB["SkadaRequest"] = true
			NDuiADB["BWRequest"] = true
			ForceAddonSkins()
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Tutorial Complete"])
			pass:Hide()
		elseif currentPage == 3 then
			C.db["Tutorial"]["Complete"] = true
			tutor:Hide()
			StaticPopup_Show("RELOAD_NDUI")
		end
		TurnNextPage()
	end)
end

local welcome
local function HelloWorld()
	if welcome then welcome:Show() return end

	welcome = CreateFrame("Frame", "NDui_Tutorial", UIParent)
	welcome:SetPoint("CENTER")
	welcome:SetSize(420, 480)
	welcome:SetFrameStrata("HIGH")
	B.CreateMF(welcome)
	B.SetBD(welcome)
	B.CreateWatermark(welcome)
	B.CreateFS(welcome, 18, L["Help Title"], true, "TOP", 0, -10)

	local ll = B.SetGradient(welcome, "H", .7, .7, .7, 0, .5, 100, C.mult)
	ll:SetPoint("TOP", -50, -35)
	local lr = B.SetGradient(welcome, "H", .7, .7, .7, .5, 0, 100, C.mult)
	lr:SetPoint("TOP", 50, -35)

	local intro = B.CreateFS(welcome, 14, "", false, "TOPLEFT", 20, -70)
	intro:SetPoint("BOTTOMRIGHT", -20, 50)
	intro:SetWordWrap(true)
	intro:SetJustifyV("TOP")
	intro:SetJustifyH("LEFT")

	local c1, c2 = "|cffFFFF00", "|cff00FF00"
	local lines = {
		c1.." /ww "..c2..L["Cmd ww intro"].."|r",
		" /bb "..c2..L["Cmd bb intro"].."|r",
		" /mm /mmm "..c2..L["Cmd mm intro"].."|r",
		" /rl "..c2..L["Cmd rl intro"].."|r",
	}
	if GetLocale() == "zhCN" then
		tinsert(lines, " /ncl "..c2..L["Cmd ncl intro"].."|r")
	end
	local text = L["Help Intro"].."|n|n"
	for _, line in pairs(lines) do
		text = text.."|n|n"..line
	end
	intro:SetText(text)

	if C.db["Tutorial"]["Complete"] then
		local close = B.CreateButton(welcome, 16, 16, true, DB.closeTex)
		close:SetPoint("TOPRIGHT", -10, -10)
		close:SetScript("OnClick", function()
			welcome:Hide()
		end)
	end

	local goTutor = B.CreateButton(welcome, 100, 20, L["Tutorial"])
	goTutor:SetPoint("BOTTOM", 0, 10)
	goTutor:SetScript("OnClick", function()
		welcome:Hide()
		YesTutor()
	end)
end
SlashCmdList["NDUI"] = HelloWorld
SLASH_NDUI1 = "/ndui"

function module:OnLogin()
	-- todo: hide UIScale options

	-- Tutorial and settings
	ForceAddonSkins()
	if not C.db["Tutorial"]["Complete"] then HelloWorld() end
end