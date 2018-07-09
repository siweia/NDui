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
		{AuraID = 26297, UnitID = "player"},	-- 狂暴 巨魔
		{AuraID = 20572, UnitID = "player"},	-- 血性狂怒 兽人
		{AuraID = 33697, UnitID = "player"},	-- 血性狂怒 兽人
		-- 艾泽里特特质
		{AuraID = 273685, UnitID = "player"},	-- 缜密计谋
		{AuraID = 273714, UnitID = "player"},	-- 争分夺秒
		{AuraID = 274443, UnitID = "player"},	-- 死亡之舞
		{AuraID = 280433, UnitID = "player"},	-- 呼啸狂沙
		{AuraID = 268953, UnitID = "player", Text = RAID_BUFF_6},	-- 元素回旋 爆击
		{AuraID = 268954, UnitID = "player", Text = RAID_BUFF_4},	-- 急速
		{AuraID = 268955, UnitID = "player", Text = RAID_BUFF_7},	-- 精通
		{AuraID = 268956, UnitID = "player", Text = RAID_BUFF_8},	-- 全能
		{AuraID = 280780, UnitID = "player"},	-- 战斗荣耀
		{AuraID = 280787, UnitID = "player"},	-- 反击之怒
		{AuraID = 279928, UnitID = "player"},	-- 大地链接
		-- LEG药水附魔
		{AuraID = 188027, UnitID = "player"},	-- 致命优雅，远程
		{AuraID = 188028, UnitID = "player"},	-- 上古战神，近战
		{AuraID = 188029, UnitID = "player"},	-- 不屈药水，坦克
		{AuraID = 190909, UnitID = "player"},	-- 利爪之印
		{AuraID = 228399, UnitID = "player"},	-- 厚皮之印
		{AuraID = 229206, UnitID = "player"},	-- 延时之力
		{AuraID = 230039, UnitID = "player"},	-- 搏击延时之力
		-- 泰坦之路系列饰品
		{AuraID = 256816, UnitID = "player"},	-- 阿格拉玛的信念
		{AuraID = 256831, UnitID = "player"},	-- 阿格拉玛的信念
		{AuraID = 256818, UnitID = "player"},	-- 阿曼苏尔的预见
		{AuraID = 256832, UnitID = "player"},	-- 阿曼苏尔的预见
		{AuraID = 256833, UnitID = "player"},	-- 高戈奈斯的活力
		{AuraID = 256834, UnitID = "player"},	-- 艾欧娜尔的怜悯
		{AuraID = 256826, UnitID = "player"},	-- 卡兹格罗斯的勇气
		{AuraID = 256835, UnitID = "player"},	-- 卡兹格罗斯的勇气
		{AuraID = 256828, UnitID = "player"},	-- 诺甘农的威能
		{AuraID = 256836, UnitID = "player"},	-- 诺甘农的威能
		-- LEG饰品
		{AuraID = 253327, UnitID = "player"},	-- 高沙拉克的回响
		{AuraID = 253808, UnitID = "player"},	-- 虚空之拥
		{AuraID = 253307, UnitID = "player"},	-- 影灼之牙
		{AuraID = 253308, UnitID = "player"},	-- 影灼之牙
		{AuraID = 251938, UnitID = "player"},	-- 裂隙世界法典
		{AuraID = 256415, UnitID = "player"},	-- 裂隙世界法典
		{AuraID = 252545, UnitID = "player", Value = true},		-- 裂隙世界法典
		{AuraID = 253260, UnitID = "player"},	-- 注射器 三维
		{AuraID = 253261, UnitID = "player"},	-- 注射器 急速
		{AuraID = 255744, UnitID = "player"},	-- 注射器 精通
		{AuraID = 255742, UnitID = "player"},	-- 注射器 暴击
		{AuraID = 254161, UnitID = "player"},	-- 超能奥术
		{AuraID = 242570, UnitID = "player"},	-- 猫头鹰
		{AuraID = 243644, UnitID = "player"},	-- 幽魂香炉
		{AuraID = 243942, UnitID = "player"},	-- 醒神宝典
		{AuraID = 242612, UnitID = "player"},	-- 灭绝引擎
		{AuraID = 225719, UnitID = "player"},	-- 节拍器
		{AuraID = 225774, UnitID = "player"},	-- 黑暗低语
		{AuraID = 225776, UnitID = "player"},	-- 黑暗低语
		{AuraID = 215816, UnitID = "player"},	-- 地狱火之书
		{AuraID = 208081, UnitID = "player"},	-- 罗宁护腕
		{AuraID = 225736, UnitID = "player"},	-- 回归打击
		{AuraID = 224151, UnitID = "player"},	-- 苏拉玛套装，爆击
		{AuraID = 215658, UnitID = "player"},	-- 黑暗打击，+伤害
		{AuraID = 215659, UnitID = "player"},	-- 黑暗打击，+护盾
		{AuraID = 215632, UnitID = "player"},	-- 专注闪电，+精通
		{AuraID = 214831, UnitID = "player"},	-- 混沌能量，+力量/敏捷
		{AuraID = 215956, UnitID = "player"},	-- 瓦拉加尔之道，+主属性
		{AuraID = 215294, UnitID = "player"},	-- 召云聚气
		{AuraID = 221796, UnitID = "player"},	-- 血性狂乱
		{AuraID = 214807, UnitID = "player"},	-- 安格博达的挽歌
		{AuraID = 214803, UnitID = "player"},	-- 席瓦尔的哀嚎
		{AuraID = 214802, UnitID = "player"},	-- 因格瓦尔的嚎叫
		{AuraID = 221695, UnitID = "player"},	-- 蛮荒诸神之怒，+生命护甲
		{AuraID = 222166, UnitID = "player"},	-- 恐惧附肢
		{AuraID = 214128, UnitID = "player"},	-- 增速
		{AuraID = 225749, UnitID = "player"},	-- 艾塔乌斯的星图
		{AuraID = 225752, UnitID = "player"},	-- 艾塔乌斯的星图
		{AuraID = 225753, UnitID = "player"},	-- 艾塔乌斯的星图
		{AuraID = 222479, UnitID = "player"},	-- 幻影回想 50%减伤
		{AuraID = 208052, UnitID = "player"},	-- 塞弗斯的秘密
		{AuraID = 242066, UnitID = "player"},	-- 警戒栖木
		{AuraID = 221805, UnitID = "player"},	-- 吸血传染
		{AuraID = 214572, UnitID = "player"},	-- 暗夜井能量
		{AuraID = 214624, UnitID = "player", Value = true},		-- 督军的坚韧
		{AuraID = 214577, UnitID = "player", Value = true},		-- 暗夜井能量
		{AuraID = 214423, UnitID = "player", Value = true},		-- 山峰形态，+护盾
		{AuraID = 228323, UnitID = "player", Value = true},		-- 克罗塔的护盾
		{AuraID = 236380, UnitID = "player", Combat = true},	-- 诺甘农的预见
		{AuraID = 207472, UnitID = "player", Value = true, Combat = true},	-- 萨瓦迪卡
		{AuraID = 234143, UnitID = "player"},	-- 坍缩，戒指
		{AuraID = 215648, UnitID = "player"},	-- 艾露恩之光，加主属性
		{AuraID = 230152, UnitID = "player"},	-- 军团之眼
		{AuraID = 215476, UnitID = "player"},	-- 坍缩之影
		{AuraID = 222517, UnitID = "player"},	-- 净化的远古祝福
		{AuraID = 222518, UnitID = "player"},	-- 净化的远古祝福
		{AuraID = 222519, UnitID = "player"},	-- 净化的远古祝福
		{AuraID = 225726, UnitID = "player"},	-- 焦镜
		{AuraID = 225729, UnitID = "player"},	-- 焦镜
		{AuraID = 225730, UnitID = "player"},	-- 焦镜
		{AuraID = 214342, UnitID = "player"},	-- 下冲气流
		{AuraID = 225723, UnitID = "player"},	-- 美味蛋糕
		{AuraID = 191624, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191625, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191626, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191627, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191628, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191629, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191630, UnitID = "player"},	-- 暗月不朽
		{AuraID = 191631, UnitID = "player"},	-- 暗月不朽
		{AuraID = 238499, UnitID = "player"},	-- 无尽暗影恐惧石
		{AuraID = 238500, UnitID = "player"},	-- 无尽暗影恐惧石
		{AuraID = 238501, UnitID = "player"},	-- 无尽暗影恐惧石
		{AuraID = 228461, UnitID = "player"},	-- 咬一口
		{AuraID = 190026, UnitID = "player"},	-- PVP饰品，+敏捷
		{AuraID = 170397, UnitID = "player"},	-- PVP饰品，+全能
		{AuraID = 215670, UnitID = "target", Caster = "player"},	-- 海洋污染
		{AuraID = 214169, UnitID = "target", Caster = "player"},	-- 野蛮强击，15%易伤
		{AuraID = 222209, UnitID = "target", Caster = "player"},	-- 晦暗灵魂，目标伤害降低
		{AuraID = 230259, UnitID = "target", Caster = "player"},	-- 烈焰花环
		{AuraID = 225746, UnitID = "target", Caster = "player"},	-- 阳光坍缩
		{AuraID = 242583, UnitID = "player"},	-- 抗磨联军的调和
		{AuraID = 242584, UnitID = "player"},	-- 抗磨联军的调和
		{AuraID = 242586, UnitID = "player"},	-- 抗磨联军的调和
		{AuraID = 243096, UnitID = "player"},	-- 抗磨联军的调和
		-- 炼金石
		{AuraID =  60233, UnitID = "player"},	-- 敏捷
		{AuraID =  60229, UnitID = "player"},	-- 力量
		{AuraID =  60234, UnitID = "player"},	-- 智力
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
		{AuraID = 90355, UnitID = "player"},	-- 熔岩犬：远古狂乱
		{AuraID = 160452, UnitID = "player"},	-- 虚空鳐：虚空之风
		{AuraID = 178207, UnitID = "player"},	-- 鼓
		{AuraID = 230935, UnitID = "player"},	-- 高山战鼓
		{AuraID = 102364, UnitID = "player"},	-- 青铜龙的祝福
		-- 团队增益或减伤
		{AuraID = 1022, UnitID = "player"},		-- 保护祝福
		{AuraID = 6940, UnitID = "player"},		-- 牺牲祝福
		{AuraID = 1044, UnitID = "player"},		-- 自由祝福
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
		{AuraID = 156910, UnitID = "player"},	-- 信仰道标
		{AuraID = 192082, UnitID = "player"},	-- 狂风图腾
		{AuraID = 201633, UnitID = "player"},	-- 大地图腾
		{AuraID = 207498, UnitID = "player"},	-- 先祖护佑
		{AuraID = 204150, UnitID = "player"},	-- 圣光护盾
		{AuraID = 238698, UnitID = "player"},	-- 吸血光环
		{AuraID = 209426, UnitID = "player"},	-- 幻影打击
	},
	["Raid Debuff"] = {		-- 团队减益组
		-- 史诗钥石
		{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
		{AuraID = 240559, UnitID = "player"},	-- 重伤
		{AuraID = 240443, UnitID = "player"},	-- 爆裂
		{AuraID = 193018, UnitID = "player", Value = true},	-- 气体泡泡
		{AuraID = 230087, UnitID = "player"},	-- 振作
		-- 卡拉赞
		{AuraID = 228796, UnitID = "player"},	-- 夜之魇燃魂
	-- 翡翠梦魇
		-- 尼珊德拉
		{AuraID = 221028, UnitID = "player"},	-- 不稳定的腐烂，小怪
		{AuraID = 204504, UnitID = "player"},	-- 感染
		{AuraID = 205043, UnitID = "player"},	-- 感染意志
		{AuraID = 203096, UnitID = "player"},	-- 溃烂
		{AuraID = 204463, UnitID = "player"},	-- 爆裂溃烂
		{AuraID = 203646, UnitID = "player"},	-- 腐蚀爆发
		-- 伊格诺斯，腐蚀之心
		{AuraID = 210099, UnitID = "player"},	-- 锁定
		{AuraID = 209469, UnitID = "player"},	-- 腐蚀之触
		{AuraID = 210984, UnitID = "player"},	-- 命运之眼
		{AuraID = 208929, UnitID = "player"},	-- 腐化吐息
		{AuraID = 215128, UnitID = "player"},	-- 诅咒之血
		{AuraID = 209471, UnitID = "player"},	-- 梦魇爆破
		-- 艾乐瑞瑟雷弗拉尔
		{AuraID = 210228, UnitID = "player"},	-- 流毒獠牙
		{AuraID = 215300, UnitID = "player"},	-- 痛苦之网
		{AuraID = 215307, UnitID = "player"},	-- 痛苦之网
		{AuraID = 215460, UnitID = "player"},	-- 死灵毒液
		{AuraID = 210850, UnitID = "player"},	-- 扭曲暗影
		{AuraID = 215582, UnitID = "player"},	-- 邪掠之爪
		{AuraID = 218519, UnitID = "player"},	-- 狂风燃烧
		-- 乌索克
		{AuraID = 197943, UnitID = "player"},	-- 易伤
		{AuraID = 204859, UnitID = "player"},	-- 撕裂肉体
		{AuraID = 198006, UnitID = "player"},	-- 专注凝视
		{AuraID = 198108, UnitID = "player"},	-- 势如破竹
		-- 梦魇之龙
		{AuraID = 204731, UnitID = "player"},	-- 恐惧蔓延
		{AuraID = 205341, UnitID = "player"},	-- 渗透之雾
		{AuraID = 203770, UnitID = "player"},	-- 被亵渎的藤曼
		{AuraID = 204078, UnitID = "player"},	-- 低吼
		{AuraID = 203110, UnitID = "player"},	-- 嗜睡梦魇
		{AuraID = 203787, UnitID = "player"},	-- 快速传染
		{AuraID = 214543, UnitID = "player"},	-- 坍缩梦魇
		-- 塞纳留斯
		{AuraID = 210315, UnitID = "player"},	-- 梦魇荆棘
		{AuraID = 211989, UnitID = "player"},	-- 狂暴之触
		{AuraID = 216516, UnitID = "player"},	-- 上古之梦
		{AuraID = 213162, UnitID = "player"},	-- 梦魇冲击
		{AuraID = 208431, UnitID = "player"},	-- 坠入疯狂
		-- 萨维斯
		{AuraID = 206651, UnitID = "player"},	-- 晦暗灵魂
		{AuraID = 209158, UnitID = "player"},	-- 黑化灵魂
		{AuraID = 210451, UnitID = "player"},	-- 恐惧连接
		{AuraID = 209034, UnitID = "player"},	-- 恐惧连接
		{AuraID = 211802, UnitID = "player"},	-- 梦魇之刃
		{AuraID = 205771, UnitID = "player"},	-- 折磨锁定
	-- 勇气试练
		-- 奥丁
		{AuraID = 228932, UnitID = "player"},	-- 雷铸之矛
		{AuraID = 227807, UnitID = "player"},	-- 正义风暴
		-- 高姆
		{AuraID = 228228, UnitID = "player"},	-- 火舌舔舐
		{AuraID = 228248, UnitID = "player"},	-- 冰舌舔舐
		{AuraID = 228253, UnitID = "player", Value = true},	-- 影舌舔舐
		-- 海拉
		{AuraID = 227982, UnitID = "player"},	-- 毒水氧化
		{AuraID = 228054, UnitID = "player"},	-- 海洋污染
		{AuraID = 193367, UnitID = "player"},	-- 恶臭溃烂
		{AuraID = 228519, UnitID = "player"},	-- 铁锚猛击
		{AuraID = 232488, UnitID = "player"},	-- 黑暗仇恨
		{AuraID = 232450, UnitID = "player", Value = true},	-- 腐化脊髓
	-- 暗夜要塞
		-- 斯可匹隆
		{AuraID = 204531, UnitID = "player"},	-- 奥术桎梏
		{AuraID = 211659, UnitID = "player"},	-- 奥术桎梏
		{AuraID = 204483, UnitID = "player"},	-- 聚焦冲击
		-- 时空畸体
		{AuraID = 212099, UnitID = "player"},	-- 时光充能
		{AuraID = 206617, UnitID = "player", Text = L["Get Out"]},	-- 时间炸弹
		{AuraID = 219964, UnitID = "player"},	-- 时间释放
		{AuraID = 219965, UnitID = "player"},	-- 时间释放
		{AuraID = 219966, UnitID = "player"},	-- 时间释放
		-- 崔利艾克斯
		{AuraID = 206641, UnitID = "player"},	-- 奥术梦袭
		{AuraID = 206838, UnitID = "player"},	-- 多汁盛宴
		{AuraID = 214573, UnitID = "player"},	-- 饱餐一顿
		{AuraID = 208499, UnitID = "player"},	-- 吸取活力
		{AuraID = 211615, UnitID = "player"},	-- 吸取活力
		{AuraID = 208910, UnitID = "player"},	-- 弧光连接
		{AuraID = 208915, UnitID = "player"},	-- 弧光连接
		-- 魔剑士奥鲁瑞尔
		{AuraID = 212531, UnitID = "player"},	-- 冰霜印记
		{AuraID = 212587, UnitID = "player"},	-- 冰霜印记
		{AuraID = 212647, UnitID = "player"},	-- 冰霜印记
		{AuraID = 213148, UnitID = "player"},	-- 灼热烙印
		{AuraID = 213504, UnitID = "player"},	-- 奥术迷雾
		-- 提克迪奥斯
		{AuraID = 206480, UnitID = "player"},	-- 腐肉瘟疫
		{AuraID = 208230, UnitID = "player"},	-- 鲜血盛宴
		{AuraID = 206311, UnitID = "player"},	-- 幻象之夜
		{AuraID = 212794, UnitID = "player"},	-- 阿古斯的烙印
		{AuraID = 215988, UnitID = "player"},	-- 腐肉梦魇
		{AuraID = 206466, UnitID = "player"},	-- 夜之精华
		{AuraID = 216024, UnitID = "player"},	-- 爆裂伤口
		{AuraID = 216040, UnitID = "player"},	-- 燃烧的灵魂
		-- 克洛苏斯
		{AuraID = 206677, UnitID = "player"},	-- 灼烧烙印
		{AuraID = 205344, UnitID = "player"},	-- 毁灭之球
		-- 高级植物学家特尔安
		{AuraID = 218342, UnitID = "player"},	-- 寄生凝视
		{AuraID = 218503, UnitID = "player"},	-- 回归打击
		{AuraID = 218304, UnitID = "player"},	-- 寄生镣铐
		{AuraID = 218809, UnitID = "player"},	-- 黑夜的召唤
		{AuraID = 218780, UnitID = "player"},	-- 离子爆炸
		-- 占星师艾塔乌斯
		{AuraID = 206464, UnitID = "player"},	-- 日冕喷射
		{AuraID = 205649, UnitID = "player"},	-- 邪能喷射
		{AuraID = 206398, UnitID = "player"},	-- 邪能烈焰
		{AuraID = 206936, UnitID = "player"},	-- 寒冰喷射
		{AuraID = 207720, UnitID = "player"},	-- 见证虚空
		{AuraID = 206589, UnitID = "player"},	-- 冰冻
		{AuraID = 207831, UnitID = "player"},	-- 星象三角
		{AuraID = 205445, UnitID = "player"},	-- 星座配对
		{AuraID = 205429, UnitID = "player"},	-- 星座配对
		{AuraID = 216345, UnitID = "player"},	-- 星座配对
		{AuraID = 216344, UnitID = "player"},	-- 星座配对
		-- 大魔导师艾利桑德
		{AuraID = 209166, UnitID = "player"},	-- 时间加速
		{AuraID = 209165, UnitID = "player"},	-- 减缓时间
		{AuraID = 209244, UnitID = "player"},	-- 神秘射线
		{AuraID = 209598, UnitID = "player"},	-- 聚合爆破
		{AuraID = 209615, UnitID = "player"},	-- 消融
		{AuraID = 209973, UnitID = "player"},	-- 消融爆破
		{AuraID = 211885, UnitID = "player"},	-- 巨钩
		-- 古尔丹
		{AuraID = 210339, UnitID = "player"},	-- 时间延长
		{AuraID = 206985, UnitID = "player"},	-- 消散力场
	-- 萨格拉斯之墓
		-- 格罗斯
		{AuraID = 233272, UnitID = "player"},	-- 碎裂星辰
		{AuraID = 231363, UnitID = "player"},	-- 燃烧护甲
		{AuraID = 234264, UnitID = "player"},	-- 熔化护甲
		{AuraID = 230345, UnitID = "player"},	-- 彗星冲撞
		-- 恶魔审判庭
		{AuraID = 248741, UnitID = "player"},	-- 骨锯
		{AuraID = 233983, UnitID = "player"},	-- 回响之痛
		{AuraID = 233430, UnitID = "player"},	-- 无法忍受的折磨
		{AuraID = 233901, UnitID = "player"},	-- 窒息之暗
		{AuraID = 248713, UnitID = "player"},	-- 灵魂腐蚀
		-- 哈亚坦
		{AuraID = 248713, UnitID = "player"},	-- 灵魂腐蚀
		{AuraID = 234016, UnitID = "player"},	-- 强制突袭
		{AuraID = 241573, UnitID = "player"},	-- 滴水
		{AuraID = 231998, UnitID = "player"},	-- 锯齿创伤
		{AuraID = 231770, UnitID = "player"},	-- 浸透
		{AuraID = 231729, UnitID = "player"},	-- 水之爆发
		{AuraID = 241600, UnitID = "player"},	-- 病态锁定
		-- 月之姐妹
		{AuraID = 236596, UnitID = "player"},	-- 急速射击
		{AuraID = 236712, UnitID = "player"},	-- 月光信标
		{AuraID = 239264, UnitID = "player"},	-- 月光之火
		{AuraID = 236519, UnitID = "player"},	-- 月灼
		{AuraID = 236550, UnitID = "player"},	-- 无形
		{AuraID = 236305, UnitID = "player"},	-- 灵体射击
		{AuraID = 236330, UnitID = "player"},	-- 星界易伤
		{AuraID = 233263, UnitID = "player", Value = true},	-- 月蚀之拥
		-- 主母萨斯琳
		{AuraID = 230362, UnitID = "player"},	-- 雷霆震击
		{AuraID = 230201, UnitID = "player"},	-- 痛苦负担
		{AuraID = 230959, UnitID = "player"},	-- 昏暗隐匿
		{AuraID = 232754, UnitID = "player"},	-- 多头蛇酸液
		{AuraID = 232913, UnitID = "player"},	-- 污染墨汁
		{AuraID = 230384, UnitID = "player"},	-- 吞噬之饥
		{AuraID = 230920, UnitID = "player"},	-- 吞噬之饥
		{AuraID = 234661, UnitID = "player"},	-- 吞噬之饥
		{AuraID = 239375, UnitID = "player"},	-- 美味的增益鱼
		{AuraID = 239362, UnitID = "player"},	-- 美味的增益鱼
		-- 绝望的聚合体
		{AuraID = 236361, UnitID = "player"},	-- 灵魂锁链
		{AuraID = 236340, UnitID = "player"},	-- 粉碎意志
		{AuraID = 236515, UnitID = "player"},	-- 破碎尖叫
		{AuraID = 238418, UnitID = "player"},	-- 破碎尖叫
		{AuraID = 236459, UnitID = "player"},	-- 灵魂束缚
		{AuraID = 236138, UnitID = "player"},	-- 枯萎
		{AuraID = 236131, UnitID = "player"},	-- 枯萎
		{AuraID = 236011, UnitID = "player"},	-- 折磨哀嚎
		{AuraID = 238018, UnitID = "player"},	-- 折磨哀嚎
		{AuraID = 235924, UnitID = "player"},	-- 苦痛之矛
		{AuraID = 238442, UnitID = "player", Value = true},	-- 苦痛之矛
		-- 戒卫侍女
		{AuraID = 243276, UnitID = "player"},	-- 动荡的灵魂
		{AuraID = 235117, UnitID = "player"},	-- 动荡的灵魂
		{AuraID = 235538, UnitID = "player"},	-- 恶魔活力
		{AuraID = 235534, UnitID = "player"},	-- 造物者之赐
		{AuraID = 241593, UnitID = "player"},	-- 艾格文的结界
		{AuraID = 238408, UnitID = "player"},	-- 邪能残留
		{AuraID = 238028, UnitID = "player"},	-- 光明残留
		{AuraID = 248812, UnitID = "player"},	-- 反冲
		{AuraID = 248801, UnitID = "player"},	-- 碎片爆发
		{AuraID = 241729, UnitID = "player"},	-- 复仇的灵魂
		{AuraID = 235213, UnitID = "player", Text = L["AW Light"]},	-- 光明灌注
		{AuraID = 235240, UnitID = "player", Text = L["AW Fel"]},	-- 邪能灌注
		-- 堕落的化身
		{AuraID = 234059, UnitID = "player"},	-- 释放混沌
		{AuraID = 236494, UnitID = "player"},	-- 风蚀
		{AuraID = 239739, UnitID = "player"},	-- 黑暗印记
		{AuraID = 242017, UnitID = "player"},	-- 漆黑之风
		{AuraID = 240746, UnitID = "player"},	-- 被污染的矩阵
		{AuraID = 240728, UnitID = "player"},	-- 被污染的精华
		-- 基尔加丹
		{AuraID = 234310, UnitID = "player"},	-- 末日之雨
		{AuraID = 245509, UnitID = "player"},	-- 邪爪
		{AuraID = 236710, UnitID = "player"},	-- 暗影映像：爆发
		{AuraID = 236378, UnitID = "player"},	-- 暗影映像：哀嚎
		{AuraID = 240916, UnitID = "player"},	-- 末日之雹
		{AuraID = 236555, UnitID = "player"},	-- 欺诈者的遮蔽
		{AuraID = 241721, UnitID = "player"},	-- 伊利丹的无目凝视
		{AuraID = 240262, UnitID = "player"},	-- 燃烧
		{AuraID = 237590, UnitID = "player"},	-- 暗影映像：绝望
		{AuraID = 243621, UnitID = "player"},	-- 萦绕的希望
		{AuraID = 243624, UnitID = "player"},	-- 萦绕的哀嚎
		{AuraID = 241822, UnitID = "player", Value = true},	-- 窒息之影
	-- 燃烧王座
		-- 加洛西灭世者
		{AuraID = 244410, UnitID = "player"},	-- 屠戮
		{AuraID = 245294, UnitID = "player"},	-- 强化屠戮
		{AuraID = 246920, UnitID = "player"},	-- 错乱屠戮
		-- 萨格拉斯的恶犬
		{AuraID = 244091, UnitID = "player"},	-- 烧焦
		{AuraID = 248815, UnitID = "player"},	-- 点燃
		{AuraID = 244768, UnitID = "player"},	-- 荒芜凝视
		{AuraID = 244055, UnitID = "player", Text = L["Shadow Side"]},	-- 暗影触痕
		{AuraID = 244054, UnitID = "player", Text = L["Fire Side"]},	-- 烈焰触痕
		-- 安托兰统帅议会
		{AuraID = 253290, UnitID = "player"},	-- 熵能爆裂
		{AuraID = 244737, UnitID = "player"},	-- 震荡手雷
		{AuraID = 244748, UnitID = "player"},	-- 震晕
		-- 传送门守护者哈萨贝尔
		{AuraID = 245118, UnitID = "player"},	-- 饱足幽影
		{AuraID = 244709, UnitID = "player"},	-- 烈焰引爆
		{AuraID = 246208, UnitID = "player"},	-- 酸性之网
		{AuraID = 245099, UnitID = "player"},	-- 意识迷雾
		-- 生命的缚誓者艾欧娜尔
		{AuraID = 248332, UnitID = "player"},	-- 邪能之雨
		{AuraID = 249017, UnitID = "player"},	-- 反馈-奥术奇点
		{AuraID = 249014, UnitID = "player"},	-- 反馈-邪污足迹
		{AuraID = 249015, UnitID = "player"},	-- 反馈-燃烧的余烬
		{AuraID = 249016, UnitID = "player"},	-- 反馈-目标锁定
		-- 猎魂者伊墨纳尔
		{AuraID = 247367, UnitID = "player"},	-- 震击之枪
		{AuraID = 247687, UnitID = "player"},	-- 撕裂
		{AuraID = 247565, UnitID = "player"},	-- 催眠毒气
		{AuraID = 250224, UnitID = "player"},	-- 震晕
		{AuraID = 255029, UnitID = "player", Text = L["Get Out"]},	-- 催眠气罐
		-- 金加洛斯
		{AuraID = 254919, UnitID = "player"},	-- 熔铸之击
		{AuraID = 253384, UnitID = "player"},	-- 屠杀
		{AuraID = 249535, UnitID = "player"},	-- 破坏术
		-- 瓦里玛萨斯
		{AuraID = 244042, UnitID = "player"},	-- 被标记的猎物
		{AuraID = 248732, UnitID = "player"},	-- 毁灭回响
		{AuraID = 244094, UnitID = "player", Text = L["Get Out"]},	-- 冥魂之拥
		-- 破坏魔女巫会
		{AuraID = 244899, UnitID = "player"},	-- 火焰打击
		{AuraID = 245518, UnitID = "player"},	-- 快速冻结
		{AuraID = 245634, UnitID = "player"},	-- 飞旋的军刀
		{AuraID = 253020, UnitID = "player"},	-- 黑暗风暴
		{AuraID = 253520, UnitID = "player"},	-- 爆裂脉冲
		{AuraID = 245586, UnitID = "player", Value = true},	-- 冷凝之血
		-- 阿格拉玛
		{AuraID = 245990, UnitID = "player"},	-- 泰沙拉克之触
		{AuraID = 244291, UnitID = "player"},	-- 破敌者
		{AuraID = 245994, UnitID = "player"},	-- 灼热之焰
		{AuraID = 247079, UnitID = "player"},	-- 强化烈焰撕裂
		{AuraID = 254452, UnitID = "player"},	-- 饕餮烈焰
		-- 寂灭者阿古斯
		{AuraID = 248499, UnitID = "player"},	-- 巨镰横扫
		{AuraID = 253903, UnitID = "player"},	-- 天空之力
		{AuraID = 258646, UnitID = "player"},	-- 天空之赐
		{AuraID = 253901, UnitID = "player"},	-- 海洋之力
		{AuraID = 258647, UnitID = "player"},	-- 海洋之赐
		{AuraID = 255199, UnitID = "player"},	-- 阿格拉玛的化身
		{AuraID = 252729, UnitID = "player"},	-- 宇宙射线
		{AuraID = 248396, UnitID = "player", Text = L["Get Out"]},	-- 灵魂凋零
		{AuraID = 250669, UnitID = "player", Text = L["Get Out"]},	-- 灵魂爆发
	},
	["Warning"] = {			-- 目标重要光环组
	-- 勇气试练
		{AuraID = 229256, UnitID = "target"},	-- 奥丁，弧光风暴
		{AuraID = 228174, UnitID = "target"},	-- 高姆，吐沫狂怒
		{AuraID = 228803, UnitID = "target"},	-- 海拉，酝酿风暴
		{AuraID = 203816, UnitID = "target"},	-- 小怪，精力
		{AuraID = 228611, UnitID = "target"},	-- 小怪，幽灵怒火
	-- 大秘
		{AuraID = 226510, UnitID = "target"},	-- 血池回血
		{AuraID = 244621, UnitID = "target"},	-- 虚空裂隙，执政团尾王
		{AuraID = 192132, UnitID = "target"},	-- 英灵殿赫娅
		{AuraID = 192133, UnitID = "target"},	-- 英灵殿赫娅
		{AuraID = 194333, UnitID = "target"},	-- 地窟眼球易伤
		{AuraID = 254020, UnitID = "target"},	-- 黑暗笼罩，执政团鲁拉
		{AuraID = 229495, UnitID = "target"},	-- 卡拉赞国王易伤
		{AuraID = 227817, UnitID = "target", Value = true},	-- 卡拉赞圣女盾
	-- 翡翠梦魇
		{AuraID = 215234, UnitID = "target"},	-- 梦魇之怒
		{AuraID = 211137, UnitID = "target"},	-- 腐溃之风
		{AuraID = 212707, UnitID = "target"},	-- 召云聚气
		{AuraID = 210346, UnitID = "target"},	-- 恐惧荆棘光环
		{AuraID = 210340, UnitID = "target"},	-- 恐惧荆棘光环
	-- 暗夜要塞
		{AuraID = 204697, UnitID = "target"},	-- 毒蝎虫群
		{AuraID = 204448, UnitID = "target"},	-- 几丁质外壳
		{AuraID = 206947, UnitID = "target"},	-- 几丁质外壳
		{AuraID = 205947, UnitID = "target"},	-- 灌能外壳
		{AuraID = 204459, UnitID = "target"},	-- 易伤外壳
		{AuraID = 205289, UnitID = "target"},	-- 毒蝎之赐
		{AuraID = 219823, UnitID = "target"},	-- 势不可挡
		{AuraID = 215066, UnitID = "target"},	-- 人格重合
		{AuraID = 216028, UnitID = "target"},	-- 急速追击
		{AuraID = 219248, UnitID = "target"},	-- 快速生长
		{AuraID = 219270, UnitID = "target"},	-- 过度生长
		{AuraID = 219009, UnitID = "target"},	-- 自然的恩惠
		{AuraID = 209568, UnitID = "target"},	-- 热能释放
		{AuraID = 221863, UnitID = "target"},	-- 护盾
		{AuraID = 221524, UnitID = "target"},	-- 保护，小姐姐前小怪
	-- 萨格拉斯之墓
		{AuraID = 233441, UnitID = "target"},	-- 骨锯
		{AuraID = 239135, UnitID = "target"},	-- 折磨喷发
		{AuraID = 235230, UnitID = "target"},	-- 邪能狂风
		{AuraID = 241521, UnitID = "target"},	-- 苦痛重塑
		{AuraID = 234128, UnitID = "target"},	-- 强制突袭
		{AuraID = 233429, UnitID = "target"},	-- 严寒打击
		{AuraID = 240315, UnitID = "target"},	-- 硬化之壳
		{AuraID = 247781, UnitID = "target"},	-- 激怒
		{AuraID = 241590, UnitID = "target"},	-- 发脾气
		{AuraID = 241594, UnitID = "target"},	-- 愤怒
		{AuraID = 233264, UnitID = "target", Value = true},	-- 月蚀之拥
		{AuraID = 236697, UnitID = "target"},	-- 致命尖叫
		{AuraID = 236513, UnitID = "target"},	-- 骨牢护甲
		{AuraID = 236351, UnitID = "target"},	-- 束缚精华
		{AuraID = 234891, UnitID = "target"},	-- 造物者之怒
		{AuraID = 235028, UnitID = "target", Value = true},	-- 泰坦之壁
		{AuraID = 241008, UnitID = "target", Value = true},	-- 净化协议
		{AuraID = 233739, UnitID = "target"},	-- 故障
		{AuraID = 233961, UnitID = "target"},	-- 矩阵强化
		{AuraID = 236684, UnitID = "target"},	-- 邪能灌注
		{AuraID = 244834, UnitID = "target"},	-- 虚空强风
		{AuraID = 235974, UnitID = "target"},	-- 爆发
		{AuraID = 241564, UnitID = "target"},	-- 悲伤之嚎
		{AuraID = 241606, UnitID = "target"},	-- 波涛起伏
	-- 燃烧王座
		{AuraID = 244106, UnitID = "target"},	-- 灭杀
		{AuraID = 253306, UnitID = "target"},	-- 灵能创伤
		{AuraID = 255805, UnitID = "target"},	-- 不稳定的传送门
		{AuraID = 244383, UnitID = "target"},	-- 烈焰之盾
		{AuraID = 248424, UnitID = "target"},	-- 聚合之力
		{AuraID = 246516, UnitID = "target"},	-- 天启协议
		{AuraID = 246504, UnitID = "target"},	-- 程式启动
		{AuraID = 253203, UnitID = "target"},	-- 破坏魔契约
		{AuraID = 249863, UnitID = "target"},	-- 泰坦的面容
		{AuraID = 244713, UnitID = "target"},	-- 燃烧之怒
		{AuraID = 244894, UnitID = "target"},	-- 腐蚀盾牌
		{AuraID = 247091, UnitID = "target"},	-- 催化
		{AuraID = 253021, UnitID = "target"},	-- 宿命
		{AuraID = 255478, UnitID = "target"},	-- 永恒之刃
		{AuraID = 255496, UnitID = "target"},	-- 宇宙之剑
		-- 星灵易伤
		{AuraID = 255418, UnitID = "target", Text = SPELL_SCHOOL0_NAME}, -- 物理
		{AuraID = 255419, UnitID = "target", Text = SPELL_SCHOOL1_NAME}, -- 神圣
		{AuraID = 255429, UnitID = "target", Text = SPELL_SCHOOL2_NAME}, -- 火焰
		{AuraID = 255422, UnitID = "target", Text = SPELL_SCHOOL3_NAME}, -- 自然
		{AuraID = 255425, UnitID = "target", Text = SPELL_SCHOOL4_NAME}, -- 冰霜
		{AuraID = 255430, UnitID = "target", Text = SPELL_SCHOOL5_NAME}, -- 暗影
		{AuraID = 255433, UnitID = "target", Text = SPELL_SCHOOL6_NAME}, -- 奥术
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
		--{AuraID = 31842, UnitID = "target"},	-- 复仇之怒 神圣
		{AuraID = 31884, UnitID = "target"},	-- 复仇之怒 惩戒
		{AuraID = 33206, UnitID = "target"},	-- 痛苦压制
		{AuraID = 45438, UnitID = "target"},	-- 寒冰屏障
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
		{AuraID = 193526, UnitID = "target"},	-- 百发百中
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
	["InternalCD"] = {		-- 自定义内置冷却组
		{IntID = 240447, Duration = 20},		-- 践踏
		{IntID = 207472, Duration = 30, ItemID = 132444},	-- 萨瓦迪卡
		{IntID = 208052, Duration = 30, ItemID = 132452},	-- 塞弗斯的秘密
	},
}

module:AddNewAuraWatch("ALL", list)