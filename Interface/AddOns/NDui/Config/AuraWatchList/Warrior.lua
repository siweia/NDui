local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 战士的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 32216, UnitID = "player"},	-- 胜利
		{AuraID = 202602, UnitID = "player"},	-- 投入战斗
		{AuraID = 200954, UnitID = "player"},	-- 战争疤痕
		{AuraID = 202573, UnitID = "player"},	-- 报复
		{AuraID = 202574, UnitID = "player"},	-- 报复
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 355, UnitID = "target", Caster = "player"},		-- 嘲讽
		{AuraID = 772, UnitID = "target", Caster = "player"},		-- 撕裂
		{AuraID = 1715, UnitID = "target", Caster = "player"},		-- 断筋
		{AuraID = 1160, UnitID = "target", Caster = "player"},		-- 挫志怒吼
		{AuraID = 6343, UnitID = "target", Caster = "player"},		-- 雷霆一击
		{AuraID = 5246, UnitID = "target", Caster = "player"},		-- 破胆
		{AuraID = 7922, UnitID = "target", Caster = "player"},		-- 冲锋：昏迷
		{AuraID = 12323, UnitID = "target", Caster = "player"},		-- 刺耳怒吼
		{AuraID = 105771, UnitID = "target", Caster = "player"},	-- 冲锋：定身
		{AuraID = 115767, UnitID = "target", Caster = "player"},	-- 重伤
		{AuraID = 132169, UnitID = "target", Caster = "player"},	-- 风暴之锤
		{AuraID = 132168, UnitID = "target", Caster = "player"},	-- 震荡波
		{AuraID = 208086, UnitID = "target", Caster = "player"},	-- 巨人打击
		{AuraID = 115804, UnitID = "target", Caster = "player"},	-- 致死
		{AuraID = 280773, UnitID = "target", Caster = "player"},	-- 破城者
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 871, UnitID = "player"},		-- 盾墙
		{AuraID = 1719, UnitID = "player"},		-- 战吼
		{AuraID = 7384, UnitID = "player"},		-- 压制
		{AuraID = 12975, UnitID = "player"},	-- 破釜沉舟
		{AuraID = 85739, UnitID = "player"},	-- 血肉顺劈
		{AuraID = 46924, UnitID = "player"},	-- 剑刃风暴
		{AuraID = 227847, UnitID = "player"},	-- 剑刃风暴
		{AuraID = 12292, UnitID = "player"},	-- 浴血奋战
		{AuraID = 23920, UnitID = "player"},	-- 法术反射
		{AuraID = 18499, UnitID = "player"},	-- 狂暴之怒
		{AuraID = 52437, UnitID = "player"},	-- 猝死
		{AuraID = 188783, UnitID = "player"},	-- 维库之力
		{AuraID = 207982, UnitID = "player"},	-- 怒火聚焦
		{AuraID = 132404, UnitID = "player"},	-- 盾牌格挡
		{AuraID = 202289, UnitID = "player"},	-- 狂暴复兴
		{AuraID = 107574, UnitID = "player"},	-- 天神下凡
		{AuraID = 202164, UnitID = "player"},	-- 腾跃步伐
		{AuraID = 152277, UnitID = "player"},	-- 破坏者
		{AuraID = 184362, UnitID = "player"},	-- 激怒
		{AuraID = 200953, UnitID = "player"},	-- 狂暴
		{AuraID = 184364, UnitID = "player"},	-- 狂暴回复
		{AuraID = 200986, UnitID = "player"},	-- 奥丁的勇士
		{AuraID = 206333, UnitID = "player"},	-- 血腥气息
		{AuraID = 215570, UnitID = "player"},	-- 摧拉枯朽
		{AuraID = 202225, UnitID = "player"},	-- 狂暴冲锋
		{AuraID = 215572, UnitID = "player"},	-- 暴乱狂战士
		{AuraID = 213284, UnitID = "player"},	-- 绞肉机
		{AuraID = 202539, UnitID = "player"},	-- 狂乱
		{AuraID = 118000, UnitID = "player"},	-- 巨龙怒吼
		{AuraID = 209706, UnitID = "player"},	-- 粉碎防御
		{AuraID = 188923, UnitID = "player"},	-- 顺劈斩
		{AuraID = 197690, UnitID = "player"},	-- 防御姿态
		{AuraID = 118038, UnitID = "player"},	-- 剑在人在
		{AuraID = 201009, UnitID = "player"},	-- 主宰
		{AuraID = 225947, UnitID = "player"},	-- 石之心（橙戒）
		{AuraID = 203581, UnitID = "player"},	-- 龙鳞
		{AuraID = 227744, UnitID = "player"},	-- 破坏者
		{AuraID = 209484, UnitID = "player"},	-- 战术优势
		{AuraID = 248625, UnitID = "player"},	-- 粉碎防御
		{AuraID = 248622, UnitID = "player"},	-- 杀心骤起
		{AuraID = 190456, UnitID = "player", Value = true},	-- 无视痛苦
		{AuraID = 260708, UnitID = "player"},	-- 横扫攻击
		{AuraID = 262228, UnitID = "player"},	-- 致命平静
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 772, UnitID = "focus", Caster = "player"},	-- 撕裂
		{AuraID = 115767, UnitID = "focus", Caster = "player"},	-- 重伤
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13},		-- 饰品1
		{SlotID = 14},		-- 饰品2
	},
}

module:AddNewAuraWatch("WARRIOR", list)