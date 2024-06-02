local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 74 -- 风神王座

local BOSS
BOSS = 154 -- 风之议会
module:RegisterDebuff(TIER, INSTANCE, BOSS, 24099) -- 毒液箭雨

BOSS = 155 -- 奥拉基尔