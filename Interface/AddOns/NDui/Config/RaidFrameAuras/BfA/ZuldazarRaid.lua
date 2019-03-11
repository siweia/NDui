local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1176 -- 达萨罗之战
local BOSS

BOSS = 2333 -- 圣光勇士
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283573) -- 圣洁之刃
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283617) -- 圣光之潮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283651) -- 盲目之光
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284595) -- 苦修
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283582) -- 奉献

BOSS = 2325 -- 丛林之王格洛恩
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285671) -- 碾碎
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285998) -- 凶狠咆哮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285875) -- 撕裂噬咬
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285659, 6) -- 猿猴折磨者核心
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286373, 6) -- 死亡战栗
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283069) -- 原子烈焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286434) -- 死疽之核
module:RegisterDebuff(TIER, INSTANCE, BOSS, 289406) -- 蛮兽压掷

BOSS = 2341 -- 玉火大师
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286988, 6) -- 炽热余烬
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284374) -- 熔岩陷阱
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282037) -- 升腾之焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286379) -- 炎爆术
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285632) -- 追踪
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288151) -- 考验后遗症
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284089) -- 成功防御
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286503) -- 射线
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287747) -- 超力之球

BOSS = 2342 -- 丰灵
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287424) -- 窃贼的报应
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284527, 1) -- 坚毅守护者的钻石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284546) -- 枯竭的钻石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284567, 1) -- 顺风蓝宝石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284558, 1) -- 暗影之王紫水晶
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284556) -- 暗影触痕
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284611, 1) -- 聚焦敌意红宝石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284645, 1) -- 璀璨日光黄晶
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284664) -- 炽热
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284798, 6) -- 极度炽热
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284814) -- 地之根系绿宝石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284881) -- 怒意释放猫眼石
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283610) -- 碾压
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283609) -- 碾压
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283507) -- 爆裂充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287648) -- 爆裂充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283063) -- 惩罚烈焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287513) -- 惩罚烈焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285479) -- 烈焰喷射
module:RegisterDebuff(TIER, INSTANCE, BOSS, 283947) -- 烈焰喷射
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285014, 6) -- 金币雨
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284470, 6) -- 昏睡妖术
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287072) -- 液态黄金
module:RegisterDebuff(TIER, INSTANCE, BOSS, 289383) -- 混沌位移
module:RegisterDebuff(TIER, INSTANCE, BOSS, 291146, 6) -- 混沌位移

BOSS = 2330 -- 神选者教团
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282135, 6) -- 恶意妖术
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282209) -- 掠食印记
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282592) -- 血流不止
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286838) -- 静电之球
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282444) -- 裂爪猛击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285879, 6) -- 记忆清除
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284663, 6) -- 邦桑迪的愤怒

BOSS = 2335 -- 拉斯塔哈大王
module:RegisterDebuff(TIER, INSTANCE, BOSS, 289917, 6) -- 邦桑迪的契约，小怪
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284831) -- 炽焰引爆
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285010) -- 蟾蜍粘液毒素
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284676) -- 净化之印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 290450) -- 净化之印
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285178) -- 蛇焰吐息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 289858) -- 碾压
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284781, 6) -- 重斧掷击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 290955, 6) -- 重斧掷击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285349) -- 赤焰瘟疫
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284995) -- 僵尸尘
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285195) -- 寂灭凋零
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288449, 6) -- 死亡之门
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286742) -- 死疽碎击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286779) -- 死亡聚焦
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288415) -- 死亡之抚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285213) -- 死亡之抚

BOSS = 2334 -- 大工匠梅卡托克
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286646, 6) -- 千兆伏特充能
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288806) -- 千兆伏特轰炸
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284168) -- 缩小
module:RegisterDebuff(TIER, INSTANCE, BOSS, 282182) -- 毁灭加农炮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287891) -- 绵羊弹片
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286516) -- 反干涉震击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286480) -- 反干涉震击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284214) -- 践踏
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287167) -- 基因解组
module:RegisterDebuff(TIER, INSTANCE, BOSS, 286105) -- 干涉

BOSS = 2337 -- 风暴之墙阻击战
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284405) -- 诱惑之歌
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284369) -- 海洋暴风
module:RegisterDebuff(TIER, INSTANCE, BOSS, 284121) -- 雷霆轰鸣
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285350) -- 风暴哀嚎
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285000) -- 海藻缠裹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285350, 6) -- 风暴哀嚎
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285426, 6) -- 风暴哀嚎

BOSS = 2343 -- 吉安娜·普罗德摩尔
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287490) -- 冻结
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287993, 1) -- 寒冰之触
module:RegisterDebuff(TIER, INSTANCE, BOSS, 285253) -- 寒冰碎片
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288038) -- 被标记的目标
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287626) -- 冰霜掌控
module:RegisterDebuff(TIER, INSTANCE, BOSS, 287199) -- 寒冰之环
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288212) -- 舷侧攻击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288434) -- 寒冰之手
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288374) -- 破城者炮击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288219) -- 折射寒冰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 288219) -- 折射寒冰