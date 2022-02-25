local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 9
local INSTANCE -- 5人本

local SEASON_SPELLS = {
	[209858] = 2, -- 死疽
	[240443] = 2, -- 爆裂
	[240559] = 1, -- 重伤
	[342494] = 2, -- 狂妄吹嘘，S1
	[355732] = 2, -- 融化灵魂
	[356666] = 2, -- 刺骨之寒
	[356667] = 2, -- 刺骨之寒
	[356925] = 2, -- 屠戮
	[358777] = 2, -- 痛苦之链
	[366288] = 2, -- 猛力砸击，S3
	[366297] = 2, -- 解构，S3
}
local function RegisterSeasonSpells(INSTANCE)
	for spellID, priority in pairs(SEASON_SPELLS) do
		module:RegisterDebuff(TIER, INSTANCE, 0, spellID, priority)
	end
end

INSTANCE = 1194 -- 塔扎维什，帷纱集市
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 356011) -- 光线切分者
module:RegisterDebuff(TIER, INSTANCE, 0, 347949, 6) -- 审讯
module:RegisterDebuff(TIER, INSTANCE, 0, 345770) -- 扣押违禁品
module:RegisterDebuff(TIER, INSTANCE, 0, 355915) -- 约束雕文
module:RegisterDebuff(TIER, INSTANCE, 0, 346962) -- 现金汇款
module:RegisterDebuff(TIER, INSTANCE, 0, 349627) -- 暴食
module:RegisterDebuff(TIER, INSTANCE, 0, 347481) -- 奥能手里波
module:RegisterDebuff(TIER, INSTANCE, 0, 350804) -- 坍缩能量
module:RegisterDebuff(TIER, INSTANCE, 0, 350885) -- 超光速震荡
module:RegisterDebuff(TIER, INSTANCE, 0, 351101) -- 能量碎片
module:RegisterDebuff(TIER, INSTANCE, 0, 350013) -- 暴食盛宴
module:RegisterDebuff(TIER, INSTANCE, 0, 355641) -- 闪烁
module:RegisterDebuff(TIER, INSTANCE, 0, 355451) -- 逆流
module:RegisterDebuff(TIER, INSTANCE, 0, 351956) -- 高价值目标
module:RegisterDebuff(TIER, INSTANCE, 0, 346297) -- 动荡爆炸
module:RegisterDebuff(TIER, INSTANCE, 0, 347728) -- 群殴
module:RegisterDebuff(TIER, INSTANCE, 0, 356408) -- 大地践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 347744) -- 迅斩
module:RegisterDebuff(TIER, INSTANCE, 0, 350134) -- 永恒吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 355465) -- 投掷巨石

INSTANCE = 1187 -- 伤逝剧场
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 333299) -- 荒芜诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 333301) -- 荒芜诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 319539) -- 无魂者
module:RegisterDebuff(TIER, INSTANCE, 0, 326892) -- 锁定
module:RegisterDebuff(TIER, INSTANCE, 0, 321768) -- 上钩了
module:RegisterDebuff(TIER, INSTANCE, 0, 323825) -- 攫取裂隙
module:RegisterDebuff(TIER, INSTANCE, 0, 333231) -- 灼热之陨
module:RegisterDebuff(TIER, INSTANCE, 0, 330532) -- 锯齿箭
module:RegisterDebuff(TIER, INSTANCE, 0, 342675) -- 骨矛
module:RegisterDebuff(TIER, INSTANCE, 0, 323831) -- 死亡之攫
module:RegisterDebuff(TIER, INSTANCE, 0, 330608) -- 邪恶爆发
module:RegisterDebuff(TIER, INSTANCE, 0, 330868) -- 通灵箭雨
module:RegisterDebuff(TIER, INSTANCE, 0, 323750) -- 邪恶毒气
module:RegisterDebuff(TIER, INSTANCE, 0, 323406) -- 锯齿创口
module:RegisterDebuff(TIER, INSTANCE, 0, 330700) -- 腐烂凋零
module:RegisterDebuff(TIER, INSTANCE, 0, 319626) -- 幻影寄生
module:RegisterDebuff(TIER, INSTANCE, 0, 324449) -- 死亡具象
module:RegisterDebuff(TIER, INSTANCE, 0, 341949) -- 枯萎凋零

INSTANCE = 1183 -- 凋魂之殇
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 336258) -- 落单狩猎
module:RegisterDebuff(TIER, INSTANCE, 0, 331818) -- 暗影伏击
module:RegisterDebuff(TIER, INSTANCE, 0, 333353) -- 暗影伏击
module:RegisterDebuff(TIER, INSTANCE, 0, 329110) -- 软泥注射
module:RegisterDebuff(TIER, INSTANCE, 0, 325552) -- 毒性裂击
module:RegisterDebuff(TIER, INSTANCE, 0, 336301) -- 裹体之网
module:RegisterDebuff(TIER, INSTANCE, 0, 322358) -- 燃灼菌株
module:RegisterDebuff(TIER, INSTANCE, 0, 322410) -- 凋零污秽
module:RegisterDebuff(TIER, INSTANCE, 0, 328180) -- 攫握感染
module:RegisterDebuff(TIER, INSTANCE, 0, 320542) -- 荒芜凋零
module:RegisterDebuff(TIER, INSTANCE, 0, 340355) -- 急速感染
module:RegisterDebuff(TIER, INSTANCE, 0, 328395) -- 剧毒打击
module:RegisterDebuff(TIER, INSTANCE, 0, 320512) -- 侵蚀爪击
module:RegisterDebuff(TIER, INSTANCE, 0, 333406) -- 伏击
module:RegisterDebuff(TIER, INSTANCE, 0, 332397) -- 覆体缠网
module:RegisterDebuff(TIER, INSTANCE, 0, 330069) -- 凝结魔药
module:RegisterDebuff(TIER, INSTANCE, 0, 331399) -- 感染毒雨

INSTANCE = 1184 -- 塞兹仙林的迷雾
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 325027) -- 荆棘爆发
module:RegisterDebuff(TIER, INSTANCE, 0, 323043) -- 放血
module:RegisterDebuff(TIER, INSTANCE, 0, 322557) -- 灵魂分裂
module:RegisterDebuff(TIER, INSTANCE, 0, 331172) -- 心灵连接
module:RegisterDebuff(TIER, INSTANCE, 0, 322563) -- 被标记的猎物
module:RegisterDebuff(TIER, INSTANCE, 0, 341198) -- 易燃爆炸
module:RegisterDebuff(TIER, INSTANCE, 0, 325418) -- 不稳定的酸液
module:RegisterDebuff(TIER, INSTANCE, 0, 326092) -- 衰弱毒药
module:RegisterDebuff(TIER, INSTANCE, 0, 325021) -- 纱雾撕裂
module:RegisterDebuff(TIER, INSTANCE, 0, 325224) -- 心能注入
module:RegisterDebuff(TIER, INSTANCE, 0, 322486) -- 过度生长
module:RegisterDebuff(TIER, INSTANCE, 0, 322487) -- 过度生长
module:RegisterDebuff(TIER, INSTANCE, 0, 323137) -- 迷乱花粉
module:RegisterDebuff(TIER, INSTANCE, 0, 328756) -- 憎恨之容
module:RegisterDebuff(TIER, INSTANCE, 0, 321828) -- 肉饼蛋糕
module:RegisterDebuff(TIER, INSTANCE, 0, 340191) -- 再生辐光
module:RegisterDebuff(TIER, INSTANCE, 0, 321891) -- 鬼抓人锁定

INSTANCE = 1188 -- 彼界
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 320786) -- 势不可挡
module:RegisterDebuff(TIER, INSTANCE, 0, 334913) -- 死亡之主
module:RegisterDebuff(TIER, INSTANCE, 0, 325725) -- 寰宇操控
module:RegisterDebuff(TIER, INSTANCE, 0, 328987) -- 狂热
module:RegisterDebuff(TIER, INSTANCE, 0, 334496) -- 催眠光粉
module:RegisterDebuff(TIER, INSTANCE, 0, 339978) -- 安抚迷雾
module:RegisterDebuff(TIER, INSTANCE, 0, 333250) -- 放血之击
module:RegisterDebuff(TIER, INSTANCE, 0, 322746) -- 堕落之血
module:RegisterDebuff(TIER, INSTANCE, 0, 330434) -- 电锯
module:RegisterDebuff(TIER, INSTANCE, 0, 320144) -- 电锯
module:RegisterDebuff(TIER, INSTANCE, 0, 331847) -- W-00F
module:RegisterDebuff(TIER, INSTANCE, 0, 327649) -- 粉碎灵魂
module:RegisterDebuff(TIER, INSTANCE, 0, 331379) -- 润滑剂
module:RegisterDebuff(TIER, INSTANCE, 0, 332678) -- 龟裂创伤
--module:RegisterDebuff(TIER, INSTANCE, 0, 323687) -- 奥术闪电
module:RegisterDebuff(TIER, INSTANCE, 0, 323692) -- 奥术易伤
module:RegisterDebuff(TIER, INSTANCE, 0, 334535) -- 啄裂

INSTANCE = 1186 -- 晋升高塔
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 338729) -- 充能践踏
module:RegisterDebuff(TIER, INSTANCE, 0, 327481) -- 黑暗长枪
module:RegisterDebuff(TIER, INSTANCE, 0, 322818) -- 失去信心
module:RegisterDebuff(TIER, INSTANCE, 0, 322817) -- 疑云密布
module:RegisterDebuff(TIER, INSTANCE, 0, 324154) -- 暗影迅步
module:RegisterDebuff(TIER, INSTANCE, 0, 335805) -- 执政官的壁垒
module:RegisterDebuff(TIER, INSTANCE, 0, 317661) -- 险恶毒液
module:RegisterDebuff(TIER, INSTANCE, 0, 328331) -- 严刑逼供
module:RegisterDebuff(TIER, INSTANCE, 0, 323195) -- 净化冲击波
module:RegisterDebuff(TIER, INSTANCE, 0, 328453) -- 压迫
module:RegisterDebuff(TIER, INSTANCE, 0, 331997) -- 心能澎湃
module:RegisterDebuff(TIER, INSTANCE, 0, 324205) -- 炫目闪光
module:RegisterDebuff(TIER, INSTANCE, 0, 331251) -- 深度联结
module:RegisterDebuff(TIER, INSTANCE, 0, 341215) -- 动荡心能
module:RegisterDebuff(TIER, INSTANCE, 0, 323792) -- 心能力场
module:RegisterDebuff(TIER, INSTANCE, 0, 330683) -- 原始心能
module:RegisterDebuff(TIER, INSTANCE, 0, 328434) -- 胁迫
module:RegisterDebuff(TIER, INSTANCE, 0, 27638)  -- 斜掠

INSTANCE = 1185 -- 赎罪大厅
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 335338) -- 哀伤仪式
module:RegisterDebuff(TIER, INSTANCE, 0, 326891) -- 痛楚
module:RegisterDebuff(TIER, INSTANCE, 0, 329321) -- 锯齿横扫
module:RegisterDebuff(TIER, INSTANCE, 0, 344993) -- 锯齿横扫
module:RegisterDebuff(TIER, INSTANCE, 0, 319603) -- 羁石诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 319611) -- 变成石头
module:RegisterDebuff(TIER, INSTANCE, 0, 325876) -- 湮灭诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 326632) -- 石化血脉
module:RegisterDebuff(TIER, INSTANCE, 0, 323650) -- 萦绕锁定
module:RegisterDebuff(TIER, INSTANCE, 0, 326874) -- 脚踝撕咬
module:RegisterDebuff(TIER, INSTANCE, 0, 340446) -- 嫉妒之印
module:RegisterDebuff(TIER, INSTANCE, 0, 323437) -- 傲慢罪印

INSTANCE = 1189 -- 赤红深渊
RegisterSeasonSpells(INSTANCE)
module:RegisterDebuff(TIER, INSTANCE, 0, 326827) -- 恐惧之缚
module:RegisterDebuff(TIER, INSTANCE, 0, 326836) -- 镇压诅咒
module:RegisterDebuff(TIER, INSTANCE, 0, 322554) -- 严惩
module:RegisterDebuff(TIER, INSTANCE, 0, 321038) -- 烦扰之魂
module:RegisterDebuff(TIER, INSTANCE, 0, 328593) -- 苦痛刑罚
module:RegisterDebuff(TIER, INSTANCE, 0, 325254) -- 钢铁尖刺
module:RegisterDebuff(TIER, INSTANCE, 0, 335306) -- 尖刺镣铐
module:RegisterDebuff(TIER, INSTANCE, 0, 327814) -- 邪恶创口
module:RegisterDebuff(TIER, INSTANCE, 0, 331415) -- 邪恶创口
module:RegisterDebuff(TIER, INSTANCE, 0, 328737) -- 光辉残片
module:RegisterDebuff(TIER, INSTANCE, 0, 324092) -- 闪耀光辉
module:RegisterDebuff(TIER, INSTANCE, 0, 322429) -- 撕裂切割
module:RegisterDebuff(TIER, INSTANCE, 0, 334653) -- 饱餐

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
module:RegisterDebuff(TIER, INSTANCE, 0, 333492) -- 通灵粘液
module:RegisterDebuff(TIER, INSTANCE, 0, 321807) -- 白骨剥离
module:RegisterDebuff(TIER, INSTANCE, 0, 323347) -- 黑暗纠缠
module:RegisterDebuff(TIER, INSTANCE, 0, 320788) -- 冻结之缚
module:RegisterDebuff(TIER, INSTANCE, 0, 320839) -- 衰弱
module:RegisterDebuff(TIER, INSTANCE, 0, 343556) -- 病态凝视
module:RegisterDebuff(TIER, INSTANCE, 0, 338606) -- 病态凝视
module:RegisterDebuff(TIER, INSTANCE, 0, 343504) -- 黑暗之握
module:RegisterDebuff(TIER, INSTANCE, 0, 324381) -- 霜寒之镰
module:RegisterDebuff(TIER, INSTANCE, 0, 320573) -- 暗影之井
module:RegisterDebuff(TIER, INSTANCE, 0, 334748) -- 排干体液
module:RegisterDebuff(TIER, INSTANCE, 0, 333489) -- 通灵吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 320717) -- 鲜血饥渴