local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 猎人的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 136, UnitID = "pet"},			-- 治疗宠物
		{AuraID = 19577, UnitID = "pet"},		-- 胁迫
		{AuraID = 160058, UnitID = "pet"},		-- 厚皮
		{AuraID = 90361, UnitID = "player"},	-- 灵魂治愈
		{AuraID = 35079, UnitID = "player"},	-- 误导
		{AuraID = 61648, UnitID = "player"},	-- 变色龙守护
		{AuraID = 199483, UnitID = "player"},	-- 伪装
		{AuraID = 118922, UnitID = "player"},	-- 迅疾如风
		{AuraID = 164857, UnitID = "player"},	-- 生存专家
		{AuraID = 186258, UnitID = "player"},	-- 猎豹守护
		{AuraID = 246152, UnitID = "player"},	-- 倒刺射击
		{AuraID = 246851, UnitID = "player"},	-- 倒刺射击
		{AuraID = 246852, UnitID = "player"},	-- 倒刺射击
		{AuraID = 246853, UnitID = "player"},	-- 倒刺射击
		{AuraID = 246854, UnitID = "player"},	-- 倒刺射击
		{AuraID = 203924, UnitID = "player"},	-- 守护屏障
		{AuraID = 197161, UnitID = "player"},	-- 灵龟守护回血
		{AuraID = 160007, UnitID = "player"},	-- 上升气流（双头龙）
		{AuraID = 231390, UnitID = "player", Combat = true},	-- 开拓者
		{AuraID = 164273, UnitID = "player", Combat = true},	-- 独来独往
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 3355, UnitID = "target", Caster = "player"},		-- 冰冻陷阱
		{AuraID = 5116, UnitID = "target", Caster = "player"},		-- 震荡射击
		{AuraID = 19386, UnitID = "target", Caster = "player"},		-- 翼龙钉刺
		{AuraID = 24394, UnitID = "target", Caster = "pet"},		-- 胁迫
		{AuraID = 117526, UnitID = "target"},						-- 束缚射击
		{AuraID = 131894, UnitID = "target", Caster = "player"},	-- 夺命黑鸦
		{AuraID = 199803, UnitID = "target", Caster = "player"},	-- 精确瞄准
		{AuraID = 195645, UnitID = "target", Caster = "player"},	-- 摔绊
		{AuraID = 202797, UnitID = "target", Caster = "player"},	-- 蝰蛇钉刺
		{AuraID = 202900, UnitID = "target", Caster = "player"},	-- 毒蝎钉刺
		{AuraID = 224729, UnitID = "target", Caster = "player"},	-- 爆裂射击
		{AuraID = 213691, UnitID = "target", Caster = "player"},	-- 驱散射击
		{AuraID = 257284, UnitID = "target", Caster = "player"},	-- 猎人印记
		{AuraID = 162480, UnitID = "target", Caster = "player"},	-- 精钢陷阱
		{AuraID = 162487, UnitID = "target", Caster = "player"},	-- 精钢陷阱
		{AuraID = 259491, UnitID = "target", Caster = "player"},	-- 毒蛇钉刺
		{AuraID = 271788, UnitID = "target", Caster = "player"},	-- 毒蛇钉刺
		{AuraID = 269747, UnitID = "target", Caster = "player"},	-- 野火炸弹
		{AuraID = 270339, UnitID = "target", Caster = "player"},	-- 散射炸弹
		{AuraID = 270343, UnitID = "target", Caster = "player"},	-- 内出血
		{AuraID = 271049, UnitID = "target", Caster = "player"},	-- 动荡炸弹
		{AuraID = 270332, UnitID = "target", Caster = "player"},	-- 信息素炸弹
		{AuraID = 259277, UnitID = "target", Caster = "pet"},		-- 杀戮命令
		{AuraID = 277959, UnitID = "target", Caster = "player"},	-- 稳固瞄准
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 19574, UnitID = "player"},	-- 狂野怒火
		{AuraID = 54216, UnitID = "player"},	-- 主人的召唤
		{AuraID = 186257, UnitID = "player"},	-- 猎豹守护
		{AuraID = 186265, UnitID = "player"},	-- 灵龟守护
		{AuraID = 190515, UnitID = "player"},	-- 适者生存
		{AuraID = 193534, UnitID = "player"},	-- 稳固集中
		{AuraID = 194594, UnitID = "player"},	-- 荷枪实弹
		{AuraID = 118455, UnitID = "pet"},		-- 野兽瞬劈斩
		{AuraID = 207094, UnitID = "pet"},		-- 泰坦之雷
		{AuraID = 217200, UnitID = "pet"},		-- 凶猛狂暴
		{AuraID = 272790, UnitID = "pet"},		-- 狂暴
		{AuraID = 193526, UnitID = "player"},	-- 百发百中
		{AuraID = 193530, UnitID = "player"},	-- 野性守护
		{AuraID = 185791, UnitID = "player"},	-- 荒野呼唤
		{AuraID = 259388, UnitID = "player"},	-- 猫鼬之怒
		{AuraID = 186289, UnitID = "player"},	-- 雄鹰守护
		{AuraID = 201081, UnitID = "player"},	-- 莫克纳萨战术
		{AuraID = 194407, UnitID = "player"},	-- 喷毒眼镜蛇
		{AuraID = 208888, UnitID = "player"},	-- 暗影猎手的回复，橙装头
		{AuraID = 204090, UnitID = "player"},	-- 正中靶心
		{AuraID = 208913, UnitID = "player"},	-- 哨兵视野，橙腰
		{AuraID = 248085, UnitID = "player"},	-- 蛇语者之舌，橙胸
		{AuraID = 242243, UnitID = "player"},	-- 致命瞄准，射击2T20
		{AuraID = 246153, UnitID = "player"},	-- 精准，射击4T20
		{AuraID = 203155, UnitID = "player"},	-- 狙击
		{AuraID = 235712, UnitID = "player", Combat = true},	-- 回转稳定，橙手
		{AuraID = 264735, UnitID = "player"},	-- 优胜劣汰
		{AuraID = 281195, UnitID = "player"},	-- 优胜劣汰
		{AuraID = 260242, UnitID = "player"},	-- 弹无虚发
		{AuraID = 260395, UnitID = "player"},	-- 致命射击
		{AuraID = 269502, UnitID = "player"},	-- 致命射击
		{AuraID = 281036, UnitID = "player"},	-- 凶暴野兽
		{AuraID = 260402, UnitID = "player"},	-- 二连发
		{AuraID = 266779, UnitID = "player"},	-- 协调进攻
		{AuraID = 260286, UnitID = "player"},	-- 利刃之矛
		{AuraID = 265898, UnitID = "player"},	-- 接战协定
		{AuraID = 268552, UnitID = "player"},	-- 蝰蛇毒液
		{AuraID = 260249, UnitID = "player"},	-- 掠食者
		{AuraID = 257622, UnitID = "player", Text = "A"},	-- 技巧射击
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 3355, UnitID = "focus", Caster = "player"},	-- 冰冻陷阱
		{AuraID = 19386, UnitID = "focus", Caster = "player"},	-- 翼龙钉刺
		{AuraID = 118253, UnitID = "focus", Caster = "player"},	-- 毒蛇钉刺
		{AuraID = 194599, UnitID = "focus", Caster = "player"},	-- 黑箭
		{AuraID = 131894, UnitID = "focus", Caster = "player"},	-- 夺命黑鸦
		{AuraID = 199803, UnitID = "focus", Caster = "player"},	-- 精确瞄准
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 186265},	-- 灵龟守护
		{SpellID = 147362},	-- 反制射击
	},
}

module:AddNewAuraWatch("HUNTER", list)