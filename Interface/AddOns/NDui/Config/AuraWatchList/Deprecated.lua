local _, ns = ...
local B, C, L, DB = unpack(ns)

-- 旧资料片数据 Auras for old expansions
C.DeprecatedAuras = {
	["Enchant Aura"] = {	-- 附魔及饰品组
		-- SL S2，心能/统御碎片
		{AuraID = 357852, UnitID = "player"},	-- 激励
		{AuraID = 356364, UnitID = "player"},	-- 冰冷的心
		{AuraID = 356043, UnitID = "player"},	-- 森罗万象
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
		{AuraID = 165485, UnitID = "player"},	-- 琪拉的注射器
		{AuraID = 165534, UnitID = "player"},	-- 执行者的晕眩手雷
		{AuraID = 230152, UnitID = "player"},	-- 命令之眼

		{AuraID = 367241, UnitID = "player"},	-- 原初印记
		{AuraID = 363522, UnitID = "player"},	-- 角斗士的永恒结界
		{AuraID = 362699, UnitID = "player"},	-- 角斗士的决心
		{AuraID = 345231, UnitID = "player"},	-- 角斗士的纹章
		{AuraID = 368641, UnitID = "player"},	-- 最终符文
		-- 8.0
		{AuraID = 229206, UnitID = "player"},	-- 延时之力
		{AuraID = 251231, UnitID = "player"},	-- 钢肤药水
		{AuraID = 279151, UnitID = "player"},	-- 智力药水
		{AuraID = 279152, UnitID = "player"},	-- 敏捷药水
		{AuraID = 279153, UnitID = "player"},	-- 力量药水
		{AuraID = 279154, UnitID = "player"},	-- 耐力药水
		{AuraID = 298155, UnitID = "player"},	-- 超强钢肤药水
		{AuraID = 298152, UnitID = "player"},	-- 超强智力药水
		{AuraID = 298146, UnitID = "player"},	-- 超强敏捷药水
		{AuraID = 298154, UnitID = "player"},	-- 超强力量药水
		{AuraID = 298153, UnitID = "player"},	-- 超强耐力药水
		{AuraID = 298225, UnitID = "player"},	-- 邻位强化药水
		{AuraID = 298317, UnitID = "player"},	-- 专注决心药水
		{AuraID = 300714, UnitID = "player"},	-- 无拘之怒药水
		{AuraID = 300741, UnitID = "player"},	-- 狂野愈合药水
		{AuraID = 188024, UnitID = "player"},	-- 天行药水
		{AuraID = 250878, UnitID = "player"},	-- 轻足药水
		{AuraID = 290365, UnitID = "player"},	-- 辉煌蓝宝石
		{AuraID = 277179, UnitID = "player"},	-- 角斗士勋章
		{AuraID = 277181, UnitID = "player"},	-- 角斗士徽记
		{AuraID = 277187, UnitID = "player"},	-- 角斗士纹章
		{AuraID = 277185, UnitID = "player"},	-- 角斗士徽章
		{AuraID = 286342, UnitID = "player", Value = true},	-- 角斗士的护徽
		{AuraID = 275765, UnitID = "player"},	-- 艾泽里特强化
		{AuraID = 271194, UnitID = "player"},	-- 火炮
		{AuraID = 273992, UnitID = "player"},	-- 灵魂之速
		{AuraID = 273955, UnitID = "player"},	-- 望远镜视野
		{AuraID = 267612, UnitID = "player"},	-- 迅击风暴
		{AuraID = 268887, UnitID = "player"},	-- 迅捷远航
		{AuraID = 268893, UnitID = "player"},	-- 迅捷远航
		{AuraID = 268854, UnitID = "player"},	-- 全能远航
		{AuraID = 268856, UnitID = "player"},	-- 全能远航
		{AuraID = 268904, UnitID = "player"},	-- 致命远航
		{AuraID = 268905, UnitID = "player"},	-- 致命远航
		{AuraID = 268898, UnitID = "player"},	-- 精湛远航
		{AuraID = 268899, UnitID = "player"},	-- 精湛远航
		{AuraID = 264957, UnitID = "player"},	-- 急速瞄准镜
		{AuraID = 264878, UnitID = "player"},	-- 爆击瞄准镜
		{AuraID = 267685, UnitID = "player"},	-- 元素洪流
		{AuraID = 274472, UnitID = "player"},	-- 狂战士之怒
		{AuraID = 268769, UnitID = "player"},	-- 标记死穴
		{AuraID = 267179, UnitID = "player"},	-- 瓶中的电荷
		{AuraID = 278070, UnitID = "player"},	-- 泰坦过载
		{AuraID = 271103, UnitID = "player"},	-- 莱赞的微光之眼
		{AuraID = 273942, UnitID = "player"},	-- 提振精神
		{AuraID = 268518, UnitID = "player"},	-- 狂风风铃
		{AuraID = 265946, UnitID = "player", Value = true},	-- 仪式裹手
		{AuraID = 278143, UnitID = "player"},	-- 血珠狂怒
		{AuraID = 278381, UnitID = "player"},	-- 海上风暴
		{AuraID = 273974, UnitID = "player"},	-- 洛阿意志
		{AuraID = 271105, UnitID = "player"},	-- 屠夫之眼
		{AuraID = 271107, UnitID = "player"},	-- 金色光泽
		{AuraID = 278231, UnitID = "player"},	-- 森林之王的愤怒
		{AuraID = 278267, UnitID = "player"},	-- 森林之王的智慧
		{AuraID = 268311, UnitID = "player", Flash = true},	-- 唤风者之赐
		{AuraID = 285489, UnitID = "player"},	-- 黑喉之力
		{AuraID = 278317, UnitID = "player"},	-- 末日余波
		{AuraID = 278806, UnitID = "player"},	-- 雄狮谋略
		{AuraID = 278249, UnitID = "player"},	-- 刀叶风暴
		{AuraID = 287916, UnitID = "player", Stack = 6, Flash = true, Combat = true},	-- 反应堆
		{AuraID = 287917, UnitID = "player"},	-- 振荡过载
		{AuraID = 265954, UnitID = "player"},	-- 黄金之触
		{AuraID = 268439, UnitID = "player"},	-- 共鸣之心
		{AuraID = 278225, UnitID = "player"},	-- 缚魂巫毒瘤节
		{AuraID = 278388, UnitID = "player"},	-- 永冻护壳之心
		{AuraID = 274430, UnitID = "player", Text = L["Haste"]},	-- 永不间断的时钟，急速
		{AuraID = 274431, UnitID = "player", Text = L["Mastery"]},	-- 精通
		--{AuraID = 267325, UnitID = "player", Text = L["Mastery"]},	-- 注铅骰子，精通
		--{AuraID = 267326, UnitID = "player", Text = L["Mastery"]},	-- 精通
		--{AuraID = 267327, UnitID = "player", Text = L["Haste"]},	-- 急速
		--{AuraID = 267329, UnitID = "player", Text = L["Haste"]},	-- 急速
		--{AuraID = 267330, UnitID = "player", Text = L["Crit"]},	-- 爆击
		--{AuraID = 267331, UnitID = "player", Text = L["Crit"]},	-- 爆击
		{AuraID = 280573, UnitID = "player", Combat = true},	-- 重组阵列
		{AuraID = 289523, UnitID = "player", Combat = true},	-- 耀辉之光
		{AuraID = 295408, UnitID = "player"},	-- 险恶赐福
		{AuraID = 273988, UnitID = "player"},	-- 原始本能
		{AuraID = 285475, UnitID = "player"},	-- 卡亚矿涌流
		{AuraID = 306242, UnitID = "player"},	-- 红卡重置
		{AuraID = 285482, UnitID = "player"},	-- 海巨人的凶猛
		{AuraID = 303570, UnitID = "player", Flash = true},	-- 锋锐珊瑚
		{AuraID = 303568, UnitID = "target", Caster = "player"},	-- 锋锐珊瑚
		{AuraID = 301624, UnitID = "target", Caster = "player"},	-- 颤栗毒素
		{AuraID = 302565, UnitID = "target", Caster = "player"},	-- 导电墨汁
		{AuraID = 296962, UnitID = "player"},	-- 艾萨拉饰品
		{AuraID = 315787, UnitID = "player", Caster = "player"},	-- 生命充能
		-- 艾泽里特特质
		{AuraID = 274598, UnitID = "player"},	-- 冲击大师
		{AuraID = 277960, UnitID = "player"},	-- 神经电激
		{AuraID = 280852, UnitID = "player"},	-- 解放者之力
		{AuraID = 266047, UnitID = "player"},	-- 激励咆哮
		{AuraID = 280409, UnitID = "player"},	-- 血祭之力
		{AuraID = 279902, UnitID = "player"},	-- 不稳定的烈焰
		{AuraID = 281843, UnitID = "player"},	-- 汇帆
		{AuraID = 280204, UnitID = "player"},	-- 徘徊的灵魂
		{AuraID = 273685, UnitID = "player"},	-- 缜密计谋
		{AuraID = 273714, UnitID = "player"},	-- 争分夺秒
		{AuraID = 274443, UnitID = "player"},	-- 死亡之舞
		{AuraID = 280433, UnitID = "player"},	-- 呼啸狂沙
		{AuraID = 271711, UnitID = "player"},	-- 压倒能量
		{AuraID = 272733, UnitID = "player"},	-- 弦之韵律
		{AuraID = 280780, UnitID = "player"},	-- 战斗荣耀
		{AuraID = 280787, UnitID = "player"},	-- 反击之怒
		{AuraID = 280385, UnitID = "player"},	-- 压力渐增
		{AuraID = 273842, UnitID = "player"},	-- 深渊秘密
		{AuraID = 273843, UnitID = "player"},	-- 深渊秘密
		{AuraID = 280412, UnitID = "player"},	-- 激励兽群
		{AuraID = 274596, UnitID = "player"},	-- 冲击大师
		{AuraID = 277969, UnitID = "player"},	-- 迅疾爪击
		{AuraID = 273264, UnitID = "player"},	-- 怒火升腾
		{AuraID = 280653, UnitID = "player"},	-- 工程特质，变小
		{AuraID = 280654, UnitID = "player"},	-- 工程特质，变大
		{AuraID = 273525, UnitID = "player"},	-- 大难临头
		{AuraID = 274373, UnitID = "player"},	-- 溃烂之力
		{AuraID = 280170, UnitID = "player", Value = true},	-- 假死盾
		-- 艾泽里特精华
		{AuraID = 302932, UnitID = "player", Flash = true},	-- 无畏之力
		{AuraID = 297126, UnitID = "player"},	-- 仇敌之血
		{AuraID = 297168, UnitID = "player"},	-- 仇敌之血
		{AuraID = 304056, UnitID = "player"},	-- 斗争
		{AuraID = 298343, UnitID = "player"},	-- 清醒梦境
		{AuraID = 295855, UnitID = "player"},	-- 艾泽拉斯守护者
		{AuraID = 295248, UnitID = "player"},	-- 专注能量
		{AuraID = 298357, UnitID = "player"},	-- 清醒梦境之忆
		{AuraID = 302731, UnitID = "player", Flash = true},	-- 空间涟漪
		{AuraID = 302952, UnitID = "player"},	-- 现实流转
		{AuraID = 295137, UnitID = "player", Flash = true},	-- 源血
		{AuraID = 311203, UnitID = "player"},	-- 光荣时刻
		{AuraID = 311202, UnitID = "player"},	-- 收割火焰
		{AuraID = 312915, UnitID = "player"},	-- 共生姿态
		{AuraID = 295354, UnitID = "player"},	-- 精华协议
		-- 腐蚀
		{AuraID = 318378, UnitID = "player", Flash = true},	-- 坚定决心，橙披
		{AuraID = 317859, UnitID = "player"},	-- 龙族强化，橙披
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
	},
	["Raid Debuff"] = {		-- 团队减益组
		-- 9.0赛季词缀
		{AuraID = 366288, UnitID = "player"},	-- 解构
		{AuraID = 368239, UnitID = "player", Flash = true, Text = "CD"},	-- 减CD密文
		{AuraID = 368240, UnitID = "player", Flash = true, Text = L["Haste"]},	-- 急速密文
		{AuraID = 368241, UnitID = "player", Flash = true, Text = L["Speed"]},	-- 移速密文
		{AuraID = 358777, UnitID = "player"},	-- 痛苦之链
		{AuraID = 355732, UnitID = "player"},	-- 融化灵魂
		{AuraID = 356667, UnitID = "player"},	-- 刺骨之寒
		{AuraID = 356925, UnitID = "player"},	-- 屠戮
		{AuraID = 342466, UnitID = "player"},	-- 狂妄吹嘘，S1
		{AuraID = 340880, UnitID = "player"},	-- 傲慢
		-- 9.0 5人本
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
		{AuraID = 322746, UnitID = "player"},	-- 彼界，堕落之血
		{AuraID = 323692, UnitID = "player"},	-- 彼界，奥术易伤
		{AuraID = 331379, UnitID = "player"},	-- 彼界，润滑剂
		{AuraID = 320786, UnitID = "player"},	-- 彼界，势不可挡
		{AuraID = 323687, UnitID = "player", Flash = true},	-- 彼界，奥术闪电
		{AuraID = 327893, UnitID = "player", Flash = true},	-- 彼界，邦桑迪的热情
		{AuraID = 339978, UnitID = "player", Flash = true},	-- 彼界，安抚迷雾
		{AuraID = 323569, UnitID = "player", Flash = true},	-- 彼界，溅洒精魂
		{AuraID = 334496, UnitID = "player", Stack = 7, Flash = true},	-- 彼界，催眠光粉
		{AuraID = 328453, UnitID = "player"},	-- 晋升高塔，压迫
		{AuraID = 335805, UnitID = "player", Flash = true},	-- 晋升高塔，执政官的壁垒
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
		{AuraID = 357042, UnitID = "player"},	-- 集市，凌光炸弹
		{AuraID = 359019, UnitID = "player", Flash = true},	-- 集市，快拍提速
		{AuraID = 173324, UnitID = "player", Flash = true},	-- 码头，锯齿蒺藜
		{AuraID = 172963, UnitID = "player", Flash = true},	-- 码头，破门斩斧
		{AuraID = 160681, UnitID = "player", Flash = true},	-- 车站，火力压制
		{AuraID = 166676, UnitID = "player", Flash = true},	-- 车站，榴弹爆破
		{AuraID = 291937, UnitID = "player", Flash = true},	-- 车间，垃圾掩体
		{AuraID = 230087, UnitID = "player", Flash = true},	-- 卡上，振作
		{AuraID = 228993, UnitID = "player", Flash = true},	-- 卡下，腐蚀之池
		{AuraID = 228331, UnitID = "player", Flash = true},	-- 卡下，爆裂充能
		{AuraID = 227480, UnitID = "player", Flash = true},	-- 卡下，烈焰狂风
		-- 9.0 团本
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
		{AuraID = 360403, UnitID = "player"},	-- 力场，警戒卫士
		{AuraID = 361751, UnitID = "player", Flash = true},	-- 衰变光环，道茜歌妮
		-- 8.0 5人本
		{AuraID = 314478, UnitID = "player"},	-- 倾泻恐惧
		{AuraID = 314483, UnitID = "player"},	-- 倾泻恐惧
		{AuraID = 314411, UnitID = "player"},	-- 疑云密布
		{AuraID = 314406, UnitID = "player"},	-- 致残疾病
		{AuraID = 314565, UnitID = "player", Flash = true},	-- 亵渎大地
		{AuraID = 314392, UnitID = "player", Flash = true},	-- 邪恶腐化物
		{AuraID = 314308, UnitID = "player", Flash = true},	-- 灵魂毁灭
		{AuraID = 314531, UnitID = "player"},	-- 撕扯血肉
		{AuraID = 302420, UnitID = "player"},	-- 女王法令：隐藏

		{AuraID = 260954, UnitID = "player"},	-- 铁之凝视，围攻
		{AuraID = 272421, UnitID = "player"},	-- 瞄准火炮，围攻
		{AuraID = 265773, UnitID = "player"},	-- 吐金，诸王
		{AuraID = 271564, UnitID = "player", Flash = true},	-- 防腐液，诸王
		{AuraID = 271640, UnitID = "player"},	-- 黑暗启示，诸王
		{AuraID = 274507, UnitID = "player"},	-- 湿滑肥皂，自由镇
		{AuraID = 266923, UnitID = "player"},	-- 充电，神庙
		{AuraID = 273563, UnitID = "player", Text = L["Freeze"]},	-- 神经毒素，神庙
		{AuraID = 269686, UnitID = "player"},	-- 瘟疫，神庙
		{AuraID = 257407, UnitID = "player"},	-- 追踪，阿塔达萨
		{AuraID = 250585, UnitID = "player", Flash = true},	-- 剧毒之池，阿塔达萨
		{AuraID = 258723, UnitID = "player", Flash = true},	-- 怪诞之池，阿塔达萨
		{AuraID = 258058, UnitID = "player"},	-- 挤压，托尔达戈
		{AuraID = 260067, UnitID = "player"},	-- 恶毒槌击，托尔达戈
		{AuraID = 273226, UnitID = "player"},	-- 腐烂孢子，孢林
		{AuraID = 269838, UnitID = "player", Flash = true},	-- 邪恶污染，孢林
		{AuraID = 259718, UnitID = "player"},	-- 颠覆
		{AuraID = 276297, UnitID = "player"},	-- 虚空种子，风暴神殿
		{AuraID = 274438, UnitID = "player", Flash = true},	-- 风暴
		{AuraID = 276286, UnitID = "player"},	-- 切割旋风
		{AuraID = 267818, UnitID = "player"},	-- 切割冲击
		{AuraID = 268086, UnitID = "player", Text = L["Move"]},	-- 恐怖光环，庄园
		{AuraID = 298602, UnitID = "player"},	-- 烟云，麦卡贡
		{AuraID = 293724, UnitID = "player"},	-- 护盾发生器
		{AuraID = 297257, UnitID = "player"},	-- 电荷充能
		{AuraID = 303885, UnitID = "player"},	-- 爆裂喷发
		{AuraID = 291928, UnitID = "player"},	-- 超荷电磁炮
		{AuraID = 292267, UnitID = "player"},	-- 超荷电磁炮
		{AuraID = 305699, UnitID = "player"},	-- 锁定
		{AuraID = 302274, UnitID = "player"},	-- 爆裂冲击
		{AuraID = 298669, UnitID = "player"},	-- 跳电
		{AuraID = 294929, UnitID = "player"},	-- 烈焰撕咬
		{AuraID = 259533, UnitID = "player", Flash = true},	-- 艾泽里特催化剂，暴富
	-- 尼奥罗萨
		-- 黑龙帝王拉希奥
		{AuraID = 306015, UnitID = "player"},	-- 灼烧护甲
		{AuraID = 306163, UnitID = "player"},	-- 万物尽焚
		{AuraID = 313959, UnitID = "player", Flash = true},	-- 灼热气泡
		{AuraID = 307053, UnitID = "player", Flash = true},	-- 岩浆池
		{AuraID = 314347, UnitID = "player"},	-- 毒扼
		-- 玛乌特
		{AuraID = 307399, UnitID = "player"},	-- 暗影之伤
		{AuraID = 307806, UnitID = "player"},	-- 吞噬魔法
		{AuraID = 307586, UnitID = "player"},	-- 噬魔深渊
		{AuraID = 306301, UnitID = "player"},	-- 禁忌法力
		{AuraID = 315025, UnitID = "player"},	-- 远古诅咒
		{AuraID = 314993, UnitID = "player", Flash = true},	-- 吸取精华
		-- 先知斯基特拉
		{AuraID = 308059, UnitID = "player"},	-- 暗影震击
		{AuraID = 307950, UnitID = "player", Flash = true},	-- 心智剥离
		-- 黑暗审判官夏奈什
		{AuraID = 311551, UnitID = "player"},	-- 深渊打击
		{AuraID = 312406, UnitID = "player"},	-- 虚空觉醒
		{AuraID = 314298, UnitID = "player", Flash = true},	-- 末日迫近
		{AuraID = 316211, UnitID = "player"},	-- 恐惧浪潮
		-- 主脑
		{AuraID = 313461, UnitID = "player"},	-- 腐蚀
		{AuraID = 315311, UnitID = "player"},	-- 毁灭
		{AuraID = 313672, UnitID = "player", Flash = true},	-- 酸液池
		{AuraID = 314593, UnitID = "player"},	-- 麻痹毒液
		-- 无厌者夏德哈
		{AuraID = 307471, UnitID = "player"},	-- 碾压
		{AuraID = 307472, UnitID = "player"},	-- 融解
		{AuraID = 306928, UnitID = "player"},	-- 幽影吐息
		{AuraID = 306930, UnitID = "player"},	-- 熵能暗息
		{AuraID = 314736, UnitID = "player", Flash = true},	-- 气泡流溢
		{AuraID = 318078, UnitID = "player", Flash = true, Text = L["Get Out"]},	-- 锁定
		-- 德雷阿佳丝
		{AuraID = 310277, UnitID = "player"},	-- 动荡之种
		{AuraID = 310309, UnitID = "player"},	-- 动荡易伤
		{AuraID = 310361, UnitID = "player"},	-- 不羁狂乱
		{AuraID = 308377, UnitID = "player"},	-- 虚化脓液
		{AuraID = 317001, UnitID = "player"},	-- 暗影排异
		{AuraID = 310563, UnitID = "player"},	-- 背叛低语
		{AuraID = 310567, UnitID = "player"},	-- 背叛者
		-- 伊格诺斯，重生之蚀
		{AuraID = 309961, UnitID = "player"},	-- 恩佐斯之眼
		{AuraID = 311367, UnitID = "player"},	-- 腐蚀者之触
		{AuraID = 310322, UnitID = "player", Flash = true},	-- 梦魇腐蚀
		{AuraID = 313759, UnitID = "player"},	-- 诅咒之血
		-- 维克修娜
		{AuraID = 307359, UnitID = "player"},	-- 绝望
		{AuraID = 307020, UnitID = "player"},	-- 暮光之息
		{AuraID = 307019, UnitID = "player"},	-- 虚空腐蚀
		{AuraID = 306981, UnitID = "player"},	-- 虚空之赐
		{AuraID = 310224, UnitID = "player"},	-- 毁灭
		{AuraID = 307314, UnitID = "player"},	-- 渗透暗影
		{AuraID = 307343, UnitID = "player"},	-- 暗影残渣
		{AuraID = 307645, UnitID = "player"},	-- 黑暗之心
		{AuraID = 315932, UnitID = "player"},	-- 蛮力重击
		-- 虚无者莱登
		{AuraID = 313977, UnitID = "player"},	-- 虚空诅咒，小怪
		{AuraID = 306184, UnitID = "player", Value = true},	-- 释放的虚空
		{AuraID = 306819, UnitID = "player"},	-- 虚化重击
		{AuraID = 306279, UnitID = "player"},	-- 动荡暴露
		{AuraID = 306637, UnitID = "player"},	-- 不稳定的虚空爆发
		{AuraID = 309777, UnitID = "player"},	-- 虚空污秽
		{AuraID = 313227, UnitID = "player"},	-- 腐坏伤口
		{AuraID = 310019, UnitID = "player"},	-- 充能锁链
		{AuraID = 310022, UnitID = "player"},	-- 充能锁链
		{AuraID = 315252, UnitID = "player"},	-- 恐怖炼狱
		{AuraID = 316065, UnitID = "player"},	-- 腐化存续
		-- 恩佐斯的外壳
		{AuraID = 307832, UnitID = "player"},	-- 恩佐斯的仆从
		{AuraID = 313334, UnitID = "player"},	-- 恩佐斯之赐
		{AuraID = 315954, UnitID = "player"},	-- 漆黑伤疤
		{AuraID = 307044, UnitID = "player"},	-- 梦魇抗原
		{AuraID = 307011, UnitID = "player"},	-- 疯狂繁衍
		{AuraID = 307061, UnitID = "player"},	-- 菌丝生长
		{AuraID = 306973, UnitID = "player"},	-- 疯狂炸弹
		{AuraID = 306984, UnitID = "player"},	-- 狂乱炸弹
		-- 腐蚀者恩佐斯
		{AuraID = 308996, UnitID = "player"},	-- 恩佐斯的仆从
		{AuraID = 313609, UnitID = "player"},	-- 恩佐斯之赐
		{AuraID = 309991, UnitID = "player"},	-- 痛楚
		{AuraID = 316711, UnitID = "player"},	-- 意志摧毁
		{AuraID = 313400, UnitID = "player"},	-- 堕落心灵
		{AuraID = 316542, UnitID = "player"},	-- 妄念
		{AuraID = 316541, UnitID = "player"},	-- 妄念
		{AuraID = 310042, UnitID = "player"},	-- 混乱爆发
		{AuraID = 313793, UnitID = "player"},	-- 狂乱之火
		{AuraID = 313610, UnitID = "player"},	-- 精神腐烂
		{AuraID = 311392, UnitID = "player"},	-- 心灵之握
		{AuraID = 310073, UnitID = "player"},	-- 心灵之握
		{AuraID = 317112, UnitID = "player"},	-- 激荡痛楚
	-- 永恒王宫
		-- 深渊指挥官西瓦拉
		{AuraID = 295795, UnitID = "player", Flash = true, Text = L["Move"]},	-- 冻结之血
		{AuraID = 295796, UnitID = "player", Flash = true, Text = L["Freeze"]},	-- 漫毒之血
		{AuraID = 295807, UnitID = "player"},	-- 冻结之血
		{AuraID = 295850, UnitID = "player"},	-- 癫狂
		{AuraID = 294847, UnitID = "player"},	-- 不稳定混合物
		{AuraID = 300883, UnitID = "player"},	-- 倒置之疾
		{AuraID = 300701, UnitID = "player"},	-- 白霜
		{AuraID = 300705, UnitID = "player"},	-- 脓毒污染
		{AuraID = 295348, UnitID = "player"},	-- 溢流寒霜
		{AuraID = 295421, UnitID = "player"},	-- 溢流毒液
		{AuraID = 300961, UnitID = "player", Flash = true},	-- 冰霜之地
		{AuraID = 300962, UnitID = "player", Flash = true},	-- 败血之地
		-- 黑水巨鳗
		{AuraID = 298428, UnitID = "player"},	-- 暴食
		{AuraID = 292127, UnitID = "player", Flash = true},	-- 墨黑深渊
		{AuraID = 292138, UnitID = "player"},	-- 辐光生物质
		{AuraID = 292133, UnitID = "player"},	-- 生物体荧光
		{AuraID = 301968, UnitID = "player"},	-- 生物体荧光，小怪
		{AuraID = 292167, UnitID = "player"},	-- 剧毒脊刺
		{AuraID = 301180, UnitID = "player"},	-- 冲流
		{AuraID = 298595, UnitID = "player"},	-- 发光的钉刺
		{AuraID = 292307, UnitID = "player", Flash = true},	-- 深渊凝视
		-- 艾萨拉之辉
		{AuraID = 296566, UnitID = "player"},	-- 海潮之拳
		{AuraID = 296737, UnitID = "player", Flash = true},	-- 奥术炸弹
		{AuraID = 296746, UnitID = "player"},	-- 奥术炸弹
		{AuraID = 299152, UnitID = "player"},	-- 翻滚之水
		-- 艾什凡女勋爵
		{AuraID = 303630, UnitID = "player"},	-- 爆裂之黯，小怪
		{AuraID = 296725, UnitID = "player"},	-- 壶蔓猛击
		{AuraID = 296693, UnitID = "player"},	-- 浸水
		{AuraID = 296752, UnitID = "player"},	-- 锋利的珊瑚
		{AuraID = 296938, UnitID = "player"},	-- 艾泽里特弧光
		{AuraID = 296941, UnitID = "player"},
		{AuraID = 296942, UnitID = "player"},
		{AuraID = 296939, UnitID = "player"},
		{AuraID = 296940, UnitID = "player"},
		{AuraID = 296943, UnitID = "player"},
		-- 奥戈佐亚
		{AuraID = 298156, UnitID = "player"},	-- 麻痹钉刺
		{AuraID = 298459, UnitID = "player"},	-- 羊水喷发
		{AuraID = 295779, UnitID = "player", Flash = true},	-- 水舞长枪
		{AuraID = 300244, UnitID = "player", Flash = true},	-- 狂怒急流
		-- 女王法庭
		{AuraID = 297585, UnitID = "player"}, -- 服从或受苦
		{AuraID = 301830, UnitID = "player"}, -- 帕什玛之触
		{AuraID = 301832, UnitID = "player"}, -- 疯狂热诚
		{AuraID = 296851, UnitID = "player", Flash = true, Text = L["Get Out"]}, -- 狂热裁决
		{AuraID = 299914, UnitID = "player"}, -- 狂热冲锋
		{AuraID = 300545, UnitID = "player"}, -- 力量决裂
		{AuraID = 304409, UnitID = "player", Flash = true}, -- 重复行动
		{AuraID = 304410, UnitID = "player", Flash = true}, -- 重复行动
		{AuraID = 304128, UnitID = "player", Text = L["Move"]}, -- 缓刑
		{AuraID = 297586, UnitID = "player", Flash = true}, -- 承受折磨
		-- 扎库尔，尼奥罗萨先驱
		{AuraID = 298192, UnitID = "player", Flash = true}, -- 黑暗虚空
		{AuraID = 295480, UnitID = "player"}, -- 心智锁链
		{AuraID = 295495, UnitID = "player"},
		{AuraID = 300133, UnitID = "player", Flash = true}, -- 折断
		{AuraID = 292963, UnitID = "player"}, -- 惊惧
		{AuraID = 293509, UnitID = "player", Flash = true}, -- 惊惧
		{AuraID = 295327, UnitID = "player", Flash = true}, -- 碎裂心智
		{AuraID = 296018, UnitID = "player", Flash = true}, -- 癫狂惊惧
		{AuraID = 296015, UnitID = "player"}, -- 腐蚀谵妄
		-- 艾萨拉女王
		{AuraID = 297907, UnitID = "player", Flash = true}, -- 诅咒之心
		{AuraID = 299251, UnitID = "player"}, -- 服从！
		{AuraID = 299249, UnitID = "player"}, -- 受苦！
		{AuraID = 299255, UnitID = "player"}, -- 出列！
		{AuraID = 299254, UnitID = "player"}, -- 集合！
		{AuraID = 299252, UnitID = "player"}, -- 前进！
		{AuraID = 299253, UnitID = "player"}, -- 停留！
		{AuraID = 298569, UnitID = "player"}, -- 干涸灵魂
		{AuraID = 298014, UnitID = "player"}, -- 冰爆
		{AuraID = 298018, UnitID = "player", Flash = true}, -- 冻结
		{AuraID = 298756, UnitID = "player"}, -- 锯齿之锋
		{AuraID = 298781, UnitID = "player"}, -- 奥术宝珠
		{AuraID = 303825, UnitID = "player", Flash = true}, -- 溺水
		{AuraID = 302999, UnitID = "player"}, -- 奥术易伤
		{AuraID = 303657, UnitID = "player", Flash = true}, -- 奥术震爆
	-- 风暴熔炉
		{AuraID = 282384, UnitID = "player"},	-- 精神割裂，无眠秘党
		{AuraID = 282566, UnitID = "player"},	-- 力量应许
		{AuraID = 282561, UnitID = "player"},	-- 黑暗通报者
		{AuraID = 282432, UnitID = "player", Text = L["Get Out"]},	-- 粉碎之疑
		{AuraID = 282621, UnitID = "player"},	-- 终焉见证
		{AuraID = 282743, UnitID = "player"},	-- 风暴湮灭
		{AuraID = 282738, UnitID = "player"},	-- 虚空之拥
		{AuraID = 282589, UnitID = "player"},	-- 脑髓侵袭
		{AuraID = 287876, UnitID = "player"},	-- 黑暗吞噬
		{AuraID = 282540, UnitID = "player"},	-- 死亡化身
		{AuraID = 284851, UnitID = "player"},	-- 末日之触，乌纳特
		{AuraID = 285652, UnitID = "player"},	-- 贪食折磨
		{AuraID = 285685, UnitID = "player"},	-- 恩佐斯之赐：疯狂
		{AuraID = 284804, UnitID = "player"},	-- 深渊护持
		{AuraID = 285477, UnitID = "player"},	-- 渊黯
		{AuraID = 285367, UnitID = "player"},	-- 恩佐斯的穿刺凝视
		{AuraID = 284733, UnitID = "player", Flash = true},	-- 虚空之拥
	-- 达萨罗之战
		{AuraID = 283573, UnitID = "player"},	-- 圣洁之刃，圣光勇士
		{AuraID = 285671, UnitID = "player"},	-- 碾碎，丛林之王格洛恩
		{AuraID = 285998, UnitID = "player"},	-- 凶狠咆哮
		{AuraID = 285875, UnitID = "player"},	-- 撕裂噬咬
		{AuraID = 283069, UnitID = "player", Flash = true},	-- 原子烈焰
		{AuraID = 286434, UnitID = "player", Flash = true},	-- 死疽之核
		{AuraID = 289406, UnitID = "player"},	-- 蛮兽压掷
		{AuraID = 286988, UnitID = "player"},	-- 炽热余烬，玉火大师
		{AuraID = 284374, UnitID = "player"},	-- 熔岩陷阱
		{AuraID = 282037, UnitID = "player"},	-- 升腾之焰
		{AuraID = 286379, UnitID = "player"},	-- 炎爆术
		{AuraID = 285632, UnitID = "player"},	-- 追踪
		{AuraID = 288151, UnitID = "player"},	-- 考验后遗症
		{AuraID = 284089, UnitID = "player"},	-- 成功防御
		{AuraID = 287424, UnitID = "player"},	-- 窃贼的报应，丰灵
		{AuraID = 284527, UnitID = "player"},	-- 坚毅宝石
		{AuraID = 284556, UnitID = "player"},	-- 暗影触痕
		{AuraID = 284573, UnitID = "player"},	-- 顺风之力
		{AuraID = 284664, UnitID = "player"},	-- 炽热
		{AuraID = 284798, UnitID = "player"},	-- 极度炽热
		{AuraID = 284802, UnitID = "player", Flash = true},	-- 闪耀光环
		{AuraID = 284817, UnitID = "player"},	-- 地之根系
		{AuraID = 284881, UnitID = "player"},	-- 怒意释放
		{AuraID = 283507, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆裂充能
		{AuraID = 287648, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆裂充能
		{AuraID = 287072, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 液态黄金
		{AuraID = 284424, UnitID = "player", Flash = true},	-- 灼烧之地
		{AuraID = 285014, UnitID = "player", Flash = true},	-- 金币雨
		{AuraID = 285479, UnitID = "player", Flash = true},	-- 烈焰喷射
		{AuraID = 283947, UnitID = "player", Flash = true},	-- 烈焰喷射
		{AuraID = 289383, UnitID = "player", Flash = true},	-- 混沌位移
		{AuraID = 291146, UnitID = "player", Text = L["Freeze"], Flash = true},	-- 混沌位移
		{AuraID = 284470, UnitID = "player", Text = L["Freeze"], Flash = true},	-- 昏睡妖术
		{AuraID = 282444, UnitID = "player"},	-- 裂爪猛击，神选者教团
		{AuraID = 286838, UnitID = "player"},	-- 静电之球
		{AuraID = 285879, UnitID = "player"},	-- 记忆清除
		{AuraID = 282135, UnitID = "player"},	-- 恶意妖术
		{AuraID = 282209, UnitID = "player", Flash = true},	-- 掠食印记
		{AuraID = 286821, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 阿昆达的愤怒
		{AuraID = 284831, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 炽焰引爆，拉斯塔哈大王
		{AuraID = 284662, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 净化之印
		{AuraID = 290450, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 净化之印
		{AuraID = 289858, UnitID = "player"},	-- 碾压
		{AuraID = 284740, UnitID = "player"},	-- 重斧掷击
		{AuraID = 284781, UnitID = "player"},	-- 重斧掷击
		{AuraID = 285195, UnitID = "player"},	-- 寂灭凋零
		{AuraID = 288449, UnitID = "player"},	-- 死亡之门
		{AuraID = 284376, UnitID = "player"},	-- 死亡的存在
		{AuraID = 285349, UnitID = "player"},	-- 赤焰瘟疫
		{AuraID = 287147, UnitID = "player", Flash = true},	-- 恐惧收割
		{AuraID = 284168, UnitID = "player"},	-- 缩小，大工匠梅卡托克
		{AuraID = 282182, UnitID = "player"},	-- 毁灭加农炮
		{AuraID = 286516, UnitID = "player"},	-- 反干涉震击
		{AuraID = 286480, UnitID = "player"},	-- 反干涉震击
		{AuraID = 287167, UnitID = "player"},	-- 基因解组
		{AuraID = 286105, UnitID = "player"},	-- 干涉
		{AuraID = 286646, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 千兆伏特充能
		{AuraID = 285075, UnitID = "player", Flash = true},	-- 冰封潮汐池，风暴之墙阻击战
		{AuraID = 284121, UnitID = "player", Flash = true},	-- 雷霆轰鸣
		{AuraID = 285000, UnitID = "player"},	-- 海藻缠裹
		{AuraID = 285350, UnitID = "player", Flash = true},	-- 风暴哀嚎
		{AuraID = 285426, UnitID = "player", Flash = true},	-- 风暴哀嚎
		{AuraID = 287490, UnitID = "player"},	-- 冻结，吉安娜
		{AuraID = 287993, UnitID = "player"},	-- 寒冰之触
		{AuraID = 285253, UnitID = "player"},	-- 寒冰碎片
		{AuraID = 288394, UnitID = "player"},	-- 热量
		{AuraID = 288212, UnitID = "player"},	-- 舷侧攻击
		{AuraID = 288374, UnitID = "player"},	-- 破城者炮击
	-- 奥迪尔
		{AuraID = 271224, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 赤红迸发，塔罗克
		{AuraID = 271225, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 278888, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 278889, UnitID = "player", Text = L["Get Out"], Flash = true},
		{AuraID = 267787, UnitID = "player"},	-- 消毒打击，纯净圣母
		{AuraID = 262313, UnitID = "player"},	-- 恶臭沼气，腐臭吞噬者
		{AuraID = 265237, UnitID = "player"},	-- 粉碎，泽克沃兹
		{AuraID = 265264, UnitID = "player"},	-- 虚空鞭笞，泽克沃兹
		{AuraID = 265360, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 翻滚欺诈，泽克沃兹
		{AuraID = 265662, UnitID = "player"},	-- 腐化者的契约，泽克沃兹
		{AuraID = 265127, UnitID = "player"},	-- 持续感染，维克提斯
		{AuraID = 265129, UnitID = "player"},	-- 终极菌体，维克提斯
		{AuraID = 267160, UnitID = "player"},
		{AuraID = 267161, UnitID = "player"},
		{AuraID = 274990, UnitID = "player", Flash = true},	-- 破裂损伤，维克提斯
		{AuraID = 273434, UnitID = "player"},	-- 绝望深渊，祖尔
		{AuraID = 274271, UnitID = "player"},	-- 死亡之愿，祖尔
		{AuraID = 273365, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 黑暗启示，祖尔
		{AuraID = 272146, UnitID = "player"},	-- 毁灭，拆解者
		{AuraID = 272536, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 毁灭迫近，拆解者
		{AuraID = 274262, UnitID = "player", Text = L["Get Out"], Flash = true},	-- 爆炸腐蚀，戈霍恩
		{AuraID = 267409, UnitID = "player"},	-- 黑暗交易，戈霍恩
		{AuraID = 263227, UnitID = "player"},	-- 腐败之血，戈霍恩
		{AuraID = 267700, UnitID = "player"},	-- 戈霍恩的凝视，戈霍恩
		{AuraID = 273405, UnitID = "player"},	-- 黑暗交易，戈霍恩
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
		{AuraID = 235213, UnitID = "player"},	-- 光明灌注
		{AuraID = 235240, UnitID = "player"},	-- 邪能灌注
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
		{AuraID = 244055, UnitID = "player"},	-- 暗影触痕
		{AuraID = 244054, UnitID = "player"},	-- 烈焰触痕
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
	-- 9.0 词缀
		{AuraID = 373724, UnitID = "target", Value = true},	-- S4，鲜血屏障
		-- 5人本
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
		{AuraID = 229495, UnitID = "target"},	-- 卡上，国王易伤
		{AuraID = 227548, UnitID = "target", Value = true},	-- 卡上，烧蚀护盾
		{AuraID = 227817, UnitID = "target", Value = true},	-- 卡下，圣女盾
		{AuraID = 163689, UnitID = "target", Value = true, Flash = true},	-- 钢铁码头，血红之球
		-- 团本
		{AuraID = 345902, UnitID = "target"},	-- 破裂的联结，猎手
		{AuraID = 334695, UnitID = "target"},	-- 动荡的能量，猎手
		{AuraID = 346792, UnitID = "target"},	-- 罪触之刃，猩红议会
		{AuraID = 331314, UnitID = "target"},	-- 毁灭冲击，泥拳
		{AuraID = 341250, UnitID = "target"},	-- 恐怖暴怒，泥拳
		{AuraID = 329636, UnitID = "target", Flash = true},	-- 坚岩形态，干将
		{AuraID = 329808, UnitID = "target", Flash = true},	-- 坚岩形态，干将
		{AuraID = 350857, UnitID = "target", Flash = true},	-- 女妖斗篷，女王
		{AuraID = 367573, UnitID = "target", Flash = true},	-- 源生壁垒，圣物匠
		{AuraID = 368684, UnitID = "target", Value = true},	-- 回收，黑伦度斯
		{AuraID = 361651, UnitID = "target", Value = true},	-- 虹吸屏障，道茜歌妮
		{AuraID = 362505, UnitID = "target", Flash = true},	-- 统御之握，安度因
	-- 8.0副本
		{AuraID = 300011, UnitID = "target"},	-- 力场护盾，麦卡贡
		{AuraID = 257458, UnitID = "target"},	-- 自由镇尾王易伤
		{AuraID = 260512, UnitID = "target"},	-- 灵魂收割，神庙
		{AuraID = 277965, UnitID = "target"},	-- 重型军火，围攻1
		{AuraID = 273721, UnitID = "target"},
		{AuraID = 256493, UnitID = "target"},	-- 炽燃的艾泽里特，矿区1
		{AuraID = 271867, UnitID = "target"},	-- 氪金致胜，矿区1
	-- 尼奥罗萨
		{AuraID = 313175, UnitID = "target"},	-- 硬化核心，拉希奥
		{AuraID = 306005, UnitID = "target"},	-- 黑曜石之肤，玛乌特
		{AuraID = 313208, UnitID = "target"},	-- 无形幻象，先知斯基特拉
		{AuraID = 312329, UnitID = "target"},	-- 狼吞虎咽，无厌者夏德哈
		{AuraID = 312595, UnitID = "target"},	-- 易爆腐蚀，德雷阿佳丝
		{AuraID = 312750, UnitID = "target"},	-- 召唤梦魇，虚无者莱登
		{AuraID = 306990, UnitID = "target", Value = true},	-- 适化外膜，恩佐斯外壳
		{AuraID = 310126, UnitID = "target"},	-- 心灵护壳，恩佐斯
		{AuraID = 312155, UnitID = "target"},	-- 碎裂自我
		{AuraID = 313184, UnitID = "target"},	-- 突触震击
	-- 永恒王宫
		{AuraID = 296389, UnitID = "target"},	-- 上旋气流，艾萨拉之辉
		{AuraID = 304951, UnitID = "target"},	-- 聚焦能量
		{AuraID = 295916, UnitID = "target"},	-- 远古风暴
		{AuraID = 296650, UnitID = "target", Value = true},	-- 硬化甲壳，艾什凡女勋爵
		{AuraID = 299575, UnitID = "target"},	-- 指挥官之怒，女王法庭
		{AuraID = 296716, UnitID = "target", Flash = true},	-- 权力制衡，女王法庭
		{AuraID = 295099, UnitID = "target"},	-- 穿透黑暗，扎库尔
	-- 风暴熔炉
		{AuraID = 282741, UnitID = "target", Value = true},	-- 暗影之壳，无眠秘党
		{AuraID = 284722, UnitID = "target", Value = true},	-- 暗影之壳，乌纳特
		{AuraID = 287693, UnitID = "target", Flash = true},	-- 隐性联结
		{AuraID = 286310, UnitID = "target"},	-- 虚空之盾
		{AuraID = 285333, UnitID = "target"},	-- 非自然再生
		{AuraID = 285642, UnitID = "target"},	-- 恩佐斯之赐：癔乱
	-- 达萨罗之战
		{AuraID = 284459, UnitID = "target"},	-- 狂热，圣光勇士
		{AuraID = 284436, UnitID = "target"},	-- 清算圣印
		{AuraID = 282113, UnitID = "target"},	-- 复仇之怒
		{AuraID = 281936, UnitID = "target"},	-- 发怒，丛林之王格洛恩
		{AuraID = 286425, UnitID = "target", Value = true},	-- 火焰护盾，玉火大师
		{AuraID = 286436, UnitID = "target"},	-- 翡翠风暴
		{AuraID = 284614, UnitID = "target"},	-- 聚焦敌意，丰灵
		{AuraID = 284943, UnitID = "target"},	-- 贪婪
		{AuraID = 285945, UnitID = "target", Flash = true},	-- 急速之风，神选者教团
		{AuraID = 285893, UnitID = "target"},	-- 野性重殴
		{AuraID = 282079, UnitID = "target"},	-- 神灵的契约
		{AuraID = 284377, UnitID = "target"},	-- 无息，拉斯塔哈大王
		{AuraID = 284446, UnitID = "target"},	-- 邦桑迪的恩泽
		{AuraID = 289169, UnitID = "target"},	-- 邦桑迪的恩泽
		{AuraID = 284613, UnitID = "target"},	-- 天然亡者领域
		{AuraID = 286051, UnitID = "target"},	-- 超光速，大工匠
		{AuraID = 289699, UnitID = "target", Flash = true},	-- 电能增幅
		{AuraID = 286558, UnitID = "target", Value = true},	-- 潮汐遮罩，风暴之墙
		{AuraID = 287995, UnitID = "target", Value = true},	-- 电流护罩
		{AuraID = 287322, UnitID = "target"},	-- 寒冰屏障，吉安娜
	-- 奥迪尔
		{AuraID = 271965, UnitID = "target"},	-- 能源关闭，塔罗克
		{AuraID = 277548, UnitID = "target"},	-- 粉碎黑暗，小怪
		{AuraID = 278218, UnitID = "target"},	-- 虚空召唤，泽克沃兹
		{AuraID = 278220, UnitID = "target"},	-- 虚空超脱，泽克沃兹
		{AuraID = 265264, UnitID = "target"},	-- 虚空鞭笞，泽克沃兹
		{AuraID = 273432, UnitID = "target"},	-- 暗影束缚，祖尔
		{AuraID = 273288, UnitID = "target"},	-- 婆娑脉动，祖尔
		{AuraID = 274230, UnitID = "target"},	-- 湮灭帷幕，拆解者米斯拉克斯
		{AuraID = 276900, UnitID = "target"},	-- 临界炽焰，拆解者米斯拉克斯
		{AuraID = 279013, UnitID = "target"},	-- 精华碎裂，拆解者米斯拉克斯
		{AuraID = 263504, UnitID = "target"},	-- 重组冲击，戈霍恩
		{AuraID = 273251, UnitID = "target"},	-- 重组冲击，戈霍恩
		{AuraID = 263372, UnitID = "target"},	-- 能量矩阵，戈霍恩
		{AuraID = 270447, UnitID = "target"},	-- 腐化滋长，戈霍恩
		{AuraID = 263217, UnitID = "target"},	-- 鲜血护盾，戈霍恩
		{AuraID = 275129, UnitID = "target"},	-- 臃肿肥胖，戈霍恩
	-- 7.0副本
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
	-- 勇气试练
		{AuraID = 229256, UnitID = "target"},	-- 奥丁，弧光风暴
		{AuraID = 228174, UnitID = "target"},	-- 高姆，吐沫狂怒
		{AuraID = 228803, UnitID = "target"},	-- 海拉，酝酿风暴
		{AuraID = 203816, UnitID = "target"},	-- 小怪，精力
		{AuraID = 228611, UnitID = "target"},	-- 小怪，幽灵怒火
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
	},
}