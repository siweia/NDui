local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 8
local INSTANCE = 1180 -- 尼奥罗萨，觉醒之城
local BOSS

BOSS = 2368 -- 黑龙帝王拉希奥
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306015) -- 灼烧护甲
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306163, 6) -- 万物尽焚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313959) -- 灼热气泡
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314347) -- 毒扼
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309733) -- 疯狂燃烧
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307053) -- 岩浆池
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313250) -- 蠕行疯狂

BOSS = 2365 -- 玛乌特
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307399) -- 暗影之伤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307806) -- 吞噬魔法
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307586) -- 噬魔深渊
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306301) -- 禁忌法力
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314993, 6) -- 吸取精华
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315025) -- 远古诅咒

BOSS = 2369 -- 先知斯基特拉
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307785) -- 扭曲心智
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307784) -- 困惑心智
module:RegisterDebuff(TIER, INSTANCE, BOSS, 308059) -- 暗影震击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309652) -- 虚幻之蚀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307950) -- 心智剥离
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313215) -- 颤涌镜像

BOSS = 2377 -- 黑暗审判官夏奈什
module:RegisterDebuff(TIER, INSTANCE, BOSS, 311551) -- 深渊打击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 312406) -- 虚空觉醒
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314298) -- 末日迫近
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306311) -- 灵魂鞭笞
module:RegisterDebuff(TIER, INSTANCE, BOSS, 305575) -- 仪式领域
module:RegisterDebuff(TIER, INSTANCE, BOSS, 316211) -- 恐惧浪潮

BOSS = 2372 -- 主脑
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313461) -- 腐蚀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315311) -- 毁灭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313672) -- 酸液池
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314593) -- 麻痹毒液
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313460) -- 虚化
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310402) -- 吞食狂热

BOSS = 2367 -- 无厌者夏德哈
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307471) -- 碾压
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307472) -- 融解
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307358) -- 衰弱唾液
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306928) -- 幽影吐息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 308177) -- 熵能聚合
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306930) -- 熵能暗息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314736) -- 毒泡流溢
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306929) -- 翻滚毒息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 318078, 6) -- 锁定
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309704) -- 腐蚀涂层

BOSS = 2373 -- 德雷阿佳丝
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310246) -- 虚空之握
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310277) -- 动荡之种
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310309) -- 动荡易伤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310358) -- 狂乱低语
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310361) -- 不羁狂乱
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310406) -- 虚空闪耀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 308377) -- 虚化脓液
module:RegisterDebuff(TIER, INSTANCE, BOSS, 317001) -- 暗影排异
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310552) -- 精神鞭笞
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310563) -- 背叛低语
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310567) -- 背叛者

BOSS = 2374 -- 伊格诺斯，重生之蚀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309961) -- 恩佐斯之眼
module:RegisterDebuff(TIER, INSTANCE, BOSS, 311367) -- 腐蚀者之触
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310322) -- 腐蚀沼泽
module:RegisterDebuff(TIER, INSTANCE, BOSS, 312486) -- 轮回噩梦
module:RegisterDebuff(TIER, INSTANCE, BOSS, 311159) -- 诅咒之血
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315094) -- 锁定
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313759) -- 诅咒之血

BOSS = 2370 -- 维克修娜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307359) -- 绝望
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307020) -- 暮光之息
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307019) -- 虚空腐蚀
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306981) -- 虚空之赐
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310224, 6) -- 毁灭
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307314) -- 渗透暗影
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307343) -- 暗影残渣
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307250) -- 暮光屠戮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315769) -- 屠戮
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307284) -- 恐怖降临
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307645) -- 黑暗之心
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310323) -- 荒芜
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315932) -- 蛮力重击

BOSS = 2364 -- 虚无者莱登
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306819) -- 虚化重击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306279) -- 动荡暴露
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306273) -- 不稳定的生命
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306637) -- 不稳定的虚空爆发
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309777) -- 虚空污秽
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313227) -- 腐坏伤口
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310019, 6) -- 充能锁链
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310022, 6) -- 充能锁链
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315252) -- 恐怖炼狱
module:RegisterDebuff(TIER, INSTANCE, BOSS, 316065) -- 腐化存续

BOSS = 2366 -- 恩佐斯的外壳
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307832) -- 恩佐斯的仆从
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313334) -- 恩佐斯之赐
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306973) -- 疯狂炸弹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 306984) -- 狂乱炸弹
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313364) -- 精神腐烂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315954) -- 漆黑伤疤
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307044) -- 梦魇抗原
module:RegisterDebuff(TIER, INSTANCE, BOSS, 307011) -- 疯狂繁衍

BOSS = 2375 -- 腐蚀者恩佐斯
module:RegisterDebuff(TIER, INSTANCE, BOSS, 314889) -- 探视心智
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315624) -- 心智受限
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309991) -- 痛楚
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313609) -- 恩佐斯之赐
module:RegisterDebuff(TIER, INSTANCE, BOSS, 308996) -- 恩佐斯的仆从
module:RegisterDebuff(TIER, INSTANCE, BOSS, 316711) -- 意志摧毁
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313400) -- 堕落心灵
module:RegisterDebuff(TIER, INSTANCE, BOSS, 316542, 6) -- 妄念
module:RegisterDebuff(TIER, INSTANCE, BOSS, 316541, 6) -- 妄念
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310042) -- 混乱爆发
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313793) -- 狂乱之火
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313610) -- 精神腐烂
module:RegisterDebuff(TIER, INSTANCE, BOSS, 309698) -- 虚空鞭笞
module:RegisterDebuff(TIER, INSTANCE, BOSS, 311392) -- 心灵之握
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310073) -- 心灵之握
module:RegisterDebuff(TIER, INSTANCE, BOSS, 313184) -- 突触震击
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310331) -- 虚空凝视
module:RegisterDebuff(TIER, INSTANCE, BOSS, 312155) -- 碎裂自我
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315675) -- 碎裂自我
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315672) -- 碎裂自我
module:RegisterDebuff(TIER, INSTANCE, BOSS, 310134) -- 疯狂聚现
module:RegisterDebuff(TIER, INSTANCE, BOSS, 312866) -- 灾变烈焰
module:RegisterDebuff(TIER, INSTANCE, BOSS, 315772) -- 心灵之握