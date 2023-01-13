local _, ns = ...
local B, C, L, DB = unpack(ns)

local bit_band, bit_bor = bit.band, bit.bor
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo

DB.Version = GetAddOnMetadata("NDui", "Version")
DB.Support = GetAddOnMetadata("NDui", "X-Support")
DB.Client = GetLocale()
DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()
DB.isNewPatch = select(4, GetBuildInfo()) >= 100005 -- 10.0.5

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
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
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
DB.QualityColors[Enum.ItemQuality.Poor] = {r = COMMON_GRAY_COLOR.r, g = COMMON_GRAY_COLOR.g, b = COMMON_GRAY_COLOR.b}
DB.QualityColors[Enum.ItemQuality.Common] = {r = 0, g = 0, b = 0}
DB.QualityColors[99] = {r = 1, g = 0, b = 0}

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
DB.flagTex = Media.."Hutu\\flag"
DB.MicroTex = Media.."Hutu\\Menu\\"
DB.rolesTex = Media.."Hutu\\RoleIcons"
DB.tankTex = Media.."Hutu\\Tank"
DB.healTex = Media.."Hutu\\Healer"
DB.dpsTex = Media.."Hutu\\DPS"
DB.chatLogo = Media.."Hutu\\logoSmall"
DB.logoTex = Media.."Hutu\\logo"
DB.closeTex = Media.."Hutu\\close"
DB.ArrowUp = Media.."Hutu\\arrow"
DB.afdianTex = Media.."Hutu\\Afdian"
DB.patreonTex = Media.."Hutu\\Patreon"
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
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

-- Flags
function DB:IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end
DB.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

-- RoleUpdater
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
B:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)

-- Raidbuff Checklist
DB.BuffList = {
	[1] = {		-- 合剂
		370652,	-- 静电赋能瓶剂
		370653,	-- 冰寒庇护瓶剂
		371172,	-- 温存全能瓶剂
		371204,	-- 止风瓶剂
		371339,	-- 元素混沌瓶剂
		371354,	-- 风暴之眼瓶剂
		371386,	-- 疏离注能瓶剂
		373257,	-- 冰川之怒瓶剂
		374000,	-- 腐化之怒冰冻瓶剂
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
	ITEMS = {
		{	itemID = 190384, -- 9.0永久属性符文
			spells = {
				[393438] = true, -- 巨龙强化符文 itemID 201325
				[367405] = true, -- 永久符文buff
			},
			instance = true,
			disable = true, -- 禁用直到出了新符文
		},
		{	itemID = 194307, -- 巢穴守护者的诺言
			spells = {
				[394457] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		--[=[
		{	itemID = 178742, -- 瓶装毒素饰品
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{	itemID = 190958, -- 究极秘术
			spells = {
				[368512] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		]=]
	},
	MAGE = {
		{	spells = {	-- 奥术魔宠
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 奥术智慧
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{	spells = {	-- 真言术耐
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{	spells = {	-- 战斗怒吼
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{	spells = {
				[192106] = true,	-- 闪电之盾
				[974] = true,		-- 大地之盾
				[52127] = true,		-- 水之护盾
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {
				[33757] = true,		-- 风怒武器
			},
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
		{	spells = {
				[318038] = true,	-- 火舌武器
			},
			depend = 318038,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 2,
			spec = 2,
		},
	},
	ROGUE = {
		{	spells = {	-- 伤害类毒药
				[2823] = true,		-- 致命药膏
				[8679] = true,		-- 致伤药膏
				[315584] = true,	-- 速效药膏
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 效果类毒药
				[3408] = true,		-- 减速药膏
				[5761] = true,		-- 迟钝药膏
			},
			depend = 3408,
			pvp = true,
		},
	},
	EVOKER = {
		{	spells = {	-- 青铜龙的祝福
				[381748] = true,
			},
			depend = 364342,
			instance = true,
		},
	},
	DRUID = {
		{	spells = {	-- 野性印记
				[1126] = true,
			},
			depend = 1126,
			instance = true,
		},
	},
}