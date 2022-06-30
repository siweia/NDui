local _, ns = ...
local _, C = unpack(ns)
--[[
	1 鼠标左键, "", %s1
	2 鼠标左键, ALT, ALT-%s1
	3 鼠标左键, CTRL, CTRL-%s1
	4 鼠标左键, SHIFT, SHIFT-%s1
	5 鼠标左键, ALT-CTRL, ALT-CTRL-%s1
	6 鼠标左键, ALT-SHIFT, ALT-SHIFT-%s1
	7 鼠标左键, CTRL-SHIFT, CTRL-SHIFT-%s1
	8 鼠标左键, ALT-CTRL-SHIFT, ALT-CTRL-SHIFT-%s1

	9 鼠标右键, "", %s2
	10 鼠标右键, ALT, ALT-%s2
	11 鼠标右键, CTRL, CTRL-%s2
	12 鼠标右键, SHIFT, SHIFT-%s2
	13 鼠标右键, ALT-CTRL, ALT-CTRL-%s2
	14 鼠标右键, ALT-SHIFT, ALT-SHIFT-%s2
	15 鼠标右键, CTRL-SHIFT, CTRL-SHIFT-%s2
	16 鼠标右键, ALT-CTRL-SHIFT, ALT-CTRL-SHIFT-%s2

	17 鼠标中键, "", %s3
	18 鼠标中键, ALT, ALT-%s3
	19 鼠标中键, CTRL, CTRL-%s3
	20 鼠标中键, SHIFT, SHIFT-%s3
	21 鼠标中键, ALT-CTRL, ALT-CTRL-%s3
	22 鼠标中键, ALT-SHIFT, ALT-SHIFT-%s3
	23 鼠标中键, CTRL-SHIFT, CTRL-SHIFT-%s3
	24 鼠标中键, ALT-CTRL-SHIFT, ALT-CTRL-SHIFT-%s3

	25 鼠标按键4, "", %s4
	26 鼠标按键4, ALT, ALT-%s4
	27 鼠标按键4, CTRL, CTRL-%s4
	28 鼠标按键4, SHIFT, SHIFT-%s4
	29 鼠标按键4, ALT-CTRL, ALT-CTRL-%s4
	30 鼠标按键4, ALT-SHIFT, ALT-SHIFT-%s4
	31 鼠标按键4, CTRL-SHIFT, CTRL-SHIFT-%s4
	32 鼠标按键4, ALT-CTRL-SHIFT, ALT-CTRL-SHIFT-%s4

	33 鼠标按键5, "", %s5
	34 鼠标按键5, ALT, ALT-%s5
	35 鼠标按键5, CTRL, CTRL-%s5
	36 鼠标按键5, SHIFT, SHIFT-%s5
	37 鼠标按键5, ALT-CTRL, ALT-CTRL-%s5
	38 鼠标按键5, ALT-SHIFT, ALT-SHIFT-%s5
	39 鼠标按键5, CTRL-SHIFT, CTRL-SHIFT-%s5
	40 鼠标按键5, ALT-CTRL-SHIFT, ALT-CTRL-SHIFT-%s5

	41 滚轮上, "", %s6
	42 滚轮上, ALT, %s7
	43 滚轮上, CTRL, %s8
	44 滚轮上, SHIFT, %s9
	45 滚轮上, ALT-CTRL, %s10
	46 滚轮上, ALT-SHIFT, %s11
	47 滚轮上, CTRL-SHIFT, %s12
	48 滚轮上, ALT-CTRL-SHIFT, %s13

	49 滚轮下, "", %s14
	50 滚轮下, ALT, %s15
	51 滚轮下, CTRL, %s16
	52 滚轮下, SHIFT, %s17
	53 滚轮下, ALT-CTRL, %s18
	54 滚轮下, ALT-SHIFT, %s19
	55 滚轮下, CTRL-SHIFT, %s20
	56 滚轮下, ALT-CTRL-SHIFT, %s21
]]
C.ClickCastList = {
	["DRUID"] = {
		[2] = 88423,		-- 驱散
		[9] = 774,			-- 回春术
		[10] = 33763,		-- 生命绽放
	},
	["HUNTER"] = {
		[41] = 90361,		-- 灵魂治愈
		[49] = 34477,		-- 误导
	},
	["ROGUE"] = {
		[49] = 57934,		-- 嫁祸
	},
	["WARRIOR"] = {
		[10] = 198304,		-- 拦截
	},
	["SHAMAN"] = {
		[2] = 77130,		-- 驱散
		[9] = 61295,		-- 激流
		[10] = 546,			-- 水上行走
	},
	["PALADIN"] = {
		[2] = 4987,			-- 驱散
		[9] = 20473,		-- 神圣震击
		[10] = 1022,		-- 保护祝福
	},
	["PRIEST"] = {
		[2] = 527,			-- 驱散
		[9] = 17,			-- 真言术盾
		[10] = 1706,		-- 漂浮术
	},
	["MONK"] = {
		[2] = 115450,		-- 驱散
		[9] = 119611,		-- 复苏之雾
	},
	["MAGE"] = {
		[41] = 475,         -- 解除诅咒
		[49] = 130,         -- 缓落
	},
	["DEMONHUNTER"] = {},
	["WARLOCK"] = {},
	["DEATHKNIGHT"] = {},
}