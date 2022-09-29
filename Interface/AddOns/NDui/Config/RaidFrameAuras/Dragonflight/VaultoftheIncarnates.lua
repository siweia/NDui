local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE = 1200 -- 化身巨龙牢窟

local BOSS

BOSS = 2480 -- 艾拉诺格
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2500 -- 泰洛斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2486 -- 原始议会
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2482 -- 瑟娜尔丝，冰冷之息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2502 -- 晋升者达瑟雅
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2491 -- 库洛格·恐怖图腾
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2493 -- 巢穴守护者迪乌尔娜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心

BOSS = 2499 -- 莱萨杰丝，噬雷之龙
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心