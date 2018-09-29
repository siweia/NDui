local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8 -- BfA
local INSTANCE -- 5人本

INSTANCE = 1023 -- 围攻伯拉勒斯
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 257459) -- 上钩了
module:RegisterDebuff(TIER, INSTANCE, 0, 260954) -- 铁之凝视
module:RegisterDebuff(TIER, INSTANCE, 0, 270624) -- 窒息勒压
module:RegisterDebuff(TIER, INSTANCE, 0, 257169) -- 恐惧咆哮

INSTANCE = 1022 -- 地渊孢林
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 260292) -- 冲锋
module:RegisterDebuff(TIER, INSTANCE, 0, 259718) -- 颠覆
module:RegisterDebuff(TIER, INSTANCE, 0, 269310) -- 净化之光

INSTANCE = 1030 -- 塞塔里斯神庙
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 269970) -- 盲目之沙
module:RegisterDebuff(TIER, INSTANCE, 0, 266923) -- 充电
module:RegisterDebuff(TIER, INSTANCE, 0, 263371) -- 导电
module:RegisterDebuff(TIER, INSTANCE, 0, 263958) -- 缠绕的蛇群
module:RegisterDebuff(TIER, INSTANCE, 0, 269686) -- 瘟疫

INSTANCE = 1002 -- 托尔达戈
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 257092) -- 流沙陷阱
module:RegisterDebuff(TIER, INSTANCE, 0, 257617) -- 颠覆之击
module:RegisterDebuff(TIER, INSTANCE, 0, 256955) -- 炉渣之焰
module:RegisterDebuff(TIER, INSTANCE, 0, 257028) -- 点火器
module:RegisterDebuff(TIER, INSTANCE, 0, 256038) -- 致命狙击
module:RegisterDebuff(TIER, INSTANCE, 0, 256105) -- 爆炸
module:RegisterDebuff(TIER, INSTANCE, 0, 258128) -- 衰弱怒吼

INSTANCE = 1012 -- 暴富矿区
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 256493) -- 炽然的艾泽里特
module:RegisterDebuff(TIER, INSTANCE, 0, 257582) -- 愤怒凝视
module:RegisterDebuff(TIER, INSTANCE, 0, 259853) -- 化学灼烧
module:RegisterDebuff(TIER, INSTANCE, 0, 260811) -- 自控导弹
module:RegisterDebuff(TIER, INSTANCE, 0, 262515) -- 艾泽里特觅心者

INSTANCE = 1021 -- 维克雷斯庄园
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 268086) -- 恐怖光环
module:RegisterDebuff(TIER, INSTANCE, 0, 267907) -- 灵魂荆棘
module:RegisterDebuff(TIER, INSTANCE, 0, 261440) -- 恶性病原体
module:RegisterDebuff(TIER, INSTANCE, 0, 260741, 5) -- 锯齿荨麻

INSTANCE = 1001 -- 自由镇
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 255952) -- 冲冲冲锋
module:RegisterDebuff(TIER, INSTANCE, 0, 272046) -- 俯冲轰炸
module:RegisterDebuff(TIER, INSTANCE, 0, 258338) -- 眩晕酒桶
module:RegisterDebuff(TIER, INSTANCE, 0, 257314) -- 黑火药炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 257305) -- 火炮弹幕
module:RegisterDebuff(TIER, INSTANCE, 0, 281357) -- 水鼠啤酒
module:RegisterDebuff(TIER, INSTANCE, 0, 274389) -- 捕鼠陷阱

INSTANCE = 1041 -- 诸王之眠
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 265773) -- 吐金
module:RegisterDebuff(TIER, INSTANCE, 0, 266231) -- 斩首之斧
module:RegisterDebuff(TIER, INSTANCE, 0, 270487) -- 切割之刃
module:RegisterDebuff(TIER, INSTANCE, 0, 271640) -- 黑暗启示

INSTANCE = 968 -- 阿塔达萨
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 260666) -- 鲜血灌注
module:RegisterDebuff(TIER, INSTANCE, 0, 255577) -- 鲜血灌注
module:RegisterDebuff(TIER, INSTANCE, 0, 250258) -- 剧毒跳碾
module:RegisterDebuff(TIER, INSTANCE, 0, 255371) -- 恐惧之面
module:RegisterDebuff(TIER, INSTANCE, 0, 257407) -- 追踪
module:RegisterDebuff(TIER, INSTANCE, 0, 250050) -- 沙德拉的回响

INSTANCE = 1036 -- 风暴神殿
module:RegisterDebuff(TIER, INSTANCE, 0, 209858) -- 死疽
module:RegisterDebuff(TIER, INSTANCE, 0, 240559) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 240443) -- 爆裂
module:RegisterDebuff(TIER, INSTANCE, 0, 264560) -- 窒息海潮
module:RegisterDebuff(TIER, INSTANCE, 0, 264144) -- 逆流
module:RegisterDebuff(TIER, INSTANCE, 0, 267899) -- 妨害劈斩
module:RegisterDebuff(TIER, INSTANCE, 0, 269131) -- 上古摧心者
module:RegisterDebuff(TIER, INSTANCE, 0, 268214) -- 割肉