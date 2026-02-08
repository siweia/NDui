local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 534 -- 海加尔山之战

-- 小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 31688) -- 冰霜吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 31651) -- 女妖诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 31724) -- 烈焰击打
module:RegisterDebuff(TIER, INSTANCE, 0, 31610) -- 击倒
-- 雷基·冬寒
module:RegisterDebuff(TIER, INSTANCE, 0, 31257) -- 冰冻
module:RegisterDebuff(TIER, INSTANCE, 0, 31250) -- 冰霜新星
module:RegisterDebuff(TIER, INSTANCE, 0, 31249) -- 寒冰箭
module:RegisterDebuff(TIER, INSTANCE, 0, 31258) -- 死亡凋零
-- 安纳塞隆
module:RegisterDebuff(TIER, INSTANCE, 0, 31298) -- 催眠术
module:RegisterDebuff(TIER, INSTANCE, 0, 31306) -- 腐臭虫群
-- 卡兹洛加
module:RegisterDebuff(TIER, INSTANCE, 0, 31447) -- 卡兹洛加印记
module:RegisterDebuff(TIER, INSTANCE, 0, 31480) -- 战争践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 31477) -- 残废术
-- 阿兹加洛
module:RegisterDebuff(TIER, INSTANCE, 0, 31341) -- 不熄之焰
module:RegisterDebuff(TIER, INSTANCE, 0, 31347) -- 厄运
module:RegisterDebuff(TIER, INSTANCE, 0, 31340) -- 火焰之雨
module:RegisterDebuff(TIER, INSTANCE, 0, 31344) -- 阿兹加洛之嚎
-- 阿克蒙德
module:RegisterDebuff(TIER, INSTANCE, 0, 31972) -- 军团之握
module:RegisterDebuff(TIER, INSTANCE, 0, 31944) -- 厄运之火
module:RegisterDebuff(TIER, INSTANCE, 0, 31970) -- 恐惧
module:RegisterDebuff(TIER, INSTANCE, 0, 42201) -- 永恒沉默
module:RegisterDebuff(TIER, INSTANCE, 0, 32014) -- 空气爆裂