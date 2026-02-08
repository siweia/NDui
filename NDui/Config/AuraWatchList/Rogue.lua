local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "ROGUE" then return end

-- 盗贼的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 1784, UnitID = "player"},		-- 潜行
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
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 2983, UnitID = "player"},		-- 疾跑
		{AuraID = 5171, UnitID = "player"},		-- 切割
		{AuraID = 26669, UnitID = "player"},	-- 闪避
		{AuraID = 26888, UnitID = "player"},	-- 消失
		{AuraID = 13750, UnitID = "player"},	-- 冲动
		{AuraID = 13877, UnitID = "player"},	-- 剑刃乱舞
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
		{SpellID = 13750},	-- 冲动
	},
}

module:AddNewAuraWatch("ROGUE", list)