local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 75 -- 巴拉丁监狱

local BOSS
BOSS = 139 -- 阿尔加洛斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 96913) -- Searing Shadows
module:RegisterDebuff(TIER, INSTANCE, BOSS, 104936) -- Skewer
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105067) -- Seething Hate