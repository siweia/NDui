local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 术士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 5697, UnitID = "player"},		-- 无尽呼吸
		{AuraID = 48018, UnitID = "player"},	-- 恶魔法阵
		{AuraID = 108366, UnitID = "player"},	-- 灵魂榨取
		{AuraID = 119899, UnitID = "player"},	-- 灼烧主人
		{AuraID = 196099, UnitID = "player"},	-- 牺牲魔典
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 980, UnitID = "target", Caster = "player"},		-- 痛楚
		{AuraID = 710, UnitID = "target", Caster = "player"},		-- 放逐术
		{AuraID = 6358, UnitID = "target", Caster = "pet"},			-- 魅惑
		{AuraID = 89766, UnitID = "target", Caster = "pet"},		-- 巨斧投掷
		{AuraID = 6789, UnitID = "target", Caster = "player"},		-- 死亡缠绕
		{AuraID = 5484, UnitID = "target", Caster = "player"},		-- 恐惧嚎叫
		{AuraID = 27243, UnitID = "target", Caster = "player"},		-- 腐蚀之种
		{AuraID = 17877, UnitID = "target", Caster = "player"},		-- 暗影灼烧
		{AuraID = 48181, UnitID = "target", Caster = "player"},		-- 鬼影缠身
		{AuraID = 63106, UnitID = "target", Caster = "player"},		-- 生命虹吸
		{AuraID = 30283, UnitID = "target", Caster = "player"},		-- 暗影之怒
		{AuraID = 80240, UnitID = "target", Caster = "player"},		-- 浩劫
		{AuraID = 146739, UnitID = "target", Caster = "player"},	-- 腐蚀术
		{AuraID = 233490, UnitID = "target", Caster = "player"},	-- 痛苦无常
		{AuraID = 233496, UnitID = "target", Caster = "player"},	-- 痛苦无常
		{AuraID = 233497, UnitID = "target", Caster = "player"},	-- 痛苦无常
		{AuraID = 233498, UnitID = "target", Caster = "player"},	-- 痛苦无常
		{AuraID = 233499, UnitID = "target", Caster = "player"},	-- 痛苦无常
		{AuraID = 118699, UnitID = "target", Caster = "player"},	-- 恐惧
		{AuraID = 205181, UnitID = "target", Caster = "player"},	-- 暗影烈焰
		{AuraID = 157736, UnitID = "target", Caster = "player"},	-- 献祭
		{AuraID = 196414, UnitID = "target", Caster = "player"},	-- 根除
		{AuraID = 199890, UnitID = "target", Caster = "player"},	-- 语言诅咒
		{AuraID = 199892, UnitID = "target", Caster = "player"},	-- 虚弱诅咒
		{AuraID = 265412, UnitID = "target", Caster = "player"},	-- 厄运
		{AuraID = 270569, UnitID = "target", Caster = "player"},	-- 来自阴影
		{AuraID = 278350, UnitID = "target", Caster = "player"},	-- 邪恶污染
		{AuraID = 205179, UnitID = "target", Caster = "player"},	-- 诡异魅影
		{AuraID = 32390, UnitID = "target", Caster = "player"},		-- 暗影之拥
		{AuraID = 265931, UnitID = "target", Caster = "player"},	-- 燃烧
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 89751, UnitID = "pet"},		-- 魔刃风暴
		{AuraID = 216695, UnitID = "player"},	-- 被折磨的灵魂
		{AuraID = 104773, UnitID = "player"},	-- 不灭决心
		{AuraID = 199281, UnitID = "player"},	-- 痛上加痛
		{AuraID = 196606, UnitID = "player"},	-- 暗影启迪
		{AuraID = 111400, UnitID = "player"},	-- 爆燃冲刺
		{AuraID = 115831, UnitID = "pet"},		-- 愤怒风暴
		{AuraID = 193396, UnitID = "pet"},		-- 恶魔增效
		{AuraID = 117828, UnitID = "player"},	-- 爆燃
		{AuraID = 196098, UnitID = "player"},	-- 灵魂收割
		{AuraID = 205146, UnitID = "player"},	-- 魔性征兆
		{AuraID = 216708, UnitID = "player"},	-- 逆风收割者
		{AuraID = 235156, UnitID = "player"},	-- 强化生命分流
		{AuraID = 108416, UnitID = "player", Value = true},	-- 黑暗契约
		{AuraID = 264173, UnitID = "player"},	-- 恶魔之核
		{AuraID = 265273, UnitID = "player"},	-- 恶魔之力
		{AuraID = 212295, UnitID = "player"},	-- 虚空守卫
		{AuraID = 267218, UnitID = "player"},	-- 虚空传送门
		{AuraID = 113858, UnitID = "player"},	-- 黑暗灵魂：动荡
		{AuraID = 113860, UnitID = "player"},	-- 黑暗灵魂：哀难
		{AuraID = 266091, UnitID = "player"},	-- 统御魔典
		{AuraID = 264571, UnitID = "player"},	-- 夜幕
		{AuraID = 266030, UnitID = "player"},	-- 熵能返转
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 980, UnitID = "focus", Caster = "player"},		-- 痛楚
		{AuraID = 146739, UnitID = "focus", Caster = "player"},		-- 腐蚀术
		{AuraID = 233490, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233496, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233497, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233498, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233499, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 157736, UnitID = "focus", Caster = "player"},		-- 献祭
		{AuraID = 265412, UnitID = "focus", Caster = "player"},		-- 厄运
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13, UnitID = "player"},		-- 饰品1
		{SlotID = 14, UnitID = "player"},		-- 饰品2
	},
}

module:AddNewAuraWatch("WARLOCK", list)