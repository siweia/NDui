local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 72 -- 暮光堡垒

local BOSS
BOSS = 156 -- 哈尔弗斯·碎龙者

BOSS = 157 -- 瑟纳利昂和瓦里昂娜

BOSS = 158 -- 升腾者议会

BOSS = 167 -- 古加尔
module:RegisterDebuff(TIER, INSTANCE, BOSS, 39171) -- Malevolent Strikes
module:RegisterDebuff(TIER, INSTANCE, BOSS, 83710) -- Furious Roar
module:RegisterDebuff(TIER, INSTANCE, BOSS, 86840) -- Devouring Flames
module:RegisterDebuff(TIER, INSTANCE, BOSS, 88518) -- Twilight Meteorite
module:RegisterDebuff(TIER, INSTANCE, BOSS, 86505) -- Fabulous Flames
module:RegisterDebuff(TIER, INSTANCE, BOSS, 93051) -- Twilight Shift
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82762) -- Waterlogged
module:RegisterDebuff(TIER, INSTANCE, BOSS, 83099) -- Lightning Rod
module:RegisterDebuff(TIER, INSTANCE, BOSS, 92075) -- Gravity Core
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82660) -- Burning Blood
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82665) -- Heart of Ice
module:RegisterDebuff(TIER, INSTANCE, BOSS, 83500) -- Swirling Winds
module:RegisterDebuff(TIER, INSTANCE, BOSS, 83581) -- Grounded
module:RegisterDebuff(TIER, INSTANCE, BOSS, 92067) -- Static Overload
module:RegisterDebuff(TIER, INSTANCE, BOSS, 86028) -- Cho's Blast
module:RegisterDebuff(TIER, INSTANCE, BOSS, 86029) -- Gall's Blast
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82125) -- Corruption: Malformation
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82170) -- Corruption: Absolute
module:RegisterDebuff(TIER, INSTANCE, BOSS, 82411) -- Debilitating Beam
module:RegisterDebuff(TIER, INSTANCE, BOSS, 91317) -- Worshipping