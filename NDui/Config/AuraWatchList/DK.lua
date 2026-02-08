local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "DEATHKNIGHT" then return end

-- DK的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 3714, UnitID = "player"},		-- 冰霜之路
		{AuraID = 53365, UnitID = "player"},	-- 不洁之力
		{AuraID = 59052, UnitID = "player"},	-- 白霜
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 55078, UnitID = "target", Caster = "player"},		-- 血之疫病
		{AuraID = 55095, UnitID = "target", Caster = "player"},		-- 冰霜疫病
		{AuraID = 56222, UnitID = "target", Caster = "player"},		-- 黑暗命令
		{AuraID = 45524, UnitID = "target", Caster = "player"},		-- 寒冰锁链
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 63560, UnitID = "pet"},		-- 黑暗突变
		{AuraID = 47568, UnitID = "player"},	-- 符文武器增效
		{AuraID = 49039, UnitID = "player"},	-- 巫妖之躯
		{AuraID = 55233, UnitID = "player"},	-- 吸血鬼之血
		{AuraID = 48707, UnitID = "player"},	-- 反魔法护罩
		{AuraID = 48792, UnitID = "player"},	-- 冰封之韧
		{AuraID = 51271, UnitID = "player"},	-- 冰霜之柱
		{AuraID = 51124, UnitID = "player"},	-- 杀戮机器
		{AuraID = 51460, UnitID = "player"},	-- 符文腐蚀
		{AuraID = 49796, UnitID = "player", Flash = true},	-- 黑锋冰寒
		{AuraID = 48743, UnitID = "player", Value = true},	-- 天灾契约
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 55078, UnitID = "focus", Caster = "player"},	-- 血之疫病
		{AuraID = 55095, UnitID = "focus", Caster = "player"},	-- 冰霜疫病
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 48792},	-- 冰封之韧
		{SpellID = 49206},	-- 召唤石鬼像
	},
}

module:AddNewAuraWatch("DEATHKNIGHT", list)