local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 75 -- 巴拉丁监狱

local BOSS
BOSS = 139 -- 阿尔加洛斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 24099) -- 毒液箭雨