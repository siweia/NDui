local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE

INSTANCE = 1201 -- 艾杰斯亚学院
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1196 -- 蕨皮山谷
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1204 -- 注能大厅
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1199 -- 奈萨鲁斯
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1202 -- 红玉新生法池
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1203 -- 碧蓝魔馆
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 387151, 6) -- 寒冰灭绝者

INSTANCE = 1198 -- 诺库德阻击战
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1197 -- 奥达曼：提尔的遗产
module:RegisterSeasonSpells(TIER, INSTANCE)

-- S1
INSTANCE = 313 -- 青龙寺
module:RegisterSeasonSpells(5, INSTANCE)

INSTANCE = 537 -- 影月墓地
module:RegisterSeasonSpells(6, INSTANCE)