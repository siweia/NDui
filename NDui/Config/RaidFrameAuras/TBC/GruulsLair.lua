local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 565 -- 格鲁尔的巢穴

-- 莫加尔
module:RegisterDebuff(TIER, INSTANCE, 0, 36032) -- 奥术冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 11726) -- 奴役恶魔
module:RegisterDebuff(TIER, INSTANCE, 0, 33129) -- 黑暗凋零
module:RegisterDebuff(TIER, INSTANCE, 0, 33175) -- 奥术震击
module:RegisterDebuff(TIER, INSTANCE, 0, 33061) -- 冲击波
module:RegisterDebuff(TIER, INSTANCE, 0, 33130) -- 死亡缠绕
module:RegisterDebuff(TIER, INSTANCE, 0, 16508) -- 破胆咆哮
-- 格鲁尔
module:RegisterDebuff(TIER, INSTANCE, 0, 38927) -- 魔能疼痛
module:RegisterDebuff(TIER, INSTANCE, 0, 36240) -- 洞穴震颤
module:RegisterDebuff(TIER, INSTANCE, 0, 33652) -- 石化
module:RegisterDebuff(TIER, INSTANCE, 0, 33525) -- 大地冲击