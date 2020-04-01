local _, ns = ...
local B, C, L, DB = unpack(ns)

-- 旧资料片数据 Auras for old expansions
C.DeprecatedAuras = {
	["Enchant Aura"] = {	-- 附魔及饰品组
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