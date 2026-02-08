local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 548 -- 毒蛇神殿

-- 小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 39029) -- 恶性毒药
module:RegisterDebuff(TIER, INSTANCE, 0, 39015) -- 萎缩打击
module:RegisterDebuff(TIER, INSTANCE, 0, 38718) -- 剧毒之池
module:RegisterDebuff(TIER, INSTANCE, 0, 39032) -- 初期感染
module:RegisterDebuff(TIER, INSTANCE, 0, 39042) -- 快速感染
module:RegisterDebuff(TIER, INSTANCE, 0, 38626) -- 支配
-- 不稳定的海度斯
module:RegisterDebuff(TIER, INSTANCE, 0, 38235) -- 水之墓
module:RegisterDebuff(TIER, INSTANCE, 0, 38215) -- 海度斯印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38216) -- 海度斯印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38217) -- 海度斯印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38218) -- 海度斯印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38219) -- 腐蚀印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38220) -- 腐蚀印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38221) -- 腐蚀印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38222) -- 腐蚀印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38230) -- 腐蚀印记
module:RegisterDebuff(TIER, INSTANCE, 0, 38246) -- 肮脏淤泥
-- 鱼斯拉
module:RegisterDebuff(TIER, INSTANCE, 0, 37284) -- 沸水
-- 莫洛格里·踏潮者
module:RegisterDebuff(TIER, INSTANCE, 0, 38023) -- 水之墓穴
module:RegisterDebuff(TIER, INSTANCE, 0, 38024) -- 水之墓穴
module:RegisterDebuff(TIER, INSTANCE, 0, 38025) -- 水之墓穴
module:RegisterDebuff(TIER, INSTANCE, 0, 37850) -- 水之墓穴
module:RegisterDebuff(TIER, INSTANCE, 0, 37730) -- 海潮之波
-- 深水领主卡拉瑟雷斯
module:RegisterDebuff(TIER, INSTANCE, 0, 29436) -- 吸血投掷
module:RegisterDebuff(TIER, INSTANCE, 0, 39261) -- 尘风
module:RegisterDebuff(TIER, INSTANCE, 0, 38441) -- 灾难之箭
module:RegisterDebuff(TIER, INSTANCE, 0, 38234) -- 冰霜震击
-- 盲眼者莱欧瑟拉斯
module:RegisterDebuff(TIER, INSTANCE, 0, 37640) -- 旋风斩
module:RegisterDebuff(TIER, INSTANCE, 0, 37675) -- 混乱冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 37676) -- 诱惑低语
-- 瓦丝琪女王
module:RegisterDebuff(TIER, INSTANCE, 0, 38253) -- 毒液箭（被污染的元素）
module:RegisterDebuff(TIER, INSTANCE, 0, 38258) -- 恐慌（盘牙精英）
module:RegisterDebuff(TIER, INSTANCE, 0, 38262) -- 断筋（盘牙精英）
module:RegisterDebuff(TIER, INSTANCE, 0, 38509) -- 震荡波
module:RegisterDebuff(TIER, INSTANCE, 0, 38280) -- 静电充能