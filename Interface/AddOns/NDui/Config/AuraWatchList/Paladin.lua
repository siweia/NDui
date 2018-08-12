local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 圣骑士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 188370, UnitID = "player"},	-- 奉献
		{AuraID = 197561, UnitID = "player"},	-- 复仇者的勇气
		{AuraID = 269571, UnitID = "player"},	-- 狂热
		{AuraID = 114250, UnitID = "player"},	-- 无私自愈
		{AuraID = 281178, UnitID = "player"},	-- 愤怒之剑
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 853, UnitID = "target", Caster = "player"},		-- 制裁之锤
		{AuraID = 31935, UnitID = "target", Caster = "player"},		-- 复仇者之盾
		{AuraID = 53563, UnitID = "target", Caster = "player"},		-- 圣光道标
		{AuraID = 62124, UnitID = "target", Caster = "player"},		-- 清算之手
		{AuraID = 156910, UnitID = "target", Caster = "player"},	-- 信仰道标
		{AuraID = 183218, UnitID = "target", Caster = "player"},	-- 妨害之手
		{AuraID = 197277, UnitID = "target", Caster = "player"},	-- 审判
		{AuraID = 214222, UnitID = "target", Caster = "player"},	-- 审判
		{AuraID = 205273, UnitID = "target", Caster = "player"},	-- 灰烬觉醒
		{AuraID = 105421, UnitID = "target", Caster = "player"},	-- 盲目之光
		{AuraID = 200654, UnitID = "target", Caster = "player"},	-- 提尔的拯救
		{AuraID = 223306, UnitID = "target", Caster = "player"},	-- 赋予信仰
		{AuraID = 196941, UnitID = "target", Caster = "player"},	-- 圣光审判
		{AuraID = 209202, UnitID = "target", Caster = "player"},	-- 提尔之眼
		{AuraID = 204301, UnitID = "target", Caster = "player"},	-- 祝福之盾
		{AuraID = 204079, UnitID = "target", Caster = "player"},	-- 决一死战
		{AuraID = 267799, UnitID = "target", Caster = "player"},	-- 处决审判
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 498, UnitID = "player"},		-- 圣佑术
		{AuraID = 642, UnitID = "player"},		-- 圣盾术
		{AuraID = 31821, UnitID = "player"},	-- 光环掌握
		{AuraID = 31884, UnitID = "player"},	-- 复仇之怒
		{AuraID = 31850, UnitID = "player"},	-- 炽热防御者
		{AuraID = 54149, UnitID = "player"},	-- 圣光灌注
		{AuraID = 86659, UnitID = "player"},	-- 远古列王守卫
		{AuraID = 231895, UnitID = "player"},	-- 征伐
		{AuraID = 223819, UnitID = "player"},	-- 神圣意志
		{AuraID = 216413, UnitID = "player"},	-- 神圣意志
		{AuraID = 209785, UnitID = "player"},	-- 正义之火
		{AuraID = 217020, UnitID = "player"},	-- 狂热
		{AuraID = 205191, UnitID = "player"},	-- 以眼还眼
		{AuraID = 221885, UnitID = "player"},	-- 神圣马驹
		{AuraID = 200652, UnitID = "player"},	-- 提尔的拯救
		{AuraID = 214202, UnitID = "player"},	-- 律法之则
		{AuraID = 105809, UnitID = "player"},	-- 神圣复仇者
		{AuraID = 223316, UnitID = "player"},	-- 狂热殉道者
		{AuraID = 200025, UnitID = "player"},	-- 美德道标
		{AuraID = 132403, UnitID = "player"},	-- 正义盾击
		{AuraID = 152262, UnitID = "player"},	-- 炽天使
		{AuraID = 221883, UnitID = "player"},	-- 神圣马驹
		{AuraID = 184662, UnitID = "player", Value = true},	-- 复仇之盾
		{AuraID = 209388, UnitID = "player", Value = true},	-- 秩序堡垒
		{AuraID = 267611, UnitID = "player"},	-- 正义裁决
		{AuraID = 271581, UnitID = "player"},	-- 神圣审判
		{AuraID = 84963, UnitID = "player"},	-- 异端裁决
		{AuraID = 280375, UnitID = "player"},	-- 多面防御
		{AuraID = 216331, UnitID = "player"},	-- 复仇十字军
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 53563, UnitID = "focus", Caster = "player"},	-- 圣光道标
		{AuraID = 156910, UnitID = "focus", Caster = "player"},	-- 信仰道标
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13, UnitID = "player"},		-- 饰品1
		{SlotID = 14, UnitID = "player"},		-- 饰品2
		{SpellID = 31884, UnitID = "player"},	-- 复仇之怒
		{SpellID = 31842, UnitID = "player"},	-- 复仇之怒
		{SpellID = 31821, UnitID = "player"},	-- 光环掌握
	},
}

module:AddNewAuraWatch("PALADIN", list)