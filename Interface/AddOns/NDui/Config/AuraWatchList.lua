local _, C, L, _ = unpack(select(2, ...))
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
		Raid Buff，是团队重要buff（如嗜血，光环等等）以及被控制时的监控（如被羊被肾击等等）；
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
		--塞弗斯的秘密
		{IntID = 208052, Duration = 30, ItemID = 132452},
		IntID，计时条触发时的BuffID；
		Duration，自定义计时条的冷却/持续时间；
		ItemID，在计时条上显示的名称，如果不填写，就会直接使用触发时的Buff名称。
		这个功能不局限于监视内置CD，可以开发出很多其他用法。
]]

-- Configure
local BuffPoint = {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 309}
local DebuffPoint = {"BOTTOMLEFT", UIParent, "BOTTOM", 200, 309}
local SpecialPoint = {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 336}
local FocusPoint = {"BOTTOMLEFT", UIParent, "LEFT", 5, -130}
local CDPoint = {"BOTTOMRIGHT", UIParent, "BOTTOM", -425, 500}

C.InternalCD = {
	Name = "InternalCD",
	Direction = "UP",
	Interval = 5,
	IconSize = 18,
	BarWidth = 150,
	Pos = {"BOTTOMRIGHT", UIParent, "BOTTOM", -425, 125},
	List = {
		--塞弗斯的秘密
		{IntID = 208052, Duration = 30, ItemID = 132452},
	},
}

C.AuraWatchList = {
	-- 全职业
	["ALL"] = {
		{	Name = "Enchant Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = {"BOTTOMRIGHT", UIParent, "BOTTOM", -200, 377},
			List = {
				--狂暴（巨魔种族天赋）
				{AuraID =  26297, UnitID = "player"},
				--血性狂怒（兽人种族天赋）
				{AuraID =  20572, UnitID = "player"},
				{AuraID =  33697, UnitID = "player"},
		------>LEG药水附魔
				--致命优雅，远程
				{AuraID = 188027, UnitID = "player"},
				--上古战神，近战
				{AuraID = 188028, UnitID = "player"},
				--不屈药水，坦克
				{AuraID = 188029, UnitID = "player"},
				--伟哥
				{AuraID = 229206, UnitID = "player"},
				--利爪之印
				{AuraID = 190909, UnitID = "player"},
				--厚皮之印
				{AuraID = 228399, UnitID = "player"},
				--搏击伟哥
				{AuraID = 230039, UnitID = "player"},
		------>LEG饰品
				--灭绝引擎
				{AuraID = 242612, UnitID = "player"},
				--节拍器
				{AuraID = 225719, UnitID = "player"},
				--黑暗低语
				{AuraID = 225774, UnitID = "player"},
				{AuraID = 225776, UnitID = "player"},
				--地狱火之书
				{AuraID = 215816, UnitID = "player"},
				--罗宁护腕
				{AuraID = 208081, UnitID = "player"},
				--回归打击
				{AuraID = 225736, UnitID = "player"},
				--苏拉玛套装，爆击
				{AuraID = 224151, UnitID = "player"},
				--黑暗打击，+伤害
				{AuraID = 215658, UnitID = "player"},
				--黑暗打击，+护盾
				{AuraID = 215659, UnitID = "player"},
				--专注闪电，+精通
				{AuraID = 215632, UnitID = "player"},
				--混沌能量，+力量/敏捷
				{AuraID = 214831, UnitID = "player"},
				--瓦拉加尔之道，+主属性
				{AuraID = 215956, UnitID = "player"},
				--召云聚气
				{AuraID = 215294, UnitID = "player"},
				--血性狂乱
				{AuraID = 221796, UnitID = "player"},
				--山峰形态，+护盾
				{AuraID = 214423, UnitID = "player", Value = true},
				--安格博达的挽歌
				{AuraID = 214807, UnitID = "player"},
				--席瓦尔的哀嚎
				{AuraID = 214803, UnitID = "player"},
				--因格瓦尔的嚎叫
				{AuraID = 214802, UnitID = "player"},
				--蛮荒诸神之怒，+生命护甲
				{AuraID = 221695, UnitID = "player"},
				--恐惧附肢
				{AuraID = 222166, UnitID = "player"},
				--增速
				{AuraID = 214128, UnitID = "player"},
				--暗夜井能量
				{AuraID = 214572, UnitID = "player"},
				{AuraID = 214577, UnitID = "player", Value = true},
				--艾塔乌斯的星图
				{AuraID = 225749, UnitID = "player"},
				{AuraID = 225752, UnitID = "player"},
				{AuraID = 225753, UnitID = "player"},
				--幻影回想(50%减伤)
				{AuraID = 222479, UnitID = "player"},
				--赛福斯的秘密(通用戒指)
				{AuraID = 208052, UnitID = "player"},
				--诺甘农的预见
				{AuraID = 236430, UnitID = "player"},
				--吸血传染
				{AuraID = 221805, UnitID = "player"},
				--坍缩，戒指
				{AuraID = 234143, UnitID = "player"},
				--艾露恩之光，加主属性
				{AuraID = 215648, UnitID = "player"},
				--军团之眼
				{AuraID = 230152, UnitID = "player"},
				--坍缩之影
				{AuraID = 215476, UnitID = "player"},
				--净化的远古祝福
				{AuraID = 222517, UnitID = "player"},
				{AuraID = 222518, UnitID = "player"},
				{AuraID = 222519, UnitID = "player"},
				--焦镜
				{AuraID = 225726, UnitID = "player"},
				{AuraID = 225729, UnitID = "player"},
				{AuraID = 225730, UnitID = "player"},
				--下冲气流
				{AuraID = 214342, UnitID = "player"},
				--美味蛋糕
				{AuraID = 225723, UnitID = "player"},
				--暗月不朽
				{AuraID = 191624, UnitID = "player"},
				{AuraID = 191625, UnitID = "player"},
				{AuraID = 191626, UnitID = "player"},
				{AuraID = 191627, UnitID = "player"},
				{AuraID = 191628, UnitID = "player"},
				{AuraID = 191629, UnitID = "player"},
				{AuraID = 191630, UnitID = "player"},
				{AuraID = 191631, UnitID = "player"},
				--无尽暗影恐惧石
				{AuraID = 238499, UnitID = "player"},
				{AuraID = 238500, UnitID = "player"},
				{AuraID = 238501, UnitID = "player"},
				--咬一口
				{AuraID = 228461, UnitID = "player"},
				--PVP饰品，+敏捷
				{AuraID = 190026, UnitID = "player"},
				--PVP饰品，+全能
				{AuraID = 170397, UnitID = "player"},
				--海洋污染
				{AuraID = 215670, UnitID = "target", Caster = "player"},
				--野蛮强击，15%易伤
				{AuraID = 214169, UnitID = "target", Caster = "player"},
				--晦暗灵魂，目标伤害降低
				{AuraID = 222209, UnitID = "target", Caster = "player"},
				--烈焰花环
				{AuraID = 230259, UnitID = "target", Caster = "player"},
				--阳光坍缩
				{AuraID = 225746, UnitID = "target", Caster = "player"},
				--抗磨联军的调和
				{AuraID = 242583, UnitID = "player"},
				{AuraID = 242584, UnitID = "player"},
				{AuraID = 242586, UnitID = "player"},
				{AuraID = 243096, UnitID = "player"},
		------>WOD附魔
				--血环之印
				{AuraID = 173322, UnitID = "player"},
				--雷神之印
				{AuraID = 159234, UnitID = "player"},
				--战歌之印
				{AuraID = 159675, UnitID = "player"},
				--霜狼之印
				{AuraID = 159676, UnitID = "player"},
				--影月之印
				{AuraID = 159678, UnitID = "player"},
				--黑石之印
				{AuraID = 159679, UnitID = "player"},
				--瞄准镜
				{AuraID = 156055, UnitID = "player"},--溅射
				{AuraID = 156060, UnitID = "player"},--爆击
				{AuraID = 173288, UnitID = "player"},--精通
				--橙戒
				{AuraID = 177161, UnitID = "player"},--敏捷690
				{AuraID = 177172, UnitID = "player"},--敏捷710
				{AuraID = 177159, UnitID = "player"},--智力690
				{AuraID = 177176, UnitID = "player"},--智力710
				{AuraID = 177160, UnitID = "player"},--力量690
				{AuraID = 177175, UnitID = "player"},--力量710
				{AuraID = 187616, UnitID = "player"},--尼萨姆斯，智力
				{AuraID = 187617, UnitID = "player"},--萨克图斯，坦克
				{AuraID = 187618, UnitID = "player"},--伊瑟拉鲁斯，治疗
				{AuraID = 187619, UnitID = "player"},--索拉苏斯，力量
				{AuraID = 187620, UnitID = "player"},--玛鲁斯，敏捷
		------>WOD药水以及饰品
				--德拉诺敏捷
				{AuraID = 156423, UnitID = "player"},
				--德拉诺智力
				{AuraID = 156426, UnitID = "player"},
				--德拉诺力量
				{AuraID = 156428, UnitID = "player"},
				--德拉诺护甲
				{AuraID = 156430, UnitID = "player"},
				--炼金石
				{AuraID =  60233, UnitID = "player"},--敏捷
				{AuraID =  60229, UnitID = "player"},--力量
				{AuraID =  60234, UnitID = "player"},--智力
			---->传家宝饰品
				--力量
				{AuraID = 201405, UnitID = "player"},
				--敏捷
				{AuraID = 201408, UnitID = "player"},
				--智力
				{AuraID = 201410, UnitID = "player"},
				--坦克
				{AuraID = 202052, UnitID = "player", Value = true},
			},
		},
		{	Name = "Raid Buff",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 45,
			Pos = {"CENTER", UIParent, "CENTER", -220, 200},
			List = {
				--变羊
				{AuraID =    118, UnitID = "player"},
				--制裁之锤
				{AuraID =    853, UnitID = "player"},
				--肾击
				{AuraID =    408, UnitID = "player"},
				--撕扯
				{AuraID =  47481, UnitID = "player"},
				--割碎
				{AuraID =  22570, UnitID = "player"},
				--断筋
				{AuraID =   1715, UnitID = "player"},

				--时间扭曲
				{AuraID =  80353, UnitID = "player"},
				--嗜血
				{AuraID =   2825, UnitID = "player"},
				--英勇
				{AuraID =  32182, UnitID = "player"},
				--熔岩犬：远古狂乱
				{AuraID =  90355, UnitID = "player"},
				--虚空鳐：虚空之风
				{AuraID = 160452, UnitID = "player"},
				--鼓
				{AuraID = 178207, UnitID = "player"},
				--高山战鼓
				{AuraID = 230935, UnitID = "player"},
				--青铜龙的祝福
				{AuraID = 102364, UnitID = "player"},
				--火箭靴
				{AuraID =  54861, UnitID = "player"},

				--狂奔怒吼
				{AuraID =  77761, UnitID = "player"},
				{AuraID =  77764, UnitID = "player"},
				--光环掌握
				{AuraID =  31821, UnitID = "player"},
				--命令怒吼
				{AuraID =  97463, UnitID = "player"},
				--捍卫
				{AuraID = 223658, UnitID = "player"},
				--神圣赞美诗
				{AuraID =  64843, UnitID = "player"},
				--希望象征
				{AuraID =  64901, UnitID = "player"},
				--真言术：障
				{AuraID =  81782, UnitID = "player"},
				--激活
				{AuraID =  29166, UnitID = "player"},
				--五气归元
				{AuraID = 115310, UnitID = "player"},
				--作茧缚命
				{AuraID = 116849, UnitID = "player"},
				--保护祝福
				{AuraID =   1022, UnitID = "player"},
				--牺牲祝福
				{AuraID =   6940, UnitID = "player"},
				--自由祝福
				{AuraID =   1044, UnitID = "player"},
				--破咒祝福
				{AuraID = 204018, UnitID = "player"},
				--铁木树皮
				{AuraID = 102342, UnitID = "player"},
				--守护之魂
				{AuraID =  47788, UnitID = "player"},
				--痛苦压制
				{AuraID =  33206, UnitID = "player"},
				--圣光道标
				{AuraID =  53563, UnitID = "player"},
				--信仰道标
				{AuraID = 156910, UnitID = "player"},
				--灵魂连接图腾
				{AuraID =  98007, UnitID = "player"},
				--狂风图腾
				{AuraID = 192082, UnitID = "player"},
				--大地图腾
				{AuraID = 201633, UnitID = "player"},
				--先祖护佑
				{AuraID = 207498, UnitID = "player"},
				--圣光护盾
				{AuraID = 204150, UnitID = "player"},
			},
		},
		{	Name = "Raid Debuff",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 45,
			Pos = {"CENTER", UIParent, "CENTER", 220, 200},
			List = {
		-->史诗钥石
				--溢出
				{AuraID = 221772, UnitID = "player", Value = true},
		-->卡拉赞
			--夜之魇
				--燃魂
				{AuraID = 228796, UnitID = "player"},
		-->翡翠梦魇
			--尼珊德拉
				--不稳定的腐烂，小怪
				{AuraID = 221028, UnitID = "player"},
				--感染
				{AuraID = 204504, UnitID = "player"},
				--感染意志
				{AuraID = 205043, UnitID = "player"},
				--溃烂
				{AuraID = 203096, UnitID = "player"},
				--爆裂溃烂
				{AuraID = 204463, UnitID = "player"},
				--腐蚀爆发
				{AuraID = 203646, UnitID = "player"},
			--伊格诺斯，腐蚀之心
				--锁定
				{AuraID = 210099, UnitID = "player"},
				--腐蚀之触
				{AuraID = 209469, UnitID = "player"},
				--命运之眼
				{AuraID = 210984, UnitID = "player"},
				--腐化吐息
				{AuraID = 208929, UnitID = "player"},
				--诅咒之血
				{AuraID = 215128, UnitID = "player"},
				--梦魇爆破
				{AuraID = 209471, UnitID = "player"},
			--艾乐瑞瑟雷弗拉尔
				--流毒獠牙
				{AuraID = 210228, UnitID = "player"},
				--痛苦之网
				{AuraID = 215300, UnitID = "player"},
				{AuraID = 215307, UnitID = "player"},
				--死灵毒液
				{AuraID = 215460, UnitID = "player"},
				--扭曲暗影
				{AuraID = 210850, UnitID = "player"},
				--邪掠之爪
				{AuraID = 215582, UnitID = "player"},
				--狂风燃烧
				{AuraID = 218519, UnitID = "player"},
			--乌索克
				--易伤
				{AuraID = 197943, UnitID = "player"},
				--撕裂肉体
				{AuraID = 204859, UnitID = "player"},
				--专注凝视
				{AuraID = 198006, UnitID = "player"},
				--势如破竹
				{AuraID = 198108, UnitID = "player"},
			--梦魇之龙
				--恐惧蔓延
				{AuraID = 204731, UnitID = "player"},
				--渗透之雾
				{AuraID = 205341, UnitID = "player"},
				--被亵渎的藤曼
				{AuraID = 203770, UnitID = "player"},
				--低吼
				{AuraID = 204078, UnitID = "player"},
				--嗜睡梦魇
				{AuraID = 203110, UnitID = "player"},
				--快速传染
				{AuraID = 203787, UnitID = "player"},
				--坍缩梦魇
				{AuraID = 214543, UnitID = "player"},
			--塞纳留斯
				--梦魇荆棘
				{AuraID = 210315, UnitID = "player"},
				--狂暴之触
				{AuraID = 211989, UnitID = "player"},
				--上古之梦
				{AuraID = 216516, UnitID = "player"},
				--梦魇冲击
				{AuraID = 213162, UnitID = "player"},
				--坠入疯狂
				{AuraID = 208431, UnitID = "player"},
			--萨维斯
				--晦暗灵魂
				{AuraID = 206651, UnitID = "player"},
				--黑化灵魂
				{AuraID = 209158, UnitID = "player"},
				--恐惧连接
				{AuraID = 210451, UnitID = "player"},
				{AuraID = 209034, UnitID = "player"},
				--梦魇之刃
				{AuraID = 211802, UnitID = "player"},
				--折磨锁定
				{AuraID = 205771, UnitID = "player"},
		-->勇气试练
			--奥丁
				--雷铸之矛
				{AuraID = 228932, UnitID = "player"},
				--正义风暴
				{AuraID = 227807, UnitID = "player"},
			--高姆
				--影舌舔舐
				{AuraID = 228253, UnitID = "player", Value = true},
				--火舌舔舐
				{AuraID = 228228, UnitID = "player"},
				--冰舌舔舐
				{AuraID = 228248, UnitID = "player"},
			--海拉
				--毒水氧化
				{AuraID = 227982, UnitID = "player"},
				--海洋污染
				{AuraID = 228054, UnitID = "player"},
				--恶臭溃烂
				{AuraID = 193367, UnitID = "player"},
				--铁锚猛击
				{AuraID = 228519, UnitID = "player"},
				--黑暗仇恨
				{AuraID = 232488, UnitID = "player"},
				--腐化脊髓
				{AuraID = 232450, UnitID = "player", Value = true},
		-->暗夜要塞
			--斯可匹隆
				--奥术桎梏
				{AuraID = 204531, UnitID = "player"},
				{AuraID = 211659, UnitID = "player"},
				--聚焦冲击
				{AuraID = 204483, UnitID = "player"},
			--时空畸体
				--时光充能
				{AuraID = 212099, UnitID = "player"},
				--时间炸弹
				{AuraID = 206617, UnitID = "player", Text = L["Get Out"]},
				--时间释放
				{AuraID = 219964, UnitID = "player"},
				{AuraID = 219965, UnitID = "player"},
				{AuraID = 219966, UnitID = "player"},
			--崔利艾克斯
				--奥术梦袭
				{AuraID = 206641, UnitID = "player"},
				--多汁盛宴
				{AuraID = 206838, UnitID = "player"},
				--饱餐一顿
				{AuraID = 214573, UnitID = "player"},
				--吸取活力
				{AuraID = 208499, UnitID = "player"},
				{AuraID = 211615, UnitID = "player"},
				--弧光连接
				{AuraID = 208910, UnitID = "player"},
				{AuraID = 208915, UnitID = "player"},
			--魔剑士奥鲁瑞尔
				--冰霜印记
				{AuraID = 212531, UnitID = "player"},
				{AuraID = 212587, UnitID = "player"},
				{AuraID = 212647, UnitID = "player"},
				--灼热烙印
				{AuraID = 213148, UnitID = "player"},
				--奥术迷雾
				{AuraID = 213504, UnitID = "player"},
			--提克迪奥斯
				--腐肉瘟疫
				{AuraID = 206480, UnitID = "player"},
				--鲜血盛宴
				{AuraID = 208230, UnitID = "player"},
				--幻象之夜
				{AuraID = 206311, UnitID = "player"},
				--阿古斯的烙印
				{AuraID = 212794, UnitID = "player"},
				--腐肉梦魇
				{AuraID = 215988, UnitID = "player"},
				--夜之精华
				{AuraID = 206466, UnitID = "player"},
				--爆裂伤口
				{AuraID = 216024, UnitID = "player"},
				--燃烧的灵魂
				{AuraID = 216040, UnitID = "player"},
			--克洛苏斯
				--灼烧烙印
				{AuraID = 206677, UnitID = "player"},
				--毁灭之球
				{AuraID = 205344, UnitID = "player"},
			--高级植物学家特尔安
				--寄生凝视
				{AuraID = 218342, UnitID = "player"},
				--回归打击
				{AuraID = 218503, UnitID = "player"},
				--寄生镣铐
				{AuraID = 218304, UnitID = "player"},
				--黑夜的召唤
				{AuraID = 218809, UnitID = "player"},
			--占星师艾塔乌斯
				--日冕喷射
				{AuraID = 206464, UnitID = "player"},
				--邪能喷射
				{AuraID = 205649, UnitID = "player"},
				--邪能烈焰
				{AuraID = 206398, UnitID = "player"},
				--寒冰喷射
				{AuraID = 206936, UnitID = "player"},
				--见证虚空
				{AuraID = 207720, UnitID = "player"},
				--冰冻
				{AuraID = 206589, UnitID = "player"},
				--星象三角
				{AuraID = 207831, UnitID = "player"},
				--星座配对
				{AuraID = 205445, UnitID = "player"},
				{AuraID = 205429, UnitID = "player"},
				{AuraID = 216345, UnitID = "player"},
				{AuraID = 216344, UnitID = "player"},
			--大魔导师艾利桑德
				--时间加速
				{AuraID = 209166, UnitID = "player"},
				--减缓时间
				{AuraID = 209165, UnitID = "player"},
				--神秘射线
				{AuraID = 209244, UnitID = "player"},
				--聚合爆破
				{AuraID = 209598, UnitID = "player"},
				--消融
				{AuraID = 209615, UnitID = "player"},
				--消融爆破
				{AuraID = 209973, UnitID = "player"},
				--巨钩
				{AuraID = 211885, UnitID = "player"},
			--古尔丹
				--时间延长
				{AuraID = 210339, UnitID = "player"},
				--消散力场
				{AuraID = 206985, UnitID = "player"},
		-->萨格拉斯之墓
			--格罗斯
				--碎裂星辰
				{AuraID = 233272, UnitID = "player"},
				--燃烧护甲
				{AuraID = 231363, UnitID = "player"},
				--熔化护甲
				{AuraID = 234264, UnitID = "player"},
				--彗星冲撞
				{AuraID = 230345, UnitID = "player"},
			--恶魔审判庭
				--骨锯
				{AuraID = 248741, UnitID = "player"},
				--回响之痛
				{AuraID = 233983, UnitID = "player"},
				--无法忍受的折磨
				{AuraID = 233430, UnitID = "player"},
				--窒息之暗
				{AuraID = 233901, UnitID = "player"},
				--灵魂腐蚀
				{AuraID = 248713, UnitID = "player"},
			--哈亚坦
				--灵魂腐蚀
				{AuraID = 248713, UnitID = "player"},
				--强制突袭
				{AuraID = 234016, UnitID = "player"},
				--滴水
				{AuraID = 241573, UnitID = "player"},
				--锯齿创伤
				{AuraID = 231998, UnitID = "player"},
				--浸透
				{AuraID = 231770, UnitID = "player"},
				--水之爆发
				{AuraID = 231729, UnitID = "player"},
				--病态锁定
				{AuraID = 241600, UnitID = "player"},
			--月之姐妹
				--月蚀之拥
				{AuraID = 233263, UnitID = "player", value = true},
				--急速射击
				{AuraID = 236596, UnitID = "player"},
				--月光信标
				{AuraID = 236712, UnitID = "player"},
				--月光之火
				{AuraID = 239264, UnitID = "player"},
				--月灼
				{AuraID = 236519, UnitID = "player"},
				--无形
				{AuraID = 236550, UnitID = "player"},
				--灵体射击
				{AuraID = 236305, UnitID = "player"},
				--星界易伤
				{AuraID = 236330, UnitID = "player"},
			--主母萨斯琳
				--雷霆震击
				{AuraID = 230362, UnitID = "player"},
				--痛苦负担
				{AuraID = 230201, UnitID = "player"},
				--昏暗隐匿
				{AuraID = 230959, UnitID = "player"},
				--多头蛇酸液
				{AuraID = 232754, UnitID = "player"},
				--污染墨汁
				{AuraID = 232913, UnitID = "player"},
				--美味的增益鱼
				{AuraID = 239375, UnitID = "player"},
				{AuraID = 239362, UnitID = "player"},
			--绝望的聚合体
				--灵魂锁链
				{AuraID = 236361, UnitID = "player"},
				--粉碎意志
				{AuraID = 236340, UnitID = "player"},
				--破碎尖叫
				{AuraID = 236515, UnitID = "player"},
				{AuraID = 238418, UnitID = "player"},
				--灵魂束缚
				{AuraID = 236459, UnitID = "player"},
				--苦痛之矛
				{AuraID = 238442, UnitID = "player", Value = true},
				--枯萎
				{AuraID = 236138, UnitID = "player"},
				{AuraID = 236131, UnitID = "player"},
				--折磨哀嚎
				{AuraID = 236011, UnitID = "player"},
				{AuraID = 238018, UnitID = "player"},
			--戒卫侍女
				--光明灌注
				{AuraID = 235213, UnitID = "player"},
				--邪能灌注
				{AuraID = 235240, UnitID = "player"},
				--动荡的灵魂
				{AuraID = 243276, UnitID = "player"},
				--恶魔活力
				{AuraID = 235538, UnitID = "player"},
				--造物者之赐
				{AuraID = 235534, UnitID = "player"},
				--艾格文的结界
				{AuraID = 241593, UnitID = "player"},
				--邪能残留
				{AuraID = 238408, UnitID = "player"},
				--光明残留
				{AuraID = 238028, UnitID = "player"},
				--反冲
				{AuraID = 248812, UnitID = "player"},
				--碎片爆发
				{AuraID = 248801, UnitID = "player"},
				--复仇的灵魂
				{AuraID = 241729, UnitID = "player"},
			--堕落的化身
				--释放混沌
				{AuraID = 234059, UnitID = "player"},
				--风蚀
				{AuraID = 236494, UnitID = "player"},
				--黑暗印记
				{AuraID = 239739, UnitID = "player"},
				--漆黑之风
				{AuraID = 242017, UnitID = "player"},
				--被污染的矩阵
				{AuraID = 240746, UnitID = "player"},
				--被污染的精华
				{AuraID = 240728, UnitID = "player"},
			--基尔加丹
				--末日之雨
				{AuraID = 234310, UnitID = "player"},
				--邪爪
				{AuraID = 245509, UnitID = "player"},
				--暗影映像：爆发
				{AuraID = 236710, UnitID = "player"},
				--暗影映像：哀嚎
				{AuraID = 236378, UnitID = "player"},
				--末日之雹
				{AuraID = 240916, UnitID = "player"},
				--欺诈者的遮蔽
				{AuraID = 236555, UnitID = "player"},
				--窒息之影
				{AuraID = 241822, UnitID = "player", Value = true},
				--伊利丹的无目凝视
				{AuraID = 241721, UnitID = "player"},
				--燃烧
				{AuraID = 240262, UnitID = "player"},
				--暗影映像：绝望
				{AuraID = 237590, UnitID = "player"},
				--萦绕的希望
				{AuraID = 243621, UnitID = "player"},
				--萦绕的哀嚎
				{AuraID = 243624, UnitID = "player"},
			},
		},
		{	Name = "Warning",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 42,
			Pos = {"BOTTOMLEFT", UIParent, "BOTTOM", 200, 390},
			List = {
			-->勇气试练
				--奥丁，弧光风暴
				{AuraID = 229256, UnitID = "target"},
				--高姆，吐沫狂怒
				{AuraID = 228174, UnitID = "target"},
				--海拉，酝酿风暴
				{AuraID = 228803, UnitID = "target"},
				--小怪，精力
				{AuraID = 203816, UnitID = "target"},
				--小怪，幽灵怒火
				{AuraID = 228611, UnitID = "target"},
			-->卡拉赞
				--国王易伤
				{AuraID = 229495, UnitID = "target"},
			-->大秘
				--血池回血
				{AuraID = 226510, UnitID = "target"},
				--英灵殿赫娅
				{AuraID = 192132, UnitID = "target"},
				{AuraID = 192133, UnitID = "target"},
				--地窟眼球易伤
				{AuraID = 194333, UnitID = "target"},
			-->翡翠梦魇
				--梦魇之怒
				{AuraID = 215234, UnitID = "target"},
				--腐溃之风
				{AuraID = 211137, UnitID = "target"},
				--召云聚气
				{AuraID = 212707, UnitID = "target"},
				--恐惧荆棘光环
				{AuraID = 210346, UnitID = "target"},
				{AuraID = 210340, UnitID = "target"},
			-->暗夜要塞
				--毒蝎虫群
				{AuraID = 204697, UnitID = "target"},
				--几丁质外壳
				{AuraID = 204448, UnitID = "target"},
				{AuraID = 206947, UnitID = "target"},
				--灌能外壳
				{AuraID = 205947, UnitID = "target"},
				--易伤外壳
				{AuraID = 204459, UnitID = "target"},
				--毒蝎之赐
				{AuraID = 205289, UnitID = "target"},
				--势不可挡
				{AuraID = 219823, UnitID = "target"},
				--人格重合
				{AuraID = 215066, UnitID = "target"},
				--急速追击
				{AuraID = 216028, UnitID = "target"},
				--快速生长
				{AuraID = 219248, UnitID = "target"},
				--过度生长
				{AuraID = 219270, UnitID = "target"},
				--自然的恩惠
				{AuraID = 219009, UnitID = "target"},
				--热能释放
				{AuraID = 209568, UnitID = "target"},
				--护盾
				{AuraID = 221863, UnitID = "target"},
				--保护，小姐姐前小怪
				{AuraID = 221524, UnitID = "target"},
			-->萨格拉斯之墓
				--骨锯
				{AuraID = 233441, UnitID = "target"},
				--折磨喷发
				{AuraID = 239135, UnitID = "target"},
				--邪能狂风
				{AuraID = 235230, UnitID = "target"},
				--苦痛重塑
				{AuraID = 241521, UnitID = "target"},
				--强制突袭
				{AuraID = 234128, UnitID = "target"},
				--严寒打击
				{AuraID = 233429, UnitID = "target"},
				--硬化之壳
				{AuraID = 240315, UnitID = "target"},
				--激怒
				{AuraID = 247781, UnitID = "target"},
				--发脾气
				{AuraID = 241590, UnitID = "target"},
				--愤怒
				{AuraID = 241594, UnitID = "target"},
				--月蚀之拥
				{AuraID = 233264, UnitID = "target", value = true},
				--致命尖叫
				{AuraID = 236697, UnitID = "target"},
				--骨牢护甲
				{AuraID = 236513, UnitID = "target"},
				--造物者之怒
				{AuraID = 234891, UnitID = "target"},
				--泰坦之壁
				{AuraID = 235028, UnitID = "target", value = true},
				--净化协议
				{AuraID = 241008, UnitID = "target", value = true},
				--故障
				{AuraID = 233739, UnitID = "target"},
				--矩阵强化
				{AuraID = 233961, UnitID = "target"},
				--邪能灌注
				{AuraID = 236684, UnitID = "target"},
				--虚空强风
				{AuraID = 244834, UnitID = "target"},
				--爆发
				{AuraID = 235974, UnitID = "target"},
				--悲伤之嚎
				{AuraID = 241564, UnitID = "target"},
				--波涛起伏
				{AuraID = 241606, UnitID = "target"},
			-->PLAYER
				--痛苦压制
				{AuraID =  33206, UnitID = "target"},
				--盾墙
				{AuraID =    871, UnitID = "target"},
				--防御姿态
				{AuraID = 197690, UnitID = "target"},
				--援护
				{AuraID = 147833, UnitID = "target"},
				--冰封之韧
				{AuraID =  48792, UnitID = "target"},
				--反魔法护罩
				{AuraID =  48707, UnitID = "target"},
				--保护之手
				{AuraID =   1022, UnitID = "target"},
				--生存本能
				{AuraID =  61336, UnitID = "target"},
				--灵龟守护
				{AuraID = 186265, UnitID = "target"},
				--寒冰屏障
				{AuraID =  45438, UnitID = "target"},
				--强化隐形术
				{AuraID = 113862, UnitID = "target"},
				--剑在人在
				{AuraID = 118038, UnitID = "target"},
				--法术反射
				{AuraID =  23920, UnitID = "target"},
				--升腾
				{AuraID = 114050, UnitID = "target"},	--元素
				{AuraID = 114051, UnitID = "target"},	--增强
				{AuraID = 114052, UnitID = "target"},	--恢复
				--守护之魂
				{AuraID =  47788, UnitID = "target"},
				--圣佑术
				{AuraID =    498, UnitID = "target"},
				--圣盾术
				{AuraID =    642, UnitID = "target"},
				--自由祝福
				{AuraID =   1044, UnitID = "target"},
				--牺牲祝福
				{AuraID =   6940, UnitID = "target"},
				--破咒祝福
				{AuraID = 204018, UnitID = "target"},
				--保护祝福
				{AuraID =   1022, UnitID = "target"},
				--复仇之怒
				{AuraID =  31842, UnitID = "target"},	--神圣
				{AuraID =  31884, UnitID = "target"},	--惩戒
				--以眼还眼
				{AuraID = 205191, UnitID = "target"},	--惩戒
				--狂野怒火
				{AuraID =  19574, UnitID = "target"},
				--百发百中
				{AuraID = 193526, UnitID = "target"},
				--不灭决心
				{AuraID = 104773, UnitID = "target"},
				--闪避
				{AuraID =   5277, UnitID = "target"},
				--还击
				{AuraID = 199754, UnitID = "target"},
				--壮胆酒
				{AuraID = 120954, UnitID = "target"},
				--躯不坏
				{AuraID = 122278, UnitID = "target"},
				--散魔功
				{AuraID = 122783, UnitID = "target"},
				--刃舞
				{AuraID = 188499, UnitID = "target"},
				{AuraID = 210152, UnitID = "target"},
				--混乱之刃
				{AuraID = 211048, UnitID = "target"},
				--疾影
				{AuraID = 212800, UnitID = "target"},
				--恶魔变形
				{AuraID = 162264, UnitID = "target"},
				{AuraID = 187827, UnitID = "target"},
				--爱情光线
				{AuraID = 171607, UnitID = "target"},
			},
		},
	},

	-- 德鲁伊
	["DRUID"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--潜行
				{AuraID =   5215, UnitID = "player"},
				--急奔
				{AuraID =   1850, UnitID = "player"},
				--野性位移
				{AuraID = 137452, UnitID = "player"},
				--回春术
				{AuraID =    774, UnitID = "player"},
				--萌芽
				{AuraID = 155777, UnitID = "player"},
				--愈合
				{AuraID =   8936, UnitID = "player"},
				--生命绽放
				{AuraID =  33763, UnitID = "player"},
				--野性成长
				{AuraID =  48438, UnitID = "player"},
				--野性冲锋：泳速
				{AuraID = 102416, UnitID = "player"},
				--塞纳里奥结界
				{AuraID = 102351, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--低吼
				{AuraID =   6795, UnitID = "target", Caster = "player"},
				--斜掠
				{AuraID = 155722, UnitID = "target", Caster = "player"},
				--割碎
				{AuraID = 203123, UnitID = "target", Caster = "player"},
				--割裂
				{AuraID =   1079, UnitID = "target", Caster = "player"},
				--痛击
				{AuraID = 106830, UnitID = "target", Caster = "player"},
				{AuraID = 192090, UnitID = "target", Caster = "player"},
				--月火术
				{AuraID = 164812, UnitID = "target", Caster = "player"},
				{AuraID = 155625, UnitID = "target", Caster = "player"},
				--阳炎术
				{AuraID = 164815, UnitID = "target", Caster = "player"},
				--纠缠根须
				{AuraID =    339, UnitID = "target", Caster = "player"},
				--野性冲锋：晕眩
				{AuraID =  50259, UnitID = "target", Caster = "player"},
				--野性冲锋：定身
				{AuraID =  45334, UnitID = "target", Caster = "player"},
				--回春术
				{AuraID =    774, UnitID = "target", Caster = "player"},
				--愈合
				{AuraID =   8936, UnitID = "target", Caster = "player"},
				--群体缠绕
				{AuraID = 102359, UnitID = "target", Caster = "player"},
				--蛮力猛击
				{AuraID =   5211, UnitID = "target", Caster = "player"},
				--台风
				{AuraID =  61391, UnitID = "target", Caster = "player"},
				--星界增效
				{AuraID = 197637, UnitID = "target", Caster = "player"},
				--日光术
				{AuraID =  81261, UnitID = "target", Caster = "player"},
				--星辰耀斑
				{AuraID = 202347, UnitID = "target", Caster = "player"},
				--夺魂咆哮
				{AuraID =     99, UnitID = "target", Caster = "player"},
				--乌索尔旋风
				{AuraID = 127797, UnitID = "target", Caster = "player"},
				--加尼尔的精华
				{AuraID = 208253, UnitID = "target", Caster = "player"},
				--生命绽放
				{AuraID =  33763, UnitID = "target", Caster = "player"},
				--野性成长
				{AuraID =  48438, UnitID = "target", Caster = "player"},
				--萌芽
				{AuraID = 155777, UnitID = "target", Caster = "player"},
				--铁木树皮
				{AuraID = 102342, UnitID = "target", Caster = "player"},
				--塞纳里奥结界
				{AuraID = 102351, UnitID = "target", Caster = "player"},
				--栽培
				{AuraID = 200389, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--节能施法
				{AuraID = 135700, UnitID = "player"},
				{AuraID =  16870, UnitID = "player"},
				--猛虎之怒
				{AuraID =   5217, UnitID = "player"},
				--掠食者的迅捷
				{AuraID =  69369, UnitID = "player"},
				--狂暴
				{AuraID = 106951, UnitID = "player"},
				--野性本能
				{AuraID = 210649, UnitID = "player"},
				--生存本能
				{AuraID =  61336, UnitID = "player"},
				--狂暴回复
				{AuraID =  22842, UnitID = "player"},
				--铁鬃
				{AuraID = 192081, UnitID = "player"},
				--野蛮咆哮
				{AuraID =  52610, UnitID = "player"},
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
				{AuraID =  22812, UnitID = "player"},
				--超凡之盟
				{AuraID = 194223, UnitID = "player"},
				--沉睡者之怒
				{AuraID = 200851, UnitID = "player"},
				--血污毛皮
				{AuraID = 201671, UnitID = "player", Combat = true},
				--裂伤
				{AuraID =  93622, UnitID = "player"},
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
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--月火术
				{AuraID = 164812, UnitID = "focus", Caster = "player"},
				--阳炎术
				{AuraID = 164815, UnitID = "focus", Caster = "player"},
				--星辰耀斑
				{AuraID = 202347, UnitID = "focus", Caster = "player"},
				--生命绽放
				{AuraID =  33763, UnitID = "focus", Caster = "player"},
				--回春术
				{AuraID =    774, UnitID = "focus", Caster = "player"},
				--愈合
				{AuraID =   8936, UnitID = "focus", Caster = "player"},
				--萌芽
				{AuraID = 155777, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--生存本能
				{SpellID = 61336, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
				--蘑菇
				{TotemID =     1, UnitID = "player"},
				{TotemID =     2, UnitID = "player"},
				{TotemID =     3, UnitID = "player"},
			},
		},
	},
	
	-- 猎人
	["HUNTER"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--误导
				{AuraID =  35079, UnitID = "player"},
				--伪装
				{AuraID = 199483, UnitID = "player"},
				--迅疾如风
				{AuraID = 118922, UnitID = "player"},
				--灵魂治愈
				{AuraID =  90361, UnitID = "player"},
				--生存专家
				{AuraID = 164857, UnitID = "player"},
				--猎豹守护
				{AuraID = 186258, UnitID = "player"},
				--凶暴野兽
				{AuraID = 120694, UnitID = "player"},
				--守护屏障
				{AuraID = 203924, UnitID = "player"},
				--灵龟守护回血
				{AuraID = 197161, UnitID = "player"},
				--上升气流（双头龙）
				{AuraID = 160007, UnitID = "player"},
				--乱射
				{AuraID = 194386, UnitID = "player", Combat = true},
				--灵巧打击
				{AuraID = 227272, UnitID = "player"},
				--狂轰滥炸
				{AuraID =  82921, UnitID = "player"},
				--治疗宠物
				{AuraID =    136, UnitID = "pet"},
			},
		},	
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--毒蛇钉刺
				{AuraID = 118253, UnitID = "target", Caster = "player"},
				--黑箭
				{AuraID = 194599, UnitID = "target", Caster = "player"},
				--震荡射击
				{AuraID =   5116, UnitID = "target", Caster = "player"},
				--夺命黑鸦
				{AuraID = 131894, UnitID = "target", Caster = "player"},
				{AuraID = 206505, UnitID = "target", Caster = "player"},
				--爆炸陷阱
				{AuraID =  13812, UnitID = "target", Caster = "player"},
				--束缚射击
				{AuraID = 117526, UnitID = "target"},
				--易伤
				{AuraID = 187131, UnitID = "target", Caster = "player"},
				--精确瞄准
				{AuraID = 199803, UnitID = "target", Caster = "player"},
				--猎人印记
				{AuraID = 185365, UnitID = "target", Caster = "player"},
				--翼龙钉刺
				{AuraID =  19386, UnitID = "target", Caster = "player"},
				--胁迫
				{AuraID =  24394, UnitID = "target", Caster = "pet"},
				--野兽狡诈
				{AuraID = 191397, UnitID = "target", Caster = "pet"},
				--裂痕
				{AuraID = 185855, UnitID = "target", Caster = "player"},
				--摔绊
				{AuraID = 195645, UnitID = "target", Caster = "player"},
				--冰冻陷阱
				{AuraID =   3355, UnitID = "target", Caster = "player"},
				--铁蒺藜
				{AuraID = 194279, UnitID = "target", Caster = "player"},
				--精钢陷阱
				{AuraID = 162480, UnitID = "target", Caster = "player"},
				--龙焰手雷
				{AuraID = 194858, UnitID = "target", Caster = "player"},
				--粘性手雷
				{AuraID = 191241, UnitID = "target", Caster = "player"},
				--蝰蛇钉刺
				{AuraID = 202797, UnitID = "target", Caster = "player"},
				--毒蝎钉刺
				{AuraID = 202900, UnitID = "target", Caster = "player"},
				--游侠之网
				{AuraID = 200108, UnitID = "target", Caster = "player"},
				{AuraID = 206755, UnitID = "target", Caster = "player"},
				--爆裂射击
				{AuraID = 224729, UnitID = "target", Caster = "player"},
				--驱散射击
				{AuraID = 213691, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--猎豹守护
				{AuraID = 186257, UnitID = "player"},
				--灵龟守护
				{AuraID = 186265, UnitID = "player"},
				--适者生存
				{AuraID = 190515, UnitID = "player"},
				--稳固集中
				{AuraID = 193534, UnitID = "player"},
				--荷枪实弹
				{AuraID = 194594, UnitID = "player"},
				--野兽瞬劈斩
				{AuraID = 118455, UnitID = "pet"},
				--泰坦之雷
				{AuraID = 207094, UnitID = "pet"},
				--凶猛狂暴
				{AuraID = 217200, UnitID = "pet"},
				--狂野怒火
				{AuraID =  19574, UnitID = "player"},
				--百发百中
				{AuraID = 193526, UnitID = "player"},
				--标记目标
				{AuraID = 223138, UnitID = "player"},
				--野性守护
				{AuraID = 193530, UnitID = "player"},
				--荒野呼唤
				{AuraID = 185791, UnitID = "player"},
				--猫鼬之怒
				{AuraID = 190931, UnitID = "player"},
				--雄鹰守护
				{AuraID = 186289, UnitID = "player"},
				--莫克纳萨战术
				{AuraID = 201081, UnitID = "player"},
				--喷毒眼镜蛇
				{AuraID = 194407, UnitID = "player"},
				--暗影猎手的回复，橙装头
				{AuraID = 208888, UnitID = "player"},
				--正中靶心
				{AuraID = 204090, UnitID = "player"},
				--回转稳定，橙手
				{AuraID = 235712, UnitID = "player", Combat = true},
				--哨兵视野，橙腰
				{AuraID = 208913, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--毒蛇钉刺
				{AuraID = 118253, UnitID = "focus", Caster = "player"},
				--黑箭
				{AuraID = 194599, UnitID = "focus", Caster = "player"},
				--夺命黑鸦
				{AuraID = 131894, UnitID = "focus", Caster = "player"},
				{AuraID = 206505, UnitID = "focus", Caster = "player"},
				--翼龙钉刺
				{AuraID =  19386, UnitID = "focus", Caster = "player"},
				--冰冻陷阱
				{AuraID =   3355, UnitID = "focus", Caster = "player"},
				--易伤
				{AuraID = 187131, UnitID = "focus", Caster = "player"},
				--精确瞄准
				{AuraID = 199803, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--群兽奔腾
				{SpellID =201430, UnitID = "player"},
				--灵龟守护
				{SpellID =186265, UnitID = "player"},
				--野性守护
				{SpellID =193530, UnitID = "player"},
				--百发百中
				{SpellID =193526, UnitID = "player"},
				--反制射击
				{SpellID =147362, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},
	
	-- 法师
	["MAGE"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--寒冰护体
				{AuraID =  11426, UnitID = "player"},
				--烈焰护体
				{AuraID = 235313, UnitID = "player"},
				--棱光屏障
				{AuraID = 235450, UnitID = "player"},
				--隐形术
				{AuraID =  32612, UnitID = "player"},
				--强化隐形术
				{AuraID = 110960, UnitID = "player"},
				--缓落
				{AuraID =    130, UnitID = "player"},
				--灸灼
				{AuraID =  87023, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--点燃(火)
				{AuraID =  12654, UnitID = "target", Caster = "player"},
				--炎爆术(火)
				{AuraID =  11366, UnitID = "target", Caster = "player"},
				--活动炸弹(火)
				{AuraID = 217694, UnitID = "target", Caster = "player"},
				--龙息术(火)
				{AuraID =  31661, UnitID = "target", Caster = "player"},
				--冲击波
				{AuraID = 157981, UnitID = "target", Caster = "player"},
				--变形术
				{AuraID =    118, UnitID = "target", Caster = "player"},
				--冰霜新星
				{AuraID =    122, UnitID = "target", Caster = "player"},
				--冰霜之环
				{AuraID =  82691, UnitID = "target", Caster = "player"},
				--减速
				{AuraID =  31589, UnitID = "target", Caster = "player"},
				--虚空风暴
				{AuraID = 114923, UnitID = "target", Caster = "player"},
				--寒冰炸弹
				{AuraID = 112948, UnitID = "target", Caster = "player"},
				--寒冰箭
				{AuraID = 205708, UnitID = "target", Caster = "player"},
				--冰锥术
				{AuraID = 212792, UnitID = "target", Caster = "player"},
				--寒冰新星
				{AuraID = 157997, UnitID = "target", Caster = "player"},
				--奥术侵蚀
				{AuraID = 210134, UnitID = "target", Caster = "player"},
				--冰川尖刺
				{AuraID = 199786, UnitID = "target", Caster = "player"},
				--冰冻术
				{AuraID =  33395, UnitID = "target", Caster = "pet"},
				--水流喷射
				{AuraID = 135029, UnitID = "target", Caster = "pet"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--寒冰屏障
				{AuraID =  45438, UnitID = "player"},
				--隐没
				{AuraID = 157913, UnitID = "player"},
				--炽热疾速
				{AuraID = 108843, UnitID = "player"},
				--咒术洪流
				{AuraID = 116267, UnitID = "player"},
				--能量符文
				{AuraID = 116014, UnitID = "player"},
				--浮冰
				{AuraID = 108839, UnitID = "player"},
				--气定神闲
				{AuraID = 205025, UnitID = "player"},
				--奥术充能
				{AuraID =  36032, UnitID = "player"},
				--奥术飞弹!
				{AuraID =  79683, UnitID = "player"},
				--奥术强化
				{AuraID =  12042, UnitID = "player"},
				--冰冷血脉
				{AuraID =  12472, UnitID = "player"},
				--寒冰指
				{AuraID =  44544, UnitID = "player"},
				--强化隐形术
				{AuraID = 113862, UnitID = "player"},
				--炽烈之咒
				{AuraID = 194329, UnitID = "player"},
				--炎爆术！
				{AuraID =  48108, UnitID = "player"},
				--热力迸发(火)
				{AuraID =  48107, UnitID = "player"},
				--燃烧
				{AuraID = 190319, UnitID = "player"},
				--置换
				{AuraID = 212799, UnitID = "player"},
				--加速
				{AuraID = 198924, UnitID = "player"},
				--冰刺
				{AuraID = 205473, UnitID = "player"},
				--隐形术
				{AuraID =     66, UnitID = "player"},
				--刺骨冰寒
				{AuraID = 205766, UnitID = "player"},
				--凯尔萨斯的绝招，抱歉护腕
				{AuraID = 209455, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--活动炸弹(火)
				{AuraID =  44457, UnitID = "focus", Caster = "player"},
				--虚空风暴
				{AuraID = 114923, UnitID = "focus", Caster = "player"},
				--寒冰炸弹
				{AuraID = 112948, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--冰冷血脉
				{SpellID = 12472, UnitID = "player"},
				--奥术强化
				{SpellID = 12042, UnitID = "player"},
				--燃烧
				{SpellID =190319, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
				--能量符文
				{TotemID =     1, UnitID = "player"},
			},
		},
	},
	
	-- 战士
	["WARRIOR"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--胜利
				{AuraID =  32216, UnitID = "player"},
				--最后通牒
				{AuraID = 122510, UnitID = "player"},
				--投入战斗
				{AuraID = 202602, UnitID = "player"},
				--战争疤痕
				{AuraID = 200954, UnitID = "player"},
			},
		},	
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--嘲讽
				{AuraID =    355, UnitID = "target", Caster = "player"},
				--冲锋：定身
				{AuraID = 105771, UnitID = "target", Caster = "player"},
				--冲锋：昏迷
				{AuraID =   7922, UnitID = "target", Caster = "player"},
				--挫志怒吼
				{AuraID =   1160, UnitID = "target", Caster = "player"},
				--重伤
				{AuraID = 115767, UnitID = "target", Caster = "player"},
				--雷霆一击
				{AuraID =   6343, UnitID = "target", Caster = "player"},
				--风暴之锤
				{AuraID = 132169, UnitID = "target", Caster = "player"},
				--震荡波
				{AuraID = 132168, UnitID = "target", Caster = "player"},
				--刺耳怒吼
				{AuraID =  12323, UnitID = "target", Caster = "player"},
				--破胆
				{AuraID =   5246, UnitID = "target", Caster = "player"},
				--巨人打击
				{AuraID = 208086, UnitID = "target", Caster = "player"},
				--断筋
				{AuraID =   1715, UnitID = "target", Caster = "player"},
				--致死
				{AuraID = 115804, UnitID = "target", Caster = "player"},
				--撕裂
				{AuraID =    772, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--战吼
				{AuraID =   1719, UnitID = "player"},
				--无视痛苦
				{AuraID = 190456, UnitID = "player", Value = true},
				--维库之力
				{AuraID = 188783, UnitID = "player"},
				--法术反射
				{AuraID =  23920, UnitID = "player"},
				--狂暴之怒
				{AuraID =  18499, UnitID = "player"},
				--盾墙
				{AuraID =    871, UnitID = "player"},
				--怒火聚焦
				{AuraID = 204488, UnitID = "player"},
				{AuraID = 207982, UnitID = "player"},
				--破釜沉舟
				{AuraID =  12975, UnitID = "player"},
				--盾牌格挡
				{AuraID = 132404, UnitID = "player"},
				--狂暴复兴
				{AuraID = 202289, UnitID = "player"},
				--天神下凡
				{AuraID = 107574, UnitID = "player"},
				--腾跃步伐
				{AuraID = 202164, UnitID = "player"},
				--维金斯
				{AuraID = 202573, UnitID = "player"},
				{AuraID = 202574, UnitID = "player"},
				--破坏者
				{AuraID = 152277, UnitID = "player"},
				--激怒
				{AuraID = 184362, UnitID = "player"},
				--狂暴
				{AuraID = 200953, UnitID = "player"},
				--血肉顺劈
				{AuraID =  85739, UnitID = "player"},
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
				{AuraID =  46924, UnitID = "player"},
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
				{AuraID =  60503, UnitID = "player"},
				--剑在人在
				{AuraID = 108038, UnitID = "player"},
				--主宰
				{AuraID = 201009, UnitID = "player"},
				--石之心（橙戒）
				{AuraID = 225947, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--撕裂
				{AuraID =    772, UnitID = "focus", Caster = "player"},
				--重伤
				{AuraID = 115767, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--盾墙
				{SpellID =   871, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},
	
	-- 萨满
	["SHAMAN"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--水上行走
				{AuraID =    546, UnitID = "player"},
				--风暴之鞭
				{AuraID = 195222, UnitID = "player"},
				--疾风
				{AuraID = 198293, UnitID = "player"},
				--空气之怒
				{AuraID = 197211, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--蒺藜
				{AuraID = 207778, UnitID = "target", Caster = "player"},
				--先祖活力
				{AuraID = 207400, UnitID = "target", Caster = "player"},
				--妖术
				{AuraID =  51514, UnitID = "target", Caster = "player"},
				{AuraID = 196942, UnitID = "target", Caster = "player"},
				--激流
				{AuraID =  61295, UnitID = "target", Caster = "player"},
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
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--十万火急
				{AuraID = 208416, UnitID = "player"},
				--迷雾幽灵
				{AuraID = 207527, UnitID = "player"},
				--治疗之雨
				{AuraID =  73920, UnitID = "player"},
				--潮汐奔涌
				{AuraID =  53390, UnitID = "player"},
				--女王的祝福
				{AuraID = 207288, UnitID = "player"},
				--灵魂行者的恩赐
				{AuraID =  79206, UnitID = "player"},
				--生命释放
				{AuraID =  73685, UnitID = "player"},
				--波动
				{AuraID = 216251, UnitID = "player"},
				--先祖指引
				{AuraID = 108281, UnitID = "player"},
				--升腾
				{AuraID = 114050, UnitID = "player"},	--元素
				{AuraID = 114051, UnitID = "player"},	--增强
				{AuraID = 114052, UnitID = "player"},	--恢复
				--幽魂步
				{AuraID =  58875, UnitID = "player"},
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
				{AuraID =  16246, UnitID = "player"},
				--熔岩奔腾
				{AuraID =  77762, UnitID = "player"},
				--漩涡之力
				{AuraID = 191877, UnitID = "player"},
				--风暴守护者
				{AuraID = 205495, UnitID = "player"},
				--元素冲击
				{AuraID = 118522, UnitID = "player"},	--爆击
				{AuraID = 173183, UnitID = "player"},	--急速
				{AuraID = 173184, UnitID = "player"},	--精通
				--冰怒
				{AuraID = 210714, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--妖术
				{AuraID =  51514, UnitID = "focus", Caster = "player"},
				{AuraID = 196942, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--复生
				{SpellID = 20608, UnitID = "player"},
				--升腾
				{SpellID =114050, UnitID = "player"},
				{SpellID =114051, UnitID = "player"},
				{SpellID =114052, UnitID = "player"},
				--治疗之潮
				{SpellID =108280, UnitID = "player"},
				--灵魂链接
				{SpellID = 98008, UnitID = "player"},
				--野性狼魂
				{SpellID =198506, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},
	
	-- 圣骑士
	["PALADIN"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--奉献
				{AuraID = 188370, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--圣光道标
				{AuraID =  53563, UnitID = "target", Caster = "player"},
				--信仰道标
				{AuraID = 156910, UnitID = "target", Caster = "player"},
				--制裁之锤
				{AuraID =    853, UnitID = "target", Caster = "player"},
				--妨害之手
				{AuraID = 183218, UnitID = "target", Caster = "player"},
				--审判
				{AuraID = 197277, UnitID = "target", Caster = "player"},
				{AuraID = 214222, UnitID = "target", Caster = "player"},
				--清算之手
				{AuraID =  62124, UnitID = "target", Caster = "player"},
				--灰烬觉醒
				{AuraID = 205273, UnitID = "target", Caster = "player"},
				--盲目之光
				{AuraID = 105421, UnitID = "target", Caster = "player"},
				--提尔的拯救
				{AuraID = 200654, UnitID = "target", Caster = "player"},
				--赋予信仰
				{AuraID = 223306, UnitID = "target", Caster = "player"},
				--圣光审判
				{AuraID = 196941, UnitID = "target", Caster = "player"},
				--提尔之眼
				{AuraID = 209202, UnitID = "target", Caster = "player"},
				--复仇者之盾
				{AuraID =  31935, UnitID = "target", Caster = "player"},
				--祝福之盾
				{AuraID = 204301, UnitID = "target", Caster = "player"},
				--决一死战
				{AuraID = 204079, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--圣盾术
				{AuraID =    642, UnitID = "player"},
				--复仇之怒
				{AuraID =  31884, UnitID = "player"},
				{AuraID =  31842, UnitID = "player"},
				--征伐
				{AuraID = 231895, UnitID = "player"},
				--神圣意志
				{AuraID = 223819, UnitID = "player"},
				{AuraID = 216413, UnitID = "player"},
				--复仇之盾
				{AuraID = 184662, UnitID = "player", Value = true},
				--正义之火
				{AuraID = 209785, UnitID = "player"},
				--狂热
				{AuraID = 217020, UnitID = "player"},
				--以眼还眼
				{AuraID = 205191, UnitID = "player"},
				--圣洁怒火
				{AuraID = 224668, UnitID = "player"},
				--神圣马驹
				{AuraID = 221885, UnitID = "player"},
				--光环掌握
				{AuraID =  31821, UnitID = "player"},
				--圣佑术
				{AuraID =    498, UnitID = "player"},
				--提尔的拯救
				{AuraID = 200652, UnitID = "player"},
				--律法之则
				{AuraID = 214202, UnitID = "player"},
				--圣光灌注
				{AuraID =  54149, UnitID = "player"},
				--神圣复仇者
				{AuraID = 105809, UnitID = "player"},
				--狂热殉道者
				{AuraID = 223316, UnitID = "player"},
				--美德道标
				{AuraID = 200025, UnitID = "player"},
				--正义盾击
				{AuraID = 132403, UnitID = "player"},
				--炽热防御者
				{AuraID =  31850, UnitID = "player"},
				--远古列王守卫
				{AuraID =  86659, UnitID = "player"},
				--秩序堡垒
				{AuraID = 209388, UnitID = "player", Value = true},
				--炽天使
				{AuraID = 152262, UnitID = "player"},
				--神圣马驹
				{AuraID = 221883, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--圣光道标
				{AuraID =  53563, UnitID = "focus", Caster = "player"},
				--信仰道标
				{AuraID = 156910, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--复仇之怒
				{SpellID = 31884, UnitID = "player"},
				{SpellID = 31842, UnitID = "player"},
				--光环掌握
				{SpellID = 31821, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},

	-- 牧师
	["PRIEST"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--渐隐术
				{AuraID = 	 586, UnitID = "player"},
				--意志坚定
				{AuraID = 194022, UnitID = "player"},
				--真言术：盾
				{AuraID =     17, UnitID = "player"},
				--暗影洞察
				{AuraID = 124430, UnitID = "player"},
				--天堂之羽
				{AuraID = 121557, UnitID = "player"},
				--身心合一
				{AuraID = 214121, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--暗言术:痛
				{AuraID =    589, UnitID = "target", Caster = "player"},
				--吸血鬼之触
				{AuraID =  34914, UnitID = "target", Caster = "player"},
				--心灵尖啸
				{AuraID =   8122, UnitID = "target", Caster = "player"},
				--沉默
				{AuraID =  15487, UnitID = "target", Caster = "player"},
				--真言术：盾
				{AuraID =     17, UnitID = "target", Caster = "player", Value = true},
				--心灵炸弹
				{AuraID = 205369, UnitID = "target", Caster = "player"},
				--心灵尖刺
				{AuraID = 217673, UnitID = "target", Caster = "player"},
				--恢复
				{AuraID =    139, UnitID = "target", Caster = "player"},
				--图雷之光
				{AuraID = 208065, UnitID = "target", Caster = "player"},
				--圣言术：罚
				{AuraID = 200196, UnitID = "target", Caster = "player"},
				{AuraID = 200200, UnitID = "target", Caster = "player"},
				--愈合祷言
				{AuraID =  41635, UnitID = "target", Caster = "player"},
				--身心合一
				{AuraID = 214121, UnitID = "target", Caster = "player"},
				--天堂之羽
				{AuraID = 121557, UnitID = "target", Caster = "player"},
				--闪光力场
				{AuraID = 204263, UnitID = "target", Caster = "player"},
				--救赎
				{AuraID = 194384, UnitID = "target", Caster = "player"},
				--教派分歧
				{AuraID = 214621, UnitID = "target", Caster = "player"},
				--意志洞悉
				{AuraID = 152118, UnitID = "target", Caster = "player"},
				--净化邪恶
				{AuraID = 204213, UnitID = "target", Caster = "player"},
				--惩击
				{AuraID = 208772, UnitID = "target", Caster = "player", Value = true},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--消散
				{AuraID =  47585, UnitID = "player"},
				--吸血鬼的拥抱
				{AuraID =  15286, UnitID = "player"},
				--延宕狂乱
				{AuraID = 197937, UnitID = "player"},
				--虚空形态
				{AuraID = 194249, UnitID = "player"},
				--命运多舛
				{AuraID = 194249, UnitID = "player"},
				--虚空射线
				{AuraID = 205372, UnitID = "player"},
				--能量灌注
				{AuraID =  10060, UnitID = "player"},
				--疯入膏肓
				{AuraID = 193223, UnitID = "player"},
				--纳鲁之能
				{AuraID = 196490, UnitID = "player"},
				--圣光涌动
				{AuraID = 114255, UnitID = "player"},
				--图雷的祝福
				{AuraID = 196644, UnitID = "player"},
				--圣洁
				{AuraID = 197030, UnitID = "player"},
				--神圣化身
				{AuraID = 200183, UnitID = "player"},
				--全神贯注
				{AuraID =  47536, UnitID = "player"},
				--争分夺秒
				{AuraID = 197763, UnitID = "player"},
				--身心合一
				{AuraID =  65081, UnitID = "player"},
				--阴暗面之力
				{AuraID = 198069, UnitID = "player"},
				--命运多舛
				{AuraID = 123254, UnitID = "player"},
				--神牧神器
				{AuraID = 211440, UnitID = "player"},
				{AuraID = 211442, UnitID = "player"},
				--救赎之魂
				{AuraID = 27827, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {				
				--恢复
				{AuraID = 	 139, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--神圣赞美诗
				{SpellID = 64843, UnitID = "player"},
				--痛苦压制
				{SpellID = 33206, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},

	-- 术士
	["WARLOCK"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--灵魂榨取
				{AuraID = 108366, UnitID = "player"},
				--恶魔法阵
				{AuraID =  48018, UnitID = "player"},
				--吞噬之怒
				{AuraID = 199646, UnitID = "player"},
				--灼烧主人
				{AuraID = 119899, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--腐蚀之种
				{AuraID =  27243, UnitID = "target", Caster = "player"},
				--腐蚀术
				{AuraID = 146739, UnitID = "target", Caster = "player"},
				--痛楚
				{AuraID =    980, UnitID = "target", Caster = "player"},
				--痛苦无常
				{AuraID = 233490, UnitID = "target", Caster = "player"},
				{AuraID = 233496, UnitID = "target", Caster = "player"},
				{AuraID = 233497, UnitID = "target", Caster = "player"},
				{AuraID = 233498, UnitID = "target", Caster = "player"},
				{AuraID = 233499, UnitID = "target", Caster = "player"},
				--死亡缠绕
				{AuraID =   6789, UnitID = "target", Caster = "player"},
				--恐惧嚎叫
				{AuraID =   5484, UnitID = "target", Caster = "player"},
				--恐惧
				{AuraID = 118699, UnitID = "target", Caster = "player"},
				--放逐术
				{AuraID =    710, UnitID = "target", Caster = "player"},
				--鬼影缠身
				{AuraID =  48181, UnitID = "target", Caster = "player"},
				--生命虹吸
				{AuraID =  63106, UnitID = "target", Caster = "player"},
				--黑暗契约
				{AuraID = 108416, UnitID = "target", Caster = "player", Value = true},
				--暗影烈焰
				{AuraID = 205181, UnitID = "target", Caster = "player"},
				--暗影之怒
				{AuraID =  30283, UnitID = "target", Caster = "player"},
				--浩劫
				{AuraID =  80240, UnitID = "target", Caster = "player"},
				--末日灾祸
				{AuraID =    603, UnitID = "target", Caster = "player"},
				--魅惑
				{AuraID =   6358, UnitID = "target", Caster = "pet"},
				--献祭
				{AuraID = 157736, UnitID = "target", Caster = "player"},
				--暗影灼烧
				{AuraID =  17877, UnitID = "target", Caster = "player"},
				--根除
				{AuraID = 196414, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--被折磨的灵魂
				{AuraID = 216695, UnitID = "player"},
				--不灭决心
				{AuraID = 104773, UnitID = "player"},
				--痛上加痛
				{AuraID = 199281, UnitID = "player"},
				--暗影启迪
				{AuraID = 196606, UnitID = "player"},
				--爆燃冲刺
				{AuraID = 111400, UnitID = "player"},
				--魔刃风暴
				{AuraID =  89751, UnitID = "pet"},
				--愤怒风暴
				{AuraID = 115831, UnitID = "pet"},
				--恶魔增效
				{AuraID = 193396, UnitID = "pet"},
				--爆燃
				{AuraID = 117828, UnitID = "player"},
				--灵魂收割
				{AuraID = 196098, UnitID = "player"},
				--魔性征兆
				{AuraID = 205146, UnitID = "player"},
				--逆风收割者
				{AuraID = 216708, UnitID = "player"},
				--强化生命分流
				{AuraID = 235156, UnitID = "player"},

			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--痛楚
				{AuraID =    980, UnitID = "focus", Caster = "player"},
				--腐蚀术
				{AuraID = 146739, UnitID = "focus", Caster = "player"},
				--痛苦无常
				{AuraID = 233490, UnitID = "target", Caster = "player"},
				{AuraID = 233496, UnitID = "target", Caster = "player"},
				{AuraID = 233497, UnitID = "target", Caster = "player"},
				{AuraID = 233498, UnitID = "target", Caster = "player"},
				{AuraID = 233499, UnitID = "target", Caster = "player"},
				--末日灾祸
				{AuraID =    603, UnitID = "focus", Caster = "player"},
				--献祭
				{AuraID = 157736, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--灵魂石
				{SpellID = 20707, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},

	-- 盗贼
	["ROGUE"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--潜行
				{AuraID =   1784, UnitID = "player"},
				--疾跑
				{AuraID =   2983, UnitID = "player"},
				--暗影步
				{AuraID =  36554, UnitID = "player"},
				--黑暗之拥
				{AuraID = 197603, UnitID = "player"},
			}
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--偷袭
				{AuraID =   1833, UnitID = "target", Caster = "player"},
				--闷棍
				{AuraID =   6770, UnitID = "target", Caster = "player"},
				--致盲
				{AuraID =   2094, UnitID = "target", Caster = "player"},
				--锁喉
				{AuraID =    703, UnitID = "target", Caster = "player"},
				{AuraID =   1330, UnitID = "target", Caster = "player"},
				--肾击
				{AuraID =    408, UnitID = "target", Caster = "player"},
				--凿击
				{AuraID =   1776, UnitID = "target", Caster = "player"},
				--割裂
				{AuraID =   1943, UnitID = "target", Caster = "player"},
				--君王之灾
				{AuraID = 192759, UnitID = "target", Caster = "player"},
				--宿敌
				{AuraID =  79140, UnitID = "target", Caster = "player"},
				--毒素冲动
				{AuraID = 192425, UnitID = "target", Caster = "player"},
				--出血
				{AuraID =  16511, UnitID = "target", Caster = "player"},
				--苦痛毒液
				{AuraID = 200803, UnitID = "target", Caster = "player"},
				--死亡标记
				{AuraID = 137619, UnitID = "target", Caster = "player"},
				--夜刃
				{AuraID = 195452, UnitID = "target", Caster = "player"},
				--赤喉之咬
				{AuraID = 209786, UnitID = "target", Caster = "player"},
				--暗影打击
				{AuraID = 196958, UnitID = "target", Caster = "player"},
				--鬼魅攻击
				{AuraID = 196937, UnitID = "target", Caster = "player"},
				--正中眉心
				{AuraID = 199804, UnitID = "target", Caster = "player"},
				--遇刺者之血
				{AuraID = 192925, UnitID = "target", Caster = "player"},
			}
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--佯攻
				{AuraID =   1966, UnitID = "player"},
				--闪避
				{AuraID =   5277, UnitID = "player"},
				--暗影斗篷
				{AuraID =  31224, UnitID = "player"},
				--猩红之瓶
				{AuraID = 185311, UnitID = "player"},
				--毒伤
				{AuraID =  32645, UnitID = "player"},
				--消失
				{AuraID =  11327, UnitID = "player"},
				--深谋远虑
				{AuraID = 193641, UnitID = "player"},
				--诡诈
				{AuraID = 115192, UnitID = "player"},
				--敏锐
				{AuraID = 193538, UnitID = "player"},
				--暗影之刃
				{AuraID = 121471, UnitID = "player"},
				--影舞
				{AuraID = 185422, UnitID = "player"},
				--死亡标记
				{AuraID = 212283, UnitID = "player"},
				--隐秘刀刃
				{AuraID = 202754, UnitID = "player"},
				--冲动
				{AuraID =  13750, UnitID = "player"},
				--剑刃乱舞
				{AuraID =  13877, UnitID = "player"},
				--强势连击
				{AuraID = 193356, UnitID = "player"},
				--暗鲨涌动
				{AuraID = 193357, UnitID = "player"},
				--大乱斗
				{AuraID = 193358, UnitID = "player"},
				--双巧手
				{AuraID = 193359, UnitID = "player"},
				--骷髅黑帆
				{AuraID = 199603, UnitID = "player"},
				--埋藏的宝藏
				{AuraID = 199600, UnitID = "player"},
				--恐惧之刃诅咒
				{AuraID = 202665, UnitID = "player"},
				--还击
				{AuraID = 199754, UnitID = "player"},
				--切割
				{AuraID =   5171, UnitID = "player"},
				--可乘之机
				{AuraID = 195627, UnitID = "player"},
				--装死
				{AuraID =  45182, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--闷棍
				{AuraID =   6770, UnitID = "focus", Caster = "player"},
				--致盲
				{AuraID =   2094, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
				--冲动
				{SpellID = 13750, UnitID = "player"},
				--宿敌
				{SpellID = 79140, UnitID = "player"},
				--暗影之刃
				{SpellID =121471, UnitID = "player"},
			},
		},			
	},
	
	-- 死亡骑士
	["DEATHKNIGHT"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--冰霜之路
				{AuraID =   3714, UnitID = "player"},
				--赤色天灾
				{AuraID =  81141, UnitID = "player"},
				--末日突降
				{AuraID =  81340, UnitID = "player"},
				--白霜
				{AuraID =  59052, UnitID = "player"},
				--埋骨之所
				{AuraID = 219788, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--血之疫病
				{AuraID =  55078, UnitID = "target", Caster = "player"},
				--冰霜疫病
				{AuraID =  55095, UnitID = "target", Caster = "player"},
				--恶性瘟疫
				{AuraID = 191587, UnitID = "target", Caster = "player"},
				--心脏打击
				{AuraID = 206930, UnitID = "target", Caster = "player"},
				--黑暗命令
				{AuraID =  56222, UnitID = "target", Caster = "player"},
				--寒冰锁链
				{AuraID =  45524, UnitID = "target", Caster = "player"},
				--冷库严冬
				{AuraID = 211793, UnitID = "target", Caster = "player"},
				--窒息
				{AuraID = 221562, UnitID = "target", Caster = "player"},
				{AuraID = 108194, UnitID = "target", Caster = "player"},
				--鲜血印记
				{AuraID = 206940, UnitID = "target", Caster = "player"},
				--血之镜像
				{AuraID = 206977, UnitID = "target", Caster = "player"},
				--致盲冰雨
				{AuraID = 207167, UnitID = "target", Caster = "player"},
				--溃烂之伤
				{AuraID = 194310, UnitID = "target", Caster = "player"},
				--灵魂收割
				{AuraID = 130736, UnitID = "target", Caster = "player"},
				--亵渎
				{AuraID = 156004, UnitID = "target", Caster = "player"},
				--诸界之灾
				{AuraID = 191748, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--吸血鬼之血
				{AuraID =  55233, UnitID = "player"},
				--反魔法护罩
				{AuraID =  48707, UnitID = "player"},
				--符文刃舞
				{AuraID =  81256, UnitID = "player"},
				--白骨之盾
				{AuraID = 195181, UnitID = "player"},
				--永恒脐带
				{AuraID = 193320, UnitID = "player", Value = true},
				--枯萎凋零
				{AuraID = 188290, UnitID = "player"},
				--灵魂吞噬
				{AuraID = 213003, UnitID = "player"},
				--墓石
				{AuraID = 219809, UnitID = "player", Value = true},
				--符文分流
				{AuraID = 194679, UnitID = "player"},
				--白骨风暴
				{AuraID = 194844, UnitID = "player"},
				--冰封之韧
				{AuraID =  48792, UnitID = "player"},
				--冰霜之柱
				{AuraID =  51271, UnitID = "player"},
				--杀戮机器
				{AuraID =  51124, UnitID = "player"},
				--饥饿符文刃
				{AuraID = 207127, UnitID = "player"},
				--湮灭
				{AuraID = 207256, UnitID = "player"},
				--符文腐蚀
				{AuraID =  51460, UnitID = "player"},
				--邪恶狂乱
				{AuraID = 207290, UnitID = "player"},
				--血肉之盾
				{AuraID = 207319, UnitID = "player"},
				--夺魂
				{AuraID = 215711, UnitID = "player"},
				--亵渎
				{AuraID = 218100, UnitID = "player"},
				--黑暗突变
				{AuraID =  63560, UnitID = "pet"},
				--冷库严冬
				{AuraID = 196770, UnitID = "player"},
				--冰冷之爪
				{AuraID = 194879, UnitID = "player"},
				--不洁之力
				{AuraID =  53365, UnitID = "player"},
				--风暴汇聚
				{AuraID = 211805, UnitID = "player"},
				--冰龙吐息
				{AuraID = 152279, UnitID = "player"},
				--冷酷之心
				{AuraID = 235599, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--血之疫病
				{AuraID = 55078, UnitID = "focus", Caster = "player"},
				--冰霜疫病
				{AuraID = 55095, UnitID = "focus", Caster = "player"},
				--恶性瘟疫
				{AuraID = 191587, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--冰封之韧
				{SpellID = 48792, UnitID = "player"},
				--召唤石鬼像
				{SpellID = 49206, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},

	-- 武僧
	["MONK"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--真气突
				{AuraID = 119085, UnitID = "player"},
				--魂体双分
				{AuraID = 101643, UnitID = "player"},
				--禅院教诲
				{AuraID = 202090, UnitID = "player"},
				--复苏之雾
				{AuraID = 119611, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
				--分筋错骨
				{AuraID = 115078, UnitID = "target", Caster = "player"},
				--豪镇八方
				{AuraID = 116189, UnitID = "target", Caster = "player"},
				--致死之伤
				{AuraID = 115804, UnitID = "target", Caster = "player"},
				--轮回之触
				{AuraID = 115080, UnitID = "target", Caster = "player"},
				--翔龙在天
				{AuraID = 123586, UnitID = "target", Caster = "player"},
				--金刚震
				{AuraID = 116706, UnitID = "target", Caster = "player"},
				--风领主之击
				{AuraID = 205320, UnitID = "target", Caster = "player"},
				--迅如猛虎
				{AuraID = 116841, UnitID = "target", Caster = "player"},
				--扫堂腿
				{AuraID = 119381, UnitID = "target", Caster = "player"},
				--平心之环
				{AuraID = 116844, UnitID = "target", Caster = "player"},
				--醉酿投
				{AuraID = 121253, UnitID = "target", Caster = "player"},
				--爆炸酒桶
				{AuraID = 214326, UnitID = "target", Caster = "player"},
				--火焰之息
				{AuraID = 123725, UnitID = "target", Caster = "player"},
				--作茧缚命
				{AuraID = 116849, UnitID = "target", Caster = "player"},
				--复苏之雾
				{AuraID = 119611, UnitID = "target", Caster = "player"},
				--精华之泉
				{AuraID = 191840, UnitID = "target", Caster = "player"},
				--赤精之歌
				{AuraID = 198909, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
				--业报之触
				{AuraID = 125174, UnitID = "player"},
				--幻灭踢
				{AuraID = 116768, UnitID = "player"},
				--风火雷电
				{AuraID = 137639, UnitID = "player"},
				--躯不坏
				{AuraID = 122278, UnitID = "player"},
				--散魔功
				{AuraID = 122783, UnitID = "player"},
				--平心之环
				{AuraID = 116844, UnitID = "player"},
				--屏气凝神
				{AuraID = 152173, UnitID = "player"},
				--壮胆酒
				{AuraID = 120954, UnitID = "player"},
				--铁骨酒
				{AuraID = 215479, UnitID = "player"},
				--酒有余香
				{AuraID = 214373, UnitID = "player"},
				--神龙之雾
				{AuraID = 199888, UnitID = "player"},
				--升腾状态
				{AuraID = 197206, UnitID = "player"},
				--雷光茶
				{AuraID = 116680, UnitID = "player"},
				--法力茶
				{AuraID = 197908, UnitID = "player"},
				--连击
				{AuraID = 196741, UnitID = "player"},
				--幻灭连击
				{AuraID = 228563, UnitID = "player"},
				--生生不息
				{AuraID = 197916, UnitID = "player"},
				{AuraID = 197919, UnitID = "player"},
				--迅如猛虎
				{AuraID = 116841, UnitID = "player"},
				--转化力量
				{AuraID = 195321, UnitID = "player"},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
				--复苏之雾
				{AuraID = 119611, UnitID = "target", Caster = "player"},
				--分筋错骨
				{AuraID = 115078, UnitID = "focus", Caster = "player"},
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--壮胆酒
				{SpellID =115203, UnitID = "player"},
				--还魂术
				{SpellID =115310, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},

	-- 恶魔猎手
	["DEMONHUNTER"] = {
		{	Name = "Player Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 22,
			Pos = BuffPoint,
			List = {
				--灵魂盛宴
				{AuraID = 207693, UnitID = "player"},
				--献祭光环
				{AuraID = 178740, UnitID = "player"},
				--涅墨西斯
				{AuraID = 208608, UnitID = "player"},
			},
		},
		{	Name = "Target Aura",
			Direction = "RIGHT",
			Interval = 5,
			IconsPerRow = 6,
			Mode = "ICON",
			IconSize = 36,
			Pos = DebuffPoint,
			List = {
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
				--幽魂炸弹
				{AuraID = 224509, UnitID = "target", Caster = "player"},
				--锋锐之刺
				{AuraID = 210003, UnitID = "target", Caster = "player"},
				--悲苦咒符
				{AuraID = 207685, UnitID = "target", Caster = "player"},
			},
		},
		{	Name = "Special Aura",
			Direction = "LEFT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 36,
			Pos = SpecialPoint,
			List = {
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
				{AuraID = 211048, UnitID = "player"},
				--刃舞
				{AuraID = 188499, UnitID = "player"},
				{AuraID = 210152, UnitID = "player"},
				--幻影打击
				{AuraID = 209426, UnitID = "player"},
				--强化结界
				{AuraID = 218256, UnitID = "player"},
				--恶魔尖刺
				{AuraID = 203819, UnitID = "player"},
				--痛苦使者
				{AuraID = 212988, UnitID = "player"},
				--灵魂屏障
				{AuraID = 227225, UnitID = "player", Value = true},
			},
		},
		{	Name = "Focus Aura",
			Direction = "RIGHT",
			Interval = 5,
			Mode = "ICON",
			IconSize = 35,
			Pos = FocusPoint,
			List = {
			},
		},
		{	Name = "Spell Cooldown",
			Direction = "UP",
			Interval = 5,
			Mode = "BAR",
			IconSize = 18,
			BarWidth = 150,
			Pos = CDPoint,
			List = {
				--恶魔变形
				{SpellID =191427, UnitID = "player"},
				{SpellID =187827, UnitID = "player"},
				--饰品
				{SlotID  =    13, UnitID = "player"},
				{SlotID  =    14, UnitID = "player"},
			},
		},
	},
}