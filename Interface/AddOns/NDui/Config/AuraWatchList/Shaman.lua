local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("AurasTable")

-- 萨满的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--水上行走
		{AuraID = 546, UnitID = "player"},
		--风暴之鞭
		{AuraID = 195222, UnitID = "player"},
		--疾风
		{AuraID = 198293, UnitID = "player"},
		--空气之怒
		{AuraID = 197211, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--蒺藜
		{AuraID = 207778, UnitID = "target", Caster = "player"},
		--先祖活力
		{AuraID = 207400, UnitID = "target", Caster = "player"},
		--妖术
		{AuraID = 51514, UnitID = "target", Caster = "player"},
		{AuraID = 210873, UnitID = "target", Caster = "player"},
		{AuraID = 211004, UnitID = "target", Caster = "player"},
		{AuraID = 211010, UnitID = "target", Caster = "player"},
		{AuraID = 211015, UnitID = "target", Caster = "player"},
		--激流
		{AuraID = 61295, UnitID = "target", Caster = "player"},
		--烈焰震击
		{AuraID = 188838, UnitID = "target", Caster = "player"},
		{AuraID = 188389, UnitID = "target", Caster = "player"},
		--闪电奔涌图腾
		{AuraID = 118905, UnitID = "target", Caster = "player"},
		--大地之刺
		{AuraID = 188089, UnitID = "target", Caster = "player"},
		--避雷针
		{AuraID = 197209, UnitID = "target", Caster = "player"},
		--冰霜震击
		{AuraID = 196840, UnitID = "target", Caster = "player"},
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--十万火急
		{AuraID = 208416, UnitID = "player"},
		--迷雾幽灵
		{AuraID = 207527, UnitID = "player"},
		--治疗之雨
		{AuraID = 73920, UnitID = "player"},
		--潮汐奔涌
		{AuraID = 53390, UnitID = "player"},
		--女王的祝福
		{AuraID = 207288, UnitID = "player"},
		--灵魂行者的恩赐
		{AuraID = 79206, UnitID = "player"},
		--生命释放
		{AuraID = 73685, UnitID = "player"},
		--波动
		{AuraID = 216251, UnitID = "player"},
		--先祖指引
		{AuraID = 108281, UnitID = "player"},
		--升腾
		{AuraID = 114050, UnitID = "player"}, --元素
		{AuraID = 114051, UnitID = "player"}, --增强
		{AuraID = 114052, UnitID = "player"}, --恢复
		--幽魂步
		{AuraID = 58875, UnitID = "player"},
		--星界转移
		{AuraID = 108271, UnitID = "player"},
		--毁灭之风
		{AuraID = 204945, UnitID = "player"},
		--集束风暴
		{AuraID = 198300, UnitID = "player"},
		--风暴使者
		{AuraID = 201846, UnitID = "player"},
		--火舌
		{AuraID = 194084, UnitID = "player"},
		--冰封
		{AuraID = 196834, UnitID = "player"},
		--毁灭释放
		{AuraID = 199055, UnitID = "player"},
		--风歌
		{AuraID = 201898, UnitID = "player"},
		--灼热之手
		{AuraID = 215785, UnitID = "player"},
		--降雨
		{AuraID = 215864, UnitID = "player"},
		--元素集中
		{AuraID = 16246, UnitID = "player"},
		--熔岩奔腾
		{AuraID = 77762, UnitID = "player"},
		--漩涡之力
		{AuraID = 191877, UnitID = "player"},
		--风暴守护者
		{AuraID = 205495, UnitID = "player"},
		--元素冲击
		{AuraID = 118522, UnitID = "player"}, --爆击
		{AuraID = 173183, UnitID = "player"}, --急速
		{AuraID = 173184, UnitID = "player"}, --精通
		--冰怒
		{AuraID = 210714, UnitID = "player"},
		--暴雨图腾
		{AuraID = 157504, UnitID = "player", Value = true},
	},
	["Focus Aura"] = {		-- 焦点光环组
		--妖术
		{AuraID = 51514, UnitID = "focus", Caster = "player"},
		{AuraID = 210873, UnitID = "focus", Caster = "player"},
		{AuraID = 211004, UnitID = "focus", Caster = "player"},
		{AuraID = 211010, UnitID = "focus", Caster = "player"},
		{AuraID = 211015, UnitID = "focus", Caster = "player"},
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		--饰品
		{SlotID = 13, UnitID = "player"},
		{SlotID = 14, UnitID = "player"},
		--复生
		{SpellID = 20608, UnitID = "player"},
		--升腾
		{SpellID = 114050, UnitID = "player"},
		{SpellID = 114051, UnitID = "player"},
		{SpellID = 114052, UnitID = "player"},
		--治疗之潮
		{SpellID = 108280, UnitID = "player"},
		--灵魂链接
		{SpellID = 98008, UnitID = "player"},
		--野性狼魂
		{SpellID = 198506, UnitID = "player"},
	},
}

module:AddNewAuraWatch("SHAMAN", list)