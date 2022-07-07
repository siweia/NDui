local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 6
local INSTANCE -- 5人本

INSTANCE = 536 -- 恐轨车站
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 558 -- 钢铁码头
module:RegisterSeasonSpells(TIER, INSTANCE)