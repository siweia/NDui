local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- DK的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 3714, UnitID = "player"},		-- 冰霜之路
		{AuraID = 81141, UnitID = "player"},	-- 赤色天灾
		{AuraID = 81340, UnitID = "player"},	-- 末日突降
		{AuraID = 59052, UnitID = "player"},	-- 白霜
		{AuraID = 219788, UnitID = "player"},	-- 埋骨之所
		{AuraID = 215377, UnitID = "player"},	-- 巨口饿了
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 55078, UnitID = "target", Caster = "player"},		-- 血之疫病
		{AuraID = 55095, UnitID = "target", Caster = "player"},		-- 冰霜疫病
		{AuraID = 56222, UnitID = "target", Caster = "player"},		-- 黑暗命令
		{AuraID = 45524, UnitID = "target", Caster = "player"},		-- 寒冰锁链
		{AuraID = 191587, UnitID = "target", Caster = "player"},	-- 恶性瘟疫
		{AuraID = 211793, UnitID = "target", Caster = "player"},	-- 冷库严冬
		{AuraID = 221562, UnitID = "target", Caster = "player"},	-- 窒息
		{AuraID = 108194, UnitID = "target", Caster = "player"},	-- 窒息
		{AuraID = 206940, UnitID = "target", Caster = "player"},	-- 鲜血印记
		{AuraID = 206977, UnitID = "target", Caster = "player"},	-- 血之镜像
		{AuraID = 207167, UnitID = "target", Caster = "player"},	-- 致盲冰雨
		{AuraID = 194310, UnitID = "target", Caster = "player"},	-- 溃烂之伤
		{AuraID = 130736, UnitID = "target", Caster = "player"},	-- 灵魂收割
		{AuraID = 156004, UnitID = "target", Caster = "player"},	-- 亵渎
		{AuraID = 191748, UnitID = "target", Caster = "player"},	-- 诸界之灾
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 63560, UnitID = "pet"},		-- 黑暗突变
		{AuraID = 48265, UnitID = "player"},	-- 死亡脚步
		{AuraID = 55233, UnitID = "player"},	-- 吸血鬼之血
		{AuraID = 48707, UnitID = "player"},	-- 反魔法护罩
		{AuraID = 81256, UnitID = "player"},	-- 符文刃舞
		{AuraID = 48792, UnitID = "player"},	-- 冰封之韧
		{AuraID = 51271, UnitID = "player"},	-- 冰霜之柱
		{AuraID = 51124, UnitID = "player"},	-- 杀戮机器
		{AuraID = 51460, UnitID = "player"},	-- 符文腐蚀
		{AuraID = 53365, UnitID = "player"},	-- 不洁之力
		{AuraID = 195181, UnitID = "player"},	-- 白骨之盾
		{AuraID = 188290, UnitID = "player"},	-- 枯萎凋零
		{AuraID = 213003, UnitID = "player"},	-- 灵魂吞噬
		{AuraID = 194679, UnitID = "player"},	-- 符文分流
		{AuraID = 194844, UnitID = "player"},	-- 白骨风暴
		{AuraID = 207127, UnitID = "player"},	-- 饥饿符文刃
		{AuraID = 207256, UnitID = "player"},	-- 湮灭
		{AuraID = 207319, UnitID = "player"},	-- 血肉之盾
		{AuraID = 215711, UnitID = "player"},	-- 夺魂
		{AuraID = 218100, UnitID = "player"},	-- 亵渎
		{AuraID = 196770, UnitID = "player"},	-- 冷库严冬
		{AuraID = 194879, UnitID = "player"},	-- 冰冷之爪
		{AuraID = 211805, UnitID = "player"},	-- 风暴汇聚
		{AuraID = 152279, UnitID = "player"},	-- 冰龙吐息
		{AuraID = 235599, UnitID = "player"},	-- 冷酷之心
		{AuraID = 246995, UnitID = "player"},	-- 食尸鬼主宰，2T20
		{AuraID = 193320, UnitID = "player", Value = true},	-- 永恒脐带
		{AuraID = 219809, UnitID = "player", Value = true},	-- 墓石
		{AuraID = 48743, UnitID = "player", Value = true},	-- 天灾契约
		{AuraID = 115989, UnitID = "player"},	-- 黑暗虫群
		{AuraID = 212552, UnitID = "player"},	-- 幻影步
		{AuraID = 207289, UnitID = "player"},	-- 邪恶狂乱
		{AuraID = 273947, UnitID = "player"},	-- 鲜血禁闭
		{AuraID = 253595, UnitID = "player", Combat = true},	-- 酷寒突袭
		{AuraID = 281209, UnitID = "player", Combat = true},	-- 冷酷之心
		{AuraID = 47568, UnitID = "player"},	-- 符文武器增效
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 55078, UnitID = "focus", Caster = "player"},	-- 血之疫病
		{AuraID = 55095, UnitID = "focus", Caster = "player"},	-- 冰霜疫病
		{AuraID = 191587, UnitID = "focus", Caster = "player"},	-- 恶性瘟疫
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 48792},	-- 冰封之韧
		{SpellID = 49206},	-- 召唤石鬼像
	},
}

module:AddNewAuraWatch("DEATHKNIGHT", list)