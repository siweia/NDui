local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 12
local INSTANCE

INSTANCE = 1274 -- 千丝之城
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 452151) -- 严酷戳刺
module:RegisterDebuff(TIER, INSTANCE, 0, 451295) -- 虚空奔袭
module:RegisterDebuff(TIER, INSTANCE, 0, 440107) -- 飞刀投掷
module:RegisterDebuff(TIER, INSTANCE, 0, 441298) -- 冰冻之血
module:RegisterDebuff(TIER, INSTANCE, 0, 451239) -- 残暴戳刺
module:RegisterDebuff(TIER, INSTANCE, 0, 443509) -- 贪婪之虫
module:RegisterDebuff(TIER, INSTANCE, 0, 446718) -- 晦幽纺纱
module:RegisterDebuff(TIER, INSTANCE, 0, 439341) -- 捻接

INSTANCE = 1269 -- 矶石宝库
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 449154) -- 熔岩迫击炮
module:RegisterDebuff(TIER, INSTANCE, 0, 427361) -- 破裂
module:RegisterDebuff(TIER, INSTANCE, 0, 423572) -- 不稳定的能量
module:RegisterDebuff(TIER, INSTANCE, 0, 427329) -- 虚空腐蚀
module:RegisterDebuff(TIER, INSTANCE, 0, 424805) -- 折光射线
module:RegisterDebuff(TIER, INSTANCE, 0, 424913, 6) -- 不稳定的爆炸
module:RegisterDebuff(TIER, INSTANCE, 0, 443494) -- 结晶喷发

INSTANCE = 1270 -- 破晨号
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 431365) -- 折磨光束
module:RegisterDebuff(TIER, INSTANCE, 0, 451119) -- 深渊轰击
module:RegisterDebuff(TIER, INSTANCE, 0, 451107) -- 迸发虫茧
module:RegisterDebuff(TIER, INSTANCE, 0, 431350) -- 折磨喷发
module:RegisterDebuff(TIER, INSTANCE, 0, 434668) -- 火花四射的阿拉希炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 434113) -- 喷射丝线

INSTANCE = 1271 -- 艾拉-卡拉，回响之城
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 434083) -- 伏击(减速)
module:RegisterDebuff(TIER, INSTANCE, 0, 439070) -- 撕咬
module:RegisterDebuff(TIER, INSTANCE, 0, 433740) -- 感染
module:RegisterDebuff(TIER, INSTANCE, 0, 433781) -- 无休虫群
module:RegisterDebuff(TIER, INSTANCE, 0, 433662) -- 抓握之血(小怪)
module:RegisterDebuff(TIER, INSTANCE, 0, 432031) -- 抓握之血(BOSS战)

INSTANCE = 1267 -- 圣焰隐修院
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 446403) -- 牺牲烈焰

INSTANCE = 1210 -- 暗焰裂口
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1272 -- 燧酿酒庄
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1268 -- 驭雷栖巢
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 424797) -- 混沌脆弱

INSTANCE = 1298 -- 水闸行动
module:RegisterSeasonSpells(TIER, INSTANCE)