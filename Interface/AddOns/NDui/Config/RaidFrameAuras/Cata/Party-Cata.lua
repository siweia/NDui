local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE -- 5人本

INSTANCE = 68 -- 旋云之巅
module:RegisterSeasonSpells(TIER, INSTANCE)