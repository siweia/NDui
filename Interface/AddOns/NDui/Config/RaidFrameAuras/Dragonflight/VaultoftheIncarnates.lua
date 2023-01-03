local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE = 1200 -- 化身巨龙牢窟

local BOSS

BOSS = 2480 -- 艾拉诺格
module:RegisterDebuff(TIER, INSTANCE, BOSS, 370648) -- 熔岩涌流
module:RegisterDebuff(TIER, INSTANCE, BOSS, 390715) -- 火焰裂隙
module:RegisterDebuff(TIER, INSTANCE, BOSS, 370597) -- 杀戮指令

BOSS = 2500 -- 泰洛斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 382776) -- 觉醒之土
module:RegisterDebuff(TIER, INSTANCE, BOSS, 381253) -- 觉醒之土
module:RegisterDebuff(TIER, INSTANCE, BOSS, 386352) -- 岩石冲击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 382458) -- 共鸣余震

BOSS = 2486 -- 原始议会
module:RegisterDebuff(TIER, INSTANCE, BOSS, 371624) -- 传导印记
module:RegisterDebuff(TIER, INSTANCE, BOSS, 372027) -- 劈砍烈焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374039) -- 流星之斧

BOSS = 2482 -- 瑟娜尔丝，冰冷之息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 371976) -- 冰冷冲击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 372082) -- 包围之网
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374659) -- 突进
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374104) -- 困在网中
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374503) -- 困在网中
module:RegisterDebuff(TIER, INSTANCE, BOSS, 373048) -- 窒息之网

BOSS = 2502 -- 晋升者达瑟雅
module:RegisterDebuff(TIER, INSTANCE, BOSS, 391686) -- 传导印记
module:RegisterDebuff(TIER, INSTANCE, BOSS, 378277) -- 元素均衡
module:RegisterDebuff(TIER, INSTANCE, BOSS, 388290) -- 旋风

BOSS = 2491 -- 库洛格·恐怖图腾
module:RegisterDebuff(TIER, INSTANCE, BOSS, 377780) -- 骨骼碎裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 372514) -- 霜寒噬咬
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374554) -- 岩浆之池
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374023) -- 灼热屠戮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 374427) -- 碎地
module:RegisterDebuff(TIER, INSTANCE, BOSS, 390920) -- 震撼爆裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 372458) -- 绝对零度

BOSS = 2493 -- 巢穴守护者迪乌尔娜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 388920) -- 冷凝笼罩
module:RegisterDebuff(TIER, INSTANCE, BOSS, 378782) -- 致死之伤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 378787) -- 碎击龙爪
module:RegisterDebuff(TIER, INSTANCE, BOSS, 375620) -- 电离充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 375578) -- 烈焰哨卫

BOSS = 2499 -- 莱萨杰丝，噬雷之龙
module:RegisterDebuff(TIER, INSTANCE, BOSS, 381615) -- 静电充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 399713) -- 磁力充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 385073) -- 球状闪电
module:RegisterDebuff(TIER, INSTANCE, BOSS, 377467) -- 积雷充能