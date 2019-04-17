local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1177 -- 风暴熔炉
local BOSS

BOSS = 2328 -- 无眠秘党
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282384) -- 精神割裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282566) -- 力量应许
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282743) -- 风暴湮灭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282738) -- 虚空之拥
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282589) -- 脑髓侵袭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287876) -- 黑暗吞噬
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282432, 3) -- 粉碎之凝

BOSS = 2332 -- 乌纳特，虚空先驱
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284851) -- 末日之触
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285652) -- 贪食折磨
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285345) -- 恩佐斯的癫狂之眼
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285562) -- 不可知的恐惧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285477) -- 渊黯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285367) -- 恩佐斯的穿刺凝视