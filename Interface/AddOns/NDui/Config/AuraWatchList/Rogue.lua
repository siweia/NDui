local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 盗贼的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 1784, UnitID = "player"},		-- 潜行
		{AuraID = 2983, UnitID = "player"},		-- 疾跑
		{AuraID = 36554, UnitID = "player"},	-- 暗影步
		{AuraID = 197603, UnitID = "player"},	-- 黑暗之拥
		{AuraID = 270070, UnitID = "player"},	-- 隐藏之刃
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 408, UnitID = "target", Caster = "player"},		-- 肾击
		{AuraID = 703, UnitID = "target", Caster = "player"},		-- 锁喉
		{AuraID = 1833, UnitID = "target", Caster = "player"},		-- 偷袭
		{AuraID = 6770, UnitID = "target", Caster = "player"},		-- 闷棍
		{AuraID = 2094, UnitID = "target", Caster = "player"},		-- 致盲
		{AuraID = 1330, UnitID = "target", Caster = "player"},		-- 锁喉
		{AuraID = 1776, UnitID = "target", Caster = "player"},		-- 凿击
		{AuraID = 1943, UnitID = "target", Caster = "player"},		-- 割裂
		{AuraID = 79140, UnitID = "target", Caster = "player"},		-- 宿敌
		{AuraID = 16511, UnitID = "target", Caster = "player"},		-- 出血
		{AuraID = 192759, UnitID = "target", Caster = "player"},	-- 君王之灾
		{AuraID = 192425, UnitID = "target", Caster = "player"},	-- 毒素冲动
		{AuraID = 200803, UnitID = "target", Caster = "player"},	-- 苦痛毒液
		{AuraID = 137619, UnitID = "target", Caster = "player"},	-- 死亡标记
		{AuraID = 195452, UnitID = "target", Caster = "player"},	-- 夜刃
		{AuraID = 209786, UnitID = "target", Caster = "player"},	-- 赤喉之咬
		{AuraID = 196958, UnitID = "target", Caster = "player"},	-- 暗影打击
		{AuraID = 196937, UnitID = "target", Caster = "player"},	-- 鬼魅攻击
		{AuraID = 199804, UnitID = "target", Caster = "player"},	-- 正中眉心
		{AuraID = 192925, UnitID = "target", Caster = "player"},	-- 遇刺者之血
		{AuraID = 245389, UnitID = "target", Caster = "player"},	-- 淬毒之刃
		{AuraID = 121411, UnitID = "target", Caster = "player"},	-- 猩红风暴
		{AuraID = 255909, UnitID = "target", Caster = "player"},	-- 欺凌
		{AuraID = 91021, UnitID = "target", Caster = "player"},		-- 洞悉弱点
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 1966, UnitID = "player"},		-- 佯攻
		{AuraID = 5171, UnitID = "player"},		-- 切割
		{AuraID = 5277, UnitID = "player"},		-- 闪避
		{AuraID = 11327, UnitID = "player"},	-- 消失
		{AuraID = 13750, UnitID = "player"},	-- 冲动
		{AuraID = 13877, UnitID = "player"},	-- 剑刃乱舞
		{AuraID = 31224, UnitID = "player"},	-- 暗影斗篷
		{AuraID = 32645, UnitID = "player"},	-- 毒伤
		{AuraID = 45182, UnitID = "player"},	-- 装死
		{AuraID = 31665, UnitID = "player"},	-- 敏锐大师
		{AuraID = 185311, UnitID = "player"},	-- 猩红之瓶
		{AuraID = 193641, UnitID = "player"},	-- 深谋远虑
		{AuraID = 115192, UnitID = "player"},	-- 诡诈
		{AuraID = 193538, UnitID = "player"},	-- 敏锐
		{AuraID = 121471, UnitID = "player"},	-- 暗影之刃
		{AuraID = 185422, UnitID = "player"},	-- 影舞
		{AuraID = 212283, UnitID = "player"},	-- 死亡标记
		{AuraID = 202754, UnitID = "player"},	-- 隐秘刀刃
		{AuraID = 193356, UnitID = "player"},	-- 强势连击
		{AuraID = 193357, UnitID = "player"},	-- 暗鲨涌动
		{AuraID = 193358, UnitID = "player"},	-- 大乱斗
		{AuraID = 193359, UnitID = "player"},	-- 双巧手
		{AuraID = 199603, UnitID = "player"},	-- 骷髅黑帆
		{AuraID = 199600, UnitID = "player"},	-- 埋藏的宝藏
		{AuraID = 202665, UnitID = "player"},	-- 恐惧之刃诅咒
		{AuraID = 199754, UnitID = "player"},	-- 还击
		{AuraID = 195627, UnitID = "player"},	-- 可乘之机
		{AuraID = 121153, UnitID = "player"},	-- 侧袭
		{AuraID = 256735, UnitID = "player", Combat = true},	-- 刺客大师
		{AuraID = 271896, UnitID = "player"},	-- 刀锋冲刺
		{AuraID = 51690, UnitID = "player"},	-- 影舞步
		{AuraID = 277925, UnitID = "player"},	-- 袖剑旋风
		{AuraID = 196980, UnitID = "player"},	-- 暗影大师
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 6770, UnitID = "focus", Caster = "player"},	-- 闷棍
		{AuraID = 2094, UnitID = "focus", Caster = "player"},	-- 致盲
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 13750},	-- 冲动
		{SpellID = 79140},	-- 宿敌
		{SpellID = 121471},	-- 暗影之刃
	},
}

module:AddNewAuraWatch("ROGUE", list)