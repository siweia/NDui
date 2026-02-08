local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "WARRIOR" then return end

-- 战士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--{AuraID = 32216, UnitID = "player"},	-- 胜利
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 355, UnitID = "target", Caster = "player"},		-- 嘲讽
		{AuraID = 772, UnitID = "target", Caster = "player"},		-- 撕裂
		{AuraID = 1715, UnitID = "target", Caster = "player"},		-- 断筋
		{AuraID = 1160, UnitID = "target", Caster = "player"},		-- 挫志怒吼
		{AuraID = 6343, UnitID = "target", Caster = "player"},		-- 雷霆一击
		{AuraID = 5246, UnitID = "target", Caster = "player"},		-- 破胆
		{AuraID = 7922, UnitID = "target", Caster = "player"},		-- 冲锋：昏迷
		{AuraID = 12323, UnitID = "target", Caster = "player"},		-- 刺耳怒吼
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 871, UnitID = "player"},		-- 盾墙
		{AuraID = 1719, UnitID = "player"},		-- 战吼
		{AuraID = 7384, UnitID = "player"},		-- 压制
		{AuraID = 12975, UnitID = "player"},	-- 破釜沉舟
		{AuraID = 12292, UnitID = "player"},	-- 浴血奋战
		{AuraID = 23920, UnitID = "player"},	-- 法术反射
		{AuraID = 18499, UnitID = "player"},	-- 狂暴之怒
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("WARRIOR", list)