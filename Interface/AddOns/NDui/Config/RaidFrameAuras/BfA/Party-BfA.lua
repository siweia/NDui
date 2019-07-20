local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8 -- BfA
local INSTANCE -- 5人本

INSTANCE = 1023 -- 围攻伯拉勒斯
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 257169) -- 恐惧咆哮
module:RegisterDebuff(TIER, INSTANCE, 0, 257168) -- 诅咒挥砍
module:RegisterDebuff(TIER, INSTANCE, 0, 272588) -- 腐烂伤口
module:RegisterDebuff(TIER, INSTANCE, 0, 272571) -- 窒息之水
module:RegisterDebuff(TIER, INSTANCE, 0, 274991) -- 腐败之水
module:RegisterDebuff(TIER, INSTANCE, 0, 275835) -- 钉刺之毒覆膜
module:RegisterDebuff(TIER, INSTANCE, 0, 273930) -- 妨害切割
module:RegisterDebuff(TIER, INSTANCE, 0, 257292) -- 沉重挥砍
module:RegisterDebuff(TIER, INSTANCE, 0, 261428) -- 刽子手的套索
module:RegisterDebuff(TIER, INSTANCE, 0, 256897) -- 咬合之颚
module:RegisterDebuff(TIER, INSTANCE, 0, 272874) -- 践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 273470) -- 一枪毙命
module:RegisterDebuff(TIER, INSTANCE, 0, 272834) -- 粘稠的口水
module:RegisterDebuff(TIER, INSTANCE, 0, 272713) -- 碾压重击

INSTANCE = 1022 -- 地渊孢林
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 278961, 6) -- 衰弱意志
module:RegisterDebuff(TIER, INSTANCE, 0, 265468) -- 枯萎诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 259714) -- 腐烂孢子
module:RegisterDebuff(TIER, INSTANCE, 0, 272180) -- 湮灭之球
module:RegisterDebuff(TIER, INSTANCE, 0, 272609) -- 疯狂凝视
module:RegisterDebuff(TIER, INSTANCE, 0, 269301) -- 腐败之血
module:RegisterDebuff(TIER, INSTANCE, 0, 265533) -- 鲜血之喉
module:RegisterDebuff(TIER, INSTANCE, 0, 265019) -- 狂野顺劈斩
module:RegisterDebuff(TIER, INSTANCE, 0, 265377) -- 抓钩诱捕
module:RegisterDebuff(TIER, INSTANCE, 0, 265625) -- 黑暗预兆
module:RegisterDebuff(TIER, INSTANCE, 0, 260685) -- 戈霍恩之蚀
module:RegisterDebuff(TIER, INSTANCE, 0, 266107) -- 嗜血成性
module:RegisterDebuff(TIER, INSTANCE, 0, 260455) -- 锯齿利牙

INSTANCE = 1030 -- 塞塔里斯神庙
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 269686) -- 瘟疫
module:RegisterDebuff(TIER, INSTANCE, 0, 268013) -- 烈焰震击
module:RegisterDebuff(TIER, INSTANCE, 0, 268008) -- 毒蛇诱惑
module:RegisterDebuff(TIER, INSTANCE, 0, 273563) -- 神经毒素
module:RegisterDebuff(TIER, INSTANCE, 0, 272657) -- 毒性吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 267027) -- 细胞毒素
module:RegisterDebuff(TIER, INSTANCE, 0, 272699) -- 毒性喷吐
module:RegisterDebuff(TIER, INSTANCE, 0, 263371) -- 导电
module:RegisterDebuff(TIER, INSTANCE, 0, 272655) -- 黄沙冲刷
module:RegisterDebuff(TIER, INSTANCE, 0, 263914) -- 盲目之沙
module:RegisterDebuff(TIER, INSTANCE, 0, 263958) -- 缠绕的蛇群
module:RegisterDebuff(TIER, INSTANCE, 0, 266923) -- 充电
module:RegisterDebuff(TIER, INSTANCE, 0, 268007) -- 心脏打击

INSTANCE = 1002 -- 托尔达戈
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 260067, 6) -- 恶毒槌击
module:RegisterDebuff(TIER, INSTANCE, 0, 258128) -- 衰弱怒吼
module:RegisterDebuff(TIER, INSTANCE, 0, 265889) -- 火把攻击
module:RegisterDebuff(TIER, INSTANCE, 0, 257791) -- 恐惧咆哮
module:RegisterDebuff(TIER, INSTANCE, 0, 258864) -- 火力压制
module:RegisterDebuff(TIER, INSTANCE, 0, 257028) -- 点火器
module:RegisterDebuff(TIER, INSTANCE, 0, 258917) -- 正义烈焰
module:RegisterDebuff(TIER, INSTANCE, 0, 257777) -- 断筋剃刀
module:RegisterDebuff(TIER, INSTANCE, 0, 258079) -- 巨口噬咬
module:RegisterDebuff(TIER, INSTANCE, 0, 258058) -- 挤压
module:RegisterDebuff(TIER, INSTANCE, 0, 260016) -- 瘙痒叮咬
module:RegisterDebuff(TIER, INSTANCE, 0, 257119) -- 流沙陷阱
module:RegisterDebuff(TIER, INSTANCE, 0, 258313) -- 手铐
module:RegisterDebuff(TIER, INSTANCE, 0, 259711) -- 全面紧闭
module:RegisterDebuff(TIER, INSTANCE, 0, 256201) -- 爆炎弹
module:RegisterDebuff(TIER, INSTANCE, 0, 256101) -- 爆炸
module:RegisterDebuff(TIER, INSTANCE, 0, 256044) -- 致命狙击
module:RegisterDebuff(TIER, INSTANCE, 0, 256474) -- 竭心毒剂

INSTANCE = 1012 -- 暴富矿区
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 263074) -- 溃烂撕咬
module:RegisterDebuff(TIER, INSTANCE, 0, 280605) -- 脑部冻结
module:RegisterDebuff(TIER, INSTANCE, 0, 257337) -- 电击之爪
module:RegisterDebuff(TIER, INSTANCE, 0, 270882) -- 炽然的艾泽里特
module:RegisterDebuff(TIER, INSTANCE, 0, 268797) -- 转化：敌人变粘液
module:RegisterDebuff(TIER, INSTANCE, 0, 259856) -- 化学灼烧
module:RegisterDebuff(TIER, INSTANCE, 0, 269302) -- 淬毒之刃
module:RegisterDebuff(TIER, INSTANCE, 0, 280604) -- 冰镇汽水
module:RegisterDebuff(TIER, INSTANCE, 0, 257371) -- 催泪毒气
module:RegisterDebuff(TIER, INSTANCE, 0, 257544) -- 锯齿切割
module:RegisterDebuff(TIER, INSTANCE, 0, 268846) -- 回声之刃
module:RegisterDebuff(TIER, INSTANCE, 0, 262794) -- 能量鞭笞
module:RegisterDebuff(TIER, INSTANCE, 0, 262513) -- 艾泽里特觅心者
module:RegisterDebuff(TIER, INSTANCE, 0, 260829) -- 自控导弹
module:RegisterDebuff(TIER, INSTANCE, 0, 260838)
module:RegisterDebuff(TIER, INSTANCE, 0, 263637) -- 晾衣绳

INSTANCE = 1021 -- 维克雷斯庄园
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 260741, 6) -- 锯齿荨麻
module:RegisterDebuff(TIER, INSTANCE, 0, 260703) -- 不稳定的符文印记
module:RegisterDebuff(TIER, INSTANCE, 0, 263905) -- 符文劈斩
module:RegisterDebuff(TIER, INSTANCE, 0, 265880) -- 恐惧印记
module:RegisterDebuff(TIER, INSTANCE, 0, 265882) -- 萦绕恐惧
module:RegisterDebuff(TIER, INSTANCE, 0, 264105) -- 符文印记
module:RegisterDebuff(TIER, INSTANCE, 0, 264050) -- 被感染的荆棘
module:RegisterDebuff(TIER, INSTANCE, 0, 261440) -- 恶性病原体
module:RegisterDebuff(TIER, INSTANCE, 0, 263891) -- 缠绕荆棘
module:RegisterDebuff(TIER, INSTANCE, 0, 264378) -- 碎裂灵魂
module:RegisterDebuff(TIER, INSTANCE, 0, 266035) -- 碎骨片
module:RegisterDebuff(TIER, INSTANCE, 0, 266036) -- 吸取精华
module:RegisterDebuff(TIER, INSTANCE, 0, 260907) -- 灵魂操控
module:RegisterDebuff(TIER, INSTANCE, 0, 264556) -- 刺裂打击
module:RegisterDebuff(TIER, INSTANCE, 0, 265760) -- 荆棘弹幕
module:RegisterDebuff(TIER, INSTANCE, 0, 260551) -- 灵魂荆棘
module:RegisterDebuff(TIER, INSTANCE, 0, 263943) -- 蚀刻
module:RegisterDebuff(TIER, INSTANCE, 0, 265881) -- 腐烂之触
module:RegisterDebuff(TIER, INSTANCE, 0, 261438) -- 污秽攻击
module:RegisterDebuff(TIER, INSTANCE, 0, 268202) -- 死亡棱镜
module:RegisterDebuff(TIER, INSTANCE, 0, 268086) -- 恐怖光环

INSTANCE = 1001 -- 自由镇
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 258875, 6) -- 眩晕酒桶
module:RegisterDebuff(TIER, INSTANCE, 0, 274389) -- 捕鼠陷阱
module:RegisterDebuff(TIER, INSTANCE, 0, 258323) -- 感染之伤
module:RegisterDebuff(TIER, INSTANCE, 0, 257775) -- 瘟疫步
module:RegisterDebuff(TIER, INSTANCE, 0, 257908) -- 浸油之刃
module:RegisterDebuff(TIER, INSTANCE, 0, 257436) -- 毒性打击
module:RegisterDebuff(TIER, INSTANCE, 0, 274555) -- 污染之咬
module:RegisterDebuff(TIER, INSTANCE, 0, 256363) -- 裂伤拳
module:RegisterDebuff(TIER, INSTANCE, 0, 281357, 1) -- 水鼠啤酒
module:RegisterDebuff(TIER, INSTANCE, 0, 278467, 3) -- 腐蚀酒

INSTANCE = 1041 -- 诸王之眠
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 265773) -- 吐金
module:RegisterDebuff(TIER, INSTANCE, 0, 271640) -- 黑暗启示
module:RegisterDebuff(TIER, INSTANCE, 0, 270492) -- 妖术
module:RegisterDebuff(TIER, INSTANCE, 0, 267763) -- 恶疾排放
module:RegisterDebuff(TIER, INSTANCE, 0, 276031) -- 深渊绝望
module:RegisterDebuff(TIER, INSTANCE, 0, 270920) -- 诱惑
module:RegisterDebuff(TIER, INSTANCE, 0, 270865) -- 隐秘刀刃
module:RegisterDebuff(TIER, INSTANCE, 0, 271564) -- 防腐液
module:RegisterDebuff(TIER, INSTANCE, 0, 270507) -- 毒幕
module:RegisterDebuff(TIER, INSTANCE, 0, 267273) -- 毒性新星
module:RegisterDebuff(TIER, INSTANCE, 0, 270003) -- 压制猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 270084) -- 飞斧弹幕
module:RegisterDebuff(TIER, INSTANCE, 0, 267618) -- 排干体液
module:RegisterDebuff(TIER, INSTANCE, 0, 267626) -- 干枯
module:RegisterDebuff(TIER, INSTANCE, 0, 270487) -- 切裂之刃
module:RegisterDebuff(TIER, INSTANCE, 0, 266238) -- 粉碎防御
module:RegisterDebuff(TIER, INSTANCE, 0, 266231) -- 斩首之斧
module:RegisterDebuff(TIER, INSTANCE, 0, 266191) -- 回旋飞斧
module:RegisterDebuff(TIER, INSTANCE, 0, 272388) -- 暗影弹幕
module:RegisterDebuff(TIER, INSTANCE, 0, 268796) -- 穿刺长矛
module:RegisterDebuff(TIER, INSTANCE, 0, 270289) -- 净化光线

INSTANCE = 968 -- 阿塔达萨
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 252781) -- 不稳定的妖术
module:RegisterDebuff(TIER, INSTANCE, 0, 250096) -- 毁灭痛苦
module:RegisterDebuff(TIER, INSTANCE, 0, 253562) -- 野火
module:RegisterDebuff(TIER, INSTANCE, 0, 255582) -- 熔化的黄金
module:RegisterDebuff(TIER, INSTANCE, 0, 255041) -- 惊骇尖啸
module:RegisterDebuff(TIER, INSTANCE, 0, 255371) -- 恐惧之面
module:RegisterDebuff(TIER, INSTANCE, 0, 252687) -- 毒牙攻击
module:RegisterDebuff(TIER, INSTANCE, 0, 254959) -- 灵魂燃烧
module:RegisterDebuff(TIER, INSTANCE, 0, 255814) -- 撕裂重殴
module:RegisterDebuff(TIER, INSTANCE, 0, 255421) -- 吞噬
module:RegisterDebuff(TIER, INSTANCE, 0, 255434) -- 锯齿
module:RegisterDebuff(TIER, INSTANCE, 0, 256577) -- 灵魂盛宴
module:RegisterDebuff(TIER, INSTANCE, 0, 255558) -- 污血

INSTANCE = 1036 -- 风暴神殿
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 288388) -- 夺魂
module:RegisterDebuff(TIER, INSTANCE, 0, 288694) -- 暗影碎击
module:RegisterDebuff(TIER, INSTANCE, 0, 302420) -- 女王法令：隐藏
module:RegisterDebuff(TIER, INSTANCE, 0, 264560) -- 窒息海潮
module:RegisterDebuff(TIER, INSTANCE, 0, 268233) -- 电化震击
module:RegisterDebuff(TIER, INSTANCE, 0, 268322) -- 溺毙者之触
module:RegisterDebuff(TIER, INSTANCE, 0, 268896) -- 心灵撕裂
module:RegisterDebuff(TIER, INSTANCE, 0, 267034) -- 力量的低语
module:RegisterDebuff(TIER, INSTANCE, 0, 276268) -- 沉重打击
module:RegisterDebuff(TIER, INSTANCE, 0, 264166) -- 逆流
module:RegisterDebuff(TIER, INSTANCE, 0, 264526) -- 深海之握
module:RegisterDebuff(TIER, INSTANCE, 0, 274633) -- 碎甲重击
module:RegisterDebuff(TIER, INSTANCE, 0, 268214, 6) -- 割肉
module:RegisterDebuff(TIER, INSTANCE, 0, 267818) -- 切割冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 268309) -- 无尽黑暗
module:RegisterDebuff(TIER, INSTANCE, 0, 268317) -- 撕裂大脑
module:RegisterDebuff(TIER, INSTANCE, 0, 268391) -- 心智突袭
module:RegisterDebuff(TIER, INSTANCE, 0, 274720) -- 深渊打击
module:RegisterDebuff(TIER, INSTANCE, 0, 267037) -- 力量的低语
module:RegisterDebuff(TIER, INSTANCE, 0, 276286) -- 切割旋风

INSTANCE = 1178 -- 麦卡贡
module:RegisterDebuff(TIER, INSTANCE, 0, 298259, 6) -- 束缚粘液
module:RegisterDebuff(TIER, INSTANCE, 0, 297257) -- 电荷充能
module:RegisterDebuff(TIER, INSTANCE, 0, 303885) -- 爆裂喷发
module:RegisterDebuff(TIER, INSTANCE, 0, 292267) -- 超荷电磁炮
module:RegisterDebuff(TIER, INSTANCE, 0, 305699) -- 锁定