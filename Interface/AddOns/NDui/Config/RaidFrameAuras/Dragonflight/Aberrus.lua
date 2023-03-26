local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE = 1208 -- 亚贝鲁斯，焰影熔炉

local BOSS
BOSS = 2522 -- Kazzara, the Hellforged
module:RegisterDebuff(TIER, INSTANCE, BOSS, 370648) -- 熔岩涌流 -- 示例

BOSS = 2529 -- The Amalgamation Chamber

BOSS = 2530 -- The Forgotten Experiments

BOSS = 2524 -- Assault of the Zaqali

BOSS = 2525 -- Rashok, the Elder

BOSS = 2532 -- The Vigilant Steward, Zskarn

BOSS = 2527 -- 玛格莫莱克斯

BOSS = 2523 -- Echo of Neltharion

BOSS = 2520 -- 鳞长萨卡雷斯