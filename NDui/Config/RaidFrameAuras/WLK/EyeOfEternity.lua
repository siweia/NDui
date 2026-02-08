local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 3
local INSTANCE = 616 -- 永恒之眼

module:RegisterDebuff(TIER, INSTANCE, 0, 18431) -- 低沉咆哮