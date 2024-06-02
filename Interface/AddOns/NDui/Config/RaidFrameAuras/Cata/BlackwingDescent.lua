local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 73 -- 黑翼血环

local BOSS
BOSS = 169 -- 全能金刚防御系统

BOSS = 170 -- 熔喉

BOSS = 171 -- 艾卓曼德斯

BOSS = 172 -- 奇美隆

BOSS = 173 -- 马洛拉克

BOSS = 174 -- 奈法利安的末日

module:RegisterDebuff(TIER, INSTANCE, BOSS, 78199) -- Sweltering Armor
module:RegisterDebuff(TIER, INSTANCE, BOSS, 80094) -- Fixate
module:RegisterDebuff(TIER, INSTANCE, BOSS, 80161) -- Chemical Cloud
module:RegisterDebuff(TIER, INSTANCE, BOSS, 79835) -- Poison Soaked Shell
module:RegisterDebuff(TIER, INSTANCE, BOSS, 92048) -- Shadow Infusion
module:RegisterDebuff(TIER, INSTANCE, BOSS, 92053) -- Shadow Conductor
module:RegisterDebuff(TIER, INSTANCE, BOSS, 77699) -- Flash Freeze
module:RegisterDebuff(TIER, INSTANCE, BOSS, 77760) -- Biting Chill
module:RegisterDebuff(TIER, INSTANCE, BOSS, 92754) -- Engulfing Darkness
module:RegisterDebuff(TIER, INSTANCE, BOSS, 78092) -- Tracking
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82881) -- Break
module:RegisterDebuff(TIER, INSTANCE, BOSS, 89084) -- Low Health
module:RegisterDebuff(TIER, INSTANCE, BOSS, 81114) -- Magma
module:RegisterDebuff(TIER, INSTANCE, BOSS, 79339) -- Explosive Cinders
module:RegisterDebuff(TIER, INSTANCE, BOSS, 79318) -- Dominion