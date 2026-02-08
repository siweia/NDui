local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 568 -- 祖阿曼

-- 埃基尔松
module:RegisterDebuff(TIER, INSTANCE, 0, 43621) -- 强风
module:RegisterDebuff(TIER, INSTANCE, 0, 43648) -- 电能风暴

-- 纳洛拉克
module:RegisterDebuff(TIER, INSTANCE, 0, 42395) -- 刺裂
module:RegisterDebuff(TIER, INSTANCE, 0, 42397) -- 撕裂
module:RegisterDebuff(TIER, INSTANCE, 0, 42398) -- 震耳咆哮

-- 加亚莱
module:RegisterDebuff(TIER, INSTANCE, 0, 43114) -- 火墙
module:RegisterDebuff(TIER, INSTANCE, 0, 43140) -- 烈焰吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 43299) -- 烈焰打击

-- 哈尔拉兹
module:RegisterDebuff(TIER, INSTANCE, 0, 43303) -- 烈焰震击

-- 妖术领主玛拉卡斯
module:RegisterDebuff(TIER, INSTANCE, 0, 44131) -- 吸取能量
module:RegisterDebuff(TIER, INSTANCE, 0, 43501) -- 灵魂虹吸
module:RegisterDebuff(TIER, INSTANCE, 0, 43586) -- 快速感染
module:RegisterDebuff(TIER, INSTANCE, 0, 43550) -- 精神控制
module:RegisterDebuff(TIER, INSTANCE, 0, 43441) -- 致死打击

-- 祖尔金
module:RegisterDebuff(TIER, INSTANCE, 0, 43150) -- 利爪之怒
module:RegisterDebuff(TIER, INSTANCE, 0, 43983) -- 能量风暴
module:RegisterDebuff(TIER, INSTANCE, 0, 43093) -- 重伤投掷
module:RegisterDebuff(TIER, INSTANCE, 0, 43437) -- 麻痹
module:RegisterDebuff(TIER, INSTANCE, 0, 43095) -- 麻痹蔓延