local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "PRIEST" then return end

-- 牧师的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 586, UnitID = "player"},		-- 渐隐术
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 25218, UnitID = "target", Caster = "player"},		-- 真言术：盾
		{AuraID = 25222, UnitID = "target", Caster = "player"},		-- 恢复
		{AuraID = 41635, UnitID = "target", Caster = "player"},		-- 愈合祷言
		{AuraID = 25384, UnitID = "target", Caster = "player"},		-- 神圣之火
		{AuraID = 15487, UnitID = "target", Caster = "player"},		-- 沉默
		{AuraID = 25368, UnitID = "target", Caster = "player"},		-- 暗言术:痛
		{AuraID = 25467, UnitID = "target", Caster = "player"},		-- 噬灵瘟疫
		{AuraID = 10890, UnitID = "target", Caster = "player"},		-- 心灵尖啸
		{AuraID = 34914, UnitID = "target", Caster = "player"},		-- 吸血鬼之触
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 6346, UnitID = "player"},		-- 防恐结界
		{AuraID = 10060, UnitID = "player"},	-- 能量灌注
		{AuraID = 27827, UnitID = "player"},	-- 救赎之魂
		{AuraID = 25218, UnitID = "player"},	-- 真言术：盾
		{AuraID = 25222, UnitID = "player"},	-- 恢复
		{AuraID = 25429, UnitID = "player"},	-- 渐隐术
		{AuraID = 41635, UnitID = "player"},	-- 愈合祷言
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("PRIEST", list)