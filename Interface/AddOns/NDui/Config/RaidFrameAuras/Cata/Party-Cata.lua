local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE -- 5人本

INSTANCE = 68 -- 旋云之巅
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 65 -- 潮汐王座
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 71 -- 格瑞姆巴托
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 451395) -- 腐蚀
module:RegisterDebuff(TIER, INSTANCE, 0, 451378) -- 劈裂
module:RegisterDebuff(TIER, INSTANCE, 0, 447261) -- 碎颅打击
module:RegisterDebuff(TIER, INSTANCE, 0, 451241) -- 暗影烈焰斩
module:RegisterDebuff(TIER, INSTANCE, 0, 449474) -- 熔浆火花
module:RegisterDebuff(TIER, INSTANCE, 0, 451613) -- 暮光烈焰
module:RegisterDebuff(TIER, INSTANCE, 0, 448057) -- 深渊腐蚀
module:RegisterDebuff(TIER, INSTANCE, 0, 456719) -- 暗影之伤