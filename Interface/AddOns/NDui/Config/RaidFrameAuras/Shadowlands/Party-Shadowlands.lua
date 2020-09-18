local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 9
local INSTANCE -- 5人本

local SEASON_SPELLS = {
    [209858] = 2, -- 死疽
    [240443] = 2, -- 爆裂
    [240559] = 2, -- 重伤
    [342494] = 2, -- 狂妄吹嘘
}
local function RegisterSeasonSpells(INSTANCE)
    for spellID, priority in pairs(SEASON_SPELLS) do
        module:RegisterDebuff(TIER, INSTANCE, 0, spellID, priority)
    end
end

INSTANCE = 1187 -- 伤逝剧场
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 333299) -- 荒芜诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 319539) -- 无魂者
module:RegisterDebuff(TIER, INSTANCE, 0, 326892) -- 锁定
module:RegisterDebuff(TIER, INSTANCE, 0, 321768) -- 上钩了
module:RegisterDebuff(TIER, INSTANCE, 0, 323825) -- 攫取裂隙
module:RegisterDebuff(TIER, INSTANCE, 0, 333231) -- 灼热之陨
module:RegisterDebuff(TIER, INSTANCE, 0, 330532) -- 锯齿箭

INSTANCE = 1183 -- 凋魂之殇
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 336258) -- 落单狩猎
module:RegisterDebuff(TIER, INSTANCE, 0, 331818) -- 暗影伏击
module:RegisterDebuff(TIER, INSTANCE, 0, 329110) -- 软泥注射
module:RegisterDebuff(TIER, INSTANCE, 0, 325552) -- 毒性裂击
module:RegisterDebuff(TIER, INSTANCE, 0, 336301) -- 裹体之网

INSTANCE = 1184 -- 塞兹仙林的迷雾
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 325027) -- 荆棘爆发
module:RegisterDebuff(TIER, INSTANCE, 0, 323043) -- 放血
module:RegisterDebuff(TIER, INSTANCE, 0, 322557) -- 灵魂分裂
module:RegisterDebuff(TIER, INSTANCE, 0, 331172) -- 心灵连接
module:RegisterDebuff(TIER, INSTANCE, 0, 322563) -- 被标记的猎物
module:RegisterDebuff(TIER, INSTANCE, 0, 341198) -- 易燃爆炸

INSTANCE = 1188 -- 彼界
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 320786) -- 势不可挡
module:RegisterDebuff(TIER, INSTANCE, 0, 334913) -- 死亡之主
module:RegisterDebuff(TIER, INSTANCE, 0, 325725) -- 寰宇操控
module:RegisterDebuff(TIER, INSTANCE, 0, 328987) -- 狂热
module:RegisterDebuff(TIER, INSTANCE, 0, 334496) -- 催眠光粉
module:RegisterDebuff(TIER, INSTANCE, 0, 339978) -- 安抚迷雾
module:RegisterDebuff(TIER, INSTANCE, 0, 323692) -- 奥术易伤
module:RegisterDebuff(TIER, INSTANCE, 0, 333250) -- 放血之击
module:RegisterDebuff(TIER, INSTANCE, 0, 322746) -- 堕落之血

INSTANCE = 1186 -- 晋升高塔
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 338729) -- 充能践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 327481) -- 黑暗长枪
module:RegisterDebuff(TIER, INSTANCE, 0, 322818) -- 失去信心
module:RegisterDebuff(TIER, INSTANCE, 0, 322817) -- 疑云密布
module:RegisterDebuff(TIER, INSTANCE, 0, 324154) -- 暗影迅步
module:RegisterDebuff(TIER, INSTANCE, 0, 335805) -- 执政官的壁垒

INSTANCE = 1185 -- 赎罪大厅
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 335338) -- 哀伤仪式
module:RegisterDebuff(TIER, INSTANCE, 0, 326891) -- 痛楚
module:RegisterDebuff(TIER, INSTANCE, 0, 329321) -- 锯齿横扫
module:RegisterDebuff(TIER, INSTANCE, 0, 319603) -- 羁石诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 319611) -- 变成石头
module:RegisterDebuff(TIER, INSTANCE, 0, 325876) -- 湮灭诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 326632) -- 石化血脉
module:RegisterDebuff(TIER, INSTANCE, 0, 323650) -- 萦绕锁定
module:RegisterDebuff(TIER, INSTANCE, 0, 326874) -- 脚踝撕咬

INSTANCE = 1189 -- 赤红深渊
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 326827) -- 恐惧之缚
module:RegisterDebuff(TIER, INSTANCE, 0, 326836) -- 镇压诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 322554) -- 严惩
module:RegisterDebuff(TIER, INSTANCE, 0, 321038) -- 烦扰之魂

INSTANCE = 1182 -- 通灵战潮
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 321821) -- 作呕喷吐
module:RegisterDebuff(TIER, INSTANCE, 0, 323365) -- 黑暗纠缠
module:RegisterDebuff(TIER, INSTANCE, 0, 338353) -- 瘀液喷撒
module:RegisterDebuff(TIER, INSTANCE, 0, 333485) -- 疾病之云
module:RegisterDebuff(TIER, INSTANCE, 0, 338357) -- 暴锤
module:RegisterDebuff(TIER, INSTANCE, 0, 328181) -- 冷冽之寒
module:RegisterDebuff(TIER, INSTANCE, 0, 320170) -- 通灵箭
module:RegisterDebuff(TIER, INSTANCE, 0, 323464) -- 黑暗脓液
module:RegisterDebuff(TIER, INSTANCE, 0, 323198) -- 黑暗放逐
module:RegisterDebuff(TIER, INSTANCE, 0, 327401) -- 共受苦难
module:RegisterDebuff(TIER, INSTANCE, 0, 327397) -- 严酷命运
module:RegisterDebuff(TIER, INSTANCE, 0, 322681) -- 肉钩