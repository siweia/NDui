local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 1
local INSTANCE -- 5人本

INSTANCE = 48 -- 黑色深渊
module:RegisterDebuff(TIER, INSTANCE, 0, 246) -- 减速术
module:RegisterDebuff(TIER, INSTANCE, 0, 6533) -- 投网
module:RegisterDebuff(TIER, INSTANCE, 0, 8399) -- 催眠

INSTANCE = 230 -- 黑石深渊
module:RegisterDebuff(TIER, INSTANCE, 0, 13704) -- 心灵尖啸

INSTANCE = 36 -- 死矿
module:RegisterDebuff(TIER, INSTANCE, 0, 6304) 	-- 拉克佐猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 12097) -- 刺穿护甲
module:RegisterDebuff(TIER, INSTANCE, 0, 6713) 	-- 缴械
module:RegisterDebuff(TIER, INSTANCE, 0, 5213) 	-- 熔铁之水
module:RegisterDebuff(TIER, INSTANCE, 0, 5208) 	-- 毒性鱼叉

INSTANCE = 349 -- 玛拉顿
module:RegisterDebuff(TIER, INSTANCE, 0, 7964) 	-- 烟雾弹
module:RegisterDebuff(TIER, INSTANCE, 0, 21869) -- 憎恨凝视

INSTANCE = 389 -- 怒焰裂谷
module:RegisterDebuff(TIER, INSTANCE, 0, 744) 	-- 毒药
module:RegisterDebuff(TIER, INSTANCE, 0, 18267) -- 虚弱诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 20800) -- 献祭

INSTANCE = 129 -- 剃刀高地
module:RegisterDebuff(TIER, INSTANCE, 0, 12255) -- 图特卡什的诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 12252) -- 撒网
module:RegisterDebuff(TIER, INSTANCE, 0, 7645) 	-- 统御意志
module:RegisterDebuff(TIER, INSTANCE, 0, 12946) -- 腐烂恶臭

INSTANCE = 47 -- 剃刀沼泽
module:RegisterDebuff(TIER, INSTANCE, 0, 14515) -- 统御意志

INSTANCE = 189 -- 血色修道院
module:RegisterDebuff(TIER, INSTANCE, 0, 9034) 	-- 献祭
module:RegisterDebuff(TIER, INSTANCE, 0, 8814) 	-- 烈焰尖刺
module:RegisterDebuff(TIER, INSTANCE, 0, 8988) 	-- 沉默
module:RegisterDebuff(TIER, INSTANCE, 0, 9256) 	-- 深度睡眠
module:RegisterDebuff(TIER, INSTANCE, 0, 8282) 	-- 血之诅咒

INSTANCE = 33 -- 影牙城堡
module:RegisterDebuff(TIER, INSTANCE, 0, 7068) 	-- 暗影迷雾
module:RegisterDebuff(TIER, INSTANCE, 0, 7125) 	-- 毒性唾液
module:RegisterDebuff(TIER, INSTANCE, 0, 7621) 	-- 阿鲁高的诅咒

INSTANCE = 329 -- 斯塔索姆
module:RegisterDebuff(TIER, INSTANCE, 0, 16798) -- 催眠曲
module:RegisterDebuff(TIER, INSTANCE, 0, 12734) -- 大地粉碎
module:RegisterDebuff(TIER, INSTANCE, 0, 17293) -- 燃烧之风
module:RegisterDebuff(TIER, INSTANCE, 0, 17405) -- 支配
module:RegisterDebuff(TIER, INSTANCE, 0, 16867) -- 女妖诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 6016) 	-- 刺穿护甲
module:RegisterDebuff(TIER, INSTANCE, 0, 16869) -- 寒冰之墓
module:RegisterDebuff(TIER, INSTANCE, 0, 17307) -- 击昏

INSTANCE = 109 -- 沉没的神庙
module:RegisterDebuff(TIER, INSTANCE, 0, 12889) -- 语言诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 12888) -- 导致疯狂
module:RegisterDebuff(TIER, INSTANCE, 0, 12479) -- 伽玛兰的妖术
module:RegisterDebuff(TIER, INSTANCE, 0, 12493) -- 虚弱诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 12890) -- 深度睡眠
module:RegisterDebuff(TIER, INSTANCE, 0, 24375) -- 战争践踏

INSTANCE = 70 -- 奥达曼
module:RegisterDebuff(TIER, INSTANCE, 0, 3356) 	-- 烈焰鞭笞
module:RegisterDebuff(TIER, INSTANCE, 0, 6524) 	-- 大地震颤

INSTANCE = 43 -- 哀嚎洞穴
module:RegisterDebuff(TIER, INSTANCE, 0, 8040) 	-- 德鲁伊的睡眠
module:RegisterDebuff(TIER, INSTANCE, 0, 8142) 	-- 缠绕之藤
module:RegisterDebuff(TIER, INSTANCE, 0, 7967) 	-- 纳拉雷克斯的梦魇
module:RegisterDebuff(TIER, INSTANCE, 0, 7399) 	-- 恐吓
module:RegisterDebuff(TIER, INSTANCE, 0, 8150) 	-- 雷霆震颤

INSTANCE = 209 -- 祖尔法拉克
module:RegisterDebuff(TIER, INSTANCE, 0, 11836) -- 冰霜凝固