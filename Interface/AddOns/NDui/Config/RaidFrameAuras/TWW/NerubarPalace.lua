local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 11
local INSTANCE = 1273 -- 尼鲁巴尔王宫

local BOSS
BOSS = 2607 -- 噬灭者乌格拉克斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 434705) -- 暴捶
module:RegisterDebuff(TIER, INSTANCE, BOSS, 439037) -- 开膛破肚

BOSS = 2611 -- 血缚恐魔

BOSS = 2599 -- 苏雷吉队长席克兰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 434705) -- 相位之刃
module:RegisterDebuff(TIER, INSTANCE, BOSS, 454721) -- 相位之刃
module:RegisterDebuff(TIER, INSTANCE, BOSS, 434860) -- 诛灭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 439191) -- 暴露
module:RegisterDebuff(TIER, INSTANCE, BOSS, 438845) -- 相位贯突

BOSS = 2609 -- 拉夏南
module:RegisterDebuff(TIER, INSTANCE, BOSS, 435410) -- 喷射丝线

BOSS = 2612 -- 虫巢扭曲者欧维纳克斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 440421) -- 试验性剂量
module:RegisterDebuff(TIER, INSTANCE, BOSS, 441368) -- 不稳定的混合物
module:RegisterDebuff(TIER, INSTANCE, BOSS, 446349) -- 粘性之网

BOSS = 2601 -- 节点女亲王凯威扎
module:RegisterDebuff(TIER, INSTANCE, BOSS, 436870) -- 奇袭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 437343) -- 女王之灾
module:RegisterDebuff(TIER, INSTANCE, BOSS, 440576) -- 深凿重创

BOSS = 2608 -- 流丝之庭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 438218) -- 穿刺打击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 440001) -- 束缚之网
module:RegisterDebuff(TIER, INSTANCE, BOSS, 438200) -- 毒液箭

BOSS = 2602 -- 安苏雷克女王
module:RegisterDebuff(TIER, INSTANCE, BOSS, 437586) -- 活性毒素
module:RegisterDebuff(TIER, INSTANCE, BOSS, 436800) -- 液化
module:RegisterDebuff(TIER, INSTANCE, BOSS, 441958) -- 勒握流丝
module:RegisterDebuff(TIER, INSTANCE, BOSS, 447532) -- 麻痹毒液
module:RegisterDebuff(TIER, INSTANCE, BOSS, 447967) -- 晦暗之触
module:RegisterDebuff(TIER, INSTANCE, BOSS, 438974) -- 皇谕责罚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 443656) -- 感染
module:RegisterDebuff(TIER, INSTANCE, BOSS, 441865) -- 皇家镣铐