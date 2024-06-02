local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 78 -- 火焰之地

local BOSS
BOSS = 192 -- 贝丝缇拉克

BOSS = 193 -- 雷奥利斯领主

BOSS = 194 -- 奥利瑟拉佐尔

BOSS = 195 -- 沙恩诺克斯

BOSS = 196 -- 护门人贝尔洛克

BOSS = 197 -- 管理者鹿盔

BOSS = 198 -- 拉格纳罗斯

module:RegisterDebuff(TIER, INSTANCE, BOSS, 99506) -- Widows Kiss
module:RegisterDebuff(TIER, INSTANCE, BOSS, 97202) -- Fiery Web Spin
module:RegisterDebuff(TIER, INSTANCE, BOSS, 49026) -- Fixate
module:RegisterDebuff(TIER, INSTANCE, BOSS, 97079) -- Seeping Venom
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99389) -- Imprinted
module:RegisterDebuff(TIER, INSTANCE, BOSS, 100640) -- Harsh Winds
module:RegisterDebuff(TIER, INSTANCE, BOSS, 100555) -- Smouldering Roots
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99837) -- Crystal Prison
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99937) -- Jagged Tear
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99256) -- Torment
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99252) -- Blaze of Glory
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99516) -- Countdown
module:RegisterDebuff(TIER, INSTANCE, BOSS, 98450) -- Searing Seeds
module:RegisterDebuff(TIER, INSTANCE, BOSS, 98565) -- Burning Orb
module:RegisterDebuff(TIER, INSTANCE, BOSS, 98313) -- Magma Blast
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99145) -- Blazing Heat
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99399) -- Burning Wound
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99613) -- Molten Blast
module:RegisterDebuff(TIER, INSTANCE, BOSS, 100675) -- Dreadflame
module:RegisterDebuff(TIER, INSTANCE, BOSS, 99532) -- Melt Armor