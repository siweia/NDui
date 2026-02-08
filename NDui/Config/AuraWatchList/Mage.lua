local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "MAGE" then return end

-- 法师的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 130, UnitID = "player"},		-- 缓落
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 116, UnitID = "target", Caster = "player"},		-- 寒冰箭
		{AuraID = 118, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 122, UnitID = "target", Caster = "player"},		-- 冰霜新星
		{AuraID = 12654, UnitID = "target", Caster = "player"},		-- 点燃
		{AuraID = 11366, UnitID = "target", Caster = "player"},		-- 炎爆术
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 66, UnitID = "player"},		-- 隐形术
		{AuraID = 27131, UnitID = "player"},	-- 法力护盾
		{AuraID = 27128, UnitID = "player"},	-- 防护火焰结界
		{AuraID = 32796, UnitID = "player"},	-- 防护冰霜结界
		{AuraID = 45438, UnitID = "player"},	-- 寒冰屏障
		{AuraID = 11129, UnitID = "player"},	-- 燃烧
		{AuraID = 12042, UnitID = "player"},	-- 奥术强化
		{AuraID = 12472, UnitID = "player"},	-- 冰冷血脉
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("MAGE", list)