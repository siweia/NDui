local B, C, L, DB = unpack(select(2, ...))

-- 德鲁伊的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--潜行
		{AuraID = 5215, UnitID = "player"},
		--急奔
		{AuraID = 1850, UnitID = "player"},
		--野性位移
		{AuraID = 137452, UnitID = "player"},
		--回春术
		{AuraID = 774, UnitID = "player"},
		--萌芽
		{AuraID = 155777, UnitID = "player"},
		--愈合
		{AuraID = 8936, UnitID = "player"},
		--生命绽放
		{AuraID = 33763, UnitID = "player"},
		--野性成长
		{AuraID = 48438, UnitID = "player"},
		--野性冲锋：泳速
		{AuraID = 102416, UnitID = "player"},
		--塞纳里奥结界
		{AuraID = 102351, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--低吼
		{AuraID = 6795, UnitID = "target", Caster = "player"},
		--斜掠
		{AuraID = 155722, UnitID = "target", Caster = "player"},
		--割碎
		{AuraID = 203123, UnitID = "target", Caster = "player"},
		--割裂
		{AuraID = 1079, UnitID = "target", Caster = "player"},
		--痛击
		{AuraID = 106830, UnitID = "target", Caster = "player"},
		{AuraID = 192090, UnitID = "target", Caster = "player"},
		--月火术
		{AuraID = 164812, UnitID = "target", Caster = "player"},
		{AuraID = 155625, UnitID = "target", Caster = "player"},
		--阳炎术
		{AuraID = 164815, UnitID = "target", Caster = "player"},
		--纠缠根须
		{AuraID = 339, UnitID = "target", Caster = "player"},
		--野性冲锋：晕眩
		{AuraID = 50259, UnitID = "target", Caster = "player"},
		--野性冲锋：定身
		{AuraID = 45334, UnitID = "target", Caster = "player"},
		--回春术
		{AuraID = 774, UnitID = "target", Caster = "player"},
		--愈合
		{AuraID = 8936, UnitID = "target", Caster = "player"},
		--群体缠绕
		{AuraID = 102359, UnitID = "target", Caster = "player"},
		--蛮力猛击
		{AuraID = 5211, UnitID = "target", Caster = "player"},
		--台风
		{AuraID = 61391, UnitID = "target", Caster = "player"},
		--星界增效
		{AuraID = 197637, UnitID = "target", Caster = "player"},
		--日光术
		{AuraID = 81261, UnitID = "target", Caster = "player"},
		--星辰耀斑
		{AuraID = 202347, UnitID = "target", Caster = "player"},
		--夺魂咆哮
		{AuraID = 99, UnitID = "target", Caster = "player"},
		--乌索尔旋风
		{AuraID = 127797, UnitID = "target", Caster = "player"},
		--加尼尔的精华
		{AuraID = 208253, UnitID = "target", Caster = "player"},
		--生命绽放
		{AuraID = 33763, UnitID = "target", Caster = "player"},
		--野性成长
		{AuraID = 48438, UnitID = "target", Caster = "player"},
		--萌芽
		{AuraID = 155777, UnitID = "target", Caster = "player"},
		--铁木树皮
		{AuraID = 102342, UnitID = "target", Caster = "player"},
		--塞纳里奥结界
		{AuraID = 102351, UnitID = "target", Caster = "player"},
		--栽培
		{AuraID = 200389, UnitID = "target", Caster = "player"},
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--节能施法
		{AuraID = 135700, UnitID = "player"},
		{AuraID = 16870, UnitID = "player"},
		--猛虎之怒
		{AuraID = 5217, UnitID = "player"},
		--掠食者的迅捷
		{AuraID = 69369, UnitID = "player"},
		--狂暴
		{AuraID = 106951, UnitID = "player"},
		--野性本能
		{AuraID = 210649, UnitID = "player"},
		--生存本能
		{AuraID = 61336, UnitID = "player"},
		--狂暴回复
		{AuraID = 22842, UnitID = "player"},
		--铁鬃
		{AuraID = 192081, UnitID = "player"},
		--野蛮咆哮
		{AuraID = 52610, UnitID = "player"},
		--化身
		{AuraID = 102560, UnitID = "player"},
		{AuraID = 117679, UnitID = "player"},
		{AuraID = 102558, UnitID = "player"},
		{AuraID = 102543, UnitID = "player"},
		--血腥爪击
		{AuraID = 145152, UnitID = "player"},
		--星辰坠落
		{AuraID = 191034, UnitID = "player"},
		--树皮术
		{AuraID = 22812, UnitID = "player"},
		--超凡之盟
		{AuraID = 194223, UnitID = "player"},
		--沉睡者之怒
		{AuraID = 200851, UnitID = "player"},
		--血污毛皮
		{AuraID = 201671, UnitID = "player", Combat = true},
		--裂伤
		{AuraID = 93622, UnitID = "player"},
		--粉碎
		{AuraID = 158792, UnitID = "player"},
		--星河守护者
		{AuraID = 213708, UnitID = "player"},
		--大地守卫者
		{AuraID = 203975, UnitID = "player", Combat = true},
		--艾露恩的卫士
		{AuraID = 213680, UnitID = "player"},
		--鬃毛倒竖
		{AuraID = 155835, UnitID = "player"},
		--丛林之魂
		{AuraID = 114108, UnitID = "player"},
		--丰饶
		{AuraID = 207640, UnitID = "player"},
		--日光增效
		{AuraID = 164545, UnitID = "player"},
		--月光增效
		{AuraID = 164547, UnitID = "player"},
		--艾露恩的战士
		{AuraID = 202425, UnitID = "player"},
		--星界和谐，奶德2T19
		{AuraID = 232378, UnitID = "player"},
		--加尼尔的精华，奶德神器
		{AuraID = 208253, UnitID = "player"},
		--枭兽狂乱
		{AuraID = 157228, UnitID = "player"},
		--翡翠捕梦者
		{AuraID = 224706, UnitID = "player"},
		--星界加速
		{AuraID = 242232, UnitID = "player"},
		--欧奈斯的直觉
		{AuraID = 209406, UnitID = "player"},
		--欧奈斯的自负
		{AuraID = 209407, UnitID = "player"},
		--T21
		{AuraID = 252752, UnitID = "player"}, --野德
		{AuraID = 253434, UnitID = "player"}, --奶德
		{AuraID = 252767, UnitID = "player"}, --鸟德
		{AuraID = 253575, UnitID = "player"}, --熊德
	},
	["Focus Aura"] = {		-- 焦点光环组
		--月火术
		{AuraID = 164812, UnitID = "focus", Caster = "player"},
		--阳炎术
		{AuraID = 164815, UnitID = "focus", Caster = "player"},
		--星辰耀斑
		{AuraID = 202347, UnitID = "focus", Caster = "player"},
		--生命绽放
		{AuraID = 33763, UnitID = "focus", Caster = "player"},
		--回春术
		{AuraID = 774, UnitID = "focus", Caster = "player"},
		--愈合
		{AuraID = 8936, UnitID = "focus", Caster = "player"},
		--萌芽
		{AuraID = 155777, UnitID = "focus", Caster = "player"},
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		--饰品
		{SlotID = 13, UnitID = "player"},
		{SlotID = 14, UnitID = "player"},
		--蘑菇
		{TotemID = 1, UnitID = "player"},
		--生存本能
		{SpellID = 61336, UnitID = "player"},
	},
}

C.AddNewAuraWatch("DRUID", list)