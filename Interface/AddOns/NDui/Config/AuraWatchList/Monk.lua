local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 武僧的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 119085, UnitID = "player"},	-- 真气突
		{AuraID = 101643, UnitID = "player"},	-- 魂体双分
		{AuraID = 202090, UnitID = "player"},	-- 禅院教诲
		{AuraID = 119611, UnitID = "player"},	-- 复苏之雾
		{AuraID = 195381, UnitID = "player"},	-- 治疗之风
		{AuraID = 213177, UnitID = "player"},	-- 利涉大川
		{AuraID = 199407, UnitID = "player"},	-- 脚步轻盈
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 115078, UnitID = "target", Caster = "player"},	-- 分筋错骨
		{AuraID = 116189, UnitID = "target", Caster = "player"},	-- 豪镇八方
		{AuraID = 115804, UnitID = "target", Caster = "player"},	-- 致死之伤
		{AuraID = 115080, UnitID = "target", Caster = "player"},	-- 轮回之触
		{AuraID = 123586, UnitID = "target", Caster = "player"},	-- 翔龙在天
		{AuraID = 116706, UnitID = "target", Caster = "player"},	-- 金刚震
		{AuraID = 205320, UnitID = "target", Caster = "player"},	-- 风领主之击
		{AuraID = 116841, UnitID = "target", Caster = "player"},	-- 迅如猛虎
		{AuraID = 119381, UnitID = "target", Caster = "player"},	-- 扫堂腿
		{AuraID = 116844, UnitID = "target", Caster = "player"},	-- 平心之环
		{AuraID = 121253, UnitID = "target", Caster = "player"},	-- 醉酿投
		{AuraID = 214326, UnitID = "target", Caster = "player"},	-- 爆炸酒桶
		{AuraID = 123725, UnitID = "target", Caster = "player"},	-- 火焰之息
		{AuraID = 116849, UnitID = "target", Caster = "player"},	-- 作茧缚命
		{AuraID = 119611, UnitID = "target", Caster = "player"},	-- 复苏之雾
		{AuraID = 191840, UnitID = "target", Caster = "player"},	-- 精华之泉
		{AuraID = 198909, UnitID = "target", Caster = "player"},	-- 赤精之歌
		{AuraID = 124682, UnitID = "target", Caster = "player"},	-- 氤氲之雾
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 125174, UnitID = "player"},	-- 业报之触
		{AuraID = 116768, UnitID = "player"},	-- 幻灭踢
		{AuraID = 137639, UnitID = "player"},	-- 风火雷电
		{AuraID = 122278, UnitID = "player"},	-- 躯不坏
		{AuraID = 122783, UnitID = "player"},	-- 散魔功
		{AuraID = 116844, UnitID = "player"},	-- 平心之环
		{AuraID = 152173, UnitID = "player"},	-- 屏气凝神
		{AuraID = 120954, UnitID = "player"},	-- 壮胆酒
		{AuraID = 243435, UnitID = "player"},	-- 壮胆酒
		{AuraID = 215479, UnitID = "player"},	-- 铁骨酒
		{AuraID = 214373, UnitID = "player"},	-- 酒有余香
		{AuraID = 199888, UnitID = "player"},	-- 神龙之雾
		{AuraID = 197206, UnitID = "player"},	-- 升腾状态
		{AuraID = 116680, UnitID = "player"},	-- 雷光茶
		{AuraID = 197908, UnitID = "player"},	-- 法力茶
		{AuraID = 196741, UnitID = "player"},	-- 连击
		{AuraID = 228563, UnitID = "player"},	-- 幻灭连击
		{AuraID = 197916, UnitID = "player"},	-- 生生不息
		{AuraID = 197919, UnitID = "player"},	-- 生生不息
		{AuraID = 116841, UnitID = "player"},	-- 迅如猛虎
		{AuraID = 195321, UnitID = "player"},	-- 转化力量
		{AuraID = 213341, UnitID = "player"},	-- 胆略
		{AuraID = 235054, UnitID = "player"},	-- 皇帝的容电皮甲
		{AuraID = 124682, UnitID = "player", Caster = "player"},	-- 氤氲之雾
		{AuraID = 261769, UnitID = "player"},	-- 铁布衫
		{AuraID = 195630, UnitID = "player"},	-- 醉拳大师
		{AuraID = 115295, UnitID = "player", Value = true},			-- 金钟罩
		{AuraID = 116847, UnitID = "player"},	-- 碧玉疾风
	},
	["Focus Aura"] = {		-- 焦点光环组
		{AuraID = 115078, UnitID = "focus", Caster = "player"},		-- 分筋错骨
		{AuraID = 119611, UnitID = "focus", Caster = "player"},	-- 复苏之雾
	},
	["Spell Cooldown"] = {	-- 冷却计时组
		{SlotID = 13, UnitID = "player"},		-- 饰品1
		{SlotID = 14, UnitID = "player"},		-- 饰品2
		{SpellID = 115203, UnitID = "player"},	-- 壮胆酒
	},
}

module:AddNewAuraWatch("MONK", list)