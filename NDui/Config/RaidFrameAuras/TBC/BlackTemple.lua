local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 564 -- 黑暗神殿

-- 小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 40090) -- 飓风
module:RegisterDebuff(TIER, INSTANCE, 0, 40079) -- 衰弱喷射
module:RegisterDebuff(TIER, INSTANCE, 0, 40078) -- 毒液
module:RegisterDebuff(TIER, INSTANCE, 0, 40084) -- 持戟者的印记
module:RegisterDebuff(TIER, INSTANCE, 0, 40082) -- 钩网
module:RegisterDebuff(TIER, INSTANCE, 0, 40103) -- 淤泥新星
module:RegisterDebuff(TIER, INSTANCE, 0, 40946) -- 混乱之雨
module:RegisterDebuff(TIER, INSTANCE, 0, 40877) -- 火球术
module:RegisterDebuff(TIER, INSTANCE, 0, 40892) -- 注视
module:RegisterDebuff(TIER, INSTANCE, 0, 41115) -- 烈焰震击
module:RegisterDebuff(TIER, INSTANCE, 0, 41150) -- 恐惧
module:RegisterDebuff(TIER, INSTANCE, 0, 41238) -- 鲜血吸取
module:RegisterDebuff(TIER, INSTANCE, 0, 41193) -- 疾病之云
module:RegisterDebuff(TIER, INSTANCE, 0, 41274) -- 邪能践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 41272) -- 巨兽冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 41170) -- 冷心诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 41168) -- 音速打击
module:RegisterDebuff(TIER, INSTANCE, 0, 41171) -- 骷髅射击
module:RegisterDebuff(TIER, INSTANCE, 0, 41406) -- 狂乱
module:RegisterDebuff(TIER, INSTANCE, 0, 41409) -- 狂乱
module:RegisterDebuff(TIER, INSTANCE, 0, 41397) -- 迷惑
module:RegisterDebuff(TIER, INSTANCE, 0, 41346) -- 毒性投掷
module:RegisterDebuff(TIER, INSTANCE, 0, 41384) -- 寒冰箭
module:RegisterDebuff(TIER, INSTANCE, 0, 41382) -- 暴风雪
module:RegisterDebuff(TIER, INSTANCE, 0, 41379) -- 烈焰风暴
-- 高阶督军纳因图斯
module:RegisterDebuff(TIER, INSTANCE, 0, 39837) -- 穿刺之脊
-- 苏普雷姆斯
module:RegisterDebuff(TIER, INSTANCE, 0, 40253) -- 熔岩烈焰
-- 阿卡玛之影
module:RegisterDebuff(TIER, INSTANCE, 0, 42023) -- 火雨
module:RegisterDebuff(TIER, INSTANCE, 0, 41978) -- 衰弱之毒
-- 塔隆·血魔
module:RegisterDebuff(TIER, INSTANCE, 0, 40251) -- 死亡之影
module:RegisterDebuff(TIER, INSTANCE, 0, 40243) -- 毁灭之影
module:RegisterDebuff(TIER, INSTANCE, 0, 40239) -- 烧尽
module:RegisterDebuff(TIER, INSTANCE, 0, 40327) -- 萎缩
-- 古尔图格·血沸
module:RegisterDebuff(TIER, INSTANCE, 0, 40481) -- 酸性创伤
module:RegisterDebuff(TIER, INSTANCE, 0, 42005) -- 血沸
module:RegisterDebuff(TIER, INSTANCE, 0, 40595) -- 邪酸吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 40508) -- 邪酸吐息
-- 灵魂之匣
module:RegisterDebuff(TIER, INSTANCE, 0, 41294) -- 注视
module:RegisterDebuff(TIER, INSTANCE, 0, 41376) -- 敌意
module:RegisterDebuff(TIER, INSTANCE, 0, 41377) -- 敌意
-- 莎赫拉丝主母
module:RegisterDebuff(TIER, INSTANCE, 0, 40823) -- 沉默尖啸
module:RegisterDebuff(TIER, INSTANCE, 0, 41001) -- 致命吸引
module:RegisterDebuff(TIER, INSTANCE, 0, 40860) -- 败德射线
-- 伊利达雷议会
module:RegisterDebuff(TIER, INSTANCE, 0, 41541) -- 奉献
module:RegisterDebuff(TIER, INSTANCE, 0, 41482) -- 暴风雪
module:RegisterDebuff(TIER, INSTANCE, 0, 41481) -- 烈焰风暴
module:RegisterDebuff(TIER, INSTANCE, 0, 41472) -- 神圣愤怒
module:RegisterDebuff(TIER, INSTANCE, 0, 41485) -- 致命药膏
module:RegisterDebuff(TIER, INSTANCE, 0, 41461) -- 鲜血审判
-- 伊利丹·怒风
module:RegisterDebuff(TIER, INSTANCE, 0, 41914) -- 寄生暗影魔
module:RegisterDebuff(TIER, INSTANCE, 0, 41917) -- 寄生暗影魔
module:RegisterDebuff(TIER, INSTANCE, 0, 40932) -- 苦痛之焰
module:RegisterDebuff(TIER, INSTANCE, 0, 41083) -- 麻痹