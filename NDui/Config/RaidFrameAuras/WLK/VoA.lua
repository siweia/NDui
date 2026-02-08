local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 3
local INSTANCE = 624 -- 阿卡玛冯的宝库

module:RegisterDebuff(TIER, INSTANCE, 0, 18431) -- 低沉咆哮