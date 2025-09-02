local _, ns = ...
local B, C, L, DB = unpack(ns)

local bit_band, bit_bor = bit.band, bit.bor
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001

DB.Version = GetAddOnMetadata("NDui", "Version")
DB.Support = GetAddOnMetadata("NDui", "X-Support")
DB.Client = GetLocale()
DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()
DB.isClassic = select(4, GetBuildInfo()) < 90000
DB.isNewPatch = select(4, GetBuildInfo()) >= 50501 -- 5.5.1
DB.isMop = select(4, GetBuildInfo()) >= 50500 -- 5.5.0 MoP

-- Deprecated
do
	local function EasyMenu_Initialize( frame, level, menuList )
		for index = 1, #menuList do
			local value = menuList[index]
			if (value.text) then
				value.index = index
				UIDropDownMenu_AddButton( value, level )
			end
		end
	end
	
	function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay )
		if ( displayMode == "MENU" ) then
			menuFrame.displayMode = displayMode
		end
		UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
		ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
	end
end

-- Colors
DB.MyName = UnitName("player")
DB.MyRealm = GetRealmName()
DB.MyFullName = DB.MyName.."-"..DB.MyRealm
DB.MyClass = select(2, UnitClass("player"))
DB.MyFaction = UnitFactionGroup("player")
DB.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	DB.ClassList[v] = k
end
DB.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	DB.ClassColors[class] = {}
	DB.ClassColors[class].r = value.r
	DB.ClassColors[class].g = value.g
	DB.ClassColors[class].b = value.b
	DB.ClassColors[class].colorStr = value.colorStr
end
DB.r, DB.g, DB.b = DB.ClassColors[DB.MyClass].r, DB.ClassColors[DB.MyClass].g, DB.ClassColors[DB.MyClass].b
DB.MyColor = format("|cff%02x%02x%02x", DB.r*255, DB.g*255, DB.b*255)
DB.InfoColor = "|cff99ccff" --.6,.8,1
DB.GreyColor = "|cff7b8489"
DB.QualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	DB.QualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
DB.QualityColors[-1] = {r = 0, g = 0, b = 0}
DB.QualityColors[LE_ITEM_QUALITY_POOR] = {r = .61, g = .61, b = .61}
DB.QualityColors[LE_ITEM_QUALITY_COMMON] = {r = 0, g = 0, b = 0}

-- Fonts
DB.Font = {STANDARD_TEXT_FONT, 12, "OUTLINE"}
DB.LineString = DB.GreyColor.."---------------"
DB.NDuiString = "|cff0080ffNDui:|r"

-- Textures
local Media = "Interface\\Addons\\NDui\\Media\\"
DB.bdTex = "Interface\\ChatFrame\\ChatFrameBackground"
DB.glowTex = Media.."glowTex"
DB.normTex = Media.."normTex"
DB.gradTex = Media.."gradTex"
DB.flatTex = Media.."flatTex"
DB.bgTex = Media.."bgTex"
DB.pushedTex = Media.."pushed"
DB.arrowTex = Media.."TargetArrow"
DB.starTex = Media.."Hutu\\star"
DB.MicroTex = Media.."Hutu\\Menu\\"
DB.tankTex = Media.."Hutu\\Tank"
DB.healTex = Media.."Hutu\\Healer"
DB.dpsTex = Media.."Hutu\\DPS"
DB.chatLogo = Media.."Hutu\\logoSmall"
DB.logoTex = Media.."Hutu\\logoClassic"
DB.sortTex = Media.."SortIcon"
DB.closeTex = Media.."Hutu\\close"
DB.ArrowUp = Media.."Hutu\\arrow"
DB.afdianTex = Media.."Hutu\\Afdian"
DB.patreonTex = Media.."Hutu\\Patreon"
DB.curseforgeTex = Media.."Hutu\\CURSEFORGE"
DB.boxTex = Media.."Hutu\\Box"
DB.mailTex = "Interface\\Minimap\\Tracking\\Mailbox"
DB.gearTex = "Interface\\WorldMap\\Gear_64"
DB.eyeTex = "Interface\\Minimap\\Raid_Icon"		-- blue: \\Dungeon_Icon
DB.garrTex = "Interface\\HelpFrame\\HelpIcon-ReportLag"
DB.copyTex = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
DB.binTex = "Interface\\HelpFrame\\ReportLagIcon-Loot"
DB.questTex = "adventureguide-microbutton-alert"
DB.objectTex = "Warfronts-BaseMapIcons-Horde-Barracks-Minimap"
DB.creditTex = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
DB.newItemFlash = "Interface\\Cooldown\\star4"
DB.sparkTex = "Interface\\CastingBar\\UI-CastingBar-Spark"
DB.TexCoord = {.08, .92, .08, .92}
DB.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"
-- Deprecated
DB.textures = {normal = 0, flash = 0, pushed = DB.pushedTex, checked = 0}
-- Flags
function DB:IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end
DB.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

--[[ RoleUpdater
local function CheckRole()
	local tree = GetSpecialization()
	if not tree then return end
	local _, _, _, _, role, stat = GetSpecializationInfo(tree)
	if role == "TANK" then
		DB.Role = "Tank"
	elseif role == "HEALER" then
		DB.Role = "Healer"
	elseif role == "DAMAGER" then
		if stat == 4 then	--1力量，2敏捷，4智力
			DB.Role = "Caster"
		else
			DB.Role = "Melee"
		end
	end
end
B:RegisterEvent("PLAYER_LOGIN", CheckRole)
B:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckRole)]]

-- Raidbuff Checklist
DB.BuffList = {
	[1] = {		-- 合剂
		17627,	-- 精炼智慧
		28518,	-- 强固合剂
		28519,	-- 强效回复合剂
		28520,	-- 无情突袭合剂
		28521,	-- 盲目光芒合剂
		28540,	-- 纯粹死亡合剂
		42735,	-- 多彩奇迹
		-- 战斗药剂
		33726,	-- 掌控药剂
		11406,	-- 屠魔药剂
		38954,	-- 魔能力量药剂
		33721,	-- 魔能药剂
		17539,	-- 强效奥法药剂
		28491,	-- 治疗能量
		-- 守护药剂
		28502,	-- 特效护甲
		39625,	-- 特效坚韧药剂
		39626,	-- 土灵药剂
		28514,	-- 增效
		28509,	-- 强效法力回复
		39627,	-- 德莱尼智慧药剂
	},
	[2] = {     -- 进食充分
		104273, -- 250敏捷，BUFF名一致
	},
	[3] = {     -- 10%智力
		1459,
		264760,
	},
	[4] = {     -- 10%耐力
		21562,
		264764,
	},
	[5] = {     -- 10%攻强
		6673,
		264761,
	},
	[6] = {     -- 符文
		270058,
	},
}

-- Reminder Buffs Checklist
DB.ReminderBuffs = {
	MAGE = {
		{	spells = {	-- 奥术智慧
				[1459] = true,	-- 奥术光辉
				[8096] = true,  -- 智力卷轴
				[79058] = true, -- 奥术智慧
				[61024] = true, -- 达拉然智慧
				[61316] = true, -- 达拉然光辉
				--[46302] = true, -- 基鲁的胜利之歌
			},
			texture = GetSpellTexture(1459),
			depend = 1459,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {
				[7302] = true,	-- 霜甲术
				[6117] = true,	-- 法师护甲
				[30482] = true,	-- 熔岩护甲
			},
			depend = 7302,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	PRIEST = {
		{	spells = {	-- 真言术耐
				[21562] = true, -- 坚韧祷言
				[8099] = true,  -- 耐力卷轴
				[469] = true,	-- 命令怒吼
				[6307] = true,   -- 血之契印
				[90364] = true,  -- 其拉虫群坚韧
				[72590] = true,  -- 坚韧
			},
			texture = GetSpellTexture(21562),
			depend = 1243,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 心灵之火
				[48168] = true,
			},
			depend = 48168,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	DRUID = {
		{	spells = {	-- 野性印记
				[1126] = true,
			},
			depend = 1126,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	--- 荆棘术
				[467] = true,
			},
			depend = 467,
			pvp = true,
		},
	},
	WARRIOR = {
		{	spells = {
				[6673] = true,	-- 战斗怒吼
				[8076] = true,  -- 大地之力
				[57330] = true, -- 寒冬号角
				[93435] = true, -- 勇气咆哮		
			},
			texture = GetSpellTexture(6673),
			depend = 6673,
			gemini = {
				[GetSpellInfo(469)] = true, -- 命令怒吼
			},
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {
				[469] = true,	-- 命令怒吼
				[6307] = true,   -- 血之契印
				[90364] = true,  -- 其拉虫群坚韧
				[72590] = true,  -- 坚韧
				[21562] = true,  -- 真言术：韧	
			},
			texture = GetSpellTexture(469),
			depend = 469,
			gemini = {
				[GetSpellInfo(6673)] = true, -- 战斗怒吼
			},
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	HUNTER = {
		{	spells = {	-- 雄鹰守护
				[13165] = true,
				[61846] = true, -- 龙鹰
				[109260] = true, -- 铁鹰
			},
			depend = 13165,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	--- 强击光环
				[19506] = true,
			},
			depend = 19506,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	WARLOCK = {
		{	spells = {
				[28176] = true,	-- 邪甲术
				[687] = true,	-- 魔甲术
			},
			depend = 28176,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {
				[85759] = true,	-- 黑暗意图
			},
			depend = 85759,
			instance = true,
		},
	},
	DEATHKNIGHT = {
		{	spells = {
				[57330] = true,	-- 寒冬号角
				[8076] = true,  -- 大地之力
				[6673] = true, 	-- 战斗怒吼
				[93435] = true, -- 勇气咆哮
			},
			texture = GetSpellTexture(57330),
			depend = 57330,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	PALADIN = {
		{	spells = {	-- 正义之怒
				[25780] = true,
			},
			depend = 20925,
			instance = true,
		},
	},
	SHAMAN = {
		{	spells = {	-- 护盾
				[52127] = true, -- 水盾
				[324] = true,   -- 闪电护盾
			},
			depend = 52127,
			instance = true,
		},
	},
}

-- Deprecated
LE_ITEM_CLASS_CONSUMABLE = LE_ITEM_CLASS_CONSUMABLE or Enum.ItemClass.Consumable
LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_CONTAINER or Enum.ItemClass.Container
LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON or Enum.ItemClass.Weapon
LE_ITEM_CLASS_GEM = LE_ITEM_CLASS_GEM or Enum.ItemClass.Gem
LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR or Enum.ItemClass.Armor
LE_ITEM_CLASS_REAGENT = LE_ITEM_CLASS_REAGENT or Enum.ItemClass.Reagent
LE_ITEM_CLASS_PROJECTILE = LE_ITEM_CLASS_PROJECTILE or Enum.ItemClass.Projectile
LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_TRADEGOODS or Enum.ItemClass.Tradegoods
LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_ITEM_ENHANCEMENT or Enum.ItemClass.ItemEnhancement
LE_ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE or Enum.ItemClass.Recipe
LE_ITEM_CLASS_QUIVER = LE_ITEM_CLASS_QUIVER or Enum.ItemClass.Quiver
LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM or Enum.ItemClass.Questitem
LE_ITEM_CLASS_KEY = LE_ITEM_CLASS_KEY or Enum.ItemClass.Key
LE_ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS or Enum.ItemClass.Miscellaneous
LE_ITEM_CLASS_GLYPH = LE_ITEM_CLASS_GLYPH or Enum.ItemClass.Glyph
LE_ITEM_CLASS_BATTLEPET = LE_ITEM_CLASS_BATTLEPET or Enum.ItemClass.Battlepet
LE_ITEM_CLASS_WOW_TOKEN = LE_ITEM_CLASS_WOW_TOKEN or Enum.ItemClass.WoWToken
