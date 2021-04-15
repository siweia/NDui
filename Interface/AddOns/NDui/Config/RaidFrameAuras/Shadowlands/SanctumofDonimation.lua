local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if not DB.isNewPatch then return end

local TIER = 9
local INSTANCE = 1193 -- 统御圣所
local BOSS

BOSS = 2435 -- 塔拉格鲁
module:RegisterDebuff(TIER, INSTANCE, BOSS, 328897) -- 抽干，示例

BOSS = 2442 -- 典狱长之眼

BOSS = 2439 -- 九武神

BOSS = 2444 -- 耐奥祖的残迹

BOSS = 2445 -- 裂魂者多尔玛赞

BOSS = 2443 -- 痛楚工匠莱兹纳尔

BOSS = 2446 -- 初诞者的卫士

BOSS = 2447 -- Fatescribe Roh-Kalo

BOSS = 2440 -- 克尔苏加德

BOSS = 2441 -- 希尔瓦娜斯·风行者