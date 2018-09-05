local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1031 -- 奥迪尔
local BOSS

BOSS = 2168 -- 塔罗克
module:RegisterDebuff(TIER, INSTANCE, BOSS, 275270) -- 锁定
module:RegisterDebuff(TIER, INSTANCE, BOSS, 278889) -- 赤红迸发
module:RegisterDebuff(TIER, INSTANCE, BOSS, 278888)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 271225)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 271224)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 275189) -- 硬化血脉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 275205) -- 变大的心脏

BOSS = 2167 -- 纯净圣母
module:RegisterDebuff(TIER, INSTANCE, BOSS, 267787) -- 消毒打击

BOSS = 2146 -- 腐臭吞噬者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 262313) -- 恶臭沼气
module:RegisterDebuff(TIER, INSTANCE, BOSS, 262314) -- 腐烂恶臭

BOSS = 2169 -- 泽克沃兹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265237) -- 粉碎
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265264) -- 虚空鞭笞
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265360) -- 翻滚欺诈
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265646, 5) -- 腐化者的意志
module:RegisterDebuff(TIER, INSTANCE, BOSS, 270620) -- 灵能冲击波
module:RegisterDebuff(TIER, INSTANCE, BOSS, 270589) -- 虚空之嚎

BOSS = 2166 -- 维克提斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265129) -- 终极菌体
module:RegisterDebuff(TIER, INSTANCE, BOSS, 267160)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 267161)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265178) -- 进化痛苦
module:RegisterDebuff(TIER, INSTANCE, BOSS, 265212) -- 育种
module:RegisterDebuff(TIER, INSTANCE, BOSS, 274990, 5) -- 破裂损伤

BOSS = 2195 -- 重生者祖尔
module:RegisterDebuff(TIER, INSTANCE, BOSS, 274358) -- 破裂之血
module:RegisterDebuff(TIER, INSTANCE, BOSS, 273434) -- 绝望深渊
module:RegisterDebuff(TIER, INSTANCE, BOSS, 274271) -- 死亡之愿
module:RegisterDebuff(TIER, INSTANCE, BOSS, 278890) -- 剧烈失血

BOSS = 2194 -- 拆解者米斯拉克斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 274693) -- 精华撕裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 272146) -- 毁灭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 272407) -- 湮灭之球

BOSS = 2147 -- 戈霍恩
module:RegisterDebuff(TIER, INSTANCE, BOSS, 272506) -- 爆炸腐蚀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 263235) -- 鲜血盛宴
module:RegisterDebuff(TIER, INSTANCE, BOSS, 267700) -- 戈霍恩的凝视