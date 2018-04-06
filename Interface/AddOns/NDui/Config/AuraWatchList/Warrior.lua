local B, C, L, DB = unpack(select(2, ...))

-- 战士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--胜利
		{AuraID = 32216, UnitID = "player"},
		--最后通牒
		{AuraID = 122510, UnitID = "player"},
		--投入战斗
		{AuraID = 202602, UnitID = "player"},
		--战争疤痕
		{AuraID = 200954, UnitID = "player"},
		--报复
		{AuraID = 202573, UnitID = "player"},
		{AuraID = 202574, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--嘲讽
		{AuraID = 355, UnitID = "target", Caster = "player"},
		--冲锋：定身
		{AuraID = 105771, UnitID = "target", Caster = "player"},
		--冲锋：昏迷
		{AuraID = 7922, UnitID = "target", Caster = "player"},
		--挫志怒吼
		{AuraID = 1160, UnitID = "target", Caster = "player"},
		--重伤
		{AuraID = 115767, UnitID = "target", Caster = "player"},
		--雷霆一击
		{AuraID = 6343, UnitID = "target", Caster = "player"},
		--风暴之锤
		{AuraID = 132169, UnitID = "target", Caster = "player"},
		--震荡波
		{AuraID = 132168, UnitID = "target", Caster = "player"},
		--刺耳怒吼
		{AuraID = 12323, UnitID = "target", Caster = "player"},
		--破胆
		{AuraID = 5246, UnitID = "target", Caster = "player"},
		--巨人打击
		{AuraID = 208086, UnitID = "target", Caster = "player"},
		--断筋
		{AuraID = 1715, UnitID = "target", Caster = "player"},
		--致死
		{AuraID = 115804, UnitID = "target", Caster = "player"},
		--撕裂
		{AuraID = 772, UnitID = "target", Caster = "player"},
	},
	["Special Aura"] = {	-- 玩家重要光环组
		--战吼
		{AuraID = 1719, UnitID = "player"},
		--无视痛苦
		{AuraID = 190456, UnitID = "player", Value = true},
		--维库之力
		{AuraID = 188783, UnitID = "player"},
		--法术反射
		{AuraID = 23920, UnitID = "player"},
		--狂暴之怒
		{AuraID = 18499, UnitID = "player"},
		--盾墙
		{AuraID = 871, UnitID = "player"},
		--怒火聚焦
		{AuraID = 204488, UnitID = "player"},
		{AuraID = 207982, UnitID = "player"},
		--破釜沉舟
		{AuraID = 12975, UnitID = "player"},
		--盾牌格挡
		{AuraID = 132404, UnitID = "player"},
		--狂暴复兴
		{AuraID = 202289, UnitID = "player"},
		--天神下凡
		{AuraID = 107574, UnitID = "player"},
		--腾跃步伐
		{AuraID = 202164, UnitID = "player"},
		--破坏者
		{AuraID = 152277, UnitID = "player"},
		--激怒
		{AuraID = 184362, UnitID = "player"},
		--狂暴
		{AuraID = 200953, UnitID = "player"},
		--血肉顺劈
		{AuraID = 85739, UnitID = "player"},
		--狂暴回复
		{AuraID = 184364, UnitID = "player"},
		--奥丁的勇士
		{AuraID = 200986, UnitID = "player"},
		--血腥气息
		{AuraID = 206333, UnitID = "player"},
		--摧拉枯朽
		{AuraID = 215570, UnitID = "player"},
		--狂暴冲锋
		{AuraID = 202225, UnitID = "player"},
		--暴乱狂战士
		{AuraID = 215572, UnitID = "player"},
		--剑刃风暴
		{AuraID = 46924, UnitID = "player"},
		--绞肉机
		{AuraID = 213284, UnitID = "player"},
		--狂乱
		{AuraID = 202539, UnitID = "player"},
		--巨龙怒吼
		{AuraID = 118000, UnitID = "player"},
		--粉碎防御
		{AuraID = 209706, UnitID = "player"},
		--顺劈斩
		{AuraID = 188923, UnitID = "player"},
		--防御姿态
		{AuraID = 197690, UnitID = "player"},
		--压制
		{AuraID = 60503, UnitID = "player"},
		--剑在人在
		{AuraID = 108038, UnitID = "player"},
		--主宰
		{AuraID = 201009, UnitID = "player"},
		--石之心（橙戒）
		{AuraID = 225947, UnitID = "player"},
		--浴血奋战
		{AuraID = 12292, UnitID = "player"},
		--龙鳞
		{AuraID = 203581, UnitID = "player"},
		--破坏者
		{AuraID = 227744, UnitID = "player"},
		--战术优势
		{AuraID = 209484, UnitID = "player"},
		--粉碎防御
		{AuraID = 248625, UnitID = "player"},
		--杀心骤起
		{AuraID = 248622, UnitID = "player"},
	},
	["Focus Aura"] = {		-- 焦点光环组
		--撕裂
		{AuraID = 772, UnitID = "focus", Caster = "player"},
		--重伤
		{AuraID = 115767, UnitID = "focus", Caster = "player"},
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		--饰品
		{SlotID = 13, UnitID = "player"},
		{SlotID = 14, UnitID = "player"},
		--盾墙
		{SpellID = 871, UnitID = "player"},
	},
}

C.AddNewAuraWatch("WARRIOR", list)