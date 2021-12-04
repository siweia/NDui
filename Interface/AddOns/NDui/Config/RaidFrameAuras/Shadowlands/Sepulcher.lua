local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if not DB.isNewPatch then return end

local TIER = 9
local INSTANCE = 1195 -- 初诞者圣墓
local BOSS

BOSS = 2458 -- 警戒卫士
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364881) -- 物质分解

BOSS = 2459 -- 道茜歌妮，堕落先知

BOSS = 2470 -- 圣物匠赛·墨克斯

BOSS = 2460 -- 死亡万神殿原型体

BOSS = 2461 -- 首席建筑师利许威姆

BOSS = 2465 -- 司垢莱克斯，无穷噬灭者

BOSS = 2463 -- 回收者黑伦度斯

BOSS = 2469 -- 安度因·乌瑞恩

BOSS = 2457 -- 恐惧双王

BOSS = 2467 -- 莱葛隆

BOSS = 2464 -- 典狱长