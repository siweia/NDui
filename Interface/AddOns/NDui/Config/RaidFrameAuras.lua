local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("RaidFrameAuras")

local TIER, BOSS = 1, 1
local RaidBuffs, RaidDebuffs = {}, {}
local testIndex = false

-- 团队框体职业相关Buffs
local RaidBuffs = {
	["ALL"] = {			-- 全职业
		[27827] = true,		-- 救赎之魂
		[98008] = true,		-- 灵魂链接
		[192082] = true,	-- 狂风
        [1022] = true,		-- 保护祝福
        [204018] = true,	-- 破咒祝福
		[204150] = true,	-- 圣光护盾
		[31821] = true,		-- 光环掌握
		[97463] = true,		-- 命令怒吼
		[81782] = true,		-- 真言术障
        [33206] = true,		-- 痛苦压制
		[102342] = true,	-- 铁木树皮
		[209426] = true,	-- 黑暗
		[77761] = true,		-- 狂奔怒吼
		[77764] = true,		-- 狂奔怒吼
		[87023] = true,		-- 灸灼
		[45438] = true,		-- 冰箱
		[186265] = true,	-- 灵龟守护
		[642] = true,		-- 圣盾术

		[57723] = true,		-- 筋疲力尽
		[57724] = true,		-- 心满意足
		[80354] = true,		-- 时空错位
		[95809] = true,		-- 疯狂
		[160455] = true,	-- 疲倦
	},
	["DRUID"] = {		-- 德鲁伊
        [774] = true,		-- 回春
        [155777] = true,	-- 萌芽
        [8936] = true,		-- 愈合
        [33763] = true,		-- 生命绽放
        [48438] = true,		-- 野性成长
        [102352] = true,	-- 塞纳里奥结界
        [200389] = true,	-- 栽培
	},
	["HUNTER"] = {		-- 猎人
        [34477] = true,		-- 误导
	},
	["ROGUE"] = {		-- 盗贼
        [57934] = true,		-- 嫁祸
	},
	["WARRIOR"] = {		-- 战士
		[12975] = true,		-- 援护
		[114030] = true,	-- 警戒
	},
	["SHAMAN"] = {		-- 萨满
		[61295] = true,		-- 激流
	},
	["PALADIN"] = {		-- 圣骑士
        [53563] = true,		-- 圣光道标
        [156910] = true,	-- 信仰道标
        [1044] = true,		-- 自由祝福
        [6940] = true,		-- 牺牲祝福
	},
	["PRIEST"] = {		-- 牧师
        [17] = true,		-- 真言术盾
        [139] = true,		-- 恢复
        [41635] = true,		-- 愈合祷言
        [194384] = true,	-- 救赎
        [47788] = true,		-- 守护之魂
	},
	["MONK"] = {		-- 武僧
        [119611] = true,	-- 复苏之雾
        [116849] = true,	-- 作茧缚命
        [124682] = true,	-- 氤氲之雾
        [124081] = true,	-- 禅意波
	},
	["DEMONHUNTER"] = {	-- DH
	},
	["MAGE"] = {		-- 法师
	},
	["WARLOCK"] = {		-- 术士
	},
	["DEATHKNIGHT"] = {	-- DK
	},
}

function module:RegisterDebuff(tierID, instID, bossID, spellID, level)
	local instName = EJ_GetInstanceInfo(instID)
	if not instName then print("Invalid instance ID: "..instID) return end

	if not RaidDebuffs[instName] then RaidDebuffs[instName] = {} end
	if level then
		if level < 0 then level = 0 end
		if level > 5 then level = 5 end
	else
		level = 2
	end
	RaidDebuffs[instName][spellID] = level

	if testIndex == instID then
		SlashCmdList["NDUI_DUMPSPELL"](spellID)
	end
end

function module:OnLogin()
	--[[
		团队框体Debuffs添加格式：
		self:RegisterDebuff(TIER, 副本ID, BOSS, 法术ID，Debuff优先级)

		以下方为例，代表的是在<暗夜要塞>里添加<法术ID>219223，<优先级>为5，大于待驱散的魔法效果；
		待驱散的魔法效果的优先级为4，你添加的要以此为基准；
		当你没有填写副本ID时，默认优先级为2；当多个存在时，只能显示优先级最高的Debuff。
		TIER和BOSS不用管它，副本ID的话，常用的有翡翠梦魇768，暗夜要塞786。
	]]
	-- 自定义团队框体Debuffs
	self:RegisterDebuff(TIER, 786, BOSS, 219223, 5)

	-- Copy Table
	C.RaidAuraWatch = RaidBuffs
	C.RaidDebuffs = RaidDebuffs
end