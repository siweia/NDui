------------------------------------------------------------
-- TrialofValor.lua
--
-- Abin
-- 2016/11/10
------------------------------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 7 -- Legion
local INSTANCE = 861 -- Trial of Valor
local BOSS

BOSS = 1819
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228030, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 229584)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 197961)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228683)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227959)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228915)

BOSS = 1830
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227539)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227566)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227570)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228226)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228246, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228250)

BOSS = 1829
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227903)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228058)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 228054, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 193367)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 227982, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 232488, 4)
