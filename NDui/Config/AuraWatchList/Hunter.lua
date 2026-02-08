local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "HUNTER" then return end

-- 猎人的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 1539, UnitID = "pet"},		-- 喂养宠物
		{AuraID = 3662, UnitID = "pet"},		-- 治疗宠物
		{AuraID = 5118, UnitID = "player"},		-- 猎豹守护
		{AuraID = 13161, UnitID = "player"},	-- 野兽守护
		{AuraID = 13163, UnitID = "player"},	-- 灵猴守护
		{AuraID = 27045, UnitID = "player"},	-- 野性守护
		{AuraID = 34074, UnitID = "player"},	-- 蝰蛇守护
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 14325, UnitID = "target"},	-- 猎人印记
		{AuraID = 1513, UnitID = "target", Caster = "player"},		-- 恐吓野兽
		{AuraID = 5116, UnitID = "target", Caster = "player"},		-- 震荡射击
		{AuraID = 27016, UnitID = "target", Caster = "player"},		-- 毒蛇钉刺
		--{AuraID = 27018, UnitID = "target", Caster = "player"},		-- 蝰蛇钉刺
		{AuraID = 19386, UnitID = "target", Caster = "player"},		-- 翼龙钉刺
		{AuraID = 14268, UnitID = "target", Caster = "player"},		-- 摔绊
		{AuraID = 13810, UnitID = "target", Caster = "player"},		-- 冰霜陷阱
		{AuraID = 14309, UnitID = "target", Caster = "player"},		-- 冰冻陷阱
		{AuraID = 27024, UnitID = "target", Caster = "player"},		-- 献祭陷阱
		{AuraID = 27026, UnitID = "target", Caster = "player"},		-- 爆炸陷阱
		{AuraID = 24394, UnitID = "target", Caster = "pet"},		-- 胁迫
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 3045, UnitID = "player"},		-- 急速射击
		{AuraID = 6150, UnitID = "player"},		-- 快速射击
		{AuraID = 19574, UnitID = "pet"},		-- 狂野怒火
		{AuraID = 19577, UnitID = "pet"},		-- 胁迫
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("HUNTER", list)