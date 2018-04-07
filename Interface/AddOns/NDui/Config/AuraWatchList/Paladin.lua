local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("AurasTable")

-- 圣骑士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--奉献
		{AuraID = 188370, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--圣光道标
		{AuraID = 53563, UnitID = "target", Caster = "player"},
		--信仰道标
		{AuraID = 156910, UnitID = "target", Caster = "player"},
		--制裁之锤
		{AuraID = 853, UnitID = "target", Caster = "player"},
		--妨害之手
		{AuraID = 183218, UnitID = "target", Caster = "player"},
		--审判
		{AuraID = 197277, UnitID = "target", Caster = "player"},
		{AuraID = 214222, UnitID = "target", Caster = "player"},
		--清算之手
		{AuraID = 62124, UnitID = "target", Caster = "player"},
		--灰烬觉醒
		{AuraID = 205273, UnitID = "target", Caster = "player"},
		--盲目之光
		{AuraID = 105421, UnitID = "target", Caster = "player"},
		--提尔的拯救
		{AuraID = 200654, UnitID = "target", Caster = "player"},
		--赋予信仰
		{AuraID = 223306, UnitID = "target", Caster = "player"},
		--圣光审判
		{AuraID = 196941, UnitID = "target", Caster = "player"},
		--提尔之眼
		{AuraID = 209202, UnitID = "target", Caster = "player"},
		--复仇者之盾
		{AuraID = 31935, UnitID = "target", Caster = "player"},
		--祝福之盾
		{AuraID = 204301, UnitID = "target", Caster = "player"},
		--决一死战
		{AuraID = 204079, UnitID = "target", Caster = "player"},
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--圣盾术
		{AuraID = 642, UnitID = "player"},
		--复仇之怒
		{AuraID = 31884, UnitID = "player"},
		{AuraID = 31842, UnitID = "player"},
		--征伐
		{AuraID = 231895, UnitID = "player"},
		--神圣意志
		{AuraID = 223819, UnitID = "player"},
		{AuraID = 216413, UnitID = "player"},
		--复仇之盾
		{AuraID = 184662, UnitID = "player", Value = true},
		--正义之火
		{AuraID = 209785, UnitID = "player"},
		--狂热
		{AuraID = 217020, UnitID = "player"},
		--以眼还眼
		{AuraID = 205191, UnitID = "player"},
		--圣洁怒火
		{AuraID = 224668, UnitID = "player"},
		--神圣马驹
		{AuraID = 221885, UnitID = "player"},
		--光环掌握
		{AuraID = 31821, UnitID = "player"},
		--圣佑术
		{AuraID = 498, UnitID = "player"},
		--提尔的拯救
		{AuraID = 200652, UnitID = "player"},
		--律法之则
		{AuraID = 214202, UnitID = "player"},
		--圣光灌注
		{AuraID = 54149, UnitID = "player"},
		--神圣复仇者
		{AuraID = 105809, UnitID = "player"},
		--狂热殉道者
		{AuraID = 223316, UnitID = "player"},
		--美德道标
		{AuraID = 200025, UnitID = "player"},
		--正义盾击
		{AuraID = 132403, UnitID = "player"},
		--炽热防御者
		{AuraID = 31850, UnitID = "player"},
		--远古列王守卫
		{AuraID = 86659, UnitID = "player"},
		--秩序堡垒
		{AuraID = 209388, UnitID = "player", Value = true},
		--炽天使
		{AuraID = 152262, UnitID = "player"},
		--神圣马驹
		{AuraID = 221883, UnitID = "player"},
		--正义裁决
		{AuraID = 238996, UnitID = "player"},
	},
	["Focus Aura"] = {		-- 焦点光环组
		--圣光道标
		{AuraID = 53563, UnitID = "focus", Caster = "player"},
		--信仰道标
		{AuraID = 156910, UnitID = "focus", Caster = "player"},
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		--饰品
		{SlotID = 13, UnitID = "player"},
		{SlotID = 14, UnitID = "player"},
		--复仇之怒
		{SpellID = 31884, UnitID = "player"},
		{SpellID = 31842, UnitID = "player"},
		--光环掌握
		{SpellID = 31821, UnitID = "player"},
	},
}

module:AddNewAuraWatch("PALADIN", list)