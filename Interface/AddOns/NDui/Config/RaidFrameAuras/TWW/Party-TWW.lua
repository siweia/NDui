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
module:RegisterDebuff(TIER, INSTANCE, 0, 448248, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 440313, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 436322, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 461487, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 240443, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 436401, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 446794, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 209858, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 408556, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 439200, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 434830, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 432227, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 436614, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 240559, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 432119, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 438618, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 438599, 6)

INSTANCE = 1267 -- 圣焰隐修院
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 425556, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427897, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 423015, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 424426, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 240559, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 451606, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 240443, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 209858, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 408556, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 448492, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 448787, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 447439, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 424414, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 446649, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 447272, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427635, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 453461, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427900, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 428170, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 446403, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 451764, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427621, 6)

INSTANCE = 1210 -- 暗焰裂口
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 424223, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 422806, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427929, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 240559, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 1218321, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 240443, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 426295, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 421653, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 209858, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 408556, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 423080, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 421817, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 443694, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 423693, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 425561, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427015, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 420307, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 422245, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 422648, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 428019, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 421638, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1218308, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 420696, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 421067, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 421146, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 427180, 2)

INSTANCE = 1272 -- 燧酿酒庄
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 437956, 5)
module:RegisterDebuff(TIER, INSTANCE, 0, 440134, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 441413, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 436624, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 436640, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 240559, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 434773, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 439586, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 435130, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 435789, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 209858, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 408556, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 438975, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 240443, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 432182, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 441397, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 440687, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 449090, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 437721, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 436644, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 441179, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 463227, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 442589, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 439325, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 463220, 1)
module:RegisterDebuff(TIER, INSTANCE, 0, 453810, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 440141, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 439467, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 445180, 2)

INSTANCE = 1268 -- 驭雷栖巢
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 424797) -- 混沌脆弱
module:RegisterDebuff(TIER, INSTANCE, 0, 444250, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 424739, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 427616, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 1214324, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 240559, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 424966, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 240443, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 408556, 0)
module:RegisterDebuff(TIER, INSTANCE, 0, 1214523, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 430179, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 429493, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 433067, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 458082, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 209858, 0)

INSTANCE = 1298 -- 水闸行动
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 468631, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 468616, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 473051, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 468680, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 468723, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 474388, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 468811, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 469811, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 468672, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 472338, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 462737, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 472819, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 473287, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 473713, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1213803, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 466124, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 470038, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 465830, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 473836, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 473224, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 470022, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 469799, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 468815, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 466188, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 459779, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 460965, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 462771, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 474351, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 472878, 2)

INSTANCE = 1303 -- 奥尔达尼生态圆顶
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 1221190, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1217439, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 1224865, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1225179, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1236126, 6)
module:RegisterDebuff(TIER, INSTANCE, 0, 1227748, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1226444, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1220390, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1217446, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1227152, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1220671, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1222341, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1219535, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1225221, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1231224, 2)
module:RegisterDebuff(TIER, INSTANCE, 0, 1231494, 2)