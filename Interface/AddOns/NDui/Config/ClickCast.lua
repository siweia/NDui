local _, ns = ...
local _, C = unpack(ns)

--[[
	左键 LeftMouseButton LMB
	右键 RightMouseButton RMB
	中键 MiddleMouseButton MMB
	侧键1 MouseButton4 MB4
	侧键2 MouseButton5 MB5
	滚轮上 MouseWheelUp MWU
	滚轮下 MouseWheelDown MWD

	功能键组合 modKey groups
	ALT-
	CTRL-
	SHIFT-
	ALT-CTRL-
	ALT-SHIFT-
	CTRL-SHIFT-
	ALT-CTRL-SHIFT-
]]
C.ClickCastList = {
	["DRUID"] = {
		["MWU"] = 88423,		-- 自然之愈
		["MWD"] = 2782,			-- 清除腐蚀
		["RMB"] = 774,			-- 回春术
		["ALT-RMB"] = 33763,	-- 生命绽放
	},
	["HUNTER"] = {
		["MWU"] = 90361,		-- 灵魂治愈
		["MWD"] = 34477,		-- 误导
	},
	["ROGUE"] = {
		["MWD"] = 57934,		-- 嫁祸
	},
	["WARRIOR"] = {
		["MWD"] = 198304,		-- 拦截
	},
	["SHAMAN"] = {
		["MWU"] = 77130,		-- 净化灵魂
		["RMB"] = 61295,		-- 激流
		["ALT-RMB"] = 546,		-- 水上行走
	},
	["PALADIN"] = {
		["MWU"] = 4987,			-- 清洁术
		["RMB"] = 20473,		-- 神圣震击
		["ALT-RMB"] = 1022,		-- 保护祝福
	},
	["PRIEST"] = {
		["MWU"] = 527,			-- 纯净术
		["RMB"] = 17,			-- 真言术盾
		["MWD"] = 1706,			-- 漂浮术
	},
	["MONK"] = {
		["MWU"] = 115450,		-- 清创生血
		["RMB"] = 119611,		-- 复苏之雾
	},
	["MAGE"] = {
		["MWU"] = 475,			-- 解除诅咒
		["MWD"] = 130,			-- 缓落
	},
	["WARLOCK"] = {
		["MWU"] = 89808,		-- 灼烧驱魔
	},
	["DEMONHUNTER"] = {},
	["DEATHKNIGHT"] = {},
}