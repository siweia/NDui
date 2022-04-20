local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 580 -- 太阳之井

-- 卡雷苟斯
module:RegisterDebuff(TIER, INSTANCE, 0, 45034) -- 无边苦痛诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 45032) -- 无边苦痛诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 46021) -- 灵魂世界
module:RegisterDebuff(TIER, INSTANCE, 0, 44867) -- 灵魂疲惫
module:RegisterDebuff(TIER, INSTANCE, 0, 45029) -- 腐蚀打击

-- 布鲁塔卢斯
module:RegisterDebuff(TIER, INSTANCE, 0, 45150) -- 流星猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 46394) -- 燃烧
module:RegisterDebuff(TIER, INSTANCE, 0, 45185) -- 践踏

-- 菲米丝
module:RegisterDebuff(TIER, INSTANCE, 0, 45402) -- 恶魔蒸汽
module:RegisterDebuff(TIER, INSTANCE, 0, 47002) -- 毒气
module:RegisterDebuff(TIER, INSTANCE, 0, 45855) -- 毒气新星
module:RegisterDebuff(TIER, INSTANCE, 0, 45866) -- 腐蚀

-- 艾瑞达双子
module:RegisterDebuff(TIER, INSTANCE, 0, 46771) -- 烈焰灼热
module:RegisterDebuff(TIER, INSTANCE, 0, 45348) -- 烈焰触摸
module:RegisterDebuff(TIER, INSTANCE, 0, 45342) -- 燃烧
module:RegisterDebuff(TIER, INSTANCE, 0, 45271) -- 黑暗打击
module:RegisterDebuff(TIER, INSTANCE, 0, 45345) -- 黑暗烈焰
module:RegisterDebuff(TIER, INSTANCE, 0, 45347) -- 黑暗触摸