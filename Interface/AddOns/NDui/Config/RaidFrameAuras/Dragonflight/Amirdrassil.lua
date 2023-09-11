local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")
if not DB.isNewPatch then return end

local TIER = 10
local INSTANCE = 1207 -- 阿梅达希尔，梦境之愿

local BOSS
BOSS = 2564 -- 瘤根
module:RegisterDebuff(TIER, INSTANCE, BOSS, 370648) -- 熔岩涌流 -- 示例

BOSS = 2554 -- 残虐者艾姬拉

BOSS = 2557 -- 沃尔科罗斯

BOSS = 2555 -- 梦境议会

BOSS = 2553 -- 拉罗达尔，烈焰守护者

BOSS = 2556 -- 尼穆，轮回编织者

BOSS = 2563 -- 斯莫德隆

BOSS = 2565 -- 丁达尔·迅贤，烈焰预言者

BOSS = 2519 -- 火光之龙菲莱克