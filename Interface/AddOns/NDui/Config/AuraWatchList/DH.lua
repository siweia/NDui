local B, C, L, DB = unpack(select(2, ...))

-- DH的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--灵魂盛宴
		{AuraID = 207693, UnitID = "player"},
		--献祭光环
		{AuraID = 178740, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--复仇回避
		{AuraID = 198813, UnitID = "target", Caster = "player"},
		--混乱新星
		{AuraID = 179057, UnitID = "target", Caster = "player"},
		--血滴子
		{AuraID = 207690, UnitID = "target", Caster = "player"},
		--涅墨西斯
		{AuraID = 206491, UnitID = "target", Caster = "player"},
		--战刃大师
		{AuraID = 213405, UnitID = "target", Caster = "player"},
		--折磨
		{AuraID = 185245, UnitID = "target", Caster = "player"},
		--沉默咒符
		{AuraID = 204490, UnitID = "target", Caster = "player"},
		--烈焰咒符
		{AuraID = 204598, UnitID = "target", Caster = "player"},
		--锁链咒符
		{AuraID = 204843, UnitID = "target", Caster = "player"},
		--灵魂切削
		{AuraID = 207407, UnitID = "target", Caster = "player"},
		--烈火烙印
		{AuraID = 207744, UnitID = "target", Caster = "player"},
		{AuraID = 207771, UnitID = "target", Caster = "player"},
		--幽魂炸弹
		{AuraID = 224509, UnitID = "target", Caster = "player"},
		--锋锐之刺
		{AuraID = 210003, UnitID = "target", Caster = "player"},
		--悲苦咒符
		{AuraID = 207685, UnitID = "target", Caster = "player"},
		--邪能爆发
		{AuraID = 211881, UnitID = "target", Caster = "player"},
		--脆弱
		{AuraID = 247456, UnitID = "target", Caster = "player"},
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--恶魔变形
		{AuraID = 162264, UnitID = "player"},
		{AuraID = 187827, UnitID = "player"},
		--幽灵视觉
		{AuraID = 188501, UnitID = "player"},
		--疾影
		{AuraID = 212800, UnitID = "player"},
		--准备就绪
		{AuraID = 203650, UnitID = "player"},
		--虚空行走
		{AuraID = 196555, UnitID = "player"},
		--势如破竹
		{AuraID = 208628, UnitID = "player"},
		--混乱之刃
		{AuraID = 247938, UnitID = "player"},
		--刃舞
		{AuraID = 188499, UnitID = "player"},
		{AuraID = 210152, UnitID = "player"},
		--强化结界
		{AuraID = 218256, UnitID = "player"},
		--灵魂盛宴
		{AuraID = 207693, UnitID = "player"},
		--恶魔尖刺
		{AuraID = 203819, UnitID = "player"},
		--痛苦使者
		{AuraID = 212988, UnitID = "player"},
		--灵魂屏障
		{AuraID = 227225, UnitID = "player", Value = true},
		--虹吸能量
		{AuraID = 218561, UnitID = "player", Value = true},
		--涅墨西斯
		{AuraID = 208579, UnitID = "player"},
		{AuraID = 208605, UnitID = "player"},
		{AuraID = 208607, UnitID = "player"},
		{AuraID = 208608, UnitID = "player"},
		{AuraID = 208609, UnitID = "player"},
		{AuraID = 208610, UnitID = "player"},
		{AuraID = 208611, UnitID = "player"},
		{AuraID = 208612, UnitID = "player"},
		{AuraID = 208613, UnitID = "player"},
		{AuraID = 208614, UnitID = "player"},
		--剑刃扭转
		{AuraID = 247253, UnitID = "player"},
		--浩劫T21
		{AuraID = 252165, UnitID = "player"},
		--无尽吸血
		{AuraID = 216758, UnitID = "player"},
	},
	["Focus Aura"] = {		-- 焦点光环组
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		--饰品
		{SlotID = 13, UnitID = "player"},
		{SlotID = 14, UnitID = "player"},
		--恶魔变形
		{SpellID = 191427, UnitID = "player"},
		{SpellID = 187827, UnitID = "player"},
	},
}

C.AddNewAuraWatch("DEMONHUNTER", list)