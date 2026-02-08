local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 3
local INSTANCE = 249 -- 奥妮克希亚的巢穴

module:RegisterDebuff(TIER, INSTANCE, 0, 18431) -- 低沉咆哮