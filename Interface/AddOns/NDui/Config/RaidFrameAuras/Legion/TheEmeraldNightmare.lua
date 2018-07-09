------------------------------------------------------------
-- TheEmeraldNightmare.lua
--
-- Abin
-- 2019/09/13
------------------------------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 7 -- Legion
local INSTANCE = 768 -- The Emerald Nightmare
local BOSS

BOSS = 1703
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203096)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205043, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 204463)

BOSS = 1738
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208929)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210984)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209469, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208931)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210099, 4)

BOSS = 1744
module:RegisterDebuff(TIER, INSTANCE, BOSS, 215443)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210850)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 215288)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210229, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 215582, 4)

BOSS = 1667
module:RegisterDebuff(TIER, INSTANCE, BOSS, 198108)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 198006)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 197943, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 197942, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 197980)

BOSS = 1704
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203110)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203770, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203690)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203124)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 203102)

BOSS = 1750
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210279)

BOSS = 1726
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206005)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206651)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209158)

BOSS = 0
module:RegisterDebuff(TIER, INSTANCE, BOSS, 222771)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 222786)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 222719)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 223912)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 221028)
