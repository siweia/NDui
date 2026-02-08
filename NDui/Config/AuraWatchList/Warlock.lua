local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "WARLOCK" then return end

-- 术士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 5697, UnitID = "player"},		-- 无尽呼吸
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 27228, UnitID = "target"},		-- 元素诅咒
		{AuraID = 710, UnitID = "target", Caster = "player"},		-- 放逐术
		{AuraID = 6215, UnitID = "target", Caster = "pet"},			-- 恐惧
		{AuraID = 6358, UnitID = "target", Caster = "pet"},			-- 魅惑
		{AuraID = 27223, UnitID = "target", Caster = "player"},		-- 死亡缠绕
		{AuraID = 17928, UnitID = "target", Caster = "player"},		-- 恐惧嚎叫
		{AuraID = 17877, UnitID = "target", Caster = "player"},		-- 暗影灼烧
		{AuraID = 27215, UnitID = "target", Caster = "player"},		-- 献祭
		{AuraID = 30910, UnitID = "target", Caster = "player"},		-- 厄运诅咒
		{AuraID = 27216, UnitID = "target", Caster = "player"},		-- 腐蚀术
		{AuraID = 27218, UnitID = "target", Caster = "player"},		-- 痛苦诅咒
		{AuraID = 30108, UnitID = "target", Caster = "player"},		-- 痛苦无常
		{AuraID = 27243, UnitID = "target", Caster = "player"},		-- 腐蚀之种
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 28610, UnitID = "pet"},		-- 防护暗影结界
		{AuraID = 47241, UnitID = "player"},		-- 恶魔变形
		{AuraID = 50589, UnitID = "player"},		-- 献祭光环
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("WARLOCK", list)