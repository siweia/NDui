local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 73 -- 黑翼血环

local BOSS
BOSS = 169 -- 全能金刚防御系统
module:RegisterDebuff(TIER, INSTANCE, BOSS, 24099) -- 毒液箭雨

BOSS = 170 -- 熔喉

BOSS = 171 -- 艾卓曼德斯

BOSS = 172 -- 奇美隆

BOSS = 173 -- 马洛拉克

BOSS = 174 -- 奈法利安的末日