local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 11
local INSTANCE = 1302 -- 法力熔炉：欧米伽

local BOSS
BOSS = 2684 -- 集能哨兵
module:RegisterDebuff(TIER, INSTANCE, BOSS, 434705) -- 暴捶

BOSS = 2686 -- 卢米萨尔

BOSS = 2685 -- 缚魂者娜欣达利

BOSS = 2687 -- 熔炉编织者阿拉兹

BOSS = 2688 -- 狩魂猎手

BOSS = 2747 -- 弗兰克提鲁斯

BOSS = 2690 -- 节点之王萨哈达尔

BOSS = 2691 -- 诸界吞噬者迪门修斯