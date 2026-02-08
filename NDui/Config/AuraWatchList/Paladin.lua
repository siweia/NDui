local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "PALADIN" then return end

-- 圣骑士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 25780, UnitID = "player"},	-- 正义之怒
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 853, UnitID = "target", Caster = "player"},		-- 制裁之锤
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 498, UnitID = "player"},		-- 圣佑术
		{AuraID = 642, UnitID = "player"},		-- 圣盾术
		{AuraID = 27155, UnitID = "player"},	-- 正义圣印
		{AuraID = 27160, UnitID = "player"},	-- 光明圣印
		{AuraID = 27166, UnitID = "player"},	-- 智慧圣印
		{AuraID = 31884, UnitID = "player"},	-- 复仇之怒
		{AuraID = 31895, UnitID = "player"},	-- 公正圣印
		{AuraID = 348704, UnitID = "player"},	-- 复仇圣印
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("PALADIN", list)