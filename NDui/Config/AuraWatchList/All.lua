local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")
--[[
	>>>自定义添加时，要注意格式，注意逗号，注意字母大小写<<<
	ALL下面是对全职业通用的设置，其他情况请在自己职业下添加。当你添加时，要注意是否重复。
	各组别分别代表的是：
		Player Aura，是自己头像上偏小的buff组，用来监视那些不那么重要的buff；
		Special Aura，是自己头像上偏大的buff组，用来监视稍微重要的buff；
		Target Aura，是目标头像上的buff组，用来监视你循环中需要的debuff；
		Focus Aura，是焦点的buff组，用来监视焦点目标的buff及debuff；
		Spell Cooldown，是冷却时间监控组，用来监视饰品、戒指、技能CD等；
		Enchant Aura，是各种种族技能、药水、饰品触发的buff分组；
		Raid Buff，是团队重要buff的分组，用来监控如嗜血、光环、团队减伤等等；
		Raid Debuff，是团队战斗中出现的debuff组，用来监控战斗中出现的点名等等；
		Warning，是目标身上需要注意的buff及debuff，可以用来监视BOSS的易伤、PVP对方的大招等等。

	数字编号含义：
		AuraID，支持BUFF和DEBUFF，在游戏中触发时，请鼠标移过去看看ID，或者自己查询数据库；
		SpellID，只是用来监视技能的CD，直接鼠标到技能上就可以看到该ID，大部分情况下与其触发后的BUFF/DEBUFF ID不一样；
		ItemID，用来监视物品的CD，例如炉石等等；
		SlotID，装备栏各部位的冷却时间，常用的有11/12戒指，6腰带，15披风，13/14饰品栏（仅主动饰品）；
		TotemID，监视图腾的持续时间，武僧的玄牛算1号图腾，萨满1-4对应4个图腾；
		UnitID，是你想监视的目标，支持宠物pet，玩家自身player，目标target和焦点focus；

	各种过滤方式：
		Caster，是法术的释放者，如果你没有标明，则任何释放该法术的都会被监视，例如猎人印记，元素诅咒等；
		Stack，是部分法术的层数，未标明则全程监视，有标明则只在达到该层数后显示，例如DK鲜血充能仅在10层后才提示；
		Value，为true时启用，用于监视一些BUFF/DEBUFF的具体数值，如牧师的盾，DK的血盾等等；
		Timeless，具体例如萨满的闪电盾，因为持续1个小时，没有必要一直监视时间，启用Timeless则只监视层数；
		Combat，启用时将仅在战斗中监视该buff，例如猎人的狙击训练，萨满的闪电护盾；
		Text，启用时将在BUFF图标下用文字提醒，优先级低于Value。比如中了某个BUFF需要出人群时，你就可以使用这个文字提醒；
		Flash，启用时在图标显示一圈高亮；

	内置CD使用说明：
		{IntID = 208052, Duration = 30, ItemID = 132452},	-- 塞弗斯的秘密
		{IntID = 98008, Duration = 30, OnSuccess = true, UnitID = "all"},	-- 灵魂链接
		IntID，计时条触发时的法术或者技能ID；
		Duration，自定义计时条的持续时间；
		ItemID，在计时条上显示的名称，如果不填写，就会直接使用触发时的Buff名称；
		OnSuccess，用于监控技能成功施放的触发器，仅当技能成功施放时开启计时条。如果不填写，则计时条由你获得该法术光环时触发；
		UnitID，用于过滤目标法术的来源，默认为player玩家自身。如果设置为all，则监控队伍/团队里的所有成员。
]]

-- 全职业的相关监控
local list = {
	["Enchant Aura"] = {	-- 附魔及饰品组
		-- 种族天赋
		{AuraID = 58984, UnitID = "player"},	-- 影遁 暗夜
		{AuraID = 20594, UnitID = "player"},	-- 石像形态 矮人
		{AuraID = 26297, UnitID = "player"},	-- 狂暴 巨魔
		{AuraID = 20572, UnitID = "player"},	-- 血性狂暴 兽人
		{AuraID = 33697, UnitID = "player"},	-- 血性狂暴 兽人
		{AuraID = 33702, UnitID = "player"},	-- 血性狂暴 兽人
		-- 附魔药水
		{AuraID = 28093, UnitID = "player"},	-- 闪电之速，猫鼬
		{AuraID = 28515, UnitID = "player"},	-- 铁盾药水
		{AuraID = 28504, UnitID = "player"},	-- 特效无梦睡眠药水
		{AuraID = 28506, UnitID = "player"},	-- 英雄药水
		{AuraID = 28507, UnitID = "player"},	-- 加速药水
		{AuraID = 28508, UnitID = "player"},	-- 毁灭药水
		--{AuraID = 28511, UnitID = "player"},	-- 防护火焰药水
		--{AuraID = 28512, UnitID = "player"},	-- 防护冰霜药水
		--{AuraID = 28513, UnitID = "player"},	-- 防护自然药水
		--{AuraID = 28537, UnitID = "player"},	-- 防护暗影药水
		--{AuraID = 28538, UnitID = "player"},	-- 防护神圣药水
		-- 饰品
	},
	["Raid Buff"] = {		-- 团队增益组
		-- 战鼓
		{AuraID = 35474, UnitID = "player"},	-- 恐慌之鼓
		{AuraID = 35475, UnitID = "player"},	-- 战争之鼓
		{AuraID = 35476, UnitID = "player"},	-- 战斗之鼓
		{AuraID = 35477, UnitID = "player"},	-- 速度之鼓
		{AuraID = 35478, UnitID = "player"},	-- 恢复之鼓
		-- 团队增益或减伤
		{AuraID = 2825, UnitID = "player"},		-- 嗜血
		{AuraID = 32182, UnitID = "player"},	-- 英勇
		{AuraID = 1022, UnitID = "player"},		-- 保护祝福
		{AuraID = 6940, UnitID = "player"},		-- 牺牲祝福
		{AuraID = 1044, UnitID = "player"},		-- 自由祝福
		{AuraID = 29166, UnitID = "player"},	-- 激活
		{AuraID = 10060, UnitID = "player"},	-- 能量灌注
		{AuraID = 13159, UnitID = "player"},	-- 豹群守护
		{AuraID = 33206, UnitID = "player"},	-- 痛苦压制
	},
	["Raid Debuff"] = {		-- 团队减益组
		--{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
	},
	["Warning"] = {			-- 目标重要光环组
		--{AuraID = 226510, UnitID = "target"},	-- 血池回血
	-- PVP
		{AuraID = 498, UnitID = "target"},		-- 圣佑术
		{AuraID = 642, UnitID = "target"},		-- 圣盾术
		{AuraID = 871, UnitID = "target"},		-- 盾墙
		{AuraID = 5277, UnitID = "target"},		-- 闪避
		{AuraID = 1044, UnitID = "target"},		-- 自由祝福
		{AuraID = 6940, UnitID = "target"},		-- 牺牲祝福
		{AuraID = 1022, UnitID = "target"},		-- 保护祝福
		{AuraID = 19574, UnitID = "target"},	-- 狂野怒火
		{AuraID = 23920, UnitID = "target"},	-- 法术反射
		{AuraID = 33206, UnitID = "target"},	-- 痛苦压制
	},
	["InternalCD"] = {		-- 自定义内置冷却组
		--{IntID = 240447, Duration = 20},	-- 践踏
	},
}

module:AddNewAuraWatch("ALL", list)