local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 法师的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 130, UnitID = "player"},		-- 缓落
		{AuraID = 32612, UnitID = "player"},	-- 隐形术
		{AuraID = 87023, UnitID = "player"},	-- 灸灼
		{AuraID = 11426, UnitID = "player"},	-- 寒冰护体
		{AuraID = 235313, UnitID = "player"},	-- 烈焰护体
		{AuraID = 235450, UnitID = "player"},	-- 棱光屏障
		{AuraID = 110960, UnitID = "player"},	-- 强化隐形术
		{AuraID = 157644, UnitID = "player"},	-- 强化烟火之术
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 118, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 122, UnitID = "target", Caster = "player"},		-- 冰霜新星
		{AuraID = 12654, UnitID = "target", Caster = "player"},		-- 点燃
		{AuraID = 11366, UnitID = "target", Caster = "player"},		-- 炎爆术
		{AuraID = 31661, UnitID = "target", Caster = "player"},		-- 龙息术
		{AuraID = 82691, UnitID = "target", Caster = "player"},		-- 冰霜之环
		{AuraID = 31589, UnitID = "target", Caster = "player"},		-- 减速
		{AuraID = 33395, UnitID = "target", Caster = "pet"},		-- 冰冻术
		{AuraID = 28271, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 28272, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 61305, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 61721, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 61780, UnitID = "target", Caster = "player"},		-- 变形术
		{AuraID = 126819, UnitID = "target", Caster = "player"},	-- 变形术
		{AuraID = 161353, UnitID = "target", Caster = "player"},	-- 变形术
		{AuraID = 161354, UnitID = "target", Caster = "player"},	-- 变形术
		{AuraID = 161355, UnitID = "target", Caster = "player"},	-- 变形术
		{AuraID = 161372, UnitID = "target", Caster = "player"},	-- 变形术
		{AuraID = 157981, UnitID = "target", Caster = "player"},	-- 冲击波
		{AuraID = 217694, UnitID = "target", Caster = "player"},	-- 活动炸弹
		{AuraID = 114923, UnitID = "target", Caster = "player"},	-- 虚空风暴
		{AuraID = 205708, UnitID = "target", Caster = "player"},	-- 寒冰箭
		{AuraID = 212792, UnitID = "target", Caster = "player"},	-- 冰锥术
		{AuraID = 157997, UnitID = "target", Caster = "player"},	-- 寒冰新星
		{AuraID = 210134, UnitID = "target", Caster = "player"},	-- 奥术侵蚀
		{AuraID = 199786, UnitID = "target", Caster = "player"},	-- 冰川尖刺
		{AuraID = 210824, UnitID = "target", Caster = "player"},	-- 大法师之触
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 66, UnitID = "player"},		-- 隐形术
		{AuraID = 45438, UnitID = "player"},	-- 寒冰屏障
		{AuraID = 36032, UnitID = "player"},	-- 奥术充能
		{AuraID = 12042, UnitID = "player"},	-- 奥术强化
		{AuraID = 12472, UnitID = "player"},	-- 冰冷血脉
		{AuraID = 44544, UnitID = "player"},	-- 寒冰指
		{AuraID = 48108, UnitID = "player"},	-- 炎爆术！
		{AuraID = 48107, UnitID = "player"},	-- 热力迸发
		{AuraID = 157913, UnitID = "player"},	-- 隐没
		{AuraID = 108843, UnitID = "player"},	-- 炽热疾速
		{AuraID = 116267, UnitID = "player"},	-- 咒术洪流
		{AuraID = 116014, UnitID = "player"},	-- 能量符文
		{AuraID = 108839, UnitID = "player"},	-- 浮冰
		{AuraID = 205025, UnitID = "player"},	-- 气定神闲
		{AuraID = 113862, UnitID = "player"},	-- 强化隐形术
		{AuraID = 194329, UnitID = "player"},	-- 炽烈之咒
		{AuraID = 190319, UnitID = "player"},	-- 燃烧
		{AuraID = 212799, UnitID = "player"},	-- 置换
		{AuraID = 198924, UnitID = "player"},	-- 加速
		{AuraID = 205473, UnitID = "player"},	-- 冰刺
		{AuraID = 205766, UnitID = "player"},	-- 刺骨冰寒
		{AuraID = 209455, UnitID = "player"},	-- 凯尔萨斯的绝招，抱歉护腕
		{AuraID = 263725, UnitID = "player"},	-- 节能施法
		{AuraID = 264774, UnitID = "player"},	-- 三之准则
		{AuraID = 269651, UnitID = "player"},	-- 火焰冲撞
		{AuraID = 190446, UnitID = "player"},	-- 冰冷智慧
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 44457, UnitID = "focus", Caster = "player"},	-- 活动炸弹
		{AuraID = 114923, UnitID = "focus", Caster = "player"},	-- 虚空风暴
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13, UnitID = "player"},		-- 饰品1
		{SlotID = 14, UnitID = "player"},		-- 饰品2
		{TotemID = 1, UnitID = "player"},		-- 能量符文
		{SpellID = 12472, UnitID = "player"},	-- 冰冷血脉
		{SpellID = 12042, UnitID = "player"},	-- 奥术强化
		{SpellID = 190319, UnitID = "player"},	-- 燃烧
	},
}

module:AddNewAuraWatch("MAGE", list)