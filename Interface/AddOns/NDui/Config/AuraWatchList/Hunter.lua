local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "HUNTER" then return end

-- 猎人的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 1539, UnitID = "pet"},		-- 喂养宠物
		{AuraID = 5118, UnitID = "player"},		-- 猎豹守护
		{AuraID = 34477, UnitID = "player"},	-- 误导
		{AuraID = 35079, UnitID = "player"},	-- 误导
		{AuraID = 53257, UnitID = "player"},	-- 眼镜蛇打击
		{AuraID = 82925, UnitID = "player"},	-- 准备,端枪,瞄准
		{AuraID = 77769, UnitID = "player"},	-- 陷阱发射器
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 1130, UnitID = "target"}, -- 猎人印记
		{AuraID = 1513, UnitID = "target", Caster = "player"},		-- 恐吓野兽
		{AuraID = 1978, UnitID = "target", Caster = "player"},		-- 毒蛇钉刺
		{AuraID = 19503, UnitID = "target", Caster = "player"},		-- 驱散射击
		{AuraID = 5116, UnitID = "target", Caster = "player"},		-- 震荡射击
		{AuraID = 3674, UnitID = "target", Caster = "player"},		-- 黑箭
		{AuraID = 19386, UnitID = "target", Caster = "player"},		-- 翼龙钉刺
		{AuraID = 14268, UnitID = "target", Caster = "player"},		-- 摔绊
		{AuraID = 13810, UnitID = "target", Caster = "player"},		-- 冰霜陷阱
		{AuraID = 82654, UnitID = "target", Caster = "player"},		-- 蜘蛛毒刺
		{AuraID = 5116, UnitID = "target", Caster = "player"},		-- 晕眩
		{AuraID = 20736, UnitID = "target", Caster = "player"},		-- 扰乱射击
		{AuraID = 24394, UnitID = "target", Caster = "pet"},		-- 胁迫
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 3045, UnitID = "player"},		-- 急速射击
		{AuraID = 34471, UnitID = "player"},	-- 野兽之心
		{AuraID = 6150, UnitID = "player"},		-- 快速射击
		{AuraID = 19577, UnitID = "player"},	-- 胁迫
		{AuraID = 53220, UnitID = "player"},	-- 强化稳固射击
		{AuraID = 56453, UnitID = "player"},	-- 荷枪实弹
		{AuraID = 82921, UnitID = "player"},	-- 狂轰滥炸
		{AuraID = 19263, UnitID = "player"},	-- 威慑
		{AuraID = 64420, UnitID = "player"},	-- 狙击训练
		{AuraID = 82926, UnitID = "player", Flash = true},	-- 开火
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("HUNTER", list)