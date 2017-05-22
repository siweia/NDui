------------------------------------------------------------
-- TheNighthold.lua
--
-- Abin
-- 2019/09/13
------------------------------------------------------------

local module = NDui:GetModule("RaidFrameAuras")
if not module then return end

local TIER = 7 -- Legion
local INSTANCE = 786 -- The Nighthold
local BOSS

BOSS = 1706
module:RegisterDebuff(TIER, INSTANCE, BOSS, 204531)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 204284, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 204483)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 211659)

BOSS = 1725
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206607)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 219966, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 219965, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 219964, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206617, 4)

BOSS = 1731
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208506)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206788)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206641)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208924)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 214583)

BOSS = 1751
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212587)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 213328)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212494)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212647, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 213621, 5)

BOSS = 1762
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206480, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206365)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 212795, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 216040, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208230)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206466)

BOSS = 1713
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205348)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205420)

BOSS = 1761
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218424)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218780)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218438)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218502)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218809, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 218342, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 220114)		-- achievement
module:RegisterDebuff(TIER, INSTANCE, BOSS, 219235)

BOSS = 1732
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206936)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 205649)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206464)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 207720, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206603, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206398, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206585)

BOSS = 1743
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210387)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209244, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209598, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209973, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209549)

BOSS = 1737
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206222, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206221, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206883)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206896)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 206875)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 209454, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 221728, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 221606, 5)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 210339, 4)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 208802, 3)
