local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "SHAMAN" then return end

-- 萨满的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 546, UnitID = "player"},		-- 水上行走
		{AuraID = 25472, UnitID = "player"},	-- 闪电之盾
		{AuraID = 33736, UnitID = "player"},	-- 水盾
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 974, UnitID = "target", Caster = "player"},		-- 大地之盾
		{AuraID = 25464, UnitID = "target", Caster = "player"},		-- 冰霜震击
		{AuraID = 25457, UnitID = "target", Caster = "player"},		-- 烈焰震击
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 974, UnitID = "player"},		-- 大地之盾
		{AuraID = 16166, UnitID = "player"},	-- 元素掌控
		{AuraID = 30823, UnitID = "player"},	-- 萨满之怒
		{AuraID = 16188, UnitID = "player", Flash = true},	-- 自然迅捷
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 20608},	-- 复生
	},
}

module:AddNewAuraWatch("SHAMAN", list)