local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 9
local INSTANCE = 1195 -- 初诞者圣墓
local BOSS

BOSS = 2458 -- 警戒卫士
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360458) -- 不稳定的核心
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364881) -- 物质分解
module:RegisterDebuff(TIER, INSTANCE, BOSS, 366393) -- 烧灼消融
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365175) -- 防护打击[可驱散]
module:RegisterDebuff(TIER, INSTANCE, BOSS, 359610) -- 移除解析
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365168) -- 宇宙猛击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360403) -- 力场
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364904) -- 反物质

BOSS = 2459 -- 道茜歌妮，堕落先知
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361751) -- 衰变光环
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364289) -- 震颤弹幕
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361018) -- 震颤弹幕M
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360960) -- 震颤弹幕M
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361225) -- 侵蚀统御
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361966) -- 注能打击

BOSS = 2470 -- 圣物匠赛·墨克斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362803) -- 移位雕文
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362850) -- 凌光火花新星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362849) -- 凌光火花新星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362614) -- 空间撕裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362615) -- 空间撕裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362837) -- 奥术易伤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364030) -- 衰弱射线
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364604) -- 源生法环
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363413) -- 源生法环
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363114) -- 源生超新星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362882) -- 静滞陷阱

BOSS = 2460 -- 死亡万神殿原型体
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365272) -- 挫心打击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365269) -- 挫心打击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360259) -- 幽影箭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361067) -- 晋升堡垒的结界
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360687) -- 刻符者的死亡之触[可驱散]
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365041) -- 啸风双翼
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361608) -- 罪孽烦扰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362383) -- 心能箭矢
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365306) -- 振奋之花

BOSS = 2461 -- 首席建筑师利许威姆
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360159) -- 不稳定的微粒
module:RegisterDebuff(TIER, INSTANCE, BOSS, 368024) -- 动能共鸣
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363538) -- 原生体耀光
module:RegisterDebuff(TIER, INSTANCE, BOSS, 368025) -- 碎裂共鸣
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363681) -- 解构冲击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363676) -- 解构能量1
module:RegisterDebuff(TIER, INSTANCE, BOSS, 363795) -- 解构能量2

BOSS = 2465 -- 司垢莱克斯，无穷噬灭者
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364522) -- 吞噬之血[可驱散]
module:RegisterDebuff(TIER, INSTANCE, BOSS, 359976) -- 裂隙之喉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 359981) -- 撕裂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360098) -- 折跃恶感
module:RegisterDebuff(TIER, INSTANCE, BOSS, 366070) -- 不稳定的残渣

BOSS = 2463 -- 回收者黑伦度斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361309) -- 碎光射线
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361675) -- 碎地者飞弹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 367838) -- 幻磷裂隙
module:RegisterDebuff(TIER, INSTANCE, BOSS, 360114) -- 幻磷裂隙
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365297) -- 挤压棱镜[可驱散]

BOSS = 2469 -- 安度因·乌瑞恩
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361817) -- 灭愿者[常驻优先级请设定低于其他DEBUFF或者不监控]
module:RegisterDebuff(TIER, INSTANCE, BOSS, 366849) -- 御言术：痛
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365293) -- 亵渎屏障
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361993) -- 绝望
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365966) -- 绝望
module:RegisterDebuff(TIER, INSTANCE, BOSS, 361992) -- 自负
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362055) -- 失落之魂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 362774) -- 灵魂收割
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365024) -- 邪恶之星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 365021) -- 邪恶之星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 367632) -- 强化邪恶之星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 367634) -- 强化邪恶之星
module:RegisterDebuff(TIER, INSTANCE, BOSS, 364020) -- 诅咒进军

BOSS = 2457 -- 恐惧双王

BOSS = 2467 -- 莱葛隆

BOSS = 2464 -- 典狱长