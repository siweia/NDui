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
		["RMB"] = 774,			-- 回春术
		["ALT-RMB"] = 8936,		-- 愈合
		["MMB"] = 20484,		-- 复生
	},
	["SHAMAN"] = {
		["MWU"] = 526,			-- 消毒术
		["MMB"] = 2008,			-- 先祖之魂
	},
	["PALADIN"] = {
		["MWU"] = 4987,			-- 清洁术
		["RMB"] = 20473,		-- 神圣震击
		["ALT-RMB"] = 1022,		-- 保护祝福
		["MMB"] = 10322,		-- 救赎
	},
	["PRIEST"] = {
		["MWU"] = 527,			-- 驱散魔法
		["RMB"] = 17,			-- 真言术盾
		["ALT-RMB"] = 139,		-- 恢复
		["MMB"] = 2006,			-- 复活术
	},
	["MAGE"] = {
		["MWU"] = 475,			-- 解除诅咒
		["MWD"] = 1460,			-- 奥术智慧
	},
	["ROGUE"] = {},
	["HUNTER"] = {},
	["WARRIOR"] = {},
	["WARLOCK"] = {},
	["DEATHKNIGHT"] = {},
}