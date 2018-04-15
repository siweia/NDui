local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("AurasTable")

-- 术士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 48018, UnitID = "player"},	-- 恶魔法阵
		{AuraID = 108366, UnitID = "player"},	-- 灵魂榨取
		{AuraID = 199646, UnitID = "player"},	-- 吞噬之怒
		{AuraID = 119899, UnitID = "player"},	-- 灼烧主人
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 980, UnitID = "target", Caster = "player"},		-- 痛楚
		{AuraID = 603, UnitID = "target", Caster = "player"},		-- 末日灾祸
		{AuraID = 710, UnitID = "target", Caster = "player"},		-- 放逐术
		{AuraID = 6358, UnitID = "target", Caster = "pet"},			-- 魅惑
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
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 603, UnitID = "focus", Caster = "player"},		-- 末日灾祸
		{AuraID = 980, UnitID = "focus", Caster = "player"},		-- 痛楚
		{AuraID = 146739, UnitID = "focus", Caster = "player"},		-- 腐蚀术
		{AuraID = 233490, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233496, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233497, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233498, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 233499, UnitID = "focus", Caster = "player"},		-- 痛苦无常
		{AuraID = 157736, UnitID = "focus", Caster = "player"},		-- 献祭
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13, UnitID = "player"},		-- 饰品1
		{SlotID = 14, UnitID = "player"},		-- 饰品2
		{SpellID = 20707, UnitID = "player"},	-- 灵魂石
	},
}

module:AddNewAuraWatch("WARLOCK", list)