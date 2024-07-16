local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 11
local INSTANCE = 1273 -- 尼鲁巴尔王宫

local BOSS
BOSS = 2607 -- 噬灭者乌格拉克斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 370648) -- 熔岩涌流 -- 示例

BOSS = 2611 -- 血缚恐魔

BOSS = 2599 -- 苏雷吉队长席克兰

BOSS = 2609 -- 拉夏南

BOSS = 2612 -- 虫巢扭曲者欧维纳克斯

BOSS = 2601 -- 节点女亲王凯威扎

BOSS = 2608 -- 流丝之庭

BOSS = 2602 -- 安苏雷克女王