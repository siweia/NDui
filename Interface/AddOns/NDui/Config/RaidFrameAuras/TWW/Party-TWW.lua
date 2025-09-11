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
module:RegisterDebuff(TIER, INSTANCE, 0, 448248)
module:RegisterDebuff(TIER, INSTANCE, 0, 440313)
module:RegisterDebuff(TIER, INSTANCE, 0, 436322)
module:RegisterDebuff(TIER, INSTANCE, 0, 461487)
module:RegisterDebuff(TIER, INSTANCE, 0, 436401)
module:RegisterDebuff(TIER, INSTANCE, 0, 446794)
module:RegisterDebuff(TIER, INSTANCE, 0, 439200)
module:RegisterDebuff(TIER, INSTANCE, 0, 434830)
module:RegisterDebuff(TIER, INSTANCE, 0, 432227)
module:RegisterDebuff(TIER, INSTANCE, 0, 436614)
module:RegisterDebuff(TIER, INSTANCE, 0, 432119)
module:RegisterDebuff(TIER, INSTANCE, 0, 438618)
module:RegisterDebuff(TIER, INSTANCE, 0, 438599)

INSTANCE = 1267 -- 圣焰隐修院
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 425556)
module:RegisterDebuff(TIER, INSTANCE, 0, 427897)
module:RegisterDebuff(TIER, INSTANCE, 0, 423015)
module:RegisterDebuff(TIER, INSTANCE, 0, 424426)
module:RegisterDebuff(TIER, INSTANCE, 0, 451606)
module:RegisterDebuff(TIER, INSTANCE, 0, 448492)
module:RegisterDebuff(TIER, INSTANCE, 0, 448787)
module:RegisterDebuff(TIER, INSTANCE, 0, 447439)
module:RegisterDebuff(TIER, INSTANCE, 0, 424414)
module:RegisterDebuff(TIER, INSTANCE, 0, 446649)
module:RegisterDebuff(TIER, INSTANCE, 0, 447272)
module:RegisterDebuff(TIER, INSTANCE, 0, 427635)
module:RegisterDebuff(TIER, INSTANCE, 0, 453461)
module:RegisterDebuff(TIER, INSTANCE, 0, 427900)
module:RegisterDebuff(TIER, INSTANCE, 0, 428170)
module:RegisterDebuff(TIER, INSTANCE, 0, 446403)
module:RegisterDebuff(TIER, INSTANCE, 0, 451764)
module:RegisterDebuff(TIER, INSTANCE, 0, 427621)

INSTANCE = 1210 -- 暗焰裂口
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 424223)
module:RegisterDebuff(TIER, INSTANCE, 0, 422806)
module:RegisterDebuff(TIER, INSTANCE, 0, 427929)
module:RegisterDebuff(TIER, INSTANCE, 0, 1218321)
module:RegisterDebuff(TIER, INSTANCE, 0, 426295)
module:RegisterDebuff(TIER, INSTANCE, 0, 421653)
module:RegisterDebuff(TIER, INSTANCE, 0, 423080)
module:RegisterDebuff(TIER, INSTANCE, 0, 421817)
module:RegisterDebuff(TIER, INSTANCE, 0, 443694)
module:RegisterDebuff(TIER, INSTANCE, 0, 423693)
module:RegisterDebuff(TIER, INSTANCE, 0, 425561)
module:RegisterDebuff(TIER, INSTANCE, 0, 427015)
module:RegisterDebuff(TIER, INSTANCE, 0, 420307)
module:RegisterDebuff(TIER, INSTANCE, 0, 422245)
module:RegisterDebuff(TIER, INSTANCE, 0, 422648)
module:RegisterDebuff(TIER, INSTANCE, 0, 428019)
module:RegisterDebuff(TIER, INSTANCE, 0, 421638)
module:RegisterDebuff(TIER, INSTANCE, 0, 1218308)
module:RegisterDebuff(TIER, INSTANCE, 0, 420696)
module:RegisterDebuff(TIER, INSTANCE, 0, 421067)
module:RegisterDebuff(TIER, INSTANCE, 0, 421146)
module:RegisterDebuff(TIER, INSTANCE, 0, 427180)

INSTANCE = 1272 -- 燧酿酒庄
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 437956)
module:RegisterDebuff(TIER, INSTANCE, 0, 440134)
module:RegisterDebuff(TIER, INSTANCE, 0, 441413)
module:RegisterDebuff(TIER, INSTANCE, 0, 436624)
module:RegisterDebuff(TIER, INSTANCE, 0, 436640)
module:RegisterDebuff(TIER, INSTANCE, 0, 434773)
module:RegisterDebuff(TIER, INSTANCE, 0, 439586)
module:RegisterDebuff(TIER, INSTANCE, 0, 435130)
module:RegisterDebuff(TIER, INSTANCE, 0, 435789)
module:RegisterDebuff(TIER, INSTANCE, 0, 438975)
module:RegisterDebuff(TIER, INSTANCE, 0, 432182)
module:RegisterDebuff(TIER, INSTANCE, 0, 441397)
module:RegisterDebuff(TIER, INSTANCE, 0, 440687)
module:RegisterDebuff(TIER, INSTANCE, 0, 449090)
module:RegisterDebuff(TIER, INSTANCE, 0, 437721)
module:RegisterDebuff(TIER, INSTANCE, 0, 436644)
module:RegisterDebuff(TIER, INSTANCE, 0, 441179)
module:RegisterDebuff(TIER, INSTANCE, 0, 463227)
module:RegisterDebuff(TIER, INSTANCE, 0, 442589)
module:RegisterDebuff(TIER, INSTANCE, 0, 439325)
module:RegisterDebuff(TIER, INSTANCE, 0, 463220)
module:RegisterDebuff(TIER, INSTANCE, 0, 453810)
module:RegisterDebuff(TIER, INSTANCE, 0, 440141)
module:RegisterDebuff(TIER, INSTANCE, 0, 439467)
module:RegisterDebuff(TIER, INSTANCE, 0, 445180)

INSTANCE = 1268 -- 驭雷栖巢
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 424797) -- 混沌脆弱
module:RegisterDebuff(TIER, INSTANCE, 0, 444250)
module:RegisterDebuff(TIER, INSTANCE, 0, 424739)
module:RegisterDebuff(TIER, INSTANCE, 0, 427616)
module:RegisterDebuff(TIER, INSTANCE, 0, 1214324)
module:RegisterDebuff(TIER, INSTANCE, 0, 424966)
module:RegisterDebuff(TIER, INSTANCE, 0, 1214523)
module:RegisterDebuff(TIER, INSTANCE, 0, 430179)
module:RegisterDebuff(TIER, INSTANCE, 0, 429493)
module:RegisterDebuff(TIER, INSTANCE, 0, 433067)
module:RegisterDebuff(TIER, INSTANCE, 0, 458082)

INSTANCE = 1298 -- 水闸行动
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 468631)
module:RegisterDebuff(TIER, INSTANCE, 0, 468616)
module:RegisterDebuff(TIER, INSTANCE, 0, 473051)
module:RegisterDebuff(TIER, INSTANCE, 0, 468680)
module:RegisterDebuff(TIER, INSTANCE, 0, 468723)
module:RegisterDebuff(TIER, INSTANCE, 0, 474388)
module:RegisterDebuff(TIER, INSTANCE, 0, 468811)
module:RegisterDebuff(TIER, INSTANCE, 0, 469811)
module:RegisterDebuff(TIER, INSTANCE, 0, 468672)
module:RegisterDebuff(TIER, INSTANCE, 0, 472338)
module:RegisterDebuff(TIER, INSTANCE, 0, 462737)
module:RegisterDebuff(TIER, INSTANCE, 0, 472819)
module:RegisterDebuff(TIER, INSTANCE, 0, 473287)
module:RegisterDebuff(TIER, INSTANCE, 0, 473713)
module:RegisterDebuff(TIER, INSTANCE, 0, 1213803)
module:RegisterDebuff(TIER, INSTANCE, 0, 466124)
module:RegisterDebuff(TIER, INSTANCE, 0, 470038)
module:RegisterDebuff(TIER, INSTANCE, 0, 465830)
module:RegisterDebuff(TIER, INSTANCE, 0, 473836)
module:RegisterDebuff(TIER, INSTANCE, 0, 473224)
module:RegisterDebuff(TIER, INSTANCE, 0, 470022)
module:RegisterDebuff(TIER, INSTANCE, 0, 469799)
module:RegisterDebuff(TIER, INSTANCE, 0, 468815)
module:RegisterDebuff(TIER, INSTANCE, 0, 466188)
module:RegisterDebuff(TIER, INSTANCE, 0, 459779)
module:RegisterDebuff(TIER, INSTANCE, 0, 460965)
module:RegisterDebuff(TIER, INSTANCE, 0, 462771)
module:RegisterDebuff(TIER, INSTANCE, 0, 474351)
module:RegisterDebuff(TIER, INSTANCE, 0, 472878)

INSTANCE = 1303 -- 奥尔达尼生态圆顶
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 1221190)
module:RegisterDebuff(TIER, INSTANCE, 0, 1217439)
module:RegisterDebuff(TIER, INSTANCE, 0, 1224865)
module:RegisterDebuff(TIER, INSTANCE, 0, 1225179)
module:RegisterDebuff(TIER, INSTANCE, 0, 1236126)
module:RegisterDebuff(TIER, INSTANCE, 0, 1227748)
module:RegisterDebuff(TIER, INSTANCE, 0, 1226444)
module:RegisterDebuff(TIER, INSTANCE, 0, 1220390)
module:RegisterDebuff(TIER, INSTANCE, 0, 1217446)
module:RegisterDebuff(TIER, INSTANCE, 0, 1227152)
module:RegisterDebuff(TIER, INSTANCE, 0, 1220671)
module:RegisterDebuff(TIER, INSTANCE, 0, 1222341)
module:RegisterDebuff(TIER, INSTANCE, 0, 1219535)
module:RegisterDebuff(TIER, INSTANCE, 0, 1225221)
module:RegisterDebuff(TIER, INSTANCE, 0, 1231224)
module:RegisterDebuff(TIER, INSTANCE, 0, 1231494)