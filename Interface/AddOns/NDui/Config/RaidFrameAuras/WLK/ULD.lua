local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 3
local INSTANCE = 603 -- 奥杜尔

module:RegisterDebuff(TIER, INSTANCE, 0, 65121) -- 灼热之光
module:RegisterDebuff(TIER, INSTANCE, 0, 64234) -- 重力炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 64292, 6) -- 捉人