local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE = 1207 -- 阿梅达希尔，梦境之愿

local BOSS
BOSS = 2564 -- 瘤根
module:RegisterDebuff(TIER, INSTANCE, BOSS, 425709) -- 狂躁加剧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421013)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 424352)

BOSS = 2554 -- 残虐者艾姬拉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420251)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 422961)

BOSS = 2557 -- 沃尔科罗斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421675)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421672)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420933)

BOSS = 2555 -- 梦境议会
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421029)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420525)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420604)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 418757)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420979)

BOSS = 2553 -- 拉罗达尔，烈焰守护者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 417583)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 417644)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421316)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 417634)

BOSS = 2556 -- 尼穆，轮回编织者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 413443)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420553)

BOSS = 2563 -- 斯莫德隆
module:RegisterDebuff(TIER, INSTANCE, BOSS, 425885)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421859)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 423896)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 422067)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 422172)

BOSS = 2565 -- 丁达尔·迅贤，烈焰预言者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 422115)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 421603)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 420540)

BOSS = 2519 -- 火光之龙菲莱克