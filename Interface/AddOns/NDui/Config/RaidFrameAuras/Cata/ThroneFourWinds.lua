local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 74 -- 风神王座

local BOSS
BOSS = 154 -- 风之议会

BOSS = 155 -- 奥拉基尔

module:RegisterDebuff(TIER, INSTANCE, BOSS, 86206) -- Soothing Breeze
module:RegisterDebuff(TIER, INSTANCE, BOSS, 87873) -- Static Shock
module:RegisterDebuff(TIER, INSTANCE, BOSS, 87856) -- Squall Line
module:RegisterDebuff(TIER, INSTANCE, BOSS, 88427) -- Electrocute