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
		{AuraID = 354808, UnitID = "player"},	-- 棱彩之光，1万币的小宠物
		-- 种族天赋
		{AuraID = 26297, UnitID = "player"},	-- 狂暴 巨魔
		{AuraID = 20572, UnitID = "player"},	-- 血性狂怒 兽人
		{AuraID = 33697, UnitID = "player"},	-- 血性狂怒 兽人
		{AuraID = 292463, UnitID = "player"},	-- 帕库之拥 赞达拉
		-- 9.0药水
		{AuraID = 307159, UnitID = "player"},	-- 幽魂敏捷药水
		{AuraID = 307162, UnitID = "player"},	-- 幽魂智力药水
		{AuraID = 307163, UnitID = "player"},	-- 幽魂耐力药水
		{AuraID = 307164, UnitID = "player"},	-- 幽魂力量药水
		{AuraID = 307494, UnitID = "player"},	-- 强化驱魔药水
		{AuraID = 307495, UnitID = "player"},	-- 幻影火焰药水
		{AuraID = 307496, UnitID = "player"},	-- 神圣觉醒药水
		{AuraID = 307497, UnitID = "player"},	-- 死亡偏执药水
		{AuraID = 344314, UnitID = "player"},	-- 心华之速药水
		{AuraID = 307195, UnitID = "player"},	-- 隐秘精魂药水
		{AuraID = 342890, UnitID = "player"},	-- 无拘移动药水
		{AuraID = 322302, UnitID = "player"},	-- 献祭心能药水
		{AuraID = 307160, UnitID = "player"},	-- 硬化暗影药水
		-- 9.0饰品
		{AuraID = 344231, UnitID = "player"},	-- 赤红陈酿
		{AuraID = 345228, UnitID = "player"},	-- 角斗士徽章
		{AuraID = 344662, UnitID = "player"},	-- 碎裂心智
		{AuraID = 345439, UnitID = "player"},	-- 赤红华尔兹
		{AuraID = 345019, UnitID = "player"},	-- 潜伏的掠食者
		{AuraID = 345530, UnitID = "player"},	-- 过载的心能电池
		{AuraID = 345541, UnitID = "player"},	-- 天域涌动
		{AuraID = 336588, UnitID = "player"},	-- 唤醒者的复叶
		{AuraID = 348139, UnitID = "player"},	-- 导师的圣钟
		{AuraID = 311444, UnitID = "player", Value = true},	-- 不屈套牌
		{AuraID = 336465, UnitID = "player", Value = true},	-- 脉冲光辉护盾
		{AuraID = 330366, UnitID = "player", Text = L["Crit"]},	-- 不可思议的量子装置，暴击
		{AuraID = 330367, UnitID = "player", Text = L["Versa"]},	-- 不可思议的量子装置，全能
		{AuraID = 330368, UnitID = "player", Text = L["Haste"]},	-- 不可思议的量子装置，急速
		{AuraID = 330380, UnitID = "player", Text = L["Mastery"]},	-- 不可思议的量子装置，精通
		{AuraID = 351872, UnitID = "player"},	-- 钢铁尖刺
		{AuraID = 355316, UnitID = "player"},	-- 安海尔德之盾
		{AuraID = 356326, UnitID = "player"},	-- 折磨洞察
		{AuraID = 355333, UnitID = "player"},	-- 回收的聚变增幅器
		{AuraID = 357185, UnitID = "player"},	-- 忠诚的力量，低语威能碎片
		{AuraID = 357773, UnitID = "player"},	-- 神圣使命，九武神长柄

		{AuraID = 367241, UnitID = "player"},	-- 原初印记
		{AuraID = 363522, UnitID = "player"},	-- 角斗士的永恒结界
		{AuraID = 362699, UnitID = "player"},	-- 角斗士的决心
		-- 盟约
		{AuraID = 331937, UnitID = "player", Flash = true},	-- 沉醉
		{AuraID = 354053, UnitID = "player", Flash = true, Text = L["Crit"]}, -- 致命缺陷，暴击
		{AuraID = 354054, UnitID = "player", Flash = true, Text = L["Versa"]}, -- 致命缺陷，全能
		{AuraID = 323546, UnitID = "player"},	-- 饕餮狂乱
		{AuraID = 326860, UnitID = "player"},	-- 陨落僧众
		{AuraID = 310143, UnitID = "player", Combat = true},-- 灵魂变形
		{AuraID = 327104, UnitID = "player"},	-- 妖魂踏
		{AuraID = 327710, UnitID = "player"},	-- 善行法夜
		{AuraID = 328933, UnitID = "player"},	-- 法夜输灵
		{AuraID = 328281, UnitID = "player"},	-- 凛冬祝福
		{AuraID = 328282, UnitID = "player"},	-- 阳春祝福
		{AuraID = 328620, UnitID = "player"},	-- 仲夏祝福
		{AuraID = 328622, UnitID = "player"},	-- 暮秋祝福
		{AuraID = 324867, UnitID = "player", Value = true},	-- 血肉铸造
		{AuraID = 328204, UnitID = "player"},	-- 征服者之锤
		{AuraID = 325748, UnitID = "player"},	-- 激变蜂群
		{AuraID = 315443, UnitID = "player"},	-- 憎恶附肢
		{AuraID = 325299, UnitID = "player"},	-- 屠戮箭
		{AuraID = 327164, UnitID = "player"},	-- 始源之潮
		{AuraID = 325216, UnitID = "player"},	-- 骨尘酒
		{AuraID = 343672, UnitID = "player"},	-- 征服者之狂
		{AuraID = 324220, UnitID = "player"},	-- 死神之躯
		{AuraID = 311648, UnitID = "player"},	-- 云集之雾
		{AuraID = 323558, UnitID = "player"},	-- 申斥回响2
		{AuraID = 323559, UnitID = "player"},	-- 申斥回响3
		{AuraID = 323560, UnitID = "player"},	-- 申斥回响4
		{AuraID = 338142, UnitID = "player"},	-- 自审强化
		{AuraID = 310454, UnitID = "player"},	-- 精序兵戈
		{AuraID = 325013, UnitID = "player"},	-- 晋升者之赐
		{AuraID = 308495, UnitID = "player"},	-- 共鸣箭
		{AuraID = 328908, UnitID = "player"},	-- 战斗冥想
		{AuraID = 345499, UnitID = "player"},	-- 执政官的祝福
		{AuraID = 339461, UnitID = "player"},	-- 猎手坚韧
		{AuraID = 325381, UnitID = "player", Flash = true},	-- 争先打击
		{AuraID = 351414, UnitID = "player", Flash = true},	-- 切肉者之眼
		{AuraID = 342774, UnitID = "player"},	-- 繁华原野
		{AuraID = 333218, UnitID = "player"},	-- 废土礼节
		{AuraID = 336885, UnitID = "player"},	-- 抚慰阴影
		{AuraID = 324156, UnitID = "player", Flash = true},	-- 劫掠射击
		--{AuraID = 328900, UnitID = "player"},	-- 放下过去
		{AuraID = 333961, UnitID = "player"},	-- 行动的召唤：布隆
		{AuraID = 333943, UnitID = "player"},	-- 源生重槌
		{AuraID = 339928, UnitID = "player", Flash = true},	-- 残酷投射
		{AuraID = 352917, UnitID = "player"},	-- 崭新决心
		-- S2，心能/统御碎片
		{AuraID = 357852, UnitID = "player"},	-- 激励
		{AuraID = 356364, UnitID = "player"},	-- 冰冷的心
		{AuraID = 356043, UnitID = "player"},	-- 森罗万象
		-- 炼金石
		{AuraID = 60233, UnitID = "player"},	-- 敏捷
		{AuraID = 60229, UnitID = "player"},	-- 力量
		{AuraID = 60234, UnitID = "player"},	-- 智力
		-- WoD橙戒
		{AuraID = 187616, UnitID = "player"},	-- 尼萨姆斯，智力
		{AuraID = 187617, UnitID = "player"},	-- 萨克图斯，坦克
		{AuraID = 187618, UnitID = "player"},	-- 伊瑟拉鲁斯，治疗
		{AuraID = 187619, UnitID = "player"},	-- 索拉苏斯，力量
		{AuraID = 187620, UnitID = "player"},	-- 玛鲁斯，敏捷
		-- 传家宝饰品
		{AuraID = 201405, UnitID = "player"},	-- 力量
		{AuraID = 201408, UnitID = "player"},	-- 敏捷
		{AuraID = 201410, UnitID = "player"},	-- 智力
		{AuraID = 202052, UnitID = "player", Value = true},		-- 坦克
	},
	["Raid Buff"] = {		-- 团队增益组
		{AuraID = 54861, UnitID = "player"},	-- 火箭靴，工程
		-- 嗜血相关
		{AuraID = 2825, UnitID = "player"},		-- 嗜血
		{AuraID = 32182, UnitID = "player"},	-- 英勇
		{AuraID = 80353, UnitID = "player"},	-- 时间扭曲
		{AuraID = 264667, UnitID = "player"},	-- 原始狂怒
		{AuraID = 178207, UnitID = "player"},	-- 狂怒战鼓
		{AuraID = 230935, UnitID = "player"},	-- 高山战鼓
		{AuraID = 256740, UnitID = "player"},	-- 漩涡战鼓
		{AuraID = 309658, UnitID = "player"},	-- 死亡凶蛮战鼓
		{AuraID = 102364, UnitID = "player"},	-- 青铜龙的祝福
		{AuraID = 292686, UnitID = "player"},	-- 制皮鼓
		-- 团队增益或减伤
		{AuraID = 1022, UnitID = "player"},		-- 保护祝福
		{AuraID = 6940, UnitID = "player"},		-- 牺牲祝福
		{AuraID = 1044, UnitID = "player"},		-- 自由祝福
		{AuraID = 10060, UnitID = "player"},	-- 能量灌注
		{AuraID = 77761, UnitID = "player"},	-- 狂奔怒吼
		{AuraID = 77764, UnitID = "player"},	-- 狂奔怒吼
		{AuraID = 31821, UnitID = "player"},	-- 光环掌握
		{AuraID = 97463, UnitID = "player"},	-- 命令怒吼
		{AuraID = 64843, UnitID = "player"},	-- 神圣赞美诗
		{AuraID = 64901, UnitID = "player"},	-- 希望象征
		{AuraID = 81782, UnitID = "player"},	-- 真言术：障
		{AuraID = 29166, UnitID = "player"},	-- 激活
		{AuraID = 47788, UnitID = "player"},	-- 守护之魂
		{AuraID = 33206, UnitID = "player"},	-- 痛苦压制
		{AuraID = 53563, UnitID = "player"},	-- 圣光道标
		{AuraID = 98007, UnitID = "player"},	-- 灵魂链接图腾
		{AuraID = 223658, UnitID = "player"},	-- 捍卫
		{AuraID = 115310, UnitID = "player"},	-- 五气归元
		{AuraID = 116849, UnitID = "player"},	-- 作茧缚命
		{AuraID = 204018, UnitID = "player"},	-- 破咒祝福
		{AuraID = 102342, UnitID = "player"},	-- 铁木树皮
		{AuraID = 145629, UnitID = "player"},	-- 反魔法领域
		{AuraID = 156910, UnitID = "player"},	-- 信仰道标
		{AuraID = 192082, UnitID = "player"},	-- 狂风图腾
		{AuraID = 201633, UnitID = "player"},	-- 大地图腾
		{AuraID = 207498, UnitID = "player"},	-- 先祖护佑
		{AuraID = 238698, UnitID = "player"},	-- 吸血光环
		{AuraID = 209426, UnitID = "player"},	-- 幻影打击
		{AuraID = 114018, UnitID = "player", Flash = true},	-- 帷幕
		{AuraID = 115834, UnitID = "player", Flash = true},
	},
	["Raid Debuff"] = {		-- 团队减益组
		-- 大幻象
		{AuraID = 311390, UnitID = "player"},	-- 疯狂：昆虫恐惧症，幻象
		{AuraID = 306583, UnitID = "player"},	-- 灌铅脚步
		{AuraID = 313698, UnitID = "player", Flash = true},	-- 泰坦之赐
		-- 常驻词缀
		{AuraID = 366288, UnitID = "player"},	-- 解构
		{AuraID = 368239, UnitID = "player", Flash = true, Text = "CD"},	-- 减CD密文
		{AuraID = 368240, UnitID = "player", Flash = true, Text = L["Haste"]},	-- 急速密文
		{AuraID = 368241, UnitID = "player", Flash = true, Text = L["Speed"]},	-- 移速密文
		{AuraID = 358777, UnitID = "player"},	-- 痛苦之链
		{AuraID = 355732, UnitID = "player"},	-- 融化灵魂
		{AuraID = 356667, UnitID = "player"},	-- 刺骨之寒
		{AuraID = 356925, UnitID = "player"},	-- 屠戮
		{AuraID = 342466, UnitID = "player"},	-- 狂妄吹嘘，S1
		{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
		{AuraID = 240559, UnitID = "player"},	-- 重伤
		{AuraID = 340880, UnitID = "player"},	-- 傲慢
		{AuraID = 226512, UnitID = "player", Flash = true},	-- 血池
		{AuraID = 240447, UnitID = "player", Flash = true},	-- 践踏
		{AuraID = 240443, UnitID = "player", Flash = true},	-- 爆裂
		-- 5人本
		{AuraID = 327107, UnitID = "player"},	-- 赤红，闪耀光辉
		{AuraID = 340433, UnitID = "player"},	-- 赤红，堕罪之赐
		{AuraID = 324092, UnitID = "player", Flash = true},	-- 赤红，闪耀光辉
		{AuraID = 328737, UnitID = "player", Flash = true},	-- 赤红，光辉残片
		{AuraID = 326891, UnitID = "player", Flash = true},	-- 赎罪大厅，痛楚
		{AuraID = 319603, UnitID = "player", Flash = true},	-- 赎罪大厅，羁石诅咒
		{AuraID = 333299, UnitID = "player"},	-- 伤逝剧场，荒芜诅咒
		{AuraID = 319637, UnitID = "player"},	-- 伤逝剧场，魂魄归体
		{AuraID = 330725, UnitID = "player", Flash = true},	-- 伤逝剧场，暗影易伤
		{AuraID = 336258, UnitID = "player", Flash = true},	-- 凋魂之殇，落单狩猎
		{AuraID = 331399, UnitID = "player"},	-- 凋魂之殇，感染毒雨
		{AuraID = 333353, UnitID = "player"},	-- 凋魂之殇，暗影伏击
		{AuraID = 327401, UnitID = "player", Flash = true},	-- 通灵战潮，共受苦难
		{AuraID = 323471, UnitID = "player", Flash = true},	-- 通灵战潮，切肉飞刀
		{AuraID = 328181, UnitID = "player"},	-- 通灵战潮，凌冽之寒
		{AuraID = 327397, UnitID = "player"},	-- 通灵战潮，严酷命运
		{AuraID = 322681, UnitID = "player"},	-- 通灵战潮，肉钩
		{AuraID = 335161, UnitID = "player"},	-- 通灵战潮，残存心能
		{AuraID = 345323, UnitID = "player", Flash = true},	-- 通灵战潮，勇士之赐
		{AuraID = 320366, UnitID = "player", Flash = true},	-- 通灵战潮，防腐剂
		{AuraID = 322746, UnitID = "player"},	-- 彼界，堕落之血
		{AuraID = 323692, UnitID = "player"},	-- 彼界，奥术易伤
		{AuraID = 331379, UnitID = "player"},	-- 彼界，润滑剂
		{AuraID = 320786, UnitID = "player"},	-- 彼界，势不可挡
		{AuraID = 323687, UnitID = "player", Flash = true},	-- 彼界，奥术闪电
		{AuraID = 327893, UnitID = "player", Flash = true},	-- 彼界，邦桑迪的热情
		{AuraID = 339978, UnitID = "player", Flash = true},	-- 彼界，安抚迷雾
		{AuraID = 323569, UnitID = "player", Flash = true},	-- 彼界，溅洒精魂
		{AuraID = 334496, UnitID = "player"},	-- 彼界，催眠光粉
		{AuraID = 328453, UnitID = "player"},	-- 晋升高塔，压迫
		{AuraID = 335805, UnitID = "player", Flash = true},	-- 晋升高塔，执政官的壁垒
		{AuraID = 325027, UnitID = "player", Flash = true},	-- 仙林，荆棘爆发
		{AuraID = 356011, UnitID = "player"},	-- 集市，光线切分者
		{AuraID = 353421, UnitID = "player"},	-- 集市，精力
		{AuraID = 347949, UnitID = "player", Flash = true},	-- 集市，审讯
		{AuraID = 355915, UnitID = "player"},	-- 集市，约束雕文
		{AuraID = 347771, UnitID = "player"},	-- 集市，加急
		{AuraID = 346962, UnitID = "player", Flash = true},	-- 集市，现金汇款
		{AuraID = 348567, UnitID = "player"},	-- 集市，爵士乐
		{AuraID = 349627, UnitID = "player"},	-- 集市，暴食
		{AuraID = 350010, UnitID = "player", Flash = true},	-- 集市，被吞噬的心能
		{AuraID = 346828, UnitID = "player", Flash = true},	-- 集市，消毒区域
		{AuraID = 355581, UnitID = "player", Flash = true},	-- 集市，连环爆裂
		{AuraID = 346961, UnitID = "player", Flash = true},	-- 集市，净化之地
		{AuraID = 347481, UnitID = "player"},	-- 集市，奥能手里波
		{AuraID = 350013, UnitID = "player"},	-- 集市，暴食盛宴
		{AuraID = 350885, UnitID = "player"},	-- 集市，超光速震荡
		{AuraID = 350804, UnitID = "player"},	-- 集市，坍缩能量
		{AuraID = 349999, UnitID = "player"},	-- 集市，心能引爆
		{AuraID = 359019, UnitID = "player", Flash = true},	-- 集市，快拍提速
		-- 团本
		{AuraID = 342077, UnitID = "player"},	-- 回声定位，咆翼
		{AuraID = 329725, UnitID = "player"},	-- 根除，毁灭者
		{AuraID = 329298, UnitID = "player"},	-- 暴食胀气，毁灭者
		{AuraID = 325936, UnitID = "player"},	-- 共享认知，勋爵
		{AuraID = 346035, UnitID = "player"},	-- 眩目步法，猩红议会
		{AuraID = 331636, UnitID = "player", Flash = true},	-- 黑暗伴舞，猩红议会
		{AuraID = 335293, UnitID = "player"},	-- 锁链联结，泥拳
		{AuraID = 333913, UnitID = "player"},	-- 锁链联结，泥拳
		{AuraID = 327039, UnitID = "player"},	-- 邪恶撕裂，干将
		{AuraID = 344655, UnitID = "player"},	-- 震荡易伤，干将
		{AuraID = 327089, UnitID = "player"},	-- 喂食时间，德纳修斯
		{AuraID = 327796, UnitID = "player"},	-- 午夜猎手，德纳修斯

		{AuraID = 347283, UnitID = "player"},	-- 捕食者之嚎，塔拉格鲁
		{AuraID = 347286, UnitID = "player"},	-- 不散之惧，塔拉格鲁
	},
	["Warning"] = { -- 目标重要光环组
		{AuraID = 355596, UnitID = "target", Flash = true},	-- 橙弓，哀痛箭
		-- 大幻象
		{AuraID = 304975, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		{AuraID = 319643, UnitID = "target", Value = true},	-- 虚空哀嚎，吸收盾
		-- 大米
		{AuraID = 226510, UnitID = "target"},	-- 血池回血
		{AuraID = 343502, UnitID = "target"},	-- 鼓舞光环
		-- 5人本
		{AuraID = 321754, UnitID = "target", Value = true},	-- 通灵战潮，冰缚之盾
		{AuraID = 343470, UnitID = "target", Value = true},	-- 通灵战潮，碎骨之盾
		{AuraID = 328351, UnitID = "target", Flash = true},	-- 通灵战潮，染血长枪
		{AuraID = 322773, UnitID = "target", Value = true},	-- 彼界，鲜血屏障
		{AuraID = 333227, UnitID = "target", Flash = true},	-- 彼界，不死之怒
		{AuraID = 228626, UnitID = "target"},	-- 彼界，怨灵之瓮
		{AuraID = 324010, UnitID = "target"},	-- 彼界，发射
		{AuraID = 320132, UnitID = "target"},	-- 彼界，暗影之怒
		{AuraID = 320293, UnitID = "target", Value = true},	-- 伤逝剧场，融入死亡
		{AuraID = 331275, UnitID = "target", Flash = true},	-- 伤逝剧场，不灭护卫
		{AuraID = 336449, UnitID = "target"},	-- 凋魂，玛卓克萨斯之墓
		{AuraID = 336451, UnitID = "target"},	-- 凋魂，玛卓克萨斯之壁
		{AuraID = 333737, UnitID = "target"},	-- 凋魂，凝结之疾
		{AuraID = 328175, UnitID = "target"},	-- 凋魂，凝结之疾
		{AuraID = 321368, UnitID = "target", Value = true},	-- 凋魂，冰缚之盾
		{AuraID = 327416, UnitID = "target", Value = true},	-- 晋升，心能回灌
		{AuraID = 345561, UnitID = "target", Value = true},	-- 晋升，生命连结
		{AuraID = 339917, UnitID = "target", Value = true},	-- 晋升，命运之矛
		{AuraID = 323878, UnitID = "target", Flash = true},	-- 晋升，枯竭
		{AuraID = 317936, UnitID = "target"},	-- 晋升，弃誓信条
		{AuraID = 327812, UnitID = "target"},	-- 晋升，振奋英气
		{AuraID = 323149, UnitID = "target"},	-- 仙林，黑暗之拥
		{AuraID = 340191, UnitID = "target", Value = true},	-- 仙林，再生辐光
		{AuraID = 323059, UnitID = "target", Flash = true},	-- 仙林，宗主之怒
		{AuraID = 336499, UnitID = "target"},	-- 仙林，猜谜游戏
		{AuraID = 322569, UnitID = "target"},	-- 仙林，兹洛斯之手
		{AuraID = 326771, UnitID = "target"},	-- 赎罪大厅，岩石监视者
		{AuraID = 326450, UnitID = "target"},	-- 赎罪大厅，忠心的野兽
		{AuraID = 322433, UnitID = "target"},	-- 赤红深渊，石肤术
		{AuraID = 321402, UnitID = "target"},	-- 赤红深渊，饱餐
		{AuraID = 355640, UnitID = "target"},	-- 集市，重装方阵
		{AuraID = 355782, UnitID = "target"},	-- 集市，力量增幅器
		{AuraID = 351086, UnitID = "target"},	-- 集市，势不可挡
		{AuraID = 347840, UnitID = "target"},	-- 集市，野性
		{AuraID = 347992, UnitID = "target"},	-- 集市，回旋防弹衣
		{AuraID = 347840, UnitID = "target"},	-- 集市，野性
		{AuraID = 347015, UnitID = "target", Flash = true},	-- 集市，强化防御
		{AuraID = 355934, UnitID = "target", Value = true},	-- 集市，强光屏障
		{AuraID = 349933, UnitID = "target", Flash = true, Value = true},	-- 集市，狂热鞭笞协议
		-- 团本
		{AuraID = 345902, UnitID = "target"},	-- 破裂的联结，猎手
		{AuraID = 334695, UnitID = "target"},	-- 动荡的能量，猎手
		{AuraID = 346792, UnitID = "target"},	-- 罪触之刃，猩红议会
		{AuraID = 331314, UnitID = "target"},	-- 毁灭冲击，泥拳
		{AuraID = 341250, UnitID = "target"},	-- 恐怖暴怒，泥拳
		{AuraID = 329636, UnitID = "target", Flash = true},	-- 坚岩形态，干将
		{AuraID = 329808, UnitID = "target", Flash = true},	-- 坚岩形态，干将
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
		{AuraID = 31884, UnitID = "target"},	-- 复仇之怒
		{AuraID = 33206, UnitID = "target"},	-- 痛苦压制
		{AuraID = 45438, UnitID = "target"},	-- 寒冰屏障
		{AuraID = 47585, UnitID = "target"},	-- 消散
		{AuraID = 47788, UnitID = "target"},	-- 守护之魂
		{AuraID = 48792, UnitID = "target"},	-- 冰封之韧
		{AuraID = 48707, UnitID = "target"},	-- 反魔法护罩
		{AuraID = 61336, UnitID = "target"},	-- 生存本能
		{AuraID = 197690, UnitID = "target"},	-- 防御姿态
		{AuraID = 147833, UnitID = "target"},	-- 援护
		{AuraID = 186265, UnitID = "target"},	-- 灵龟守护
		{AuraID = 113862, UnitID = "target"},	-- 强化隐形术
		{AuraID = 118038, UnitID = "target"},	-- 剑在人在
		{AuraID = 114050, UnitID = "target"},	-- 升腾 元素
		{AuraID = 114051, UnitID = "target"},	-- 升腾 增强
		{AuraID = 114052, UnitID = "target"},	-- 升腾 恢复
		{AuraID = 204018, UnitID = "target"},	-- 破咒祝福
		{AuraID = 205191, UnitID = "target"},	-- 以眼还眼 惩戒
		{AuraID = 104773, UnitID = "target"},	-- 不灭决心
		{AuraID = 199754, UnitID = "target"},	-- 还击
		{AuraID = 120954, UnitID = "target"},	-- 壮胆酒
		{AuraID = 122278, UnitID = "target"},	-- 躯不坏
		{AuraID = 122783, UnitID = "target"},	-- 散魔功
		{AuraID = 188499, UnitID = "target"},	-- 刃舞
		{AuraID = 210152, UnitID = "target"},	-- 刃舞
		{AuraID = 247938, UnitID = "target"},	-- 混乱之刃
		{AuraID = 212800, UnitID = "target"},	-- 疾影
		{AuraID = 162264, UnitID = "target"},	-- 恶魔变形
		{AuraID = 187827, UnitID = "target"},	-- 恶魔变形
		{AuraID = 125174, UnitID = "target"},	-- 业报之触
		{AuraID = 171607, UnitID = "target"},	-- 爱情光线
		{AuraID = 228323, UnitID = "target", Value = true},	-- 克罗塔的护盾
	},
	["InternalCD"] = { -- 自定义内置冷却组
		{IntID = 240447, Duration = 20},	-- 大米，践踏
		{IntID = 114018, Duration = 15, OnSuccess = true, UnitID = "all"},	-- 帷幕
		{IntID = 316958, Duration = 30, OnSuccess = true, UnitID = "all"},	-- 红土
	},
}

module:AddNewAuraWatch("ALL", list)