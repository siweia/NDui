local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8 -- BfA
local INSTANCE -- 5人本

INSTANCE = 1023 -- 围攻伯拉勒斯
--module:RegisterDebuff(TIER, INSTANCE, 0, 209858)

INSTANCE = 1022 -- 地渊孢林

INSTANCE = 1030 -- 塞塔里斯神庙
module:RegisterDebuff(TIER, INSTANCE, 0, 269970) -- 盲目之沙
module:RegisterDebuff(TIER, INSTANCE, 0, 266923) -- 充电

INSTANCE = 1002 -- 托尔达戈

INSTANCE = 1012 -- 暴富矿区

INSTANCE = 1021 -- 维克雷斯庄园

INSTANCE = 1001 -- 自由镇

INSTANCE = 1041 -- 诸王之眠
module:RegisterDebuff(TIER, INSTANCE, 0, 265773) -- 吐金
module:RegisterDebuff(TIER, INSTANCE, 0, 266231) -- 斩首之斧

INSTANCE = 968 -- 阿塔达萨

INSTANCE = 1036 -- 风暴神殿