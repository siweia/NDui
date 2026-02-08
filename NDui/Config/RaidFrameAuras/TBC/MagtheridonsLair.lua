local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 544 -- 玛瑟里顿的巢穴

-- 玛瑟里顿
module:RegisterDebuff(TIER, INSTANCE, 0, 44032) -- 心灵疲倦
module:RegisterDebuff(TIER, INSTANCE, 0, 30530) -- 恐惧
module:RegisterDebuff(TIER, INSTANCE, 0, 38927) -- 魔能疼痛