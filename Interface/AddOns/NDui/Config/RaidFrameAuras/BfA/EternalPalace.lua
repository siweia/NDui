local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1179 -- 永恒王宫
local BOSS

BOSS = 2352 -- 深渊指挥官西瓦拉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 294711) -- 冰霜烙印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 294715) -- 剧毒烙印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 295795) -- 冻结之血

BOSS = 2347 -- 黑水巨鳗

BOSS = 2353 -- 艾萨拉之辉

BOSS = 2354 -- 艾什凡女勋爵

BOSS = 2351 -- 奥戈佐亚

BOSS = 2359 -- 女王法庭

BOSS = 2349 -- 扎库尔，尼奥罗萨先驱

BOSS = 2361 -- 艾萨拉女王