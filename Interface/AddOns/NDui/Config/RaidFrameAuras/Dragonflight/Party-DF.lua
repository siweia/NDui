local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 10
local INSTANCE

INSTANCE = 1196 -- 蕨皮山谷
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1204 -- 注能大厅
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1199 -- 奈萨鲁斯
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1197 -- 奥达曼：提尔的遗产
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 1209 -- 永恒黎明
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 413142) -- 万古裂片
module:RegisterDebuff(TIER, INSTANCE, 0, 410908) -- 永恒新星
module:RegisterDebuff(TIER, INSTANCE, 0, 407406) -- 腐蚀

-- S1
INSTANCE = 1201 -- 艾杰斯亚学院
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 389033) -- 鞭笞者毒素
module:RegisterDebuff(TIER, INSTANCE, 0, 391977) -- 涌动超载
module:RegisterDebuff(TIER, INSTANCE, 0, 386201) -- 腐化法力
module:RegisterDebuff(TIER, INSTANCE, 0, 389011) -- 势不可挡
module:RegisterDebuff(TIER, INSTANCE, 0, 387932) -- 星界旋风
module:RegisterDebuff(TIER, INSTANCE, 0, 396716) -- 皲皮
module:RegisterDebuff(TIER, INSTANCE, 0, 388866) -- 法力虚空
module:RegisterDebuff(TIER, INSTANCE, 0, 386181) -- 法力炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 388912) -- 断体猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 377344) -- 啄击
module:RegisterDebuff(TIER, INSTANCE, 0, 376997) -- 狂野啄击
module:RegisterDebuff(TIER, INSTANCE, 0, 388984) -- 邪恶伏击
module:RegisterDebuff(TIER, INSTANCE, 0, 388544) -- 裂树击
module:RegisterDebuff(TIER, INSTANCE, 0, 377008) -- 震耳尖啸

INSTANCE = 1202 -- 红玉新生法池
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 392406) -- 雷霆一击
module:RegisterDebuff(TIER, INSTANCE, 0, 372820) -- 焦灼之土
module:RegisterDebuff(TIER, INSTANCE, 0, 384823) -- 地狱烈火
module:RegisterDebuff(TIER, INSTANCE, 0, 381862) -- 地狱火之核
module:RegisterDebuff(TIER, INSTANCE, 0, 372860) -- 灼热伤口
module:RegisterDebuff(TIER, INSTANCE, 0, 373869) -- 燃烧之触
module:RegisterDebuff(TIER, INSTANCE, 0, 385536) -- 烈焰之舞
module:RegisterDebuff(TIER, INSTANCE, 0, 381518) -- 变迁之风
module:RegisterDebuff(TIER, INSTANCE, 0, 372858) -- 灼热打击
module:RegisterDebuff(TIER, INSTANCE, 0, 373589) -- 原始酷寒
module:RegisterDebuff(TIER, INSTANCE, 0, 373693) -- 活动炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 392924) -- 震爆
module:RegisterDebuff(TIER, INSTANCE, 0, 381515) -- 风暴猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 396411) -- 原始过载
module:RegisterDebuff(TIER, INSTANCE, 0, 384773) -- 烈焰余烬
module:RegisterDebuff(TIER, INSTANCE, 0, 392451) -- 闪火
module:RegisterDebuff(TIER, INSTANCE, 0, 372697) -- 锯齿土地
module:RegisterDebuff(TIER, INSTANCE, 0, 372047) -- 钢铁弹幕
module:RegisterDebuff(TIER, INSTANCE, 0, 372963) -- 霜风

INSTANCE = 1203 -- 碧蓝魔馆
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 387151, 6) -- 寒冰灭绝者
module:RegisterDebuff(TIER, INSTANCE, 0, 388777) -- 压制瘴气
module:RegisterDebuff(TIER, INSTANCE, 0, 386881) -- 冰霜炸弹
module:RegisterDebuff(TIER, INSTANCE, 0, 387150) -- 冰霜之地
module:RegisterDebuff(TIER, INSTANCE, 0, 387564) -- 秘法蒸汽
module:RegisterDebuff(TIER, INSTANCE, 0, 385267) -- 爆裂旋涡
module:RegisterDebuff(TIER, INSTANCE, 0, 386640) -- 撕扯血肉
module:RegisterDebuff(TIER, INSTANCE, 0, 374567) -- 爆裂法印
module:RegisterDebuff(TIER, INSTANCE, 0, 374523) -- 刺痛树液
module:RegisterDebuff(TIER, INSTANCE, 0, 375596) -- 古怪生长
module:RegisterDebuff(TIER, INSTANCE, 0, 375602) -- 古怪生长
module:RegisterDebuff(TIER, INSTANCE, 0, 370764) -- 穿刺碎片
module:RegisterDebuff(TIER, INSTANCE, 0, 384978) -- 巨龙打击
module:RegisterDebuff(TIER, INSTANCE, 0, 375649) -- 注能之地
module:RegisterDebuff(TIER, INSTANCE, 0, 377488) -- 寒冰束缚
module:RegisterDebuff(TIER, INSTANCE, 0, 374789) -- 注能打击
module:RegisterDebuff(TIER, INSTANCE, 0, 371007) -- 裂生碎片
module:RegisterDebuff(TIER, INSTANCE, 0, 375591) -- 树脂爆发
module:RegisterDebuff(TIER, INSTANCE, 0, 385409) -- 噢，噢，噢！
module:RegisterDebuff(TIER, INSTANCE, 0, 386549) -- 清醒的克星

INSTANCE = 1198 -- 诺库德阻击战
module:RegisterSeasonSpells(TIER, INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 382628) -- 能量湍流
module:RegisterDebuff(TIER, INSTANCE, 0, 386025) -- 风暴
module:RegisterDebuff(TIER, INSTANCE, 0, 381692) -- 迅捷刺击
module:RegisterDebuff(TIER, INSTANCE, 0, 387615) -- 亡者之握
module:RegisterDebuff(TIER, INSTANCE, 0, 387629) -- 腐烂之风
module:RegisterDebuff(TIER, INSTANCE, 0, 386912) -- 风暴喷涌之云
module:RegisterDebuff(TIER, INSTANCE, 0, 395669) -- 余震
module:RegisterDebuff(TIER, INSTANCE, 0, 384134) -- 穿刺
module:RegisterDebuff(TIER, INSTANCE, 0, 388451) -- 风暴召唤者之怒
module:RegisterDebuff(TIER, INSTANCE, 0, 395035) -- 粉碎灵魂
module:RegisterDebuff(TIER, INSTANCE, 0, 376899) -- 鸣裂之云
module:RegisterDebuff(TIER, INSTANCE, 0, 384492) -- 猎人印记
module:RegisterDebuff(TIER, INSTANCE, 0, 376730) -- 暴风
module:RegisterDebuff(TIER, INSTANCE, 0, 376894) -- 鸣裂颠覆
module:RegisterDebuff(TIER, INSTANCE, 0, 388801) -- 致死打击
module:RegisterDebuff(TIER, INSTANCE, 0, 376827) -- 传导打击
module:RegisterDebuff(TIER, INSTANCE, 0, 376864) -- 静电之矛
module:RegisterDebuff(TIER, INSTANCE, 0, 375937) -- 撕裂猛击
module:RegisterDebuff(TIER, INSTANCE, 0, 376634) -- 钢铁之矛

INSTANCE = 313 -- 青龙寺
module:RegisterSeasonSpells(5, INSTANCE)
module:RegisterDebuff(5, INSTANCE, 0, 396150) -- 优越感
module:RegisterDebuff(5, INSTANCE, 0, 397878) -- 腐化涟漪
module:RegisterDebuff(5, INSTANCE, 0, 106113) -- 虚无之触
module:RegisterDebuff(5, INSTANCE, 0, 397914) -- 污染迷雾
module:RegisterDebuff(5, INSTANCE, 0, 397904) -- 残阳西沉踢
module:RegisterDebuff(5, INSTANCE, 0, 397911) -- 毁灭之触
module:RegisterDebuff(5, INSTANCE, 0, 395859) -- 游荡尖啸
module:RegisterDebuff(5, INSTANCE, 0, 374037) -- 怒不可挡
module:RegisterDebuff(5, INSTANCE, 0, 396093) -- 野蛮飞跃
module:RegisterDebuff(5, INSTANCE, 0, 106823) -- 翔龙猛袭
module:RegisterDebuff(5, INSTANCE, 0, 396152) -- 自卑感
module:RegisterDebuff(5, INSTANCE, 0, 110125) -- 粉碎决心
module:RegisterDebuff(5, INSTANCE, 0, 397797) -- 腐蚀漩涡

INSTANCE = 537 -- 影月墓地
module:RegisterSeasonSpells(6, INSTANCE)
module:RegisterDebuff(6, INSTANCE, 0, 156776) -- 虚空撕裂
module:RegisterDebuff(6, INSTANCE, 0, 153692) -- 死疽淤青
module:RegisterDebuff(6, INSTANCE, 0, 153524) -- 瘟疫喷吐
module:RegisterDebuff(6, INSTANCE, 0, 154469) -- 仪式枯骨
module:RegisterDebuff(6, INSTANCE, 0, 162652) -- 纯净之月
module:RegisterDebuff(6, INSTANCE, 0, 164907) -- 虚空挥砍
module:RegisterDebuff(6, INSTANCE, 0, 152979) -- 灵魂撕裂
module:RegisterDebuff(6, INSTANCE, 0, 158061) -- 被祝福的净水
module:RegisterDebuff(6, INSTANCE, 0, 154442) -- 怨毒
module:RegisterDebuff(6, INSTANCE, 0, 153501) -- 虚空冲击
module:RegisterDebuff(6, INSTANCE, 0, 152819, 6) -- 暗言术：虚