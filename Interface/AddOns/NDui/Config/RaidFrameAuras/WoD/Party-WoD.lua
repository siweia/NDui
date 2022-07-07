local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 6
local INSTANCE -- 5人本

INSTANCE = 536 -- 恐轨车站
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 162057) -- 蚀骨之矛
module:RegisterDebuff(TIER, INSTANCE, 0, 156357) -- 黑石榴弹
module:RegisterDebuff(TIER, INSTANCE, 0, 160702) -- 黑石迫击炮弹
module:RegisterDebuff(TIER, INSTANCE, 0, 160681) -- 火力压制
module:RegisterDebuff(TIER, INSTANCE, 0, 166570) -- 熔渣冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 164218) -- 双重猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 162491) -- 正在获取目标1
module:RegisterDebuff(TIER, INSTANCE, 0, 162507) -- 正在获取目标2
module:RegisterDebuff(TIER, INSTANCE, 0, 161588) -- 散射能量
module:RegisterDebuff(TIER, INSTANCE, 0, 162065) -- 冰冻诱捕

INSTANCE = 558 -- 钢铁码头
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 163276) -- 筋腱撕裂
module:RegisterDebuff(TIER, INSTANCE, 0, 162415, 6) -- 进食时间
module:RegisterDebuff(TIER, INSTANCE, 0, 168398) -- 急速射击瞄准
module:RegisterDebuff(TIER, INSTANCE, 0, 373570, 6) -- 催眠
module:RegisterDebuff(TIER, INSTANCE, 0, 373607) -- 暗影屏障
module:RegisterDebuff(TIER, INSTANCE, 0, 172889) -- 冲击猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 374295) -- 恢复 6%
module:RegisterDebuff(TIER, INSTANCE, 0, 374300) -- 恢复 20%
module:RegisterDebuff(TIER, INSTANCE, 0, 172631) -- 被击倒
module:RegisterDebuff(TIER, INSTANCE, 0, 158341) -- 龟裂创伤
module:RegisterDebuff(TIER, INSTANCE, 0, 167240) -- 牵制射击
module:RegisterDebuff(TIER, INSTANCE, 0, 373509) -- 暗影利爪
module:RegisterDebuff(TIER, INSTANCE, 0, 173105) -- 锁链旋风
module:RegisterDebuff(TIER, INSTANCE, 0, 173324) -- 锯齿蒺藜
module:RegisterDebuff(TIER, INSTANCE, 0, 172771) -- 燃烧弹
module:RegisterDebuff(TIER, INSTANCE, 0, 173307) -- 倒钩长矛
module:RegisterDebuff(TIER, INSTANCE, 0, 169341) -- 挫志怒吼