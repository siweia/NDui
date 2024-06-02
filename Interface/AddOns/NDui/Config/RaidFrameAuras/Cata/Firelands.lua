local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 78 -- 火焰之地

local BOSS
BOSS = 192 -- 贝丝缇拉克
module:RegisterDebuff(TIER, INSTANCE, BOSS, 24099) -- 毒液箭雨

BOSS = 193 -- 雷奥利斯领主

BOSS = 194 -- 奥利瑟拉佐尔

BOSS = 195 -- 沙恩诺克斯

BOSS = 196 -- 护门人贝尔洛克

BOSS = 197 -- 管理者鹿盔

BOSS = 198 -- 拉格纳罗斯