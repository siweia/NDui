local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1179 -- 永恒王宫
local BOSS

BOSS = 2352 -- 深渊指挥官西瓦拉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 294711) -- 冰霜烙印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 294715) -- 剧毒烙印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295795) -- 冻结之血
module:RegisterDebuff(TIER, INSTANCE, BOSS, 300701) -- 白霜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 300705) -- 败血之地
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295348, 6) -- 溢流寒霜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295421, 6) -- 溢流毒液
module:RegisterDebuff(TIER, INSTANCE, BOSS, 300883) -- 倒置之疾
module:RegisterDebuff(TIER, INSTANCE, BOSS, 294847) -- 不稳定混合物
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295807, 6) -- 冻结之血
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295850, 6) -- 癫狂

BOSS = 2347 -- 黑水巨鳗
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298428) -- 暴食
module:RegisterDebuff(TIER, INSTANCE, BOSS, 292127, 6) -- 墨黑深渊
module:RegisterDebuff(TIER, INSTANCE, BOSS, 292138) -- 辐光生物质
module:RegisterDebuff(TIER, INSTANCE, BOSS, 292167) -- 剧毒脊刺
module:RegisterDebuff(TIER, INSTANCE, BOSS, 301180) -- 冲流
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298595) -- 发光的钉刺
module:RegisterDebuff(TIER, INSTANCE, BOSS, 292307, 6) -- 深渊凝视
module:RegisterDebuff(TIER, INSTANCE, BOSS, 301494) -- 尖锐脊刺

BOSS = 2353 -- 艾萨拉之辉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296566) -- 海潮之拳
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296737, 6) -- 奥术炸弹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296746) -- 奥术炸弹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 299152) -- 翻滚之水

BOSS = 2354 -- 艾什凡女勋爵
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296725) -- 壶蔓猛击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296693) -- 浸水
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296752) -- 锋利的珊瑚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 302992) -- 咸水气泡
module:RegisterDebuff(TIER, INSTANCE, BOSS, 297333)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 297397)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296938) -- 艾泽里特弧光
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296941)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296942)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296939)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296940)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296943)

BOSS = 2351 -- 奥戈佐亚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298156) -- 麻痹钉刺
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298459) -- 羊水喷发
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295779, 6) -- 水舞长枪

BOSS = 2359 -- 女王法庭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 303630) -- 爆裂之黯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 301830) -- 帕什玛之触
module:RegisterDebuff(TIER, INSTANCE, BOSS, 301832) -- 疯狂热诚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296851, 6) -- 狂热裁决
module:RegisterDebuff(TIER, INSTANCE, BOSS, 299914) -- 狂热冲锋
module:RegisterDebuff(TIER, INSTANCE, BOSS, 300545) -- 力量决裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 304410, 6) -- 重复行动
module:RegisterDebuff(TIER, INSTANCE, BOSS, 304128) -- 缓刑
module:RegisterDebuff(TIER, INSTANCE, BOSS, 297586, 6) -- 承受折磨

BOSS = 2349 -- 扎库尔，尼奥罗萨先驱
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298192) -- 黑暗虚空
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295480) -- 心智锁链
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295495)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 300133, 6) -- 折断
module:RegisterDebuff(TIER, INSTANCE, BOSS, 292963, 6) -- 惊惧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 293509, 6) -- 惊惧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295327, 6) -- 碎裂心智
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296018, 6) -- 癫狂惊惧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 296015) -- 腐蚀谵妄

BOSS = 2361 -- 艾萨拉女王
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298569) -- 干涸灵魂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298014) -- 冰爆
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298018, 6) -- 冻结
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298756) -- 锯齿之锋
module:RegisterDebuff(TIER, INSTANCE, BOSS, 298781) -- 奥术宝珠
module:RegisterDebuff(TIER, INSTANCE, BOSS, 303825, 6) -- 溺水
module:RegisterDebuff(TIER, INSTANCE, BOSS, 302999) -- 奥术易伤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 303657, 6) -- 奥术震爆