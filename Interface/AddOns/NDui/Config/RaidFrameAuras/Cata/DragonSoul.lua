local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 4
local INSTANCE = 187 -- 巨龙之魂

local BOSS
BOSS = 311 -- 莫卓克

BOSS = 324 -- 督军佐诺兹

BOSS = 325 -- 不眠的约萨希

BOSS = 317 -- 缚风者哈格拉

BOSS = 331 -- 奥卓克希昂

BOSS = 332 -- 战争大师黑角

BOSS = 318 -- 死亡之翼的背脊

BOSS = 333 -- 疯狂的死亡之翼

module:RegisterDebuff(TIER, INSTANCE, BOSS, 103541) -- Safe
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103536) -- Warning
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103534) -- Danger
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103687) -- Crush Armor
module:RegisterDebuff(TIER, INSTANCE, BOSS, 103434) -- Disrupting Shadows
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105171) -- Deep Corruption
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105465) -- Lighting Storm
module:RegisterDebuff(TIER, INSTANCE, BOSS, 104451) -- Ice Tomb
module:RegisterDebuff(TIER, INSTANCE, BOSS, 109325) -- Frostflake
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105289) -- Shattered Ice
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105285) -- Target
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105259) -- Watery Entrenchment
module:RegisterDebuff(TIER, INSTANCE, BOSS, 109075) -- Fading Light
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108043) -- Sunder Armor
module:RegisterDebuff(TIER, INSTANCE, BOSS, 107558) -- Degeneration
module:RegisterDebuff(TIER, INSTANCE, BOSS, 107567) -- Brutal Strike
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108046) -- Shockwave
module:RegisterDebuff(TIER, INSTANCE, BOSS, 110214) -- Shockwave
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105479) -- Searing Plasma
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105490) -- Fiery Grip
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105563) -- Grasping Tendrils
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106199) -- Blood Corruption: Death
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105841) -- Degenerative Bite
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106385) -- Crush
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106730) -- Tetanus
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106444) -- Impale
module:RegisterDebuff(TIER, INSTANCE, BOSS, 106794) -- Shrapnel (Target)
module:RegisterDebuff(TIER, INSTANCE, BOSS, 105445) -- Blistering Heat
module:RegisterDebuff(TIER, INSTANCE, BOSS, 108649) -- Corrupting Parasite