local _, _, L, DB = unpack(select(2, ...))
DB.Version = GetAddOnMetadata("NDui", "Version")
DB.Support = GetAddOnMetadata("NDui", "X-Support")
DB.Client = GetLocale()

-- Colors
DB.MyClass = select(2, UnitClass("player"))
DB.cc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[DB.MyClass]
DB.MyColor = format("|cff%02x%02x%02x", DB.cc.r*255, DB.cc.g*255, DB.cc.b*255)
DB.InfoColor = "|cff70C0F5"
DB.GreyColor = "|cffB5B5B5"

-- Fonts
DB.Font = {STANDARD_TEXT_FONT, 12, "OUTLINE"}
DB.TipFont = {GameTooltipText:GetFont(), 14, "OUTLINE"}

-- Textures
local Media = "Interface\\Addons\\NDui\\Media\\"
DB.bdTex = "Interface\\ChatFrame\\ChatFrameBackground"
DB.glowTex = Media.."glowTex"
DB.normTex = Media.."normTex"
DB.bgTex = Media.."bgTex"
DB.Micro = Media.."MicroMenu\\"
DB.arrowTex = Media.."NeonRedArrow"
DB.mailTex = "Interface\\Minimap\\Tracking\\Mailbox"
DB.gearTex = "Interface\\WorldMap\\Gear_64"
DB.eyeTex = "Interface\\Minimap\\Raid_Icon"		-- blue: \\Dungeon_Icon
DB.garrTex = "Interface\\HelpFrame\\HelpIcon-ReportLag"
DB.copyTex = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
DB.binTex = "Interface\\HelpFrame\\ReportLagIcon-Loot"
DB.questTex = "Interface\\BUTTONS\\AdventureGuideMicrobuttonAlert"
DB.creditTex = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
DB.TexCoord = {.08, .92, .08, .92}
DB.textures = {
    normal		= Media.."ActionBar\\gloss",
    flash		= Media.."ActionBar\\flash",
    pushed		= Media.."ActionBar\\pushed",
    checked		= Media.."ActionBar\\checked",
    equipped	= Media.."ActionBar\\gloss",
}
DB.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:230:307|t "
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:333:411|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:-1:512:512:12:66:127:204|t "

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
NDui:EventFrame({"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"}):SetScript("OnEvent", CheckRole)

-- Raidbuff Checklist
DB.BuffList = {
	[1] = {		-- 合剂
		188031,	-- 1300智力
		188033,	-- 1300敏捷
		188034,	-- 1300力量
		188035,	-- 1950耐力
	},
	[2] = {     -- 进食充分
		104273, -- 250敏捷，BUFF名一致
	},
	[3] = {     -- 符文
		224001,
	},
}

-- Reminder Buffs Checklist
DB.ReminderBuffs = {
	SHAMAN = {
		[L["Lightning Shield"]] = {		-- 闪电之盾
			["spells"] = {
				[192106] = true,
			},
			["requirespell"] = 192106,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
	},
	ROGUE = {
		[L["Damage Poison"]] = {		-- 伤害类毒药
			["spells"] = {
				[2823] = true,			-- 致命药膏
			},
			["negate_spells"] = {
				[8679] = true,			-- 致伤药膏
				[200802] = true,		-- 苦痛毒液
			},
			["tree"] = 1,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		[L["Effect Poison"]] = { 		-- 效果类毒药
			["spells"] = {
				[3408] = true,   		-- 减速药膏
			},
			["negate_spells"] = {
				[108211] = true, 		-- 吸血药膏
			},
			["tree"] = 1,
			["pvp"] = true,
		},
	},
}

-- Filter Chat symbols
DB.Symbols = {"`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/"}