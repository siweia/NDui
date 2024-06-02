local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 72 -- 暮光堡垒

local BOSS
BOSS = 156 -- 哈尔弗斯·碎龙者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 24099) -- 毒液箭雨

BOSS = 157 -- 瑟纳利昂和瓦里昂娜

BOSS = 158 -- 升腾者议会

BOSS = 167 -- 古加尔