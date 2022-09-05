local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "EVOKER" then return end

-- 战士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--{AuraID = 32216, UnitID = "player"},	-- 胜利
	},
	["Target Aura"] = {		-- 目标光环组
		--{AuraID = 355, UnitID = "target", Caster = "player"},		-- 嘲讽
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--{AuraID = 871, UnitID = "player"},		-- 盾墙
	},
	["Focus Aura"] = {		-- 焦点光环组
		--{AuraID = 772, UnitID = "focus", Caster = "player"},	-- 撕裂
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("EVOKER", list)