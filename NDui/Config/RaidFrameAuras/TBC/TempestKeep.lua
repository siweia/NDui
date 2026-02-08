local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 550 -- 风暴要塞

-- 小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 37132) -- 奥术震击（星占师学徒）
module:RegisterDebuff(TIER, INSTANCE, 0, 37133) -- 奥术击打（星占师学徒）
module:RegisterDebuff(TIER, INSTANCE, 0, 37279) -- 火焰之雨（星术师学徒）
module:RegisterDebuff(TIER, INSTANCE, 0, 38712) -- 冲击波（星术师领主）
module:RegisterDebuff(TIER, INSTANCE, 0, 37289) -- 龙息术（星术师领主）
module:RegisterDebuff(TIER, INSTANCE, 0, 37123) -- 锯齿利刃（晶核机械师）
module:RegisterDebuff(TIER, INSTANCE, 0, 37135) -- 支配（虚空占卜者）
module:RegisterDebuff(TIER, INSTANCE, 0, 17928) -- 恐惧嚎叫（虚空占卜者）
module:RegisterDebuff(TIER, INSTANCE, 0, 37118) -- 外壳震击（风暴要塞铁匠）
module:RegisterDebuff(TIER, INSTANCE, 0, 37120) -- 破片炸弹（风暴要塞铁匠）
module:RegisterDebuff(TIER, INSTANCE, 0, 37160) -- 沉默（凤鹰幼崽）
module:RegisterDebuff(TIER, INSTANCE, 0, 37155) -- 献祭（风暴驯鹰者）
module:RegisterDebuff(TIER, INSTANCE, 0, 39077) -- 制裁之锤（血警卫侍从/炽手血骑士）
module:RegisterDebuff(TIER, INSTANCE, 0, 13005) -- 制裁之锤（血警卫守备官）
module:RegisterDebuff(TIER, INSTANCE, 0, 37276) -- 精神鞭笞（炽手审讯者）
module:RegisterDebuff(TIER, INSTANCE, 0, 37263) -- 暴风雪（炽手战斗法师）
module:RegisterDebuff(TIER, INSTANCE, 0, 37265) -- 冰锥术（炽手战斗法师）
module:RegisterDebuff(TIER, INSTANCE, 0, 39087) -- 冰霜攻击（炽手战斗法师）
module:RegisterDebuff(TIER, INSTANCE, 0, 37262) -- 寒冰箭雨（炽手战斗法师））
module:RegisterDebuff(TIER, INSTANCE, 0, 33390) -- 奥术洪流（日晷祭司）
-- 奥
module:RegisterDebuff(TIER, INSTANCE, 0, 35383) -- 烈焰之地
module:RegisterDebuff(TIER, INSTANCE, 0, 35410) -- 融化护甲
-- 魔能机甲
module:RegisterDebuff(TIER, INSTANCE, 0, 34190) -- 奥术宝珠
-- 大星术师
module:RegisterDebuff(TIER, INSTANCE, 0, 33023) -- 索兰莉安印记
module:RegisterDebuff(TIER, INSTANCE, 0, 33044) -- 星术师之怒
module:RegisterDebuff(TIER, INSTANCE, 0, 33045) -- 星术师之怒
-- 凯尔萨斯·逐日者
module:RegisterDebuff(TIER, INSTANCE, 0, 36970) -- 奥术爆裂（星术师卡波妮娅）
module:RegisterDebuff(TIER, INSTANCE, 0, 37018) -- 燃烧（星术师卡波妮娅）
module:RegisterDebuff(TIER, INSTANCE, 0, 44863) -- 咆哮（萨古纳尔男爵）
module:RegisterDebuff(TIER, INSTANCE, 0, 37027) -- 遥控玩具（首席技师塔隆尼库斯）
module:RegisterDebuff(TIER, INSTANCE, 0, 36965) -- 撕裂（亵渎者萨拉德雷）
module:RegisterDebuff(TIER, INSTANCE, 0, 30225) -- 沉默（亵渎者萨拉德雷）
module:RegisterDebuff(TIER, INSTANCE, 0, 36834) -- 奥术干扰（凯尔萨斯·逐日者）
module:RegisterDebuff(TIER, INSTANCE, 0, 36797) -- 精神控制（凯尔萨斯·逐日者）