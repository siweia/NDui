local _, ns = ...
local B, C, L, DB = unpack(ns)

DB.Version = GetAddOnMetadata("NDui", "Version")
DB.Support = GetAddOnMetadata("NDui", "X-Support")
DB.Client = GetLocale()
DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()

-- Colors
DB.MyClass = select(2, UnitClass("player"))
DB.cc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[DB.MyClass]
DB.MyColor = format("|cff%02x%02x%02x", DB.cc.r*255, DB.cc.g*255, DB.cc.b*255)
DB.InfoColor = "|cff70c0f5"
DB.GreyColor = "|cff808080"
BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR] = {r = .61, g = .61, b = .61}
BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON] = {r = 0, g = 0, b = 0}

-- Fonts
DB.Font = {STANDARD_TEXT_FONT, 12, "OUTLINE"}
DB.TipFont = {GameTooltipText:GetFont(), 14, "OUTLINE"}
DB.LineString = DB.GreyColor.."---------------"

-- Textures
local Media = "Interface\\Addons\\NDui\\Media\\"
DB.bdTex = "Interface\\ChatFrame\\ChatFrameBackground"
DB.glowTex = Media.."glowTex"
DB.normTex = Media.."normTex"
DB.bgTex = Media.."bgTex"
DB.MicroTex = Media.."MicroMenu\\micro_"
DB.arrowTex = Media.."NeonRedArrow"
DB.mailTex = "Interface\\Minimap\\Tracking\\Mailbox"
DB.gearTex = "Interface\\WorldMap\\Gear_64"
DB.eyeTex = "Interface\\Minimap\\Raid_Icon"		-- blue: \\Dungeon_Icon
DB.garrTex = "Interface\\HelpFrame\\HelpIcon-ReportLag"
DB.copyTex = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
DB.binTex = "Interface\\HelpFrame\\ReportLagIcon-Loot"
DB.questTex = "Interface\\BUTTONS\\AdventureGuideMicrobuttonAlert"
DB.creditTex = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
DB.newItemFlash = "Interface\\Cooldown\\star4"
DB.sparkTex = "Interface\\CastingBar\\UI-CastingBar-Spark"
DB.TexCoord = {.08, .92, .08, .92}
DB.textures = {
	normal		= Media.."ActionBar\\gloss",
	flash		= Media.."ActionBar\\flash",
	pushed		= Media.."ActionBar\\pushed",
	checked		= Media.."ActionBar\\checked",
	equipped	= Media.."ActionBar\\gloss",
}
DB.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

-- Flags
DB.MyPetFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.PartyPetFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.RaidPetFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.GuardianFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_GUARDIAN)

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
		251836,	-- 敏捷
		251837,	-- 智力
		251838,	-- 耐力
		251839,	-- 力量
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
		{	spells = {	-- 闪电之盾
				[192106] = true,
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	ROGUE = {
		{	spells = {	-- 伤害类毒药
				[2823] = true,		-- 致命药膏
				[8679] = true,		-- 致伤药膏
			},
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 效果类毒药
				[3408] = true,		-- 减速药膏
			},
			spec = 1,
			pvp = true,
		},
	},
}