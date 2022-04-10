local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 1
local INSTANCE  -- 团本

INSTANCE = 409 -- 熔火之心
module:RegisterDebuff(TIER, INSTANCE, 0, 19703) -- 奥西弗隆的诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 19408) -- 恐慌
module:RegisterDebuff(TIER, INSTANCE, 0, 19716) -- 基赫纳斯的诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 20277) -- 拉格纳罗斯之拳
module:RegisterDebuff(TIER, INSTANCE, 0, 20475) -- 活化炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 19695) -- 地狱火
module:RegisterDebuff(TIER, INSTANCE, 0, 19659) -- 点燃法力
module:RegisterDebuff(TIER, INSTANCE, 0, 19714) -- 衰减魔法
module:RegisterDebuff(TIER, INSTANCE, 0, 19713) -- 沙斯拉尔的诅咒

INSTANCE = 249 -- 奥妮克希亚的巢穴
module:RegisterDebuff(TIER, INSTANCE, 0, 18431) -- 低沉咆哮

INSTANCE = 309 -- 祖尔格拉布
module:RegisterDebuff(TIER, INSTANCE, 0, 23860) -- 神圣之火
module:RegisterDebuff(TIER, INSTANCE, 0, 22884) -- 心灵尖啸
module:RegisterDebuff(TIER, INSTANCE, 0, 23918) -- 音爆
module:RegisterDebuff(TIER, INSTANCE, 0, 24111) -- 腐蚀之毒
module:RegisterDebuff(TIER, INSTANCE, 0, 21060) -- 致盲
module:RegisterDebuff(TIER, INSTANCE, 0, 24328) -- 堕落之血
module:RegisterDebuff(TIER, INSTANCE, 0, 16856) -- 致死打击
module:RegisterDebuff(TIER, INSTANCE, 0, 24664) -- 睡眠
module:RegisterDebuff(TIER, INSTANCE, 0, 17172) -- 妖术
module:RegisterDebuff(TIER, INSTANCE, 0, 24306) -- 金度的欺骗
module:RegisterDebuff(TIER, INSTANCE, 0, 24099) -- 毒箭之雨

INSTANCE = 469 -- 黑翼之巢
module:RegisterDebuff(TIER, INSTANCE, 0, 23023) -- 燃烧
module:RegisterDebuff(TIER, INSTANCE, 0, 18173) -- 燃烧刺激
module:RegisterDebuff(TIER, INSTANCE, 0, 24573) -- 致死打击
module:RegisterDebuff(TIER, INSTANCE, 0, 23340) -- 埃博诺克之影
module:RegisterDebuff(TIER, INSTANCE, 0, 22274) -- 强效变形术
module:RegisterDebuff(TIER, INSTANCE, 0, 23341) -- 烈焰打击
module:RegisterDebuff(TIER, INSTANCE, 0, 23170) -- 青铜
module:RegisterDebuff(TIER, INSTANCE, 0, 22687) -- 暗影迷雾

INSTANCE = 509 -- 安其拉废墟
module:RegisterDebuff(TIER, INSTANCE, 0, 25646) -- 重伤
module:RegisterDebuff(TIER, INSTANCE, 0, 25471) -- 攻击命令
module:RegisterDebuff(TIER, INSTANCE, 0, 96) 	-- 肢解
module:RegisterDebuff(TIER, INSTANCE, 0, 25725) -- 麻痹
module:RegisterDebuff(TIER, INSTANCE, 0, 25189) -- 包围之风
module:RegisterDebuff(TIER, INSTANCE, 0, 22997) -- 瘟疫

INSTANCE = 531 -- 安其拉神殿
module:RegisterDebuff(TIER, INSTANCE, 0, 785) 	-- 充实
module:RegisterDebuff(TIER, INSTANCE, 0, 26580) -- 恐惧
module:RegisterDebuff(TIER, INSTANCE, 0, 26050) -- 酸性喷射
module:RegisterDebuff(TIER, INSTANCE, 0, 26180) -- 翼龙钉刺
module:RegisterDebuff(TIER, INSTANCE, 0, 26053) -- 致命剧毒
module:RegisterDebuff(TIER, INSTANCE, 0, 26613) -- 重压打击
module:RegisterDebuff(TIER, INSTANCE, 0, 26029) -- 黑暗闪耀
module:RegisterDebuff(TIER, INSTANCE, 0, 26476) -- 消化酸液（克苏恩胃内）
module:RegisterDebuff(TIER, INSTANCE, 0, 26556) -- 瘟疫
module:RegisterDebuff(TIER, INSTANCE, 0, 25991) -- 毒箭之雨（维希度斯）

INSTANCE = 533 -- 纳克萨玛斯
module:RegisterDebuff(TIER, INSTANCE, 0, 28350) -- 黑暗之雾*小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 28440) -- 幽影之雾*小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 28431) -- 毒性充能*小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 27993) -- 践踏*小怪
module:RegisterDebuff(TIER, INSTANCE, 0, 28732) -- 黑女巫的拥抱*法琳娜
module:RegisterDebuff(TIER, INSTANCE, 0, 28796) -- 毒箭之雨*法琳娜
module:RegisterDebuff(TIER, INSTANCE, 0, 28776) -- 死灵之毒*迈克斯纳
module:RegisterDebuff(TIER, INSTANCE, 0, 28622) -- 蛛网裹体*迈克斯纳
module:RegisterDebuff(TIER, INSTANCE, 0, 29484) -- 蛛网喷射*迈克斯纳
module:RegisterDebuff(TIER, INSTANCE, 0, 29213) -- 瘟疫使者的诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 29212) -- 残废术*诺斯
module:RegisterDebuff(TIER, INSTANCE, 0, 29998) -- 衰弱瘟疫*希尔盖
module:RegisterDebuff(TIER, INSTANCE, 0, 29204) -- 必然的厄运*洛欧塞布
module:RegisterDebuff(TIER, INSTANCE, 0, 28832) -- 库尔塔兹印记*
module:RegisterDebuff(TIER, INSTANCE, 0, 28833) -- 布劳缪克丝印记*
module:RegisterDebuff(TIER, INSTANCE, 0, 28834) -- 莫格莱尼印记*
module:RegisterDebuff(TIER, INSTANCE, 0, 28835) -- 瑟里耶克印记
module:RegisterDebuff(TIER, INSTANCE, 0, 28169) -- 变异注射
module:RegisterDebuff(TIER, INSTANCE, 0, 28062) -- 正能量*塔迪乌斯
module:RegisterDebuff(TIER, INSTANCE, 0, 28085) -- 负能量*塔迪乌斯
module:RegisterDebuff(TIER, INSTANCE, 0, 28542) -- 生命吸取*萨菲隆
module:RegisterDebuff(TIER, INSTANCE, 0, 28522) -- 寒冰箭*萨菲隆
module:RegisterDebuff(TIER, INSTANCE, 0, 27808) -- 冰霜冲击
module:RegisterDebuff(TIER, INSTANCE, 0, 28410) -- 克尔苏加德的锁链
module:RegisterDebuff(TIER, INSTANCE, 0, 27819) -- 自爆法力
module:RegisterDebuff(TIER, INSTANCE, 0, 29325, 1)	-- 酸性箭雨