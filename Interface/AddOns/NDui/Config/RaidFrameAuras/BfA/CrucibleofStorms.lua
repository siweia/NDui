local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1177 -- 风暴熔炉
local BOSS

BOSS = 2328 -- 无眠秘党
module:RegisterDebuff(TIER, INSTANCE, BOSS, 118) -- 占位符

BOSS = 2332 -- 乌纳特，虚空先驱